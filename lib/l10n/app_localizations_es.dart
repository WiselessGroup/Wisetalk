// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get brandingTagline => 'Chat de voz y vídeo para tu comunidad';

  @override
  String get brandingSignIn => 'Iniciar sesión';

  @override
  String brandingSignInWith(String provider) {
    return 'Iniciar sesión con $provider';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Alojado por $community.';
  }

  @override
  String get signInServers => 'Servidores';

  @override
  String get signInUnreachable => 'No se puede conectar con el servidor.';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signInInBrowser => 'Continúa en tu navegador…';

  @override
  String get signInAccountHelp =>
      'Tu nombre, tu avatar y las llamadas te acompañan a todas partes.';

  @override
  String get signInOr => 'o';

  @override
  String get signInGuest => 'Entrar como invitado';

  @override
  String get signInGuestName => 'Tu nombre';

  @override
  String get signInGuestHelp =>
      'Los invitados pueden hablar y escuchar, pero no compartir vídeo ni recibir llamadas a un canal.';

  @override
  String get signInJoining => 'Entrando…';

  @override
  String get signInAsGuest => 'Continuar como invitado';

  @override
  String get signInNobody =>
      'Este servidor no deja entrar a nadie ahora mismo.';

  @override
  String get signInGuestsClosed =>
      'El acceso de invitados está cerrado por ahora.';

  @override
  String get signInEncrypted =>
      'Las llamadas están cifradas de extremo a extremo.';

  @override
  String get signInNameLength => 'Un nombre tiene de 1 a 32 caracteres.';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callUnmute => 'Activar micrófono';

  @override
  String get callCameraOn => 'Activar cámara';

  @override
  String get callCameraOff => 'Desactivar cámara';

  @override
  String get callShareScreen => 'Compartir pantalla';

  @override
  String get callStopSharing => 'Dejar de compartir';

  @override
  String get callLeave => 'Salir';

  @override
  String get callServiceChannel => 'Llamadas';

  @override
  String get callServiceInCall => 'En una llamada de voz';

  @override
  String get callServiceSharing => 'Compartiendo tu pantalla';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsDone => 'Listo';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatVanishes => 'Los mensajes desaparecen 4 h después del último';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Se borra en $hours h $minutes min si nadie escribe';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Se borra en $minutes min si nadie escribe';
  }

  @override
  String get chatClose => 'Cerrar chat';

  @override
  String get chatEmpty => 'Aún no hay mensajes. ¡Saluda!';

  @override
  String get chatLoading => 'Cargando…';

  @override
  String get chatGettingKey => 'Obteniendo la clave del chat…';

  @override
  String get chatSendingPicture => 'Enviando la imagen…';

  @override
  String get chatPreparingPicture => 'Preparando la imagen…';

  @override
  String get chatAddPicture => 'Añadir imagen';

  @override
  String chatMessageTo(String channel) {
    return 'Escribe en $channel';
  }

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatLocked =>
      'Cifrado con una clave que este dispositivo no tiene: se envió antes de que se uniera al chat.';

  @override
  String get chatGuest => 'invitado';

  @override
  String get chatDeleteMessage => 'Eliminar mensaje';

  @override
  String get chatPictures => 'Imágenes';

  @override
  String get chatInvalidMessage =>
      'Un mensaje tiene de 1 a 2000 caracteres, sin caracteres de control.';

  @override
  String chatPictureNotSent(String reason) {
    return 'La imagen no se envió: $reason';
  }

  @override
  String get pictureFailed => 'La imagen no se cargó';

  @override
  String get pictureTooLarge => 'Esta imagen es demasiado grande.';

  @override
  String get pictureUnreadable => 'No se puede leer esta imagen.';

  @override
  String trustNewDevice(String name) {
    return '$name se unió desde un dispositivo nuevo.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos nuevos iniciaron sesión en tu cuenta.',
      many: '$count dispositivos nuevos iniciaron sesión en tu cuenta.',
      one: 'Un dispositivo nuevo inició sesión en tu cuenta.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Cuidado: un dispositivo de tu cuenta llegó con otra clave.';

  @override
  String get personKeyChanged =>
      'Cuidado: la clave del dispositivo de esta persona ha cambiado.';

  @override
  String get notificationOpen => 'Abrir';

  @override
  String get notificationChannel => 'Mensajes y llamadas';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller te está llamando';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Únete a $channel';
  }

  @override
  String get signInErrorRefused => 'Se canceló el inicio de sesión.';

  @override
  String get signInErrorExpired =>
      'El inicio de sesión tardó demasiado. Inténtalo de nuevo.';

  @override
  String get signInErrorBanned => 'Esta cuenta está baneada en este servidor.';

  @override
  String get signInErrorUnavailable =>
      'El inicio de sesión con cuenta no está disponible ahora.';

  @override
  String get signInErrorFailed =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get signInNoBrowser =>
      'No se puede abrir el navegador para iniciar sesión.';

  @override
  String get signInBrowserDone =>
      'Has iniciado sesión. Puedes cerrar esta pestaña y volver a Wisetalk.';

  @override
  String get signInBrowserFailed =>
      'No se pudo iniciar sesión. Vuelve a Wisetalk para intentarlo de nuevo.';

  @override
  String get updatesNotSelfUpdating =>
      'Esta versión de Wisetalk no se actualiza sola.';

  @override
  String get updatesCannotCheck =>
      'No se pueden buscar actualizaciones. Inténtalo más tarde.';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version está listo: reinicia para actualizar.';
  }

  @override
  String updatesAvailable(String version) {
    return 'Ya salió Wisetalk $version: actualiza a $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version es la versión más reciente.';
  }

  @override
  String get voiceMutedByModerator =>
      'Un moderador te silenció y solo él puede quitarlo.';

  @override
  String get voiceCameraUnavailable => 'Cámara no disponible.';

  @override
  String get voiceCannotSwitchCamera => 'No se pudo cambiar a esa cámara.';

  @override
  String get voiceScreenUnavailable => 'Compartir pantalla no está disponible.';

  @override
  String get voiceServerMuted => 'Un moderador te silenció.';

  @override
  String get voiceServerUnmuted =>
      'Un moderador quitó tu silencio. Activa el micrófono cuando quieras.';

  @override
  String voiceKicked(String reason) {
    return 'Saliste del canal: $reason.';
  }

  @override
  String get voiceCannotConnect => 'No se pudo conectar al canal de voz.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Micrófono no disponible: puedes escuchar, pero no hablar.';

  @override
  String get videoYou => 'Tú';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'Se cerró tu sesión.';

  @override
  String get apiUnreachable => 'No se puede conectar con el servidor.';

  @override
  String get apiUnreachableCheck =>
      'No se puede conectar con el servidor. Revisa la dirección y tu conexión.';

  @override
  String get apiNotWisetalk => 'Eso no parece un servidor de Wisetalk.';

  @override
  String apiRefused(int status) {
    return 'El servidor lo rechazó ($status).';
  }

  @override
  String get desktopComment => 'Chat de voz y vídeo para una comunidad';

  @override
  String personYou(String name) {
    return '$name (tú)';
  }

  @override
  String get personAudioVideoSettings => 'Ajustes de audio y vídeo…';

  @override
  String personVolume(int percent) {
    return 'Volumen $percent %';
  }

  @override
  String get personMuteForMe => 'Silenciar para mí';

  @override
  String get personUnmuteForMe => 'Activar sonido para mí';

  @override
  String get moderationServerMute => 'Silenciar en el servidor';

  @override
  String get moderationLiftServerMute => 'Quitar silencio del servidor';

  @override
  String get moderationKick => 'Expulsar del canal';

  @override
  String get personMakeServerAdmin => 'Hacer administrador del servidor';

  @override
  String get personRemoveServerAdmin => 'Quitar administrador del servidor';

  @override
  String personNowAdmin(String name) {
    return '$name ahora es administrador del servidor.';
  }

  @override
  String personNowMember(String name) {
    return '$name ahora es miembro.';
  }

  @override
  String get moderationBan => 'Banear del servidor…';

  @override
  String moderationBanTitle(String name) {
    return '¿Banear a $name?';
  }

  @override
  String moderationBanConfirm(String name) {
    return '¿Banear a $name de este servidor? Sus sesiones terminan de inmediato.';
  }

  @override
  String get moderationBanAction => 'Banear';

  @override
  String moderationBanned(String name) {
    return '$name ha sido baneado.';
  }

  @override
  String get moderationBanGuest => 'Banear al invitado por un día…';

  @override
  String moderationBanGuestConfirm(String name) {
    return '¿Expulsar a $name y bloquear a los invitados desde su dirección durante un día?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name está fuera; su dirección queda bloqueada por un día.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Hacer propietario de $channel';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Quitar como propietario de $channel';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name ahora es propietario de $channel.';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel ya no tiene propietario.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Hacer propietario de $space';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Quitar como propietario de $space';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name ahora es propietario de $space.';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space ya no tiene propietario.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Audio de hasta $kbps kbps, estéreo';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Audio de hasta $kbps kbps, mono';
  }

  @override
  String get channelJoin => 'Unirse';

  @override
  String get channelOpenChat => 'Abrir chat';

  @override
  String get channelOpenSettings => 'Ajustes del canal…';

  @override
  String get inviteCopyLink => 'Copiar enlace de invitación';

  @override
  String inviteCopied(String channel) {
    return 'Enlace de invitación a $channel copiado.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Invitación a $channel copiada. Cuando alguien la use, dejará entrar a cualquiera durante 10 minutos; sin usar, dura un día.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Enlace de invitación a $channel copiado. Solo funciona para quienes el canal ya deja entrar.';
  }

  @override
  String get inviteCannotCreate => 'No se pudo crear la invitación.';

  @override
  String get spaceNewChannel => 'Nuevo canal en el espacio…';

  @override
  String get spaceOpenSettings => 'Ajustes del espacio…';

  @override
  String get spaceDelete => 'Eliminar espacio…';

  @override
  String spaceDeleteConfirm(String space) {
    return '¿Eliminar el espacio $space? Sus canales pasan al nivel superior.';
  }

  @override
  String get workspaceMoveUp => 'Subir';

  @override
  String get workspaceMoveDown => 'Bajar';

  @override
  String get workspaceCannotReorder => 'No se pudo reordenar.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbps (voz)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbps (música)';
  }

  @override
  String get createNewChannel => 'Nuevo canal';

  @override
  String get createNewSpace => 'Nuevo espacio';

  @override
  String get createSubmit => 'Crear';

  @override
  String get createChannel => 'Canal';

  @override
  String get createSpace => 'Espacio';

  @override
  String get createChannelHint =>
      'Una sala de voz a la que se une la gente, con su propio chat.';

  @override
  String get createSpaceHint =>
      'Una carpeta que agrupa canales en la barra lateral.';

  @override
  String get createChannelPlaceholder => 'Equipo Azul';

  @override
  String get channelSettingsTitle => 'Ajustes del canal';

  @override
  String get channelSettingsOwnerHint =>
      'El propietario gestiona este canal. Solo los administradores eligen quién es el propietario.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return '¿Eliminar $name? Se desconectará a todos los que estén dentro.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'Personas y sonido';

  @override
  String get channelSettingsMaxPeople => 'Máximo de personas';

  @override
  String get channelSettingsNoLimit => 'Sin límite';

  @override
  String get channelSettingsAudioQuality => 'Calidad de audio';

  @override
  String get channelSettingsStereo => 'Estéreo';

  @override
  String get channelSettingsDelete => 'Eliminar canal…';

  @override
  String get manageSpace => 'Espacio';

  @override
  String get manageOwner => 'Propietario';

  @override
  String get manageAccess => 'Acceso';

  @override
  String get spaceSettingsTitle => 'Ajustes del espacio';

  @override
  String get spaceSettingsOwnerHint =>
      'El propietario gestiona el espacio y todos sus canales. Solo los administradores eligen quién es el propietario.';

  @override
  String get accessAccountsOnly => 'Solo con cuenta';

  @override
  String get accessAccountsOnlyDetail => 'Sin invitados';

  @override
  String get accessWhitelistOnly => 'Solo lista de acceso';

  @override
  String get accessHidden => 'Oculto';

  @override
  String get accessHiddenDetail => 'Invisible para quien no puede entrar';

  @override
  String get accessFromSpace => 'Definido por el espacio';

  @override
  String summonsTitle(String channel) {
    return 'Llamar a $channel';
  }

  @override
  String get summonsSummon => 'Llamar';

  @override
  String get summonsNickname => 'Apodo';

  @override
  String get summonsNoMatch => 'Nadie que coincida puede entrar aquí.';

  @override
  String get summonsHint =>
      'Recibirá una notificación de que lo estás esperando. Una vez cada 5 minutos por persona.';

  @override
  String get summonsSearchFailed => 'No se pudo buscar.';

  @override
  String get manageDeviceKey => 'Clave del dispositivo';

  @override
  String manageDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get manageDelete => 'Eliminar';

  @override
  String get manageSave => 'Guardar';

  @override
  String get manageName => 'Nombre';

  @override
  String get manageNone => 'Ninguno';

  @override
  String get manageNobody => 'Nadie';

  @override
  String get manageSomeoneElse => 'Otra persona';

  @override
  String get manageWhitelistInWeb =>
      'Por ahora, edita la lista de acceso en el cliente web.';

  @override
  String get channelSettingsLimitHint =>
      'Cuando el canal está lleno, solo pueden entrar quienes lo gestionan. De 1 a 99 personas, o sin límite.';

  @override
  String get spaceSettingsAccessHint =>
      'Estos límites se aplican a todos los canales del espacio; un canal solo puede añadir los suyos. Por ahora, edita la lista de acceso en el cliente web.';

  @override
  String get accessWhitelistOnlyListDetail =>
      'Solo las personas y roles de su lista';

  @override
  String get summonsWho => '¿A quién?';

  @override
  String get settingsPictures => 'Imágenes';

  @override
  String get profileAddPicture => 'Añadir foto…';

  @override
  String get profileChangePicture => 'Cambiar foto…';

  @override
  String get profileRemovePicture => 'Quitar foto';

  @override
  String get profileUploadFailed => 'No se pudo subir la foto.';

  @override
  String get profileRemoveFailed => 'No se pudo quitar la foto.';

  @override
  String get saveFailed => 'No se pudo guardar.';

  @override
  String get settingsAudioVideo => 'Audio y vídeo';

  @override
  String get settingsMicrophone => 'Micrófono';

  @override
  String get settingsCamera => 'Cámara';

  @override
  String get settingsOutput => 'Salida';

  @override
  String get settingsVoiceProcessing => 'Procesamiento de voz';

  @override
  String get settingsVoiceProcessingDetail =>
      'Supresión de ruido y cancelación de eco';

  @override
  String get settingsVoiceProcessingHint =>
      'Desactívalo para el mejor sonido y usa auriculares: sin cancelación de eco, los demás se oyen a sí mismos por tus altavoces.';

  @override
  String get settingsCues => 'Sonidos de entrada y salida';

  @override
  String get settingsCuesDetail =>
      'Un búho ulula cuando alguien entra o sale, y los atajos hacen clic';

  @override
  String get settingsPingAndLoss => 'Mostrar ping y pérdida';

  @override
  String get settingsPingAndLossDetail =>
      'Junto al icono de conexión durante una llamada';

  @override
  String get summonsHeader => 'Llamadas a un canal';

  @override
  String get summonsAllow => 'Otros pueden llamarme';

  @override
  String get settingsNotificationsHere => 'Notificaciones en este dispositivo';

  @override
  String get settingsNotificationsHint =>
      'Aparecen mientras Wisetalk está en segundo plano.';

  @override
  String get settingsNotifyMessages => 'Mensajes nuevos';

  @override
  String get settingsNotifyMessagesDetail =>
      'En el chat de tu llamada y en los chats que abriste';

  @override
  String get settingsNotifySummons => 'Llamadas a un canal';

  @override
  String get settingsNotifySummonsDetail =>
      'Cuando alguien te llama a un canal';

  @override
  String get settingsPushHeader => 'Con Wisetalk cerrado';

  @override
  String get settingsPushApp => 'App de notificaciones';

  @override
  String get settingsPushAppNone => 'Ninguna';

  @override
  String get settingsPushAppChoose => 'Elegir…';

  @override
  String get settingsGetNtfy => 'Instalar ntfy';

  @override
  String settingsPushVia(String app) {
    return 'Las llamadas a un canal llegan a este teléfono a través de $app, incluso con Wisetalk cerrado.';
  }

  @override
  String get settingsPushChooseHint =>
      'Elige la app que recibe las llamadas con Wisetalk cerrado.';

  @override
  String get settingsPushNoneHint =>
      'Sin una app de notificaciones, las llamadas solo aparecen con Wisetalk abierto. Instala ntfy y, en sus ajustes, pon el servidor ntfy de tu comunidad como servidor predeterminado.';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsCrashReports => 'Enviar informes de errores';

  @override
  String get settingsCrashReportsHint =>
      'Cuando algo falla en Wisetalk, avisa a sus desarrolladores de qué falló y dónde en el código. Nunca tus mensajes, nombres, claves ni servidores.';

  @override
  String get settingsShortcuts => 'Atajos';

  @override
  String get settingsShortcutsRecording =>
      'Pulsa las nuevas teclas. Backspace quita el atajo, Esc lo mantiene.';

  @override
  String get settingsShortcutsGlobal =>
      'En una llamada funcionan sea cual sea la app en primer plano; si no, en la ventana de Wisetalk. Haz clic en uno para cambiarlo.';

  @override
  String get settingsShortcutsWayland =>
      'En Wayland solo funcionan mientras la ventana de Wisetalk está en primer plano. Haz clic en uno para cambiarlo.';

  @override
  String get settingsShortcutPressKeys => 'Pulsa teclas…';

  @override
  String get settingsShortcutNone => 'Ninguno';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys ya es “$action”.';
  }

  @override
  String get shortcutToggleMute => 'Activar o silenciar micrófono';

  @override
  String get shortcutToggleAway => 'Ausente o de vuelta';

  @override
  String get shortcutMute => 'Silenciar micrófono';

  @override
  String get shortcutUnmute => 'Activar micrófono';

  @override
  String get shortcutUnusableKey => 'Esa tecla no se puede usar para un atajo.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Añade $first o $second, o usa F1 a F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys pertenece al sistema o a todas las apps.';
  }

  @override
  String get sheetDiscardTitle => '¿Descartar cambios?';

  @override
  String get sheetDiscardMessage =>
      'Lo que cambiaste aquí aún no está guardado.';

  @override
  String get sheetDiscard => 'Descartar';

  @override
  String get sheetKeepEditing => 'Seguir editando';

  @override
  String serversRemoveTitle(String server) {
    return '¿Quitar $server?';
  }

  @override
  String get serversRemoveMessage =>
      'Este dispositivo cierra sesión en él y lo olvida. Puedes volver a añadirlo con su dirección.';

  @override
  String get serversRemove => 'Quitar';

  @override
  String get serversAddressHelp =>
      'Pide la dirección a quien gestiona tu comunidad.';

  @override
  String get serversConnecting => 'Conectando…';

  @override
  String get serversConnect => 'Conectar';

  @override
  String get serversWhich => '¿En qué servidor está tu comunidad?';

  @override
  String get serversYours => 'Tus servidores';

  @override
  String get serversAddMenu => 'Añadir servidor…';

  @override
  String get serversAddTitle => 'Añadir servidor';

  @override
  String get serversBadAddress =>
      'Escribe la dirección de un servidor, como talk.example.com.';

  @override
  String get serversTooNew =>
      'Este servidor es más nuevo que esta app. Actualiza Wisetalk para unirte.';

  @override
  String get serversTooOld =>
      'Este servidor usa una versión antigua de Wisetalk. Pide a sus administradores que lo actualicen.';

  @override
  String serversTooOldVersion(String version) {
    return 'Este servidor usa una versión antigua de Wisetalk ($version). Pide a sus administradores que lo actualicen.';
  }

  @override
  String get serversAddress => 'Dirección';

  @override
  String get serversMore => 'Más';

  @override
  String get serversRemoveServer => 'Quitar servidor';

  @override
  String get channelSomeChannel => 'un canal';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name en $channel';
  }

  @override
  String get workspaceMessageEncrypted => 'Escribió un mensaje cifrado.';

  @override
  String get workspaceMessagePicture => 'Envió una imagen.';

  @override
  String summonPushed(String name) {
    return '$name recibió una notificación.';
  }

  @override
  String get summonPushedSomeone => 'Notificación enviada.';

  @override
  String summonNotPushed(String name) {
    return 'Llamaste a $name. Tiene las notificaciones desactivadas, así que solo lo verá si tiene Wisetalk abierto.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Llamada enviada. Tiene las notificaciones desactivadas, así que solo lo verá si tiene Wisetalk abierto.';

  @override
  String summonReceived(String from, String channel) {
    return '$from te llama a $channel.';
  }

  @override
  String get workspaceSummoned => 'Te están llamando';

  @override
  String get workspaceRoleChangedOwner =>
      'Tu rol en el servidor ahora es propietario.';

  @override
  String get workspaceRoleChangedAdmin =>
      'Tu rol en el servidor ahora es administrador.';

  @override
  String get workspaceRoleChangedModerator =>
      'Tu rol en el servidor ahora es moderador.';

  @override
  String get workspaceRoleChangedMember =>
      'Tu rol en el servidor ahora es miembro.';

  @override
  String get workspaceRoleChangedGuest =>
      'Tu rol en el servidor ahora es invitado.';

  @override
  String get takeOverTitle => '¿Unirte desde este dispositivo?';

  @override
  String takeOverSameChannel(String channel) {
    return 'Ya estás en $channel en otro dispositivo o pestaña. Si te unes a $channel aquí, saldrás de la llamada allí.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'Estás en $there en otro dispositivo o pestaña. Si te unes a $here aquí, saldrás de la llamada allí.';
  }

  @override
  String get takeOverElsewhere =>
      'Estás en una llamada en otro dispositivo o pestaña. Si te unes aquí, saldrás de la llamada allí.';

  @override
  String get takeOverJoinHere => 'Unirme aquí';

  @override
  String get workspaceShowChannels => 'Mostrar canales';

  @override
  String get workspaceHideChannels => 'Ocultar canales';

  @override
  String workspaceInVoice(int count) {
    return '$count en voz';
  }

  @override
  String get workspaceCreateTitle => 'Nuevo canal o espacio';

  @override
  String get workspaceStatusConnecting => 'Conectando…';

  @override
  String get workspaceStatusOffline => 'Sin conexión…';

  @override
  String get workspaceEmptyAdmin =>
      'Aún no hay canales. Crea uno con el botón +.';

  @override
  String get workspaceEmpty =>
      'Aún no hay canales. Un administrador puede añadirlos.';

  @override
  String get workspaceMore => 'Más';

  @override
  String get workspaceCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get workspaceChangeServer => 'Cambiar de servidor';

  @override
  String get workspaceSignOut => 'Cerrar sesión';

  @override
  String get personMutedForYou => 'Silenciado para ti';

  @override
  String get awayTitle => 'Ausente';

  @override
  String get awayDescription => 'Ausente: micrófono y sonido apagados';

  @override
  String get callMutedByModerator => 'Silenciado por un moderador';

  @override
  String workspaceDrag(String name) {
    return 'Arrastrar $name';
  }

  @override
  String get workspaceDropEndHint =>
      'Suelta aquí para ponerlo al final de la lista';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version se ha descargado';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Ya salió Wisetalk $version';
  }

  @override
  String get workspaceRestartToUpdate => 'Reiniciar para actualizar';

  @override
  String workspaceUpdateTo(String version) {
    return 'Actualizar a $version';
  }

  @override
  String get workspaceWelcomeTitle => 'Elige un canal de voz';

  @override
  String get workspaceWelcomeHint => 'Haz clic en un canal para unirte.';

  @override
  String get callJoining => 'Uniéndote…';

  @override
  String get callWaitingForKey => 'Esperando la clave de la llamada…';

  @override
  String get callEncrypted => 'Cifrado de extremo a extremo';

  @override
  String videoScreen(String name) {
    return '$name · pantalla';
  }

  @override
  String get connectionExcellent => 'excelente';

  @override
  String get connectionGood => 'buena';

  @override
  String get connectionPoor => 'débil';

  @override
  String get connectionLost => 'perdida';

  @override
  String get connectionChecking => 'comprobando';

  @override
  String connectionStatus(String quality) {
    return 'Conexión: $quality';
  }

  @override
  String get connectionLabel => 'Conexión';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · $loss de pérdida';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping, pérdida $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => 'Pérdida de salida';

  @override
  String get connectionIncomingLoss => 'Pérdida de entrada';

  @override
  String get connectionJitter => 'Jitter';

  @override
  String get connectionMicrophone => 'Micrófono';

  @override
  String get connectionNotSending => 'Sin enviar';

  @override
  String connectionKilobits(int value) {
    return '$value kbps';
  }

  @override
  String get screenShareTitle => 'Compartir tu pantalla';

  @override
  String get screenShareAction => 'Compartir';

  @override
  String get screenShareBestFor => 'Ideal para';

  @override
  String get screenShareAndroidHint =>
      'A continuación, Android te pregunta si quieres compartir toda la pantalla o una app. Por ahora, sin sonido.';

  @override
  String get screenShareWaylandHint =>
      'La primera vez, el sistema te pregunta qué pantalla compartir. Después se usa esa misma pantalla hasta que Wisetalk se reinicie. Por ahora, solo pantallas completas y sin sonido.';

  @override
  String get screenShareText => 'Texto y diapositivas';

  @override
  String get screenShareTextDetail =>
      'Nítido y ligero: pocos fotogramas por segundo.';

  @override
  String get screenShareMotion => 'Vídeos y juegos';

  @override
  String get screenShareMotionDetail =>
      'Fluido: 30 fotogramas por segundo, más pesado en ambos extremos.';

  @override
  String get screenShareSource => 'Pantalla o ventana';

  @override
  String get screenShareSound => 'Compartir sonido';

  @override
  String get screenShareSoundWindow => 'Solo la app de esta ventana.';

  @override
  String get screenShareSoundScreen => 'Todo lo que oyes, sin la llamada.';

  @override
  String get screenShareSoundAny =>
      'La app de una ventana o, para una pantalla, todo lo que oyes, sin la llamada.';

  @override
  String get screenShareListFailed =>
      'No se pueden listar las pantallas y ventanas.';

  @override
  String get screenShareChooseTitle => 'Elige una pantalla';

  @override
  String get screenShareChooseHint =>
      'Elige la pantalla que quieres compartir en la ventana del sistema.';

  @override
  String get problemNotSignedIn => 'No has iniciado sesión.';

  @override
  String get problemAccountRequired => 'Primero inicia sesión con una cuenta.';

  @override
  String get problemAccountBanned => 'Esta cuenta está baneada.';

  @override
  String get problemSignInCodeInvalid =>
      'Este código de inicio de sesión ya no es válido. Vuelve a iniciar sesión.';

  @override
  String get problemBrowserCheckMissing =>
      'Falta la comprobación del navegador. Recarga la página e inténtalo de nuevo.';

  @override
  String get problemBrowserCheckFailed =>
      'La comprobación del navegador falló. Recarga la página e inténtalo de nuevo.';

  @override
  String get problemBrowserCheckExpired =>
      'La comprobación del navegador caducó. Inténtalo de nuevo.';

  @override
  String get problemGuestSignInClosed =>
      'El acceso de invitados está cerrado ahora. Inicia sesión con una cuenta.';

  @override
  String get problemGuestAddressBlocked =>
      'Los invitados de esta dirección están bloqueados durante un tiempo.';

  @override
  String get problemTooManyGuests =>
      'Hay demasiados invitados ahora. Inténtalo más tarde o inicia sesión con una cuenta.';

  @override
  String get problemTooManyGuestSignIns =>
      'Demasiados accesos de invitado desde esta dirección. Inténtalo más tarde.';

  @override
  String get problemNameBelongsToAccount =>
      'Este nombre pertenece a una cuenta.';

  @override
  String get problemAccountsCantBeGuests =>
      'Con una cuenta no se puede entrar como invitado.';

  @override
  String get problemNoSuchAccount => 'Esta cuenta no existe.';

  @override
  String get problemNoSuchChannel => 'Este canal ya no existe.';

  @override
  String get problemNoSuchSpace => 'Este espacio ya no existe.';

  @override
  String get problemNoSuchEmoji => 'Este emoji no existe.';

  @override
  String get problemNoSuchGuest => 'Este invitado ya no está conectado.';

  @override
  String get problemNoSuchPicture => 'Esta imagen ya no existe.';

  @override
  String get problemNoSuchMessage => 'Este mensaje ya no existe.';

  @override
  String get problemNoAvatar => 'No hay avatar.';

  @override
  String get problemNotBanned => 'Esta cuenta no está baneada.';

  @override
  String get problemDisplayNameLength =>
      'Un nombre tiene de 1 a 32 caracteres.';

  @override
  String get problemChannelNameLength =>
      'Un nombre de canal tiene de 1 a 64 caracteres.';

  @override
  String get problemSpaceNameLength =>
      'Un nombre de espacio tiene de 1 a 64 caracteres.';

  @override
  String get problemEmojiNameInvalid =>
      'Un nombre de emoji tiene de 2 a 32 caracteres entre a–z, 0–9 y _.';

  @override
  String get problemIconInvalid =>
      'Un icono es un solo emoji o un :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Los nombres tienen hasta 40 caracteres y el eslogan hasta 120, sin caracteres de control.';

  @override
  String get problemChannelLimitInvalid =>
      'Un canal admite de 1 a 99 personas, o no tiene límite.';

  @override
  String get problemBitrateInvalid =>
      'La tasa de bits del audio debe estar entre 6 y 510 kbit/s.';

  @override
  String get problemPictureType => 'La imagen debe ser PNG, JPEG o WebP.';

  @override
  String get problemAvatarTooLarge => 'La imagen pesa más de 256 KB.';

  @override
  String get problemEmojiTooLarge => 'La imagen pesa más de 128 KB.';

  @override
  String get problemChatPictureTooLarge =>
      'Una imagen puede pesar hasta 20 MB.';

  @override
  String get problemPictureIdTaken => 'Esta imagen ya está aquí.';

  @override
  String get problemChatFullOfPictures =>
      'Este chat tiene demasiadas imágenes. Espera a que se vacíe.';

  @override
  String get problemTooManyPictures => 'Son muchas imágenes. Espera un poco.';

  @override
  String get problemManageNotPerRole =>
      'La gestión no se puede conceder por rol.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'Los propietarios y administradores siempre tienen todos los permisos.';

  @override
  String get problemOneOverridePerRole => 'Solo una regla por rol.';

  @override
  String get problemWhitelistUnknownAccount =>
      'La lista de acceso incluye una cuenta que no existe.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Los invitados nunca pasan una lista de acceso.';

  @override
  String get problemPushSubscriptionInvalid =>
      'El navegador envió una suscripción a notificaciones defectuosa.';

  @override
  String get problemPushEndpointNotPublic =>
      'La dirección de notificaciones debe ser una dirección HTTPS pública.';

  @override
  String get problemNotAllowedInChannel =>
      'No puedes hacer esto en este canal.';

  @override
  String get problemMayNotEnter => 'No puedes entrar en este canal.';

  @override
  String get problemTheyMayNotEnter =>
      'Esa persona no puede entrar en este canal.';

  @override
  String get problemMayNotModerate => 'No puedes moderar este canal.';

  @override
  String get problemCantModerateYourself => 'No puedes moderarte a ti mismo.';

  @override
  String get problemModerateRank =>
      'No puedes moderar a alguien de tu rango o superior.';

  @override
  String get problemBanRank =>
      'No puedes banear a alguien de tu rango o superior.';

  @override
  String get problemRoleRank =>
      'Solo puedes dar roles inferiores al tuyo, y solo a personas por debajo de ti.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Solo los propietarios y administradores del servidor lo gestionan.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Solo los propietarios y administradores del servidor gestionan los baneos.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Solo los propietarios y administradores del servidor gestionan los emoji personalizados.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Solo los propietarios y administradores del servidor gestionan los espacios.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Solo los propietarios y administradores del servidor eligen a los propietarios de los canales.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Solo los propietarios y administradores del servidor eligen a los propietarios de los espacios.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Solo los administradores y el propietario del espacio pueden gestionarlo.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Solo los administradores, y los propietarios de un espacio dentro de él, pueden crear canales.';

  @override
  String get problemMoveIntoOwnSpace =>
      'Solo puedes mover canales a un espacio que gestiones.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Solo quien puede moderar el canal puede invitar.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Los invitados no pueden crear canales.';

  @override
  String get problemGuestsCantInvite => 'Los invitados no pueden invitar.';

  @override
  String get problemGuestsCantBan => 'Los invitados no pueden banear.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Los invitados no pueden recibir notificaciones.';

  @override
  String get problemGuestsHaveNoAvatar => 'Los invitados no tienen avatar.';

  @override
  String get problemNotYourDevice => 'Ese dispositivo no es tuyo.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'Este dispositivo pertenece a otra cuenta.';

  @override
  String get problemOwnMessagesOnly =>
      'Solo puedes eliminar tus propios mensajes.';

  @override
  String get problemChannelFull => 'Este canal está lleno.';

  @override
  String get problemInviteUsed => 'Esta invitación ya se usó o caducó.';

  @override
  String get problemTooManyInvites =>
      'Demasiadas invitaciones sin usar. Espera a que caduquen algunas.';

  @override
  String get problemJoinChannelFirst => 'Primero únete al canal.';

  @override
  String get problemNotInVoice => 'No estás en un canal de voz.';

  @override
  String get problemNotInThatChannel => 'No estás en ese canal.';

  @override
  String get problemPersonNotInYourChannel =>
      'Esa persona no está en tu canal.';

  @override
  String get problemDeviceNotInChannel =>
      'Ese dispositivo no está en el canal.';

  @override
  String get problemDeviceNotOnline =>
      'Ese dispositivo no está conectado o no puede entrar.';

  @override
  String get problemVoiceNotConfigured =>
      'La voz no está configurada en este servidor.';

  @override
  String get problemSummonNeedsAccount =>
      'Inicia sesión con una cuenta para llamar a alguien.';

  @override
  String get problemCantSummonYourself => 'No puedes llamarte a ti mismo.';

  @override
  String get problemAlreadyHere => 'Esa persona ya está aquí.';

  @override
  String get problemSummonsOff => 'Esa persona desactivó las llamadas.';

  @override
  String get problemSummonedRecently =>
      'Ya llamaste a esa persona hace menos de 5 minutos.';

  @override
  String get problemMessageLength => 'Un mensaje tiene de 1 a 2000 caracteres.';

  @override
  String get problemUploadPictureFirst => 'La imagen no se subió.';

  @override
  String get problemPictureNotAccepted => 'Este chat no acepta esta imagen.';

  @override
  String get problemChatHasNoKey => 'Este chat aún no tiene clave.';

  @override
  String get problemNobodyHasChatKey =>
      'Nadie conectado tiene la clave de este chat.';

  @override
  String get problemNotCurrentChatKey => 'Esa no es la clave actual del chat.';

  @override
  String get problemChatKeyChanged =>
      'La clave del chat cambió. Inténtalo de nuevo.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'Las claves se sellaron para otra clave del chat.';

  @override
  String get problemSealForYourself => 'Sella la clave también para ti.';

  @override
  String get problemSealDeviceCount =>
      'Una clave se sella para entre 1 y 1000 dispositivos.';

  @override
  String get problemNoLongerAllowed => 'Ya no tienes acceso a este canal.';

  @override
  String get problemJoinedElsewhere => 'Entraste desde otro dispositivo.';

  @override
  String problemKickedBy(String by) {
    return '$by te sacó del canal.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by te sacó. Los invitados de tu dirección quedan bloqueados un día.';
  }

  @override
  String get problemBannedFromServer =>
      'Tu cuenta está baneada en este servidor.';

  @override
  String get problemGuestSignInClosedByAdmin =>
      'Un administrador cerró el acceso de invitados.';

  @override
  String get problemHelloFirst =>
      'La conexión no estaba lista. Recarga la página.';

  @override
  String get problemUnreadableCommand =>
      'El servidor no entendió eso. Recarga la página.';

  @override
  String get problemUnsupportedProtocol =>
      'Esta versión de Wisetalk es demasiado antigua para el servidor. Recarga la página.';

  @override
  String get problemSlowDown => 'Ve un poco más despacio.';

  @override
  String get problemTooManyCommands =>
      'Demasiadas acciones a la vez. Ve un poco más despacio.';

  @override
  String get problemGone => 'Eso ya no existe.';

  @override
  String get problemInternal => 'Algo salió mal en el servidor.';

  @override
  String get problemTooLarge => 'Es demasiado grande para enviarlo.';

  @override
  String get problemUnavailable =>
      'El servidor no responde. Inténtalo de nuevo en un minuto.';
}
