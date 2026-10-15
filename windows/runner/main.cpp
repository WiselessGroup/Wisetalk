#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <string>

#include "app_links/app_links_plugin_c_api.h"
#include "flutter_window.h"
#include "utils.h"

// wisetalk: links, from a server's web page, open this program. Registered
// for the user on every start: Velopack runs each version from the same
// "current" folder, but a portable copy may have moved.
static void RegisterLinkScheme() {
  wchar_t exe[MAX_PATH];
  DWORD length = ::GetModuleFileNameW(nullptr, exe, MAX_PATH);
  if (length == 0 || length == MAX_PATH) return;
  const std::wstring name = L"URL:Wisetalk";
  const std::wstring command = L"\"" + std::wstring(exe) + L"\" \"%1\"";
  const wchar_t* key = L"Software\\Classes\\wisetalk";
  ::RegSetKeyValueW(HKEY_CURRENT_USER, key, nullptr, REG_SZ, name.c_str(),
                    static_cast<DWORD>((name.size() + 1) * sizeof(wchar_t)));
  ::RegSetKeyValueW(HKEY_CURRENT_USER, key, L"URL Protocol", REG_SZ, L"",
                    sizeof(wchar_t));
  ::RegSetKeyValueW(
      HKEY_CURRENT_USER, L"Software\\Classes\\wisetalk\\shell\\open\\command",
      nullptr, REG_SZ, command.c_str(),
      static_cast<DWORD>((command.size() + 1) * sizeof(wchar_t)));
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // One Wisetalk at a time: a second start hands its wisetalk: link, if
  // any, to the window already open and brings that forward.
  if (SendAppLinkToInstance()) {
    return EXIT_SUCCESS;
  }
  RegisterLinkScheme();

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Wisetalk", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
