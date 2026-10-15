// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get brandingTagline => 'Voice and video chat for your community';

  @override
  String get brandingSignIn => 'Sign In';

  @override
  String brandingSignInWith(String provider) {
    return 'Sign In with $provider';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Hosted by $community.';
  }

  @override
  String get signInServers => 'Servers';

  @override
  String get signInUnreachable => 'Can\'t reach the server.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get signInInBrowser => 'Continue in Your Browser…';

  @override
  String get signInAccountHelp =>
      'Your name, avatar and summons follow you everywhere.';

  @override
  String get signInOr => 'or';

  @override
  String get signInGuest => 'Join as a guest';

  @override
  String get signInGuestName => 'Your name';

  @override
  String get signInGuestHelp =>
      'Guests can talk and listen, but not share video or be summoned.';

  @override
  String get signInJoining => 'Joining…';

  @override
  String get signInAsGuest => 'Continue as Guest';

  @override
  String get signInNobody => 'This server lets nobody in right now.';

  @override
  String get signInGuestsClosed => 'Guest sign-in is closed for now.';

  @override
  String get signInEncrypted => 'Calls are end-to-end encrypted.';

  @override
  String get signInNameLength => 'A name is 1 to 32 characters.';

  @override
  String get callMute => 'Mute';

  @override
  String get callUnmute => 'Unmute';

  @override
  String get callCameraOn => 'Turn Camera On';

  @override
  String get callCameraOff => 'Turn Camera Off';

  @override
  String get callShareScreen => 'Share Screen';

  @override
  String get callStopSharing => 'Stop Sharing';

  @override
  String get callLeave => 'Leave';

  @override
  String get callServiceChannel => 'Calls';

  @override
  String get callServiceInCall => 'In a voice call';

  @override
  String get callServiceSharing => 'Sharing your screen';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSystemDefault => 'System Default';

  @override
  String get settingsDone => 'Done';
}
