#include "my_application.h"

#include <epoxy/gl.h>
#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  FlMethodChannel* window_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Brings the window forward with an activation token, as GtkApplication does
// with the one in a launch: the notification server's for a click on a
// notification. On Wayland a window can't come forward without one (GNOME
// says "Wisetalk is ready" instead); on X11 it carries the click's time past
// focus stealing prevention.
static void present_window(GtkWindow* window, const gchar* token) {
  GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(window));
  if (token != nullptr) {
#ifdef GDK_WINDOWING_WAYLAND
    if (GDK_IS_WAYLAND_DISPLAY(display)) {
      gdk_wayland_display_set_startup_notification_id(display, token);
    }
#endif
#ifdef GDK_WINDOWING_X11
    if (GDK_IS_X11_DISPLAY(display)) {
      gdk_x11_display_set_startup_notification_id(display, token);
    }
#endif
  }
  gtk_window_present(window);
}

// net.wiseless.wisetalk/window: "present" with a token or null.
static void window_method_cb(FlMethodChannel* channel, FlMethodCall* call,
                             gpointer user_data) {
  GtkWindow* window = GTK_WINDOW(user_data);
  if (g_strcmp0(fl_method_call_get_name(call), "present") != 0) {
    fl_method_call_respond_not_implemented(call, nullptr);
    return;
  }
  FlValue* args = fl_method_call_get_args(call);
  present_window(window, fl_value_get_type(args) == FL_VALUE_TYPE_STRING
                             ? fl_value_get_string(args)
                             : nullptr);
  fl_method_call_respond_success(call, nullptr, nullptr);
}

// GNOME under Wayland never tells a minimized window that it is minimized
// (xdg-shell has no state for it before "suspended" in version 6, which
// GTK 3 does not pass on), so Flutter keeps the window "inactive" and goes
// on drawing video and animations nobody sees (WLK-38). What the compositor
// does do is stop answering the window's frame callbacks: after a paint
// GDK freezes the frame clock until the compositor says the frame was
// shown, and for a window out of sight that never comes. So, a second after
// a paint, this asks the clock for a tick; when none comes within half a
// second, the window is out of sight and Flutter hears "hidden". The next
// tick, which comes the moment the compositor shows the window again, says
// "resumed" or "inactive", by focus, as the engine's own monitor would. A
// visible window that just sits still ticks at once when asked, so nothing
// happens there, and nothing runs while nothing is painted.
struct VisibilityWatch {
  GtkWindow* window;
  FlBinaryMessenger* messenger;
  GdkFrameClock* clock;
  gulong paint_handler;
  // After a paint, a second later: ask for a tick.
  guint probe_source;
  // The tick asked for; stays registered while out of sight.
  guint tick_id;
  // Half a second after asking: no tick means out of sight.
  guint confirm_source;
  gboolean presumed_hidden;
};

static void send_lifecycle_state(VisibilityWatch* watch, const gchar* state) {
  g_autoptr(FlValue) value = fl_value_new_string(state);
  g_autoptr(FlStringCodec) codec = fl_string_codec_new();
  g_autoptr(GError) error = nullptr;
  g_autoptr(GBytes) message =
      fl_message_codec_encode_message(FL_MESSAGE_CODEC(codec), value, &error);
  if (message == nullptr) {
    g_warning("Cannot encode lifecycle state: %s", error->message);
    return;
  }
  fl_binary_messenger_send_on_channel(watch->messenger, "flutter/lifecycle",
                                      message, nullptr, nullptr, nullptr);
}

static gboolean visibility_tick_cb(GtkWidget* widget, GdkFrameClock* clock,
                                   gpointer user_data) {
  VisibilityWatch* watch = static_cast<VisibilityWatch*>(user_data);
  if (watch->confirm_source != 0) {
    g_source_remove(watch->confirm_source);
    watch->confirm_source = 0;
  }
  if (watch->presumed_hidden) {
    watch->presumed_hidden = FALSE;
    GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(watch->window));
    gboolean focused =
        gdk_window != nullptr &&
        (gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_FOCUSED);
    send_lifecycle_state(
        watch, focused ? "AppLifecycleState.resumed" : "AppLifecycleState.inactive");
  }
  watch->tick_id = 0;
  return G_SOURCE_REMOVE;
}

static gboolean visibility_confirm_cb(gpointer user_data) {
  VisibilityWatch* watch = static_cast<VisibilityWatch*>(user_data);
  watch->confirm_source = 0;
  if (!watch->presumed_hidden) {
    watch->presumed_hidden = TRUE;
    send_lifecycle_state(watch, "AppLifecycleState.hidden");
  }
  return G_SOURCE_REMOVE;
}

static gboolean visibility_probe_cb(gpointer user_data) {
  VisibilityWatch* watch = static_cast<VisibilityWatch*>(user_data);
  watch->probe_source = 0;
  if (watch->tick_id == 0) {
    watch->tick_id = gtk_widget_add_tick_callback(
        GTK_WIDGET(watch->window), visibility_tick_cb, watch, nullptr);
  }
  if (watch->confirm_source == 0) {
    watch->confirm_source =
        g_timeout_add(500, visibility_confirm_cb, watch);
  }
  return G_SOURCE_REMOVE;
}

