// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get brandingTagline => 'Sprach- und Videochat für deine Community';

  @override
  String get brandingSignIn => 'Anmelden';

  @override
  String brandingSignInWith(String provider) {
    return 'Mit $provider anmelden';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Betrieben von $community.';
  }

  @override
  String get signInServers => 'Server';

  @override
  String get signInUnreachable => 'Der Server ist nicht erreichbar.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get signInInBrowser => 'Im Browser fortfahren…';

  @override
  String get signInAccountHelp =>
      'Name, Avatar und Rufe begleiten dich überallhin.';

  @override
  String get signInOr => 'oder';

  @override
  String get signInGuest => 'Als Gast beitreten';

  @override
  String get signInGuestName => 'Dein Name';

  @override
  String get signInGuestHelp =>
      'Gäste können sprechen und zuhören, aber kein Video teilen und nicht gerufen werden.';

  @override
  String get signInJoining => 'Trete bei…';

  @override
  String get signInAsGuest => 'Als Gast fortfahren';

  @override
  String get signInNobody => 'Dieser Server lässt gerade niemanden herein.';

  @override
  String get signInGuestsClosed => 'Die Gastanmeldung ist vorerst geschlossen.';

  @override
  String get signInEncrypted => 'Anrufe sind Ende-zu-Ende-verschlüsselt.';

  @override
  String get signInNameLength => 'Ein Name hat 1 bis 32 Zeichen.';

  @override
  String get callMute => 'Stummschalten';

  @override
  String get callUnmute => 'Stummschaltung aufheben';

  @override
  String get callCameraOn => 'Kamera einschalten';

  @override
  String get callCameraOff => 'Kamera ausschalten';

  @override
  String get callShareScreen => 'Bildschirm teilen';

  @override
  String get callStopSharing => 'Teilen beenden';

  @override
  String get callLeave => 'Verlassen';

  @override
  String get callServiceChannel => 'Anrufe';

  @override
  String get callServiceInCall => 'Im Sprachanruf';

  @override
  String get callServiceSharing => 'Dein Bildschirm wird geteilt';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsSystemDefault => 'Systemstandard';

  @override
  String get settingsDone => 'Fertig';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatVanishes => 'Nachrichten verschwinden 4 Std. nach der letzten';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Leert sich in $hours Std. $minutes Min., falls niemand schreibt';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Leert sich in $minutes Min., falls niemand schreibt';
  }

  @override
  String get chatClose => 'Chat schließen';

  @override
  String get chatEmpty => 'Noch keine Nachrichten. Sag Hallo!';

  @override
  String get chatLoading => 'Wird geladen…';

  @override
  String get chatGettingKey => 'Chat-Schlüssel wird abgerufen …';

  @override
  String get chatSendingPicture => 'Bild wird gesendet …';

  @override
  String get chatPreparingPicture => 'Bild wird vorbereitet …';

  @override
  String get chatAddPicture => 'Bild hinzufügen';

  @override
  String chatMessageTo(String channel) {
    return 'Nachricht an $channel';
  }

  @override
  String get chatSend => 'Senden';

  @override
  String get chatLocked =>
      'Mit einem Schlüssel verschlüsselt, den dieses Gerät nicht hat: gesendet, bevor es dem Chat beigetreten ist.';

  @override
  String get chatGuest => 'Gast';

  @override
  String get chatDeleteMessage => 'Nachricht löschen';

  @override
  String get chatPictures => 'Bilder';

  @override
  String get chatInvalidMessage =>
      'Eine Nachricht hat 1 bis 2000 Zeichen, ohne Steuerzeichen.';

  @override
  String chatPictureNotSent(String reason) {
    return 'Das Bild wurde nicht gesendet: $reason';
  }

  @override
  String get pictureFailed => 'Bild nicht geladen';

  @override
  String get pictureTooLarge => 'Dieses Bild ist zu groß.';

  @override
  String get pictureUnreadable => 'Dieses Bild kann nicht gelesen werden.';

  @override
  String trustNewDevice(String name) {
    return '$name ist von einem neuen Gerät beigetreten.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Geräte haben sich bei deinem Konto angemeldet.',
      one: 'Ein neues Gerät hat sich bei deinem Konto angemeldet.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Achtung: Ein Gerät deines Kontos kam mit einem anderen Schlüssel.';

  @override
  String get personKeyChanged =>
      'Achtung: Der Geräteschlüssel dieser Person hat sich geändert.';

  @override
  String get notificationOpen => 'Öffnen';

  @override
  String get notificationChannel => 'Nachrichten und Rufe';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller ruft dich';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Komm in $channel';
  }

  @override
  String get signInErrorRefused => 'Die Anmeldung wurde abgebrochen.';

  @override
  String get signInErrorExpired =>
      'Die Anmeldung hat zu lange gedauert. Versuch es noch einmal.';

  @override
  String get signInErrorBanned =>
      'Dieses Konto ist auf diesem Server gesperrt.';

  @override
  String get signInErrorUnavailable =>
      'Die Anmeldung mit Konto ist gerade nicht verfügbar.';

  @override
  String get signInErrorFailed =>
      'Anmeldung fehlgeschlagen. Versuch es noch einmal.';

  @override
  String get signInNoBrowser =>
      'Der Browser zum Anmelden lässt sich nicht öffnen.';

  @override
  String get signInBrowserDone =>
      'Du bist angemeldet. Du kannst diesen Tab schließen und zu Wisetalk zurückkehren.';

  @override
  String get signInBrowserFailed =>
      'Die Anmeldung hat nicht geklappt. Geh zurück zu Wisetalk und versuch es noch einmal.';

  @override
  String get updatesNotSelfUpdating =>
      'Dieser Build von Wisetalk aktualisiert sich nicht selbst.';

  @override
  String get updatesCannotCheck =>
      'Updates können nicht geprüft werden. Versuch es später noch einmal.';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version ist bereit: Starte neu, um zu aktualisieren.';
  }

  @override
  String updatesAvailable(String version) {
    return 'Wisetalk $version ist da: Aktualisiere auf $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version ist die neueste Version.';
  }

  @override
  String get voiceMutedByModerator =>
      'Ein Moderator hat dich stummgeschaltet – nur er kann das aufheben.';

  @override
  String get voiceCameraUnavailable => 'Kamera nicht verfügbar.';

  @override
  String get voiceCannotSwitchCamera =>
      'Zu dieser Kamera kann nicht gewechselt werden.';

  @override
  String get voiceScreenUnavailable => 'Bildschirm teilen ist nicht verfügbar.';

  @override
  String get voiceServerMuted => 'Ein Moderator hat dich stummgeschaltet.';

  @override
  String get voiceServerUnmuted =>
      'Ein Moderator hat deine Stummschaltung aufgehoben. Schalte das Mikrofon ein, wenn du bereit bist.';

  @override
  String voiceKicked(String reason) {
    return 'Du hast den Kanal verlassen: $reason.';
  }

  @override
  String get voiceCannotConnect => 'Keine Verbindung zum Sprachkanal möglich.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Mikrofon nicht verfügbar: Du kannst zuhören, aber nicht sprechen.';

  @override
  String get videoYou => 'Du';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'Du wurdest abgemeldet.';

  @override
  String get apiUnreachable => 'Server nicht erreichbar.';

  @override
  String get apiUnreachableCheck =>
      'Server nicht erreichbar. Prüfe die Adresse und deine Verbindung.';

  @override
  String get apiNotWisetalk =>
      'Das sieht nicht nach einem Wisetalk-Server aus.';

  @override
  String apiRefused(int status) {
    return 'Der Server hat abgelehnt ($status).';
  }

  @override
  String get desktopComment => 'Sprach- und Videochat für eine Community';

  @override
  String personYou(String name) {
    return '$name (du)';
  }

  @override
  String get personAudioVideoSettings => 'Audio- und Videoeinstellungen…';

  @override
  String personVolume(int percent) {
    return 'Lautstärke $percent %';
  }

  @override
  String get personMuteForMe => 'Für mich stummschalten';

  @override
  String get personUnmuteForMe => 'Für mich Stummschaltung aufheben';

  @override
  String get moderationServerMute => 'Serverweit stummschalten';

  @override
  String get moderationLiftServerMute => 'Serverweite Stummschaltung aufheben';

  @override
  String get moderationKick => 'Aus dem Kanal werfen';

  @override
  String get personMakeServerAdmin => 'Zum Server-Admin machen';

  @override
  String get personRemoveServerAdmin => 'Server-Admin entziehen';

  @override
  String personNowAdmin(String name) {
    return '$name ist jetzt Server-Admin.';
  }

  @override
  String personNowMember(String name) {
    return '$name ist jetzt Mitglied.';
  }

  @override
  String get moderationBan => 'Vom Server sperren…';

  @override
  String moderationBanTitle(String name) {
    return '$name sperren?';
  }

  @override
  String moderationBanConfirm(String name) {
    return '$name auf diesem Server sperren? Alle Sitzungen enden sofort.';
  }

  @override
  String get moderationBanAction => 'Sperren';

  @override
  String moderationBanned(String name) {
    return '$name ist gesperrt.';
  }

  @override
  String get moderationBanGuest => 'Gast für einen Tag sperren…';

  @override
  String moderationBanGuestConfirm(String name) {
    return '$name entfernen und Gäste von dieser Adresse für einen Tag sperren?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name ist raus; die Adresse ist für einen Tag gesperrt.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Zum Inhaber von $channel machen';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Als Inhaber von $channel entfernen';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name ist jetzt Inhaber von $channel.';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel hat jetzt keinen Inhaber.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Zum Inhaber von $space machen';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Als Inhaber von $space entfernen';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name ist jetzt Inhaber von $space.';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space hat jetzt keinen Inhaber.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Audio bis $kbps kbit/s, Stereo';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Audio bis $kbps kbit/s, Mono';
  }

  @override
  String get channelJoin => 'Beitreten';

  @override
  String get channelOpenChat => 'Chat öffnen';

  @override
  String get channelOpenSettings => 'Kanaleinstellungen…';

  @override
  String get inviteCopyLink => 'Einladungslink kopieren';

  @override
  String inviteCopied(String channel) {
    return 'Einladungslink zu $channel kopiert.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Einladung zu $channel kopiert. Sobald jemand sie nutzt, lässt sie 10 Minuten lang alle herein; unbenutzt gilt sie einen Tag.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Einladungslink zu $channel kopiert. Er funktioniert nur für Leute, die der Kanal ohnehin hereinlässt.';
  }

  @override
  String get inviteCannotCreate => 'Einladung konnte nicht erstellt werden.';

  @override
  String get spaceNewChannel => 'Neuer Kanal im Bereich…';

  @override
  String get spaceOpenSettings => 'Bereichseinstellungen…';

  @override
  String get spaceDelete => 'Bereich löschen…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'Bereich $space löschen? Seine Kanäle wandern auf die oberste Ebene.';
  }

  @override
  String get workspaceMoveUp => 'Nach oben';

  @override
  String get workspaceMoveDown => 'Nach unten';

  @override
  String get workspaceCannotReorder =>
      'Reihenfolge konnte nicht geändert werden.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbit/s';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbit/s (Sprache)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbit/s (Musik)';
  }

  @override
  String get createNewChannel => 'Neuer Kanal';

  @override
  String get createNewSpace => 'Neuer Bereich';

  @override
  String get createSubmit => 'Erstellen';

  @override
  String get createChannel => 'Kanal';

  @override
  String get createSpace => 'Bereich';

  @override
  String get createChannelHint =>
      'Ein Sprachraum zum Beitreten, mit eigenem Chat.';

  @override
  String get createSpaceHint =>
      'Ein Ordner, der Kanäle in der Seitenleiste gruppiert.';

  @override
  String get createChannelPlaceholder => 'Team Blau';

  @override
  String get channelSettingsTitle => 'Kanaleinstellungen';

  @override
  String get channelSettingsOwnerHint =>
      'Der Inhaber verwaltet diesen Kanal. Nur Admins legen fest, wem er gehört.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return '$name löschen? Alle darin werden getrennt.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'Personen und Ton';

  @override
  String get channelSettingsMaxPeople => 'Max. Personen';

  @override
  String get channelSettingsNoLimit => 'Kein Limit';

  @override
  String get channelSettingsAudioQuality => 'Audioqualität';

  @override
  String get channelSettingsStereo => 'Stereo';

  @override
  String get channelSettingsDelete => 'Kanal löschen…';

  @override
  String get manageSpace => 'Bereich';

  @override
  String get manageOwner => 'Inhaber';

  @override
  String get manageAccess => 'Zugang';

  @override
  String get spaceSettingsTitle => 'Bereichseinstellungen';

  @override
  String get spaceSettingsOwnerHint =>
      'Der Inhaber verwaltet den Bereich und alle Kanäle darin. Nur Admins legen fest, wem er gehört.';

  @override
  String get accessAccountsOnly => 'Nur mit Konto';

  @override
  String get accessAccountsOnlyDetail => 'Keine Gäste';

  @override
  String get accessWhitelistOnly => 'Nur Zulassungsliste';

  @override
  String get accessHidden => 'Versteckt';

  @override
  String get accessHiddenDetail => 'Unsichtbar für alle, die nicht rein dürfen';

  @override
  String get accessFromSpace => 'Vom Bereich festgelegt';

  @override
  String summonsTitle(String channel) {
    return 'In $channel rufen';
  }

  @override
  String get summonsSummon => 'Rufen';

  @override
  String get summonsNickname => 'Nickname';

  @override
  String get summonsNoMatch => 'Niemand Passendes darf hierherkommen.';

  @override
  String get summonsHint =>
      'Die Person bekommt eine Benachrichtigung, dass du wartest. Einmal alle 5 Minuten pro Person.';

  @override
  String get summonsSearchFailed => 'Suche nicht möglich.';

  @override
  String get manageDeviceKey => 'Geräteschlüssel';

  @override
  String manageDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get manageDelete => 'Löschen';

  @override
  String get manageSave => 'Speichern';

  @override
  String get manageName => 'Name';

  @override
  String get manageNone => 'Keiner';

  @override
  String get manageNobody => 'Niemand';

  @override
  String get manageSomeoneElse => 'Jemand anderes';

  @override
  String get manageWhitelistInWeb =>
      'Die Zulassungsliste bearbeitest du vorerst im Webclient.';

  @override
  String get channelSettingsLimitHint =>
      'Ist der Kanal voll, können nur noch Leute beitreten, die ihn verwalten. 1 bis 99 Personen oder kein Limit.';

  @override
  String get spaceSettingsAccessHint =>
      'Diese Einschränkungen gelten für jeden Kanal im Bereich; ein Kanal kann nur eigene hinzufügen. Die Zulassungsliste bearbeitest du vorerst im Webclient.';

  @override
  String get accessWhitelistOnlyListDetail =>
      'Nur die Personen und Rollen auf der Liste';

  @override
  String get summonsWho => 'Wen?';

  @override
  String get settingsPictures => 'Bilder';

  @override
  String get profileAddPicture => 'Bild hinzufügen…';

  @override
  String get profileChangePicture => 'Bild ändern…';

  @override
  String get profileRemovePicture => 'Bild entfernen';

  @override
  String get profileUploadFailed => 'Das Bild lässt sich nicht hochladen.';

  @override
  String get profileRemoveFailed => 'Das Bild lässt sich nicht entfernen.';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen.';

  @override
  String get settingsAudioVideo => 'Audio und Video';

  @override
  String get settingsMicrophone => 'Mikrofon';

  @override
  String get settingsCamera => 'Kamera';

  @override
  String get settingsOutput => 'Ausgabe';

  @override
  String get settingsVoiceProcessing => 'Sprachverarbeitung';

  @override
  String get settingsVoiceProcessingDetail => 'Rausch- und Echounterdrückung';

  @override
  String get settingsVoiceProcessingHint =>
      'Schalte sie für den besten Klang aus und trag dann Kopfhörer: Ohne Echounterdrückung hören sich die anderen über deine Lautsprecher selbst.';

  @override
  String get settingsCues => 'Töne beim Kommen und Gehen';

  @override
  String get settingsCuesDetail =>
      'Eine Eule ruft, wenn jemand kommt oder geht, und Tastenkürzel klicken';

  @override
  String get settingsPingAndLoss => 'Ping und Verlust anzeigen';

  @override
  String get settingsPingAndLossDetail =>
      'Neben dem Verbindungssymbol im Anruf';

  @override
  String get summonsHeader => 'Rufen';

  @override
  String get summonsAllow => 'Andere dürfen mich rufen';

  @override
  String get settingsNotificationsHere => 'Benachrichtigungen auf diesem Gerät';

  @override
  String get settingsNotificationsHint =>
      'Erscheinen, während Wisetalk im Hintergrund läuft.';

  @override
  String get settingsNotifyMessages => 'Neue Nachrichten';

  @override
  String get settingsNotifyMessagesDetail =>
      'Im Chat deines Anrufs und in Chats, die du geöffnet hast';

  @override
  String get settingsNotifySummons => 'Rufen';

  @override
  String get settingsNotifySummonsDetail =>
      'Wenn dich jemand in einen Kanal ruft';

  @override
  String get settingsPushHeader => 'Wenn Wisetalk geschlossen ist';

  @override
  String get settingsPushApp => 'Push-App';

  @override
  String get settingsPushAppNone => 'Keine';

  @override
  String get settingsPushAppChoose => 'Auswählen…';

  @override
  String get settingsGetNtfy => 'ntfy installieren';

  @override
  String settingsPushVia(String app) {
    return 'Wenn dich jemand in einen Kanal ruft, erfährt dein Handy es über $app, auch wenn Wisetalk geschlossen ist.';
  }

  @override
  String get settingsPushChooseHint =>
      'Wähle die App, über die Rufe ankommen, während Wisetalk geschlossen ist.';

  @override
  String get settingsPushNoneHint =>
      'Ohne Push-App siehst du Rufe nur, solange Wisetalk läuft. Installiere ntfy und stell in seinen Einstellungen den ntfy-Server deiner Community als Standardserver ein.';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsCrashReports => 'Absturzberichte senden';

  @override
  String get settingsCrashReportsHint =>
      'Wenn in Wisetalk etwas kaputtgeht, erfahren die Entwickler, was kaputtging und wo im Code. Nie deine Nachrichten, Namen, Schlüssel oder Server.';

  @override
  String get settingsShortcuts => 'Tastenkürzel';

  @override
  String get settingsShortcutsRecording =>
      'Drück die neuen Tasten. Backspace entfernt das Kürzel, Esc behält es.';

  @override
  String get settingsShortcutsGlobal =>
      'Im Anruf funktionieren sie, egal welche App vorne ist, sonst im Wisetalk-Fenster. Klick eins an, um es zu ändern.';

  @override
  String get settingsShortcutsWayland =>
      'Unter Wayland funktionieren sie nur, solange das Wisetalk-Fenster vorne ist. Klick eins an, um es zu ändern.';

  @override
  String get settingsShortcutPressKeys => 'Tasten drücken…';

  @override
  String get settingsShortcutNone => 'Keins';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys ist schon „$action“.';
  }

  @override
  String get shortcutToggleMute => 'Mikrofon an oder aus';

  @override
  String get shortcutToggleAway => 'Abwesend oder zurück';

  @override
  String get shortcutMute => 'Mikrofon aus';

  @override
  String get shortcutUnmute => 'Mikrofon an';

  @override
  String get shortcutUnusableKey =>
      'Diese Taste geht nicht für ein Tastenkürzel.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Nimm $first oder $second dazu oder nutze F1 bis F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys gehört dem System oder jeder App.';
  }

  @override
  String get sheetDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get sheetDiscardMessage =>
      'Was du hier geändert hast, ist noch nicht gespeichert.';

  @override
  String get sheetDiscard => 'Verwerfen';

  @override
  String get sheetKeepEditing => 'Weiter bearbeiten';

  @override
  String serversRemoveTitle(String server) {
    return '$server entfernen?';
  }

  @override
  String get serversRemoveMessage =>
      'Dieses Gerät meldet sich dort ab und vergisst den Server. Mit seiner Adresse kannst du ihn wieder hinzufügen.';

  @override
  String get serversRemove => 'Entfernen';

  @override
  String get serversAddressHelp =>
      'Frag die Leute, die deine Community betreiben, nach der Adresse.';

  @override
  String get serversConnecting => 'Verbindung wird hergestellt…';

  @override
  String get serversConnect => 'Verbinden';

  @override
  String get serversWhich => 'Auf welchem Server ist deine Community?';

  @override
  String get serversYours => 'Deine Server';

  @override
  String get serversAddMenu => 'Server hinzufügen…';

  @override
  String get serversAddTitle => 'Server hinzufügen';

  @override
  String get serversBadAddress =>
      'Gib die Adresse eines Servers ein, etwa talk.example.com.';

  @override
  String get serversTooNew =>
      'Dieser Server ist neuer als diese App. Aktualisiere Wisetalk, um beizutreten.';

  @override
  String get serversTooOld =>
      'Auf diesem Server läuft ein älteres Wisetalk. Bitte die Admins, ihn zu aktualisieren.';

  @override
  String serversTooOldVersion(String version) {
    return 'Auf diesem Server läuft ein älteres Wisetalk ($version). Bitte die Admins, ihn zu aktualisieren.';
  }

  @override
  String get serversAddress => 'Adresse';

  @override
  String get serversMore => 'Mehr';

  @override
  String get serversRemoveServer => 'Server entfernen';

  @override
  String get channelSomeChannel => 'einen Kanal';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name in $channel';
  }

  @override
  String get workspaceMessageEncrypted =>
      'Hat eine verschlüsselte Nachricht geschrieben.';

  @override
  String get workspaceMessagePicture => 'Hat ein Bild geschickt.';

  @override
  String summonPushed(String name) {
    return '$name hat eine Benachrichtigung bekommen.';
  }

  @override
  String get summonPushedSomeone => 'Benachrichtigung zugestellt.';

  @override
  String summonNotPushed(String name) {
    return '$name gerufen. Dort sind Benachrichtigungen aus, daher erscheint der Ruf nur in einem offenen Wisetalk.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Gerufen. Dort sind Benachrichtigungen aus, daher erscheint der Ruf nur in einem offenen Wisetalk.';

  @override
  String summonReceived(String from, String channel) {
    return '$from ruft dich in $channel.';
  }

  @override
  String get workspaceSummoned => 'Du wirst gerufen';

  @override
  String get workspaceRoleChangedOwner =>
      'Deine Serverrolle ist jetzt Inhaber.';

  @override
  String get workspaceRoleChangedAdmin => 'Deine Serverrolle ist jetzt Admin.';

  @override
  String get workspaceRoleChangedModerator =>
      'Deine Serverrolle ist jetzt Moderator.';

  @override
  String get workspaceRoleChangedMember =>
      'Deine Serverrolle ist jetzt Mitglied.';

  @override
  String get workspaceRoleChangedGuest => 'Deine Serverrolle ist jetzt Gast.';

  @override
  String get takeOverTitle => 'Von diesem Gerät beitreten?';

  @override
  String takeOverSameChannel(String channel) {
    return 'Du bist schon auf einem anderen Gerät oder Tab in $channel. Wenn du $channel hier beitrittst, verlässt du den Anruf dort.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'Du bist auf einem anderen Gerät oder Tab in $there. Wenn du hier $here beitrittst, verlässt du den Anruf dort.';
  }

  @override
  String get takeOverElsewhere =>
      'Du bist auf einem anderen Gerät oder Tab in einem Anruf. Wenn du hier beitrittst, verlässt du den Anruf dort.';

  @override
  String get takeOverJoinHere => 'Hier beitreten';

  @override
  String get workspaceShowChannels => 'Kanäle anzeigen';

  @override
  String get workspaceHideChannels => 'Kanäle ausblenden';

  @override
  String workspaceInVoice(int count) {
    return '$count im Sprachkanal';
  }

  @override
  String get workspaceCreateTitle => 'Neuer Kanal oder Bereich';

  @override
  String get workspaceStatusConnecting => 'Verbinde…';

  @override
  String get workspaceStatusOffline => 'Offline…';

  @override
  String get workspaceEmptyAdmin =>
      'Noch keine Kanäle. Erstelle einen mit der Schaltfläche +.';

  @override
  String get workspaceEmpty =>
      'Noch keine Kanäle. Ein Admin kann welche anlegen.';

  @override
  String get workspaceMore => 'Mehr';

  @override
  String get workspaceCheckForUpdates => 'Nach Updates suchen';

  @override
  String get workspaceChangeServer => 'Server wechseln';

  @override
  String get workspaceSignOut => 'Abmelden';

  @override
  String get personMutedForYou => 'Für dich stummgeschaltet';

  @override
  String get awayTitle => 'Abwesend';

  @override
  String get awayDescription => 'Abwesend: Mikrofon und Ton aus';

  @override
  String get callMutedByModerator => 'Von einem Moderator stummgeschaltet';

  @override
  String workspaceDrag(String name) {
    return '$name ziehen';
  }

  @override
  String get workspaceDropEndHint => 'Hier ablegen, um ans Ende zu verschieben';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version ist heruntergeladen';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Wisetalk $version ist erschienen';
  }

  @override
  String get workspaceRestartToUpdate => 'Neu starten und aktualisieren';

  @override
  String workspaceUpdateTo(String version) {
    return 'Auf $version aktualisieren';
  }

  @override
  String get workspaceWelcomeTitle => 'Wähle einen Sprachkanal';

  @override
  String get workspaceWelcomeHint => 'Klicke auf einen Kanal, um beizutreten.';

  @override
  String get callJoining => 'Trete bei…';

  @override
  String get callWaitingForKey => 'Warte auf den Anrufschlüssel…';

  @override
  String get callEncrypted => 'Ende-zu-Ende-verschlüsselt';

  @override
  String videoScreen(String name) {
    return '$name · Bildschirm';
  }

  @override
  String get connectionExcellent => 'ausgezeichnet';

  @override
  String get connectionGood => 'gut';

  @override
  String get connectionPoor => 'schwach';

  @override
  String get connectionLost => 'verloren';

  @override
  String get connectionChecking => 'wird geprüft';

  @override
  String connectionStatus(String quality) {
    return 'Verbindung: $quality';
  }

  @override
  String get connectionLabel => 'Verbindung';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · $loss Verlust';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping, Verlust $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => 'Ausgehender Verlust';

  @override
  String get connectionIncomingLoss => 'Eingehender Verlust';

  @override
  String get connectionJitter => 'Jitter';

  @override
  String get connectionMicrophone => 'Mikrofon';

  @override
  String get connectionNotSending => 'Sendet nicht';

  @override
  String connectionKilobits(int value) {
    return '$value kbit/s';
  }

  @override
  String get screenShareTitle => 'Bildschirm teilen';

  @override
  String get screenShareAction => 'Teilen';

  @override
  String get screenShareBestFor => 'Am besten für';

  @override
  String get screenShareAndroidHint =>
      'Als Nächstes fragt Android, ob du den ganzen Bildschirm oder eine App teilen willst. Vorerst ohne Ton.';

  @override
  String get screenShareWaylandHint =>
      'Beim ersten Mal fragt dein System, welcher Bildschirm geteilt wird. Danach wird dieser Bildschirm wiederverwendet, bis Wisetalk neu startet. Vorerst nur ganze Bildschirme, ohne Ton.';

  @override
  String get screenShareText => 'Text und Folien';

  @override
  String get screenShareTextDetail =>
      'Scharf und leicht: wenige Bilder pro Sekunde.';

  @override
  String get screenShareMotion => 'Videos und Spiele';

  @override
  String get screenShareMotionDetail =>
      'Flüssig: 30 Bilder pro Sekunde, aufwendiger auf beiden Seiten.';

  @override
  String get screenShareSource => 'Bildschirm oder Fenster';

  @override
  String get screenShareSound => 'Ton teilen';

  @override
  String get screenShareSoundWindow => 'Nur die App dieses Fensters.';

  @override
  String get screenShareSoundScreen => 'Alles, was du hörst, ohne den Anruf.';

  @override
  String get screenShareSoundAny =>
      'Bei einem Fenster dessen App, bei einem Bildschirm alles, was du hörst, ohne den Anruf.';

  @override
  String get screenShareListFailed =>
      'Bildschirme und Fenster lassen sich nicht auflisten.';

  @override
  String get screenShareChooseTitle => 'Wähle einen Bildschirm';

  @override
  String get screenShareChooseHint =>
      'Wähle im Fenster deines Systems den Bildschirm, den du teilen willst.';

  @override
  String get problemNotSignedIn => 'Du bist nicht angemeldet.';

  @override
  String get problemAccountRequired => 'Melde dich zuerst mit einem Konto an.';

  @override
  String get problemAccountBanned => 'Dieses Konto ist gesperrt.';

  @override
  String get problemSignInCodeInvalid =>
      'Dieser Anmeldecode ist nicht mehr gültig. Melde dich erneut an.';

  @override
  String get problemBrowserCheckMissing =>
      'Die Browserprüfung fehlt. Lade die Seite neu und versuch es noch einmal.';

  @override
  String get problemBrowserCheckFailed =>
      'Die Browserprüfung ist fehlgeschlagen. Lade die Seite neu und versuch es noch einmal.';

  @override
  String get problemBrowserCheckExpired =>
      'Die Browserprüfung ist abgelaufen. Versuch es noch einmal.';

  @override
  String get problemGuestSignInClosed =>
      'Die Gastanmeldung ist gerade geschlossen. Melde dich mit einem Konto an.';

  @override
  String get problemGuestAddressBlocked =>
      'Gäste von dieser Adresse sind vorübergehend blockiert.';

  @override
  String get problemTooManyGuests =>
      'Gerade sind zu viele Gäste da. Versuch es später noch einmal oder melde dich mit einem Konto an.';

  @override
  String get problemTooManyGuestSignIns =>
      'Zu viele Gastanmeldungen von dieser Adresse. Versuch es später noch einmal.';

  @override
  String get problemNameBelongsToAccount =>
      'Dieser Name gehört zu einem Konto.';

  @override
  String get problemAccountsCantBeGuests =>
      'Mit einem Konto kannst du kein Gast sein.';

  @override
  String get problemNoSuchAccount => 'Dieses Konto gibt es nicht.';

  @override
  String get problemNoSuchChannel => 'Diesen Kanal gibt es nicht mehr.';

  @override
  String get problemNoSuchSpace => 'Diesen Bereich gibt es nicht mehr.';

  @override
  String get problemNoSuchEmoji => 'Dieses Emoji gibt es nicht.';

  @override
  String get problemNoSuchGuest => 'Dieser Gast ist nicht mehr online.';

  @override
  String get problemNoSuchPicture => 'Dieses Bild ist nicht mehr da.';

  @override
  String get problemNoSuchMessage => 'Diese Nachricht ist nicht mehr da.';

  @override
  String get problemNoAvatar => 'Es gibt keinen Avatar.';

  @override
  String get problemNotBanned => 'Dieses Konto ist nicht gesperrt.';

  @override
  String get problemDisplayNameLength => 'Ein Name hat 1 bis 32 Zeichen.';

  @override
  String get problemChannelNameLength => 'Ein Kanalname hat 1 bis 64 Zeichen.';

  @override
  String get problemSpaceNameLength => 'Ein Bereichsname hat 1 bis 64 Zeichen.';

  @override
  String get problemEmojiNameInvalid =>
      'Ein Emoji-Name hat 2 bis 32 Zeichen aus a–z, 0–9 und _.';

  @override
  String get problemIconInvalid =>
      'Ein Icon ist ein einzelnes Emoji oder ein :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Namen haben bis zu 40 Zeichen, der Slogan bis zu 120, ohne Steuerzeichen.';

  @override
  String get problemChannelLimitInvalid =>
      'In einen Kanal passen 1 bis 99 Personen, oder er hat kein Limit.';

  @override
  String get problemBitrateInvalid =>
      'Die Audio-Bitrate muss zwischen 6 und 510 kbit/s liegen.';

  @override
  String get problemPictureType => 'Das Bild muss PNG, JPEG oder WebP sein.';

  @override
  String get problemAvatarTooLarge => 'Das Bild ist größer als 256 KB.';

  @override
  String get problemEmojiTooLarge => 'Das Bild ist größer als 128 KB.';

  @override
  String get problemChatPictureTooLarge =>
      'Ein Bild darf bis zu 20 MB groß sein.';

  @override
  String get problemPictureIdTaken => 'Dieses Bild ist schon da.';

  @override
  String get problemChatFullOfPictures =>
      'Dieser Chat hat zu viele Bilder, bis er sich leert.';

  @override
  String get problemTooManyPictures => 'Das sind viele Bilder. Warte kurz.';

  @override
  String get problemManageNotPerRole =>
      'Verwalten lässt sich nicht pro Rolle vergeben.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'Inhaber und Admins haben immer alle Berechtigungen.';

  @override
  String get problemOneOverridePerRole => 'Nur eine Regel pro Rolle.';

  @override
  String get problemWhitelistUnknownAccount =>
      'Die Zulassungsliste nennt ein Konto, das es nicht gibt.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Gäste kommen nie durch eine Zulassungsliste.';

  @override
  String get problemPushSubscriptionInvalid =>
      'Der Browser hat ein fehlerhaftes Benachrichtigungsabo gesendet.';

  @override
  String get problemPushEndpointNotPublic =>
      'Die Benachrichtigungsadresse muss eine öffentliche HTTPS-Adresse sein.';

  @override
  String get problemNotAllowedInChannel =>
      'Das darfst du in diesem Kanal nicht.';

  @override
  String get problemMayNotEnter => 'Du darfst diesen Kanal nicht betreten.';

  @override
  String get problemTheyMayNotEnter =>
      'Diese Person darf diesen Kanal nicht betreten.';

  @override
  String get problemMayNotModerate =>
      'Du darfst diesen Kanal nicht moderieren.';

  @override
  String get problemCantModerateYourself =>
      'Du kannst dich nicht selbst moderieren.';

  @override
  String get problemModerateRank =>
      'Du darfst niemanden mit gleichem oder höherem Rang moderieren.';

  @override
  String get problemBanRank =>
      'Du darfst niemanden mit gleichem oder höherem Rang sperren.';

  @override
  String get problemRoleRank =>
      'Du darfst nur Rollen unter deiner vergeben, und nur an Leute unter dir.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Nur Inhaber und Admins des Servers verwalten den Server.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Nur Inhaber und Admins des Servers verwalten Sperren.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Nur Inhaber und Admins des Servers verwalten eigene Emoji.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Nur Inhaber und Admins des Servers verwalten Bereiche.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Nur Inhaber und Admins des Servers bestimmen Kanalinhaber.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Nur Inhaber und Admins des Servers bestimmen Bereichsinhaber.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Nur Admins und der Inhaber des Bereichs verwalten ihn.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Kanäle erstellen dürfen nur Admins und, in ihrem Bereich, Bereichsinhaber.';

  @override
  String get problemMoveIntoOwnSpace =>
      'Du darfst Kanäle nur in einen Bereich verschieben, den du verwaltest.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Einladen darf nur, wer den Kanal moderieren darf.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Gäste dürfen keine Kanäle erstellen.';

  @override
  String get problemGuestsCantInvite => 'Gäste können nicht einladen.';

  @override
  String get problemGuestsCantBan => 'Gäste können nicht sperren.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Gäste können keine Benachrichtigungen bekommen.';

  @override
  String get problemGuestsHaveNoAvatar => 'Gäste haben keinen Avatar.';

  @override
  String get problemNotYourDevice => 'Das ist nicht dein Gerät.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'Dieses Gerät gehört zu einem anderen Konto.';

  @override
  String get problemOwnMessagesOnly =>
      'Du darfst nur deine eigenen Nachrichten löschen.';

  @override
  String get problemChannelFull => 'Dieser Kanal ist voll.';

  @override
  String get problemInviteUsed =>
      'Diese Einladung wurde schon benutzt oder ist abgelaufen.';

  @override
  String get problemTooManyInvites =>
      'Zu viele unbenutzte Einladungen. Warte, bis einige ablaufen.';

  @override
  String get problemJoinChannelFirst => 'Tritt zuerst dem Kanal bei.';

  @override
  String get problemNotInVoice => 'Du bist in keinem Sprachkanal.';

  @override
  String get problemNotInThatChannel => 'Du bist nicht in diesem Kanal.';

  @override
  String get problemPersonNotInYourChannel =>
      'Diese Person ist nicht in deinem Kanal.';

  @override
  String get problemDeviceNotInChannel => 'Dieses Gerät ist nicht im Kanal.';

  @override
  String get problemDeviceNotOnline =>
      'Dieses Gerät ist nicht online oder darf nicht rein.';

  @override
  String get problemVoiceNotConfigured =>
      'Sprachanrufe sind auf diesem Server nicht eingerichtet.';

  @override
  String get problemSummonNeedsAccount =>
      'Melde dich mit einem Konto an, um andere zu rufen.';

  @override
  String get problemCantSummonYourself => 'Du kannst dich nicht selbst rufen.';

  @override
  String get problemAlreadyHere => 'Die Person ist schon hier.';

  @override
  String get problemSummonsOff => 'Die Person hat Rufe ausgeschaltet.';

  @override
  String get problemSummonedRecently =>
      'Du hast die Person vor weniger als 5 Minuten gerufen.';

  @override
  String get problemMessageLength => 'Eine Nachricht hat 1 bis 2000 Zeichen.';

  @override
  String get problemUploadPictureFirst => 'Das Bild wurde nicht hochgeladen.';

  @override
  String get problemPictureNotAccepted =>
      'Dieser Chat nimmt dieses Bild nicht an.';

  @override
  String get problemChatHasNoKey => 'Dieser Chat hat noch keinen Schlüssel.';

  @override
  String get problemNobodyHasChatKey =>
      'Niemand, der online ist, hat den Schlüssel dieses Chats.';

  @override
  String get problemNotCurrentChatKey =>
      'Das ist nicht der aktuelle Schlüssel des Chats.';

  @override
  String get problemChatKeyChanged =>
      'Der Schlüssel des Chats hat sich geändert. Versuch es noch einmal.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'Die Schlüssel wurden für einen anderen Chatschlüssel versiegelt.';

  @override
  String get problemSealForYourself =>
      'Versiegle den Schlüssel auch für dich selbst.';

  @override
  String get problemSealDeviceCount =>
      'Ein Schlüssel wird für 1 bis 1000 Geräte versiegelt.';

  @override
  String get problemNoLongerAllowed =>
      'Du hast keinen Zugang mehr zu diesem Kanal.';

  @override
  String get problemJoinedElsewhere =>
      'Du bist von einem anderen Gerät aus beigetreten.';

  @override
  String problemKickedBy(String by) {
    return '$by hat dich aus dem Kanal geworfen.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by hat dich entfernt. Gäste von deiner Adresse sind für einen Tag gesperrt.';
  }

  @override
  String get problemBannedFromServer => 'Du bist auf diesem Server gesperrt.';

  @override
  String get problemGuestSignInClosedByAdmin =>
      'Ein Admin hat die Gastanmeldung geschlossen.';

  @override
  String get problemHelloFirst =>
      'Die Verbindung war noch nicht bereit. Lade die Seite neu.';

  @override
  String get problemUnreadableCommand =>
      'Der Server konnte das nicht lesen. Lade die Seite neu.';

  @override
  String get problemUnsupportedProtocol =>
      'Diese Wisetalk-Version ist zu alt für den Server. Lade die Seite neu.';

  @override
  String get problemSlowDown => 'Etwas langsamer, bitte.';

  @override
  String get problemTooManyCommands =>
      'Zu viele Aktionen auf einmal. Etwas langsamer, bitte.';

  @override
  String get problemGone => 'Das ist nicht mehr da.';

  @override
  String get problemInternal => 'Auf dem Server ist etwas schiefgelaufen.';

  @override
  String get problemTooLarge => 'Das ist zu groß zum Senden.';

  @override
  String get problemUnavailable =>
      'Der Server antwortet nicht. Versuch es in einer Minute noch einmal.';
}
