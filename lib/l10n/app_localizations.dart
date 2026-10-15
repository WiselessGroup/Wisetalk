import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Under the logo when the server set no tagline of its own.
  ///
  /// In en, this message translates to:
  /// **'Voice and video chat for your community'**
  String get brandingTagline;

  /// No description provided for @brandingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get brandingSignIn;

  /// The account button when the server named its identity provider.
  ///
  /// In en, this message translates to:
  /// **'Sign In with {provider}'**
  String brandingSignInWith(String provider);

  /// No description provided for @brandingHostedBy.
  ///
  /// In en, this message translates to:
  /// **'Hosted by {community}.'**
  String brandingHostedBy(String community);

  /// Back to the list of servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get signInServers;

  /// No description provided for @signInUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server.'**
  String get signInUnreachable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// While the browser is open for signing in with an account.
  ///
  /// In en, this message translates to:
  /// **'Continue in Your Browser…'**
  String get signInInBrowser;

  /// No description provided for @signInAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Your name, avatar and summons follow you everywhere.'**
  String get signInAccountHelp;

  /// Between signing in with an account and joining as a guest.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// No description provided for @signInGuest.
  ///
  /// In en, this message translates to:
  /// **'Join as a guest'**
  String get signInGuest;

  /// No description provided for @signInGuestName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get signInGuestName;

  /// No description provided for @signInGuestHelp.
  ///
  /// In en, this message translates to:
  /// **'Guests can talk and listen, but not share video or be summoned.'**
  String get signInGuestHelp;

  /// No description provided for @signInJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get signInJoining;

  /// No description provided for @signInAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get signInAsGuest;

  /// No description provided for @signInNobody.
  ///
  /// In en, this message translates to:
  /// **'This server lets nobody in right now.'**
  String get signInNobody;

  /// No description provided for @signInGuestsClosed.
  ///
  /// In en, this message translates to:
  /// **'Guest sign-in is closed for now.'**
  String get signInGuestsClosed;

  /// No description provided for @signInEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Calls are end-to-end encrypted.'**
  String get signInEncrypted;

  /// No description provided for @signInNameLength.
  ///
  /// In en, this message translates to:
  /// **'A name is 1 to 32 characters.'**
  String get signInNameLength;

  /// No description provided for @callMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get callMute;

  /// No description provided for @callUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get callUnmute;

  /// No description provided for @callCameraOn.
  ///
  /// In en, this message translates to:
  /// **'Turn Camera On'**
  String get callCameraOn;

  /// No description provided for @callCameraOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Camera Off'**
  String get callCameraOff;

  /// No description provided for @callShareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share Screen'**
  String get callShareScreen;

  /// No description provided for @callStopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get callStopSharing;

  /// No description provided for @callLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get callLeave;

  /// Android: the name of the ongoing call notification's channel in the system settings.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get callServiceChannel;

  /// Android: the ongoing call notification, under the channel name.
  ///
  /// In en, this message translates to:
  /// **'In a voice call'**
  String get callServiceInCall;

  /// Android: the ongoing call notification while sharing the screen.
  ///
  /// In en, this message translates to:
  /// **'Sharing your screen'**
  String get callServiceSharing;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemDefault;

  /// No description provided for @settingsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get settingsDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