// GdkFrameClock::paint: something was drawn, and the clock now waits for
// the compositor to show it.
static void visibility_paint_cb(GdkFrameClock* clock, gpointer user_data) {
  VisibilityWatch* watch = static_cast<VisibilityWatch*>(user_data);
  if (watch->probe_source == 0 && watch->confirm_source == 0) {
    watch->probe_source = g_timeout_add(1000, visibility_probe_cb, watch);
  }
}

// GtkWidget::destroy, while the window and its frame clock are still whole.
static void visibility_watch_destroy_cb(GtkWidget* widget, gpointer data) {
  VisibilityWatch* watch = static_cast<VisibilityWatch*>(data);
  if (watch->probe_source != 0) g_source_remove(watch->probe_source);
  if (watch->confirm_source != 0) g_source_remove(watch->confirm_source);
  if (watch->tick_id != 0) {
    gtk_widget_remove_tick_callback(widget, watch->tick_id);
  }
  if (watch->paint_handler != 0) {
    g_signal_handler_disconnect(watch->clock, watch->paint_handler);
  }
  g_clear_object(&watch->clock);
  g_clear_object(&watch->messenger);
  g_free(watch);
}

static void watch_visibility(GtkWindow* window, FlView* view) {
#ifdef GDK_WINDOWING_WAYLAND
  if (!GDK_IS_WAYLAND_DISPLAY(gtk_widget_get_display(GTK_WIDGET(window)))) {
    return;
  }
  GdkFrameClock* clock = gtk_widget_get_frame_clock(GTK_WIDGET(window));
  if (clock == nullptr) return;
  VisibilityWatch* watch = g_new0(VisibilityWatch, 1);
  watch->window = window;
  watch->messenger = FL_BINARY_MESSENGER(
      g_object_ref(fl_engine_get_binary_messenger(fl_view_get_engine(view))));
  watch->clock = GDK_FRAME_CLOCK(g_object_ref(clock));
  watch->paint_handler =
      g_signal_connect(clock, "paint", G_CALLBACK(visibility_paint_cb), watch);
  g_signal_connect(window, "destroy", G_CALLBACK(visibility_watch_destroy_cb),
                   watch);
#else
  (void)window;
  (void)view;
#endif
}

// What every frame costs on Wayland (WLK-56). The engine hands GTK its frame
// as a texture with alpha, so GTK first uploads what it thinks lies underneath:
// a window-sized image, cleared, then filled with the window's and the view's
// backgrounds, all by the CPU, only for the frame to cover it completely. With
// video playing that took a third of a core, and 15 MB per frame at 1440p.
//
// The backgrounds go away with app-paintable and a transparent view. The upload
// goes away by telling GTK this area is already on screen: an opaque
// renderbuffer through gdk_cairo_draw_from_gl marks it so. It is 1x1, and a blit
// from outside a framebuffer writes nothing, so that costs nothing either.
static gboolean mark_view_drawn_cb(GtkWidget* widget, cairo_t* cr,
                                   gpointer user_data) {
  static GdkGLContext* context = nullptr;
  static GLuint renderbuffer = 0;
  static gboolean failed = FALSE;
  if (failed) return FALSE;
  GdkWindow* window = gtk_widget_get_window(widget);
  if (renderbuffer == 0) {
    g_autoptr(GError) error = nullptr;
    context = gdk_window_create_gl_context(window, &error);
    if (context == nullptr || !gdk_gl_context_realize(context, &error)) {
      g_warning("Painting the whole window on every frame: %s",
                error != nullptr ? error->message : "no GL context");
      g_clear_object(&context);
      failed = TRUE;
      return FALSE;
    }
    gdk_gl_context_make_current(context);
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGB8, 1, 1);
    gdk_gl_context_clear_current();
  }
  gint scale = gtk_widget_get_scale_factor(widget);
  gdk_cairo_draw_from_gl(cr, window, renderbuffer, GL_RENDERBUFFER, scale, 0, 0,
                         gtk_widget_get_allocated_width(widget) * scale,
                         gtk_widget_get_allocated_height(widget) * scale);
  return FALSE;
}

// Called when first Flutter frame received.
static void first_frame_cb(MyApplication* self, FlView* view) {
  GtkWidget* window = gtk_widget_get_toplevel(GTK_WIDGET(view));
  gtk_widget_show(window);
  watch_visibility(GTK_WINDOW(window), view);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  // One Wisetalk at a time: launching it again, or opening a wisetalk:
  // link, brings the open window forward (app_links reads the link).
  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }

  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Wisetalk");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Wisetalk");
  }

  gtk_window_set_default_size(window, 1100, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#000000");
#ifdef GDK_WINDOWING_WAYLAND
  if (GDK_IS_WAYLAND_DISPLAY(gtk_widget_get_display(GTK_WIDGET(window))) &&
      g_getenv("FLUTTER_LINUX_RENDERER") == nullptr) {
    gdk_rgba_parse(&background_color, "#00000000");
    gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);
    g_signal_connect(view, "draw", G_CALLBACK(mark_view_drawn_cb), nullptr);
  }
#endif
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // Show the window when Flutter renders.
  // Requires the view to be realized so we can start rendering.
  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->window_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "net.wiseless.wisetalk/window", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      self->window_channel, window_method_cb, window, nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  // Not handled here: GLib hands the command line (a wisetalk: link, say)
  // to the instance already running, or to this one.
  return FALSE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->window_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_HANDLES_COMMAND_LINE |
                                         G_APPLICATION_HANDLES_OPEN,
                                     nullptr));
}
