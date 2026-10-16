// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get brandingTagline => 'Chat vocal et vidéo pour votre communauté';

  @override
  String get brandingSignIn => 'Se connecter';

  @override
  String brandingSignInWith(String provider) {
    return 'Se connecter avec $provider';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Hébergé par $community.';
  }

  @override
  String get signInServers => 'Serveurs';

  @override
  String get signInUnreachable => 'Impossible de joindre le serveur.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get signInInBrowser => 'Continuez dans votre navigateur…';

  @override
  String get signInAccountHelp =>
      'Votre nom, votre avatar et les appels vous suivent partout.';

  @override
  String get signInOr => 'ou';

  @override
  String get signInGuest => 'Rejoindre en tant qu’invité';

  @override
  String get signInGuestName => 'Votre nom';

  @override
  String get signInGuestHelp =>
      'Les invités peuvent parler et écouter, mais pas partager de vidéo ni être appelés.';

  @override
  String get signInJoining => 'Connexion…';

  @override
  String get signInAsGuest => 'Continuer en tant qu’invité';

  @override
  String get signInNobody =>
      'Ce serveur ne laisse entrer personne pour le moment.';

  @override
  String get signInGuestsClosed =>
      'La connexion des invités est fermée pour le moment.';

  @override
  String get signInEncrypted => 'Les appels sont chiffrés de bout en bout.';

  @override
  String get signInNameLength => 'Un nom fait de 1 à 32 caractères.';

  @override
  String get callMute => 'Couper le micro';

  @override
  String get callUnmute => 'Activer le micro';

  @override
  String get callCameraOn => 'Activer la caméra';

  @override
  String get callCameraOff => 'Désactiver la caméra';

  @override
  String get callShareScreen => 'Partager l’écran';

  @override
  String get callStopSharing => 'Arrêter le partage';

  @override
  String get callLeave => 'Quitter';

  @override
  String get callServiceChannel => 'Appels';

  @override
  String get callServiceInCall => 'En appel vocal';

  @override
  String get callServiceSharing => 'Partage de votre écran';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsSystemDefault => 'Par défaut du système';

  @override
  String get settingsDone => 'OK';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatVanishes => 'Les messages disparaissent 4 h après le dernier';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Effacé dans $hours h $minutes min si personne n’écrit';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Effacé dans $minutes min si personne n’écrit';
  }

  @override
  String get chatClose => 'Fermer le chat';

  @override
  String get chatEmpty => 'Aucun message pour l’instant. Dites bonjour !';

  @override
  String get chatLoading => 'Chargement…';

  @override
  String get chatGettingKey => 'Récupération de la clé du chat…';

  @override
  String get chatSendingPicture => 'Envoi de l’image…';

  @override
  String get chatPreparingPicture => 'Préparation de l’image…';

  @override
  String get chatAddPicture => 'Ajouter une image';

  @override
  String chatMessageTo(String channel) {
    return 'Écrire dans $channel';
  }

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatLocked =>
      'Chiffré avec une clé que cet appareil n’a pas : envoyé avant qu’il ne rejoigne le chat.';

  @override
  String get chatGuest => 'invité';

  @override
  String get chatDeleteMessage => 'Supprimer le message';

  @override
  String get chatPictures => 'Images';

  @override
  String get chatInvalidMessage =>
      'Un message compte de 1 à 2000 caractères, sans caractères de contrôle.';

  @override
  String chatPictureNotSent(String reason) {
    return 'L’image n’est pas partie : $reason';
  }

  @override
  String get pictureFailed => 'L’image n’a pas chargé';

  @override
  String get pictureTooLarge => 'Cette image est trop lourde.';

  @override
  String get pictureUnreadable => 'Impossible de lire cette image.';

  @override
  String trustNewDevice(String name) {
    return '$name utilise un nouvel appareil.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux appareils se sont connectés à votre compte.',
      many: '$count nouveaux appareils se sont connectés à votre compte.',
      one: 'Un nouvel appareil s’est connecté à votre compte.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Attention : un appareil de votre compte est arrivé avec une autre clé.';

  @override
  String get personKeyChanged =>
      'Attention : la clé de l’appareil de cette personne a changé.';

  @override
  String get notificationOpen => 'Ouvrir';

  @override
  String get notificationChannel => 'Messages et appels';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller vous appelle';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Rejoignez $channel';
  }

  @override
  String get signInErrorRefused => 'Connexion annulée.';

  @override
  String get signInErrorExpired =>
      'La connexion a pris trop de temps. Réessayez.';

  @override
  String get signInErrorBanned => 'Ce compte est banni de ce serveur.';

  @override
  String get signInErrorUnavailable =>
      'La connexion par compte n’est pas disponible pour le moment.';

  @override
  String get signInErrorFailed => 'Échec de la connexion. Réessayez.';

  @override
  String get signInNoBrowser =>
      'Impossible d’ouvrir le navigateur pour se connecter.';

  @override
  String get signInBrowserDone =>
      'Vous êtes connecté. Vous pouvez fermer cet onglet et revenir à Wisetalk.';

  @override
  String get signInBrowserFailed =>
      'La connexion n’a pas abouti. Revenez à Wisetalk pour réessayer.';

  @override
  String get updatesNotSelfUpdating =>
      'Cette version de Wisetalk ne se met pas à jour toute seule.';

  @override
  String get updatesCannotCheck =>
      'Impossible de vérifier les mises à jour. Réessayez plus tard.';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version est prêt : redémarrez pour mettre à jour.';
  }

  @override
  String updatesAvailable(String version) {
    return 'Wisetalk $version est sorti : mettez à jour vers $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version est la dernière version.';
  }

  @override
  String get voiceMutedByModerator =>
      'Un modérateur a coupé votre micro, et lui seul peut le réactiver.';

  @override
  String get voiceCameraUnavailable => 'Caméra indisponible.';

  @override
  String get voiceCannotSwitchCamera => 'Impossible de passer à cette caméra.';

  @override
  String get voiceScreenUnavailable => 'Partage d’écran indisponible.';

  @override
  String get voiceServerMuted => 'Un modérateur a coupé votre micro.';

  @override
  String get voiceServerUnmuted =>
      'Un modérateur vous a rendu le micro. Activez-le quand vous voulez.';

  @override
  String voiceKicked(String reason) {
    return 'Vous avez quitté le salon : $reason.';
  }

  @override
  String get voiceCannotConnect => 'Impossible de rejoindre le salon vocal.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Micro indisponible : vous pouvez écouter, mais pas parler.';

  @override
  String get videoYou => 'Vous';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'Votre session a été fermée.';

  @override
  String get apiUnreachable => 'Impossible de joindre le serveur.';

  @override
  String get apiUnreachableCheck =>
      'Impossible de joindre le serveur. Vérifiez l’adresse et votre connexion.';

  @override
  String get apiNotWisetalk => 'Cela ne ressemble pas à un serveur Wisetalk.';

  @override
  String apiRefused(int status) {
    return 'Le serveur a refusé ($status).';
  }

  @override
  String get desktopComment => 'Chat vocal et vidéo pour une communauté';

  @override
  String personYou(String name) {
    return '$name (vous)';
  }

  @override
  String get personAudioVideoSettings => 'Réglages audio et vidéo…';

  @override
  String personVolume(int percent) {
    return 'Volume $percent %';
  }

  @override
  String get personMuteForMe => 'Couper pour moi';

  @override
  String get personUnmuteForMe => 'Réactiver pour moi';

  @override
  String get moderationServerMute => 'Couper le micro';

  @override
  String get moderationLiftServerMute => 'Rétablir le micro';

  @override
  String get moderationKick => 'Expulser du salon';

  @override
  String get personMakeServerAdmin => 'Nommer admin du serveur';

  @override
  String get personRemoveServerAdmin => 'Retirer les droits d’admin du serveur';

  @override
  String personNowAdmin(String name) {
    return '$name est maintenant admin du serveur.';
  }

  @override
  String personNowMember(String name) {
    return '$name est maintenant membre.';
  }

  @override
  String get moderationBan => 'Bannir du serveur…';

  @override
  String moderationBanTitle(String name) {
    return 'Bannir $name ?';
  }

  @override
  String moderationBanConfirm(String name) {
    return 'Bannir $name de ce serveur ? Ses sessions se terminent immédiatement.';
  }

  @override
  String get moderationBanAction => 'Bannir';

  @override
  String moderationBanned(String name) {
    return '$name a été banni.';
  }

  @override
  String get moderationBanGuest => 'Bannir l’invité pour un jour…';

  @override
  String moderationBanGuestConfirm(String name) {
    return 'Retirer $name et bloquer les invités depuis son adresse pendant un jour ?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name est exclu ; son adresse est bloquée pendant un jour.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Nommer propriétaire de $channel';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Retirer comme propriétaire de $channel';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name est maintenant propriétaire de $channel.';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel n’a plus de propriétaire.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Nommer propriétaire de $space';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Retirer comme propriétaire de $space';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name est maintenant propriétaire de $space.';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space n’a plus de propriétaire.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Audio jusqu’à $kbps kbit/s, stéréo';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Audio jusqu’à $kbps kbit/s, mono';
  }

  @override
  String get channelJoin => 'Rejoindre';

  @override
  String get channelOpenChat => 'Ouvrir le chat';

  @override
  String get channelOpenSettings => 'Paramètres du salon…';

  @override
  String get inviteCopyLink => 'Copier le lien d’invitation';

  @override
  String inviteCopied(String channel) {
    return 'Lien d’invitation vers $channel copié.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Invitation vers $channel copiée. Dès que quelqu’un l’utilise, elle laisse entrer n’importe qui pendant 10 minutes ; inutilisée, elle dure un jour.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Lien d’invitation vers $channel copié. Il ne marche que pour les personnes que le salon accepte déjà.';
  }

  @override
  String get inviteCannotCreate => 'Impossible de créer une invitation.';

  @override
  String get spaceNewChannel => 'Nouveau salon dans l’espace…';

  @override
  String get spaceOpenSettings => 'Paramètres de l’espace…';

  @override
  String get spaceDelete => 'Supprimer l’espace…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'Supprimer l’espace $space ? Ses salons passent au premier niveau.';
  }

  @override
  String get workspaceMoveUp => 'Monter';

  @override
  String get workspaceMoveDown => 'Descendre';

  @override
  String get workspaceCannotReorder => 'Impossible de réorganiser.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbit/s';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbit/s (voix)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbit/s (musique)';
  }

  @override
  String get createNewChannel => 'Nouveau salon';

  @override
  String get createNewSpace => 'Nouvel espace';

  @override
  String get createSubmit => 'Créer';

  @override
  String get createChannel => 'Salon';

  @override
  String get createSpace => 'Espace';

  @override
  String get createChannelHint =>
      'Un salon vocal que l’on rejoint, avec son propre chat.';

  @override
  String get createSpaceHint =>
      'Un dossier qui regroupe des salons dans la barre latérale.';

  @override
  String get createChannelPlaceholder => 'Équipe bleue';

  @override
  String get channelSettingsTitle => 'Réglages du salon';

  @override
  String get channelSettingsOwnerHint =>
      'Le propriétaire gère ce salon. Seuls les admins choisissent qui en est propriétaire.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return 'Supprimer $name ? Toutes les personnes présentes seront déconnectées.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'Personnes et son';

  @override
  String get channelSettingsMaxPeople => 'Personnes max.';

  @override
  String get channelSettingsNoLimit => 'Sans limite';

  @override
  String get channelSettingsAudioQuality => 'Qualité audio';

  @override
  String get channelSettingsStereo => 'Stéréo';

  @override
  String get channelSettingsDelete => 'Supprimer le salon…';

  @override
  String get manageSpace => 'Espace';

  @override
  String get manageOwner => 'Propriétaire';

  @override
  String get manageAccess => 'Accès';

  @override
  String get spaceSettingsTitle => 'Réglages de l’espace';

  @override
  String get spaceSettingsOwnerHint =>
      'Le propriétaire gère l’espace et tous ses salons. Seuls les admins choisissent qui en est propriétaire.';

  @override
  String get accessAccountsOnly => 'Comptes uniquement';

  @override
  String get accessAccountsOnlyDetail => 'Pas d’invités';

  @override
  String get accessWhitelistOnly => 'Liste d’accès uniquement';

  @override
  String get accessHidden => 'Masqué';

  @override
  String get accessHiddenDetail => 'Invisible pour qui ne peut pas entrer';

  @override
  String get accessFromSpace => 'Défini par l’espace';

  @override
  String summonsTitle(String channel) {
    return 'Appeler dans $channel';
  }

  @override
  String get summonsSummon => 'Appeler';

  @override
  String get summonsNickname => 'Pseudo';

  @override
  String get summonsNoMatch => 'Personne de correspondant ne peut venir ici.';

  @override
  String get summonsHint =>
      'La personne reçoit une notification indiquant que vous l’attendez. Une fois toutes les 5 minutes par personne.';

  @override
  String get summonsSearchFailed => 'Recherche impossible.';

  @override
  String get manageDeviceKey => 'Clé de l’appareil';

  @override
  String manageDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get manageDelete => 'Supprimer';

  @override
  String get manageSave => 'Enregistrer';

  @override
  String get manageName => 'Nom';

  @override
  String get manageNone => 'Aucun';

  @override
  String get manageNobody => 'Personne';

  @override
  String get manageSomeoneElse => 'Quelqu’un d’autre';

  @override
  String get manageWhitelistInWeb =>
      'Pour l’instant, modifiez la liste d’accès dans le client web.';

  @override
  String get channelSettingsLimitHint =>
      'Quand le salon est plein, seules les personnes qui le gèrent peuvent encore entrer. De 1 à 99 personnes, ou sans limite.';

  @override
  String get spaceSettingsAccessHint =>
      'Ces limites s’appliquent à tous les salons de l’espace ; un salon peut seulement en ajouter. Pour l’instant, modifiez la liste d’accès dans le client web.';

  @override
  String get accessWhitelistOnlyListDetail =>
      'Seulement les personnes et rôles de sa liste';

  @override
  String get summonsWho => 'Qui ?';

  @override
  String get settingsPictures => 'Images';

  @override
  String get profileAddPicture => 'Ajouter une photo…';

  @override
  String get profileChangePicture => 'Changer de photo…';

  @override
  String get profileRemovePicture => 'Supprimer la photo';

  @override
  String get profileUploadFailed => 'Impossible d’envoyer la photo.';

  @override
  String get profileRemoveFailed => 'Impossible de supprimer la photo.';

  @override
  String get saveFailed => 'Impossible d’enregistrer.';

  @override
  String get settingsAudioVideo => 'Audio et vidéo';

  @override
  String get settingsMicrophone => 'Micro';

  @override
  String get settingsCamera => 'Caméra';

  @override
  String get settingsOutput => 'Sortie';

  @override
  String get settingsVoiceProcessing => 'Traitement de la voix';

  @override
  String get settingsVoiceProcessingDetail =>
      'Réduction du bruit et annulation d’écho';

  @override
  String get settingsVoiceProcessingHint =>
      'Désactivez-le pour un meilleur son, et portez alors un casque : sans annulation d’écho, les autres s’entendent dans vos haut-parleurs.';

  @override
  String get settingsCues => 'Sons d’arrivée et de départ';

  @override
  String get settingsCuesDetail =>
      'Une chouette hulule quand quelqu’un arrive ou part, et les raccourcis font un clic';

  @override
  String get settingsPingAndLoss => 'Afficher le ping et la perte';

  @override
  String get settingsPingAndLossDetail =>
      'À côté de l’icône de connexion pendant un appel';

  @override
  String get summonsHeader => 'Appels vers un salon';

  @override
  String get summonsAllow => 'Les autres peuvent m’appeler';

  @override
  String get settingsNotificationsHere => 'Notifications sur cet appareil';

  @override
  String get settingsNotificationsHint =>
      'Affichées quand Wisetalk est en arrière-plan.';

  @override
  String get settingsNotifyMessages => 'Nouveaux messages';

  @override
  String get settingsNotifyMessagesDetail =>
      'Dans le chat de votre appel et les chats que vous avez ouverts';

  @override
  String get settingsNotifySummons => 'Appels vers un salon';

  @override
  String get settingsNotifySummonsDetail =>
      'Quand quelqu’un vous appelle dans un salon';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsCrashReports => 'Envoyer les rapports de plantage';

  @override
  String get settingsCrashReportsHint =>
      'Quand quelque chose plante dans Wisetalk, ses développeurs apprennent ce qui a planté et où dans le code. Jamais vos messages, noms, clés ni serveurs.';

  @override
  String get settingsShortcuts => 'Raccourcis';

  @override
  String get settingsShortcutsRecording =>
      'Appuyez sur les nouvelles touches. Backspace supprime le raccourci, Esc le garde.';

  @override
  String get settingsShortcutsGlobal =>
      'Pendant un appel, ils marchent quelle que soit l’app au premier plan ; sinon, dans la fenêtre de Wisetalk. Cliquez sur l’un d’eux pour le changer.';

  @override
  String get settingsShortcutsWayland =>
      'Sous Wayland, ils ne marchent que si la fenêtre de Wisetalk est au premier plan. Cliquez sur l’un d’eux pour le changer.';

  @override
  String get settingsShortcutPressKeys => 'Appuyez sur des touches…';

  @override
  String get settingsShortcutNone => 'Aucun';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys sert déjà à « $action ».';
  }

  @override
  String get shortcutToggleMute => 'Activer ou couper le micro';

  @override
  String get shortcutToggleAway => 'Absent ou de retour';

  @override
  String get shortcutMute => 'Couper le micro';

  @override
  String get shortcutUnmute => 'Activer le micro';

  @override
  String get shortcutUnusableKey =>
      'Cette touche ne peut pas servir de raccourci.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Ajoutez $first ou $second, ou utilisez F1 à F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys appartient au système ou à toutes les apps.';
  }

  @override
  String get sheetDiscardTitle => 'Abandonner les modifications ?';

  @override
  String get sheetDiscardMessage =>
      'Ce que vous avez modifié ici n’est pas encore enregistré.';

  @override
  String get sheetDiscard => 'Abandonner';

  @override
  String get sheetKeepEditing => 'Continuer';

  @override
  String serversRemoveTitle(String server) {
    return 'Retirer $server ?';
  }

  @override
  String get serversRemoveMessage =>
      'Cet appareil s’en déconnecte et l’oublie. Vous pourrez l’ajouter à nouveau avec son adresse.';

  @override
  String get serversRemove => 'Retirer';

  @override
  String get serversAddressHelp =>
      'Demandez son adresse à qui gère votre communauté.';

  @override
  String get serversConnecting => 'Connexion…';

  @override
  String get serversConnect => 'Se connecter';

  @override
  String get serversWhich => 'Sur quel serveur est votre communauté ?';

  @override
  String get serversYours => 'Vos serveurs';

  @override
  String get serversAddMenu => 'Ajouter un serveur…';

  @override
  String get serversAddTitle => 'Ajouter un serveur';

  @override
  String get serversBadAddress =>
      'Saisissez l’adresse d’un serveur, comme talk.example.com.';

  @override
  String get serversTooNew =>
      'Ce serveur est plus récent que cette app. Mettez Wisetalk à jour pour le rejoindre.';

  @override
  String get serversTooOld =>
      'Ce serveur utilise une ancienne version de Wisetalk. Demandez à ses admins de le mettre à jour.';

  @override
  String serversTooOldVersion(String version) {
    return 'Ce serveur utilise une ancienne version de Wisetalk ($version). Demandez à ses admins de le mettre à jour.';
  }

  @override
  String get serversAddress => 'Adresse';

  @override
  String get serversMore => 'Plus';

  @override
  String get serversRemoveServer => 'Retirer le serveur';

  @override
  String get channelSomeChannel => 'un salon';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name dans $channel';
  }

  @override
  String get workspaceMessageEncrypted => 'A écrit un message chiffré.';

  @override
  String get workspaceMessagePicture => 'A envoyé une image.';

  @override
  String summonPushed(String name) {
    return '$name a reçu une notification.';
  }

  @override
  String get summonPushedSomeone => 'Notification envoyée.';

  @override
  String summonNotPushed(String name) {
    return 'Appel envoyé à $name. Ses notifications sont désactivées : seul un Wisetalk ouvert l’affichera.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Appel envoyé. Les notifications de cette personne sont désactivées : seul un Wisetalk ouvert l’affichera.';

  @override
  String summonReceived(String from, String channel) {
    return '$from vous appelle dans $channel.';
  }

  @override
  String get workspaceSummoned => 'On vous appelle';

  @override
  String get workspaceRoleChangedOwner =>
      'Votre rôle sur le serveur est désormais : propriétaire.';

  @override
  String get workspaceRoleChangedAdmin =>
      'Votre rôle sur le serveur est désormais : admin.';

  @override
  String get workspaceRoleChangedModerator =>
      'Votre rôle sur le serveur est désormais : modérateur.';

  @override
  String get workspaceRoleChangedMember =>
      'Votre rôle sur le serveur est désormais : membre.';

  @override
  String get workspaceRoleChangedGuest =>
      'Votre rôle sur le serveur est désormais : invité.';

  @override
  String get takeOverTitle => 'Rejoindre depuis cet appareil ?';

  @override
  String takeOverSameChannel(String channel) {
    return 'Vous êtes déjà dans $channel sur un autre appareil ou onglet. Rejoindre $channel ici vous fera quitter l’appel là-bas.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'Vous êtes dans $there sur un autre appareil ou onglet. Rejoindre $here ici vous fera quitter l’appel là-bas.';
  }

  @override
  String get takeOverElsewhere =>
      'Vous êtes en appel sur un autre appareil ou onglet. Rejoindre ici vous fera quitter l’appel là-bas.';

  @override
  String get takeOverJoinHere => 'Rejoindre ici';

  @override
  String get workspaceShowChannels => 'Afficher les salons';

  @override
  String get workspaceHideChannels => 'Masquer les salons';

  @override
  String workspaceInVoice(int count) {
    return '$count en vocal';
  }

  @override
  String get workspaceCreateTitle => 'Nouveau salon ou espace';

  @override
  String get workspaceStatusConnecting => 'Connexion…';

  @override
  String get workspaceStatusOffline => 'Hors ligne…';

  @override
  String get workspaceEmptyAdmin =>
      'Aucun salon pour l’instant. Créez-en un avec le bouton +.';

  @override
  String get workspaceEmpty =>
      'Aucun salon pour l’instant. Un admin peut en ajouter.';

  @override
  String get workspaceMore => 'Plus';

  @override
  String get workspaceCheckForUpdates => 'Rechercher des mises à jour';

  @override
  String get workspaceChangeServer => 'Changer de serveur';

  @override
  String get workspaceSignOut => 'Se déconnecter';

  @override
  String get personMutedForYou => 'Coupé pour vous';

  @override
  String get awayTitle => 'Absent';

  @override
  String get awayDescription => 'Absent : micro et son coupés';

  @override
  String get callMutedByModerator => 'Micro coupé par un modérateur';

  @override
  String workspaceDrag(String name) {
    return 'Déplacer $name';
  }

  @override
  String get workspaceDropEndHint => 'Déposez ici pour placer en fin de liste';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version est téléchargé';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Wisetalk $version est disponible';
  }

  @override
  String get workspaceRestartToUpdate => 'Redémarrer pour mettre à jour';

  @override
  String workspaceUpdateTo(String version) {
    return 'Mettre à jour vers $version';
  }

  @override
  String get workspaceWelcomeTitle => 'Choisissez un salon vocal';

  @override
  String get workspaceWelcomeHint => 'Cliquez sur un salon pour le rejoindre.';

  @override
  String get callJoining => 'Connexion au salon…';

  @override
  String get callWaitingForKey => 'En attente de la clé d’appel…';

  @override
  String get callEncrypted => 'Chiffré de bout en bout';

  @override
  String videoScreen(String name) {
    return '$name · écran';
  }

  @override
  String get connectionExcellent => 'excellente';

  @override
  String get connectionGood => 'bonne';

  @override
  String get connectionPoor => 'faible';

  @override
  String get connectionLost => 'perdue';

  @override
  String get connectionChecking => 'vérification…';

  @override
  String connectionStatus(String quality) {
    return 'Connexion : $quality';
  }

  @override
  String get connectionLabel => 'Connexion';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · $loss de perte';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping, perte $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => 'Perte sortante';

  @override
  String get connectionIncomingLoss => 'Perte entrante';

  @override
  String get connectionJitter => 'Gigue';

  @override
  String get connectionMicrophone => 'Micro';

  @override
  String get connectionNotSending => 'Aucun envoi';

  @override
  String connectionKilobits(int value) {
    return '$value kbit/s';
  }

  @override
  String get screenShareTitle => 'Partager votre écran';

  @override
  String get screenShareAction => 'Partager';

  @override
  String get screenShareBestFor => 'Idéal pour';

  @override
  String get screenShareAndroidHint =>
      'Android vous demande ensuite de partager l’écran entier ou une seule application. Sans le son, pour l’instant.';

  @override
  String get screenShareWaylandHint =>
      'La première fois, votre système demande quel écran partager. Les partages suivants réutilisent cet écran jusqu’au redémarrage de Wisetalk. Écrans entiers uniquement et sans le son, pour l’instant.';

  @override
  String get screenShareText => 'Texte et diapositives';

  @override
  String get screenShareTextDetail =>
      'Net et léger : quelques images par seconde.';

  @override
  String get screenShareMotion => 'Vidéos et jeux';

  @override
  String get screenShareMotionDetail =>
      'Fluide : 30 images par seconde, plus lourd des deux côtés.';

  @override
  String get screenShareSource => 'Écran ou fenêtre';

  @override
  String get screenShareSound => 'Partager le son';

  @override
  String get screenShareSoundWindow =>
      'Uniquement l’application de cette fenêtre.';

  @override
  String get screenShareSoundScreen =>
      'Tout ce que vous entendez, sans l’appel.';

  @override
  String get screenShareSoundAny =>
      'L’application d’une fenêtre ou, pour un écran, tout ce que vous entendez, sans l’appel.';

  @override
  String get screenShareListFailed =>
      'Impossible de lister les écrans et les fenêtres.';

  @override
  String get screenShareChooseTitle => 'Choisissez un écran';

  @override
  String get screenShareChooseHint =>
      'Choisissez l’écran à partager dans la fenêtre de votre système.';

  @override
  String get problemNotSignedIn => 'Vous devez vous connecter.';

  @override
  String get problemAccountRequired => 'Connectez-vous d’abord avec un compte.';

  @override
  String get problemAccountBanned => 'Ce compte est banni.';

  @override
  String get problemSignInCodeInvalid =>
      'Ce code de connexion n’est plus valide. Reconnectez-vous.';

  @override
  String get problemBrowserCheckMissing =>
      'La vérification du navigateur manque. Rechargez la page et réessayez.';

  @override
  String get problemBrowserCheckFailed =>
      'La vérification du navigateur a échoué. Rechargez la page et réessayez.';

  @override
  String get problemBrowserCheckExpired =>
      'La vérification du navigateur a expiré. Réessayez.';

  @override
  String get problemGuestSignInClosed =>
      'La connexion invité est fermée pour le moment. Connectez-vous avec un compte.';

  @override
  String get problemGuestAddressBlocked =>
      'Les invités de cette adresse sont bloqués pour un moment.';

  @override
  String get problemTooManyGuests =>
      'Trop d’invités en ce moment. Réessayez plus tard ou connectez-vous avec un compte.';

  @override
  String get problemTooManyGuestSignIns =>
      'Trop de connexions invité depuis cette adresse. Réessayez plus tard.';

  @override
  String get problemNameBelongsToAccount => 'Ce nom appartient à un compte.';

  @override
  String get problemAccountsCantBeGuests =>
      'Un compte ne peut pas se connecter en tant qu’invité.';

  @override
  String get problemNoSuchAccount => 'Ce compte n’existe pas.';

  @override
  String get problemNoSuchChannel => 'Ce salon n’existe plus.';

  @override
  String get problemNoSuchSpace => 'Cet espace n’existe plus.';

  @override
  String get problemNoSuchEmoji => 'Cet emoji n’existe pas.';

  @override
  String get problemNoSuchGuest => 'Cet invité n’est plus en ligne.';

  @override
  String get problemNoSuchPicture => 'Cette image n’existe plus.';

  @override
  String get problemNoSuchMessage => 'Ce message n’existe plus.';

  @override
  String get problemNoAvatar => 'Il n’y a pas d’avatar.';

  @override
  String get problemNotBanned => 'Ce compte n’est pas banni.';

  @override
  String get problemDisplayNameLength => 'Un nom fait de 1 à 32 caractères.';

  @override
  String get problemChannelNameLength =>
      'Un nom de salon fait de 1 à 64 caractères.';

  @override
  String get problemSpaceNameLength =>
      'Un nom d’espace fait de 1 à 64 caractères.';

  @override
  String get problemEmojiNameInvalid =>
      'Un nom d’emoji fait de 2 à 32 caractères parmi a–z, 0–9 et _.';

  @override
  String get problemIconInvalid =>
      'Une icône est un seul emoji ou un :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Les noms font jusqu’à 40 caractères, le slogan jusqu’à 120, sans caractères de contrôle.';

  @override
  String get problemChannelLimitInvalid =>
      'Un salon accueille de 1 à 99 personnes, ou n’a pas de limite.';

  @override
  String get problemBitrateInvalid =>
      'Le débit audio doit être compris entre 6 et 510 kbit/s.';

  @override
  String get problemPictureType =>
      'L’image doit être au format PNG, JPEG ou WebP.';

  @override
  String get problemAvatarTooLarge => 'L’image dépasse 256 Ko.';

  @override
  String get problemEmojiTooLarge => 'L’image dépasse 128 Ko.';

  @override
  String get problemChatPictureTooLarge =>
      'Une image peut faire jusqu’à 20 Mo.';

  @override
  String get problemPictureIdTaken => 'Cette image est déjà là.';

  @override
  String get problemChatFullOfPictures =>
      'Ce chat contient trop d’images. Attendez qu’il se vide.';

  @override
  String get problemTooManyPictures =>
      'Ça fait beaucoup d’images. Patientez un peu.';

  @override
  String get problemManageNotPerRole =>
      'La gestion ne peut pas être accordée par rôle.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'Les propriétaires et les admins ont toujours toutes les autorisations.';

  @override
  String get problemOneOverridePerRole => 'Une seule règle par rôle.';

  @override
  String get problemWhitelistUnknownAccount =>
      'La liste d’accès contient un compte qui n’existe pas.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Les invités ne passent jamais une liste d’accès.';

  @override
  String get problemPushSubscriptionInvalid =>
      'Le navigateur a envoyé un abonnement aux notifications invalide.';

  @override
  String get problemPushEndpointNotPublic =>
      'L’adresse des notifications doit être une adresse HTTPS publique.';

  @override
  String get problemNotAllowedInChannel =>
      'Vous ne pouvez pas faire cela dans ce salon.';

  @override
  String get problemMayNotEnter => 'Vous ne pouvez pas entrer dans ce salon.';

  @override
  String get problemTheyMayNotEnter =>
      'Cette personne ne peut pas entrer dans ce salon.';

  @override
  String get problemMayNotModerate => 'Vous ne pouvez pas modérer ce salon.';

  @override
  String get problemCantModerateYourself =>
      'Vous ne pouvez pas vous modérer vous-même.';

  @override
  String get problemModerateRank =>
      'Vous ne pouvez pas modérer quelqu’un de votre rang ou au-dessus.';

  @override
  String get problemBanRank =>
      'Vous ne pouvez pas bannir quelqu’un de votre rang ou au-dessus.';

  @override
  String get problemRoleRank =>
      'Vous ne pouvez donner que des rôles inférieurs au vôtre, et seulement aux personnes en dessous de vous.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Seuls les propriétaires et admins du serveur gèrent le serveur.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Seuls les propriétaires et admins du serveur gèrent les bannissements.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Seuls les propriétaires et admins du serveur gèrent les emoji personnalisés.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Seuls les propriétaires et admins du serveur gèrent les espaces.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Seuls les propriétaires et admins du serveur choisissent les propriétaires des salons.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Seuls les propriétaires et admins du serveur choisissent les propriétaires des espaces.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Seuls les admins et le propriétaire de l’espace peuvent le gérer.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Seuls les admins, et les propriétaires d’espace dans leur espace, peuvent créer des salons.';

  @override
  String get problemMoveIntoOwnSpace =>
      'Vous ne pouvez déplacer des salons que dans un espace que vous gérez.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Seules les personnes qui peuvent modérer le salon envoient des invitations.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Les invités ne peuvent pas créer de salons.';

  @override
  String get problemGuestsCantInvite => 'Les invités ne peuvent pas inviter.';

  @override
  String get problemGuestsCantBan => 'Les invités ne peuvent pas bannir.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Les invités ne peuvent pas recevoir de notifications.';

  @override
  String get problemGuestsHaveNoAvatar => 'Les invités n’ont pas d’avatar.';

  @override
  String get problemNotYourDevice => 'Ce n’est pas votre appareil.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'Cet appareil appartient à un autre compte.';

  @override
  String get problemOwnMessagesOnly =>
      'Vous ne pouvez supprimer que vos propres messages.';

  @override
  String get problemChannelFull => 'Ce salon est plein.';

  @override
  String get problemInviteUsed => 'Cette invitation a déjà servi ou a expiré.';

  @override
  String get problemTooManyInvites =>
      'Trop d’invitations inutilisées. Attendez que certaines expirent.';

  @override
  String get problemJoinChannelFirst => 'Rejoignez d’abord le salon.';

  @override
  String get problemNotInVoice => 'Vous n’êtes pas dans un salon vocal.';

  @override
  String get problemNotInThatChannel => 'Vous n’êtes pas dans ce salon.';

  @override
  String get problemPersonNotInYourChannel =>
      'Cette personne n’est pas dans votre salon.';

  @override
  String get problemDeviceNotInChannel =>
      'Cet appareil n’est pas dans le salon.';

  @override
  String get problemDeviceNotOnline =>
      'Cet appareil n’est pas en ligne ou ne peut pas entrer.';

  @override
  String get problemVoiceNotConfigured =>
      'La voix n’est pas configurée sur ce serveur.';

  @override
  String get problemSummonNeedsAccount =>
      'Connectez-vous avec un compte pour appeler quelqu’un.';

  @override
  String get problemCantSummonYourself =>
      'Vous ne pouvez pas vous appeler vous-même.';

  @override
  String get problemAlreadyHere => 'Cette personne est déjà là.';

  @override
  String get problemSummonsOff => 'Cette personne a désactivé les appels.';

  @override
  String get problemSummonedRecently =>
      'Vous avez appelé cette personne il y a moins de 5 minutes.';

  @override
  String get problemMessageLength => 'Un message fait de 1 à 2000 caractères.';

  @override
  String get problemUploadPictureFirst => 'L’image n’a pas été envoyée.';

  @override
  String get problemPictureNotAccepted => 'Ce chat n’accepte pas cette image.';

  @override
  String get problemChatHasNoKey => 'Ce chat n’a pas encore de clé.';

  @override
  String get problemNobodyHasChatKey =>
      'Personne en ligne n’a la clé de ce chat.';

  @override
  String get problemNotCurrentChatKey =>
      'Ce n’est pas la clé actuelle du chat.';

  @override
  String get problemChatKeyChanged => 'La clé du chat a changé. Réessayez.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'Les clés ont été scellées pour une autre clé de chat.';

  @override
  String get problemSealForYourself => 'Scellez aussi la clé pour vous-même.';

  @override
  String get problemSealDeviceCount =>
      'Une clé est scellée pour 1 à 1000 appareils.';

  @override
  String get problemNoLongerAllowed => 'Vous n’avez plus accès à ce salon.';

  @override
  String get problemJoinedElsewhere =>
      'Vous avez rejoint depuis un autre appareil.';

  @override
  String problemKickedBy(String by) {
    return '$by vous a fait sortir du salon.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by vous a fait sortir. Les invités de votre adresse sont bloqués pendant un jour.';
  }

  @override
  String get problemBannedFromServer => 'Votre compte est banni de ce serveur.';

  @override
  String get problemGuestSignInClosedByAdmin =>
      'Un admin a fermé la connexion invité.';

  @override
  String get problemHelloFirst =>
      'La connexion n’était pas prête. Rechargez la page.';

  @override
  String get problemUnreadableCommand =>
      'Le serveur n’a pas compris la demande. Rechargez la page.';

  @override
  String get problemUnsupportedProtocol =>
      'Cette version de Wisetalk est trop ancienne pour le serveur. Rechargez la page.';

  @override
  String get problemSlowDown => 'Ralentissez un peu.';

  @override
  String get problemTooManyCommands =>
      'Trop d’actions à la fois. Ralentissez un peu.';

  @override
  String get problemGone => 'Ça n’existe plus.';

  @override
  String get problemInternal => 'Un problème est survenu sur le serveur.';

  @override
  String get problemTooLarge => 'C’est trop volumineux pour être envoyé.';

  @override
  String get problemUnavailable =>
      'Le serveur ne répond pas. Réessayez dans une minute.';
}
