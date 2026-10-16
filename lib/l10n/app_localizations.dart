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
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Under the chat title while the chat is empty.
  ///
  /// In en, this message translates to:
  /// **'Messages vanish 4 h after the last one'**
  String get chatVanishes;

  /// Under the chat title: when the chat clears itself.
  ///
  /// In en, this message translates to:
  /// **'Clears in {hours} h {minutes} min unless someone writes'**
  String chatClearsInHours(int hours, int minutes);

  /// Under the chat title: when the chat clears itself.
  ///
  /// In en, this message translates to:
  /// **'Clears in {minutes} min unless someone writes'**
  String chatClearsInMinutes(int minutes);

  /// No description provided for @chatClose.
  ///
  /// In en, this message translates to:
  /// **'Close Chat'**
  String get chatClose;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hi!'**
  String get chatEmpty;

  /// While the chat history loads.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get chatLoading;

  /// No description provided for @chatGettingKey.
  ///
  /// In en, this message translates to:
  /// **'Getting the chat key…'**
  String get chatGettingKey;

  /// No description provided for @chatSendingPicture.
  ///
  /// In en, this message translates to:
  /// **'Sending the picture…'**
  String get chatSendingPicture;

  /// No description provided for @chatPreparingPicture.
  ///
  /// In en, this message translates to:
  /// **'Preparing the picture…'**
  String get chatPreparingPicture;

  /// No description provided for @chatAddPicture.
  ///
  /// In en, this message translates to:
  /// **'Add Picture'**
  String get chatAddPicture;

  /// Hint in the chat composer.
  ///
  /// In en, this message translates to:
  /// **'Message {channel}'**
  String chatMessageTo(String channel);

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// In place of a message this device cannot decrypt.
  ///
  /// In en, this message translates to:
  /// **'Encrypted with a key this device doesn\'t have: sent before it joined the chat.'**
  String get chatLocked;

  /// Next to the name of a guest who wrote a message.
  ///
  /// In en, this message translates to:
  /// **'guest'**
  String get chatGuest;

  /// No description provided for @chatDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get chatDeleteMessage;

  /// The file type filter in the dialog for picking a picture to send.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get chatPictures;

  /// No description provided for @chatInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'A message is 1 to 2000 characters, without control characters.'**
  String get chatInvalidMessage;

  /// The reason is the server's message.
  ///
  /// In en, this message translates to:
  /// **'The picture didn\'t go out: {reason}'**
  String chatPictureNotSent(String reason);

  /// In place of a chat picture that did not load.
  ///
  /// In en, this message translates to:
  /// **'Picture didn\'t load'**
  String get pictureFailed;

  /// No description provided for @pictureTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This picture is too large.'**
  String get pictureTooLarge;

  /// No description provided for @pictureUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This picture can\'t be read.'**
  String get pictureUnreadable;

  /// Toast: someone I met before is in my call from a device I have not seen.
  ///
  /// In en, this message translates to:
  /// **'{name} joined from a new device.'**
  String trustNewDevice(String name);

  /// Toast: devices added to my own account since I last looked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{A new device signed in to your account.} other{{count} new devices signed in to your account.}}'**
  String trustMineAdded(int count);

  /// No description provided for @trustMineChanged.
  ///
  /// In en, this message translates to:
  /// **'Careful: a device of your account came with another key.'**
  String get trustMineChanged;

  /// Tooltip of the key mark next to someone in my call whose device key changed.
  ///
  /// In en, this message translates to:
  /// **'Careful: their device key has changed.'**
  String get personKeyChanged;

  /// Linux: the action of a system notification, which opens what it is about.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get notificationOpen;

  /// Android: the name of the notification channel in the system settings.
  ///
  /// In en, this message translates to:
  /// **'Messages and summons'**
  String get notificationChannel;

  /// System notification title: someone summons me into their channel.
  ///
  /// In en, this message translates to:
  /// **'{caller} is calling you'**
  String notificationSummonTitle(String caller);

  /// System notification text under notificationSummonTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {channel}'**
  String notificationSummonBody(String channel);

  /// No description provided for @signInErrorRefused.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get signInErrorRefused;

  /// No description provided for @signInErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'Sign-in took too long. Try again.'**
  String get signInErrorExpired;

  /// No description provided for @signInErrorBanned.
  ///
  /// In en, this message translates to:
  /// **'This account is banned on this server.'**
  String get signInErrorBanned;

  /// No description provided for @signInErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account sign-in is not available right now.'**
  String get signInErrorUnavailable;

  /// No description provided for @signInErrorFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Try again.'**
  String get signInErrorFailed;

  /// No description provided for @signInNoBrowser.
  ///
  /// In en, this message translates to:
  /// **'Can\'t open the browser to sign in.'**
  String get signInNoBrowser;

  /// The page the browser shows after signing in for the app.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in. You can close this tab and go back to Wisetalk.'**
  String get signInBrowserDone;

  /// The page the browser shows when signing in for the app failed.
  ///
  /// In en, this message translates to:
  /// **'Signing in did not work. Go back to Wisetalk to try again.'**
  String get signInBrowserFailed;

  /// No description provided for @updatesNotSelfUpdating.
  ///
  /// In en, this message translates to:
  /// **'This build of Wisetalk doesn’t update itself.'**
  String get updatesNotSelfUpdating;

  /// No description provided for @updatesCannotCheck.
  ///
  /// In en, this message translates to:
  /// **'Cannot check for updates. Try again later.'**
  String get updatesCannotCheck;

  /// After Check for Updates: a new version is downloaded; Restart to Update is the button that applies it.
  ///
  /// In en, this message translates to:
  /// **'Wisetalk {version} is ready: Restart to Update.'**
  String updatesReady(String version);

  /// After Check for Updates: a newer version the browser downloads; Update to … is the button for it.
  ///
  /// In en, this message translates to:
  /// **'Wisetalk {version} is out: Update to {version}.'**
  String updatesAvailable(String version);

  /// After Check for Updates: nothing newer.
  ///
  /// In en, this message translates to:
  /// **'Wisetalk {version} is the latest.'**
  String updatesLatest(String version);

  /// No description provided for @voiceMutedByModerator.
  ///
  /// In en, this message translates to:
  /// **'A moderator muted you; only they can lift it.'**
  String get voiceMutedByModerator;

  /// No description provided for @voiceCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable.'**
  String get voiceCameraUnavailable;

  /// No description provided for @voiceCannotSwitchCamera.
  ///
  /// In en, this message translates to:
  /// **'Cannot switch to that camera.'**
  String get voiceCannotSwitchCamera;

  /// No description provided for @voiceScreenUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Screen sharing unavailable.'**
  String get voiceScreenUnavailable;

  /// No description provided for @voiceServerMuted.
  ///
  /// In en, this message translates to:
  /// **'A moderator muted you.'**
  String get voiceServerMuted;

  /// No description provided for @voiceServerUnmuted.
  ///
  /// In en, this message translates to:
  /// **'A moderator lifted your mute. Unmute when you are ready.'**
  String get voiceServerUnmuted;

  /// The reason is the server's message.
  ///
  /// In en, this message translates to:
  /// **'You left the channel: {reason}.'**
  String voiceKicked(String reason);

  /// No description provided for @voiceCannotConnect.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to voice.'**
  String get voiceCannotConnect;

  /// No description provided for @voiceMicrophoneUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable: you can listen, but not speak.'**
  String get voiceMicrophoneUnavailable;

  /// The name on my own video tile.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get videoYou;

  /// Ping or jitter in milliseconds.
  ///
  /// In en, this message translates to:
  /// **'{value} ms'**
  String connectionMilliseconds(int value);

  /// No description provided for @connectionSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You were signed out.'**
  String get connectionSignedOut;

  /// No description provided for @apiUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server.'**
  String get apiUnreachable;

  /// No description provided for @apiUnreachableCheck.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check the address and your connection.'**
  String get apiUnreachableCheck;

  /// No description provided for @apiNotWisetalk.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a Wisetalk server.'**
  String get apiNotWisetalk;

  /// A refusal without a message of the server's own; status is the HTTP status code.
  ///
  /// In en, this message translates to:
  /// **'The server said no ({status}).'**
  String apiRefused(int status);

  /// Linux: the app menu entry's comment.
  ///
  /// In en, this message translates to:
  /// **'Voice and video chat for one community'**
  String get desktopComment;

  /// Menu header for yourself.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String personYou(String name);

  /// No description provided for @personAudioVideoSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio and Video Settings…'**
  String get personAudioVideoSettings;

  /// How loud someone is for me, in their menu.
  ///
  /// In en, this message translates to:
  /// **'Volume {percent}%'**
  String personVolume(int percent);

  /// No description provided for @personMuteForMe.
  ///
  /// In en, this message translates to:
  /// **'Mute for Me'**
  String get personMuteForMe;

  /// No description provided for @personUnmuteForMe.
  ///
  /// In en, this message translates to:
  /// **'Unmute for Me'**
  String get personUnmuteForMe;

  /// No description provided for @moderationServerMute.
  ///
  /// In en, this message translates to:
  /// **'Server Mute'**
  String get moderationServerMute;

  /// No description provided for @moderationLiftServerMute.
  ///
  /// In en, this message translates to:
  /// **'Lift Server Mute'**
  String get moderationLiftServerMute;

  /// No description provided for @moderationKick.
  ///
  /// In en, this message translates to:
  /// **'Kick from Channel'**
  String get moderationKick;

  /// No description provided for @personMakeServerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Server Admin'**
  String get personMakeServerAdmin;

  /// No description provided for @personRemoveServerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Server Admin'**
  String get personRemoveServerAdmin;

  /// No description provided for @personNowAdmin.
  ///
  /// In en, this message translates to:
  /// **'{name} is now a server admin.'**
  String personNowAdmin(String name);

  /// No description provided for @personNowMember.
  ///
  /// In en, this message translates to:
  /// **'{name} is now a member.'**
  String personNowMember(String name);

  /// No description provided for @moderationBan.
  ///
  /// In en, this message translates to:
  /// **'Ban from Server…'**
  String get moderationBan;

  /// No description provided for @moderationBanTitle.
  ///
  /// In en, this message translates to:
  /// **'Ban {name}?'**
  String moderationBanTitle(String name);

  /// No description provided for @moderationBanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ban {name} from this server? Their sessions end right away.'**
  String moderationBanConfirm(String name);

  /// The button that confirms a ban.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get moderationBanAction;

  /// No description provided for @moderationBanned.
  ///
  /// In en, this message translates to:
  /// **'{name} is banned.'**
  String moderationBanned(String name);

  /// No description provided for @moderationBanGuest.
  ///
  /// In en, this message translates to:
  /// **'Ban Guest for a Day…'**
  String get moderationBanGuest;

  /// No description provided for @moderationBanGuestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} and block guests from their address for a day?'**
  String moderationBanGuestConfirm(String name);

  /// No description provided for @moderationGuestBanned.
  ///
  /// In en, this message translates to:
  /// **'{name} is out; their address is blocked for a day.'**
  String moderationGuestBanned(String name);

  /// No description provided for @channelMakeOwner.
  ///
  /// In en, this message translates to:
  /// **'Make Owner of {channel}'**
  String channelMakeOwner(String channel);

  /// No description provided for @channelRemoveOwner.
  ///
  /// In en, this message translates to:
  /// **'Remove as Owner of {channel}'**
  String channelRemoveOwner(String channel);

  /// No description provided for @channelNewOwner.
  ///
  /// In en, this message translates to:
  /// **'{name} now owns {channel}.'**
  String channelNewOwner(String name, String channel);

  /// No description provided for @channelNoOwner.
  ///
  /// In en, this message translates to:
  /// **'{channel} has no owner now.'**
  String channelNoOwner(String channel);

  /// No description provided for @spaceMakeOwner.
  ///
  /// In en, this message translates to:
  /// **'Make Owner of {space}'**
  String spaceMakeOwner(String space);

  /// No description provided for @spaceRemoveOwner.
  ///
  /// In en, this message translates to:
  /// **'Remove as Owner of {space}'**
  String spaceRemoveOwner(String space);

  /// No description provided for @spaceNewOwner.
  ///
  /// In en, this message translates to:
  /// **'{name} now owns {space}.'**
  String spaceNewOwner(String name, String space);

  /// No description provided for @spaceNoOwner.
  ///
  /// In en, this message translates to:
  /// **'{space} has no owner now.'**
  String spaceNoOwner(String space);

  /// Under the channel name in its menu.
  ///
  /// In en, this message translates to:
  /// **'Audio up to {kbps} kbps, stereo'**
  String channelAudioStereo(int kbps);

  /// Under the channel name in its menu.
  ///
  /// In en, this message translates to:
  /// **'Audio up to {kbps} kbps, mono'**
  String channelAudioMono(int kbps);

  /// No description provided for @channelJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get channelJoin;

  /// No description provided for @channelOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Open Chat'**
  String get channelOpenChat;

  /// No description provided for @channelOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Channel Settings…'**
  String get channelOpenSettings;

  /// No description provided for @inviteCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get inviteCopyLink;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link to {channel} copied.'**
  String inviteCopied(String channel);

  /// No description provided for @inviteCopiedWithKey.
  ///
  /// In en, this message translates to:
  /// **'Invite to {channel} copied. Once someone uses it, it lets anyone in for 10 minutes; unused, it lasts a day.'**
  String inviteCopiedWithKey(String channel);

  /// No description provided for @inviteCopiedRestricted.
  ///
  /// In en, this message translates to:
  /// **'Invite link to {channel} copied. It only works for people the channel already lets in.'**
  String inviteCopiedRestricted(String channel);

  /// No description provided for @inviteCannotCreate.
  ///
  /// In en, this message translates to:
  /// **'Cannot create an invite.'**
  String get inviteCannotCreate;

  /// No description provided for @spaceNewChannel.
  ///
  /// In en, this message translates to:
  /// **'New Channel in Space…'**
  String get spaceNewChannel;

  /// No description provided for @spaceOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Space Settings…'**
  String get spaceOpenSettings;

  /// No description provided for @spaceDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Space…'**
  String get spaceDelete;

  /// No description provided for @spaceDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the space {space}? Its channels move to the top level.'**
  String spaceDeleteConfirm(String space);

  /// No description provided for @workspaceMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get workspaceMoveUp;

  /// No description provided for @workspaceMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get workspaceMoveDown;

  /// No description provided for @workspaceCannotReorder.
  ///
  /// In en, this message translates to:
  /// **'Cannot reorder.'**
  String get workspaceCannotReorder;

  /// No description provided for @channelSettingsKbps.
  ///
  /// In en, this message translates to:
  /// **'{kbps} kbps'**
  String channelSettingsKbps(int kbps);

  /// No description provided for @channelSettingsKbpsSpeech.
  ///
  /// In en, this message translates to:
  /// **'{kbps} kbps (speech)'**
  String channelSettingsKbpsSpeech(int kbps);

  /// No description provided for @channelSettingsKbpsMusic.
  ///
  /// In en, this message translates to:
  /// **'{kbps} kbps (music)'**
  String channelSettingsKbpsMusic(int kbps);

  /// No description provided for @createNewChannel.
  ///
  /// In en, this message translates to:
  /// **'New Channel'**
  String get createNewChannel;

  /// No description provided for @createNewSpace.
  ///
  /// In en, this message translates to:
  /// **'New Space'**
  String get createNewSpace;

  /// No description provided for @createSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createSubmit;

  /// A choice: create a channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get createChannel;

  /// A choice: create a space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get createSpace;

  /// No description provided for @createChannelHint.
  ///
  /// In en, this message translates to:
  /// **'A voice room people join, with its own chat.'**
  String get createChannelHint;

  /// No description provided for @createSpaceHint.
  ///
  /// In en, this message translates to:
  /// **'A folder that groups channels in the sidebar.'**
  String get createSpaceHint;

  /// An example name for a new channel.
  ///
  /// In en, this message translates to:
  /// **'Team Blue'**
  String get createChannelPlaceholder;

  /// No description provided for @channelSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Channel Settings'**
  String get channelSettingsTitle;

  /// No description provided for @channelSettingsOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'The owner manages this channel. Only admins choose who owns it.'**
  String get channelSettingsOwnerHint;

  /// No description provided for @channelSettingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Everyone inside is dropped.'**
  String channelSettingsDeleteConfirm(String name);

  /// No description provided for @channelSettingsPeopleAndSound.
  ///
  /// In en, this message translates to:
  /// **'People and Sound'**
  String get channelSettingsPeopleAndSound;

  /// No description provided for @channelSettingsMaxPeople.
  ///
  /// In en, this message translates to:
  /// **'Max People'**
  String get channelSettingsMaxPeople;

  /// No description provided for @channelSettingsNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get channelSettingsNoLimit;

  /// No description provided for @channelSettingsAudioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get channelSettingsAudioQuality;

  /// No description provided for @channelSettingsStereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get channelSettingsStereo;

  /// No description provided for @channelSettingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Channel…'**
  String get channelSettingsDelete;

  /// Which space a channel is in.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get manageSpace;

  /// Who owns a channel or a space.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get manageOwner;

  /// No description provided for @manageAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get manageAccess;

  /// No description provided for @spaceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Space Settings'**
  String get spaceSettingsTitle;

  /// No description provided for @spaceSettingsOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'The owner manages the space and every channel in it. Only admins choose who owns it.'**
  String get spaceSettingsOwnerHint;

  /// No description provided for @accessAccountsOnly.
  ///
  /// In en, this message translates to:
  /// **'Accounts Only'**
  String get accessAccountsOnly;

  /// No description provided for @accessAccountsOnlyDetail.
  ///
  /// In en, this message translates to:
  /// **'No guests'**
  String get accessAccountsOnlyDetail;

  /// No description provided for @accessWhitelistOnly.
  ///
  /// In en, this message translates to:
  /// **'Whitelist Only'**
  String get accessWhitelistOnly;

  /// No description provided for @accessHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get accessHidden;

  /// No description provided for @accessHiddenDetail.
  ///
  /// In en, this message translates to:
  /// **'Invisible to those who may not enter'**
  String get accessHiddenDetail;

  /// No description provided for @accessFromSpace.
  ///
  /// In en, this message translates to:
  /// **'Set by the space'**
  String get accessFromSpace;

  /// No description provided for @summonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Summon to {channel}'**
  String summonsTitle(String channel);

  /// No description provided for @summonsSummon.
  ///
  /// In en, this message translates to:
  /// **'Summon'**
  String get summonsSummon;

  /// No description provided for @summonsNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get summonsNickname;

  /// No description provided for @summonsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nobody matching who could come here.'**
  String get summonsNoMatch;

  /// No description provided for @summonsHint.
  ///
  /// In en, this message translates to:
  /// **'They get a notification that you are waiting. Once per 5 minutes per person.'**
  String get summonsHint;

  /// No description provided for @summonsSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot search.'**
  String get summonsSearchFailed;

  /// Menu header over someone's device key fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Device Key'**
  String get manageDeviceKey;

  /// Title of the dialog that confirms deleting a channel or a space.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String manageDeleteTitle(String name);

  /// The button that confirms deleting a channel or a space.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageDelete;

  /// No description provided for @manageSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get manageSave;

  /// The name of a channel or a space.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get manageName;

  /// A channel in no space, at the top level of the list.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get manageNone;

  /// A channel or a space owned by nobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get manageNobody;

  /// The owner picker: the current owner is not among the accounts listed.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get manageSomeoneElse;

  /// The app cannot edit the whitelist of a channel yet.
  ///
  /// In en, this message translates to:
  /// **'Edit the whitelist in the web client for now.'**
  String get manageWhitelistInWeb;

  /// No description provided for @channelSettingsLimitHint.
  ///
  /// In en, this message translates to:
  /// **'When the channel is full, only people who manage it can still join. From 1 to 99 people, or no limit.'**
  String get channelSettingsLimitHint;

  /// No description provided for @spaceSettingsAccessHint.
  ///
  /// In en, this message translates to:
  /// **'These limits apply to every channel in the space; a channel can only add its own. Edit the whitelist in the web client for now.'**
  String get spaceSettingsAccessHint;

  /// Under Whitelist Only; the list itself is edited in the web client.
  ///
  /// In en, this message translates to:
  /// **'Only the people and roles on its list'**
  String get accessWhitelistOnlyListDetail;

  /// Hint in the empty nickname field of the summon dialog.
  ///
  /// In en, this message translates to:
  /// **'Who?'**
  String get summonsWho;

  /// The file type filter in the system dialog that picks a profile picture.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get settingsPictures;

  /// No description provided for @profileAddPicture.
  ///
  /// In en, this message translates to:
  /// **'Add Picture…'**
  String get profileAddPicture;

  /// No description provided for @profileChangePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Picture…'**
  String get profileChangePicture;

  /// Removes your profile picture.
  ///
  /// In en, this message translates to:
  /// **'Remove Picture'**
  String get profileRemovePicture;

  /// No description provided for @profileUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot upload the picture.'**
  String get profileUploadFailed;

  /// No description provided for @profileRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove the picture.'**
  String get profileRemoveFailed;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot save.'**
  String get saveFailed;

  /// No description provided for @settingsAudioVideo.
  ///
  /// In en, this message translates to:
  /// **'Audio and Video'**
  String get settingsAudioVideo;

  /// No description provided for @settingsMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get settingsMicrophone;

  /// No description provided for @settingsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get settingsCamera;

  /// Which speakers or headphones the sound goes to.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get settingsOutput;

  /// No description provided for @settingsVoiceProcessing.
  ///
  /// In en, this message translates to:
  /// **'Voice Processing'**
  String get settingsVoiceProcessing;

  /// No description provided for @settingsVoiceProcessingDetail.
  ///
  /// In en, this message translates to:
  /// **'Noise suppression and echo cancellation'**
  String get settingsVoiceProcessingDetail;

  /// No description provided for @settingsVoiceProcessingHint.
  ///
  /// In en, this message translates to:
  /// **'Turn it off for the best sound, and wear headphones then: without echo cancellation others hear themselves through your speakers.'**
  String get settingsVoiceProcessingHint;

  /// No description provided for @settingsCues.
  ///
  /// In en, this message translates to:
  /// **'Join and Leave Sounds'**
  String get settingsCues;

  /// Under Join and Leave Sounds: keyboard shortcuts also make a short tick when they turn something on or off.
  ///
  /// In en, this message translates to:
  /// **'An owl hoots when someone comes or goes, and shortcuts tick'**
  String get settingsCuesDetail;

  /// No description provided for @settingsPingAndLoss.
  ///
  /// In en, this message translates to:
  /// **'Show Ping and Loss'**
  String get settingsPingAndLoss;

  /// No description provided for @settingsPingAndLossDetail.
  ///
  /// In en, this message translates to:
  /// **'Next to the connection icon in a call'**
  String get settingsPingAndLossDetail;

  /// Settings group: whether others may ask you by a notification to join their voice channel.
  ///
  /// In en, this message translates to:
  /// **'Summons'**
  String get summonsHeader;

  /// No description provided for @summonsAllow.
  ///
  /// In en, this message translates to:
  /// **'Others May Summon Me'**
  String get summonsAllow;

  /// No description provided for @settingsNotificationsHere.
  ///
  /// In en, this message translates to:
  /// **'Notifications on This Device'**
  String get settingsNotificationsHere;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Shown while Wisetalk is in the background.'**
  String get settingsNotificationsHint;

  /// No description provided for @settingsNotifyMessages.
  ///
  /// In en, this message translates to:
  /// **'New Messages'**
  String get settingsNotifyMessages;

  /// No description provided for @settingsNotifyMessagesDetail.
  ///
  /// In en, this message translates to:
  /// **'In your call’s chat and chats you opened'**
  String get settingsNotifyMessagesDetail;

  /// Notification switch: a notification when someone summons you into their voice channel.
  ///
  /// In en, this message translates to:
  /// **'Summons'**
  String get settingsNotifySummons;

  /// No description provided for @settingsNotifySummonsDetail.
  ///
  /// In en, this message translates to:
  /// **'When someone calls you into a channel'**
  String get settingsNotifySummonsDetail;

  /// Settings group, Android only: how summons reach the phone while the app is not running.
  ///
  /// In en, this message translates to:
  /// **'While Wisetalk Is Closed'**
  String get settingsPushHeader;

  /// Row label: the UnifiedPush distributor app (such as ntfy) that delivers pushes while Wisetalk is closed.
  ///
  /// In en, this message translates to:
  /// **'Push App'**
  String get settingsPushApp;

  /// Value of the Push App row when no such app is installed.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsPushAppNone;

  /// No description provided for @settingsPushAppChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose…'**
  String get settingsPushAppChoose;

  /// Button opening the store page of ntfy, a push app. "ntfy" is a name, written in lowercase.
  ///
  /// In en, this message translates to:
  /// **'Get ntfy'**
  String get settingsGetNtfy;

  /// Caption under the Push App row.
  ///
  /// In en, this message translates to:
  /// **'Summons reach this phone through {app}, even while Wisetalk is closed.'**
  String settingsPushVia(String app);

  /// No description provided for @settingsPushChooseHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the app that brings summons while Wisetalk is closed.'**
  String get settingsPushChooseHint;

  /// Caption when no push app is installed: ntfy must use the community’s own ntfy server as its default server.
  ///
  /// In en, this message translates to:
  /// **'Without a push app, summons show only while Wisetalk runs. Install ntfy, then in its settings make your community’s ntfy server the default server.'**
  String get settingsPushNoneHint;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsCrashReports.
  ///
  /// In en, this message translates to:
  /// **'Send Crash Reports'**
  String get settingsCrashReports;

  /// No description provided for @settingsCrashReportsHint.
  ///
  /// In en, this message translates to:
  /// **'When something in Wisetalk breaks, tell its developers what broke and where in the code. Never your messages, names, keys or servers.'**
  String get settingsCrashReportsHint;

  /// Keyboard shortcuts, desktop only.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get settingsShortcuts;

  /// While recording a new keyboard shortcut. Backspace and Esc are key names.
  ///
  /// In en, this message translates to:
  /// **'Press the new keys. Backspace removes the shortcut, Esc keeps it.'**
  String get settingsShortcutsRecording;

  /// No description provided for @settingsShortcutsGlobal.
  ///
  /// In en, this message translates to:
  /// **'In a call they work whatever app is in front, otherwise in Wisetalk’s window. Click one to change it.'**
  String get settingsShortcutsGlobal;

  /// No description provided for @settingsShortcutsWayland.
  ///
  /// In en, this message translates to:
  /// **'On Wayland they work only while Wisetalk’s window is in front. Click one to change it.'**
  String get settingsShortcutsWayland;

  /// In place of a shortcut while waiting for the new keys.
  ///
  /// In en, this message translates to:
  /// **'Press keys…'**
  String get settingsShortcutPressKeys;

  /// A shortcut bound to no keys.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsShortcutNone;

  /// The keys just pressed are bound to another action.
  ///
  /// In en, this message translates to:
  /// **'{keys} is already {action}.'**
  String settingsShortcutTaken(String keys, String action);

  /// A keyboard shortcut action.
  ///
  /// In en, this message translates to:
  /// **'Microphone On or Off'**
  String get shortcutToggleMute;

  /// A keyboard shortcut action: step away from the call, or come back.
  ///
  /// In en, this message translates to:
  /// **'Away or Back'**
  String get shortcutToggleAway;

  /// A keyboard shortcut action.
  ///
  /// In en, this message translates to:
  /// **'Microphone Off'**
  String get shortcutMute;

  /// A keyboard shortcut action.
  ///
  /// In en, this message translates to:
  /// **'Microphone On'**
  String get shortcutUnmute;

  /// No description provided for @shortcutUnusableKey.
  ///
  /// In en, this message translates to:
  /// **'That key can’t be used for a shortcut.'**
  String get shortcutUnusableKey;

  /// A key that types text was pressed alone. The placeholders are modifier keys: Ctrl and Alt, or ⌘ and ⌃ on a Mac.
  ///
  /// In en, this message translates to:
  /// **'Add {first} or {second}, or use F1 to F24.'**
  String shortcutTyping(String first, String second);

  /// No description provided for @shortcutReserved.
  ///
  /// In en, this message translates to:
  /// **'{keys} belongs to the system or to every app.'**
  String shortcutReserved(String keys);

  /// No description provided for @sheetDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get sheetDiscardTitle;

  /// No description provided for @sheetDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'What you changed here is not saved yet.'**
  String get sheetDiscardMessage;

  /// No description provided for @sheetDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get sheetDiscard;

  /// No description provided for @sheetKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get sheetKeepEditing;

  /// No description provided for @serversRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {server}?'**
  String serversRemoveTitle(String server);

  /// No description provided for @serversRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'This device signs out of it and forgets it. You can add it again with its address.'**
  String get serversRemoveMessage;

  /// No description provided for @serversRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get serversRemove;

  /// No description provided for @serversAddressHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask whoever runs your community for its address.'**
  String get serversAddressHelp;

  /// No description provided for @serversConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get serversConnecting;

  /// No description provided for @serversConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get serversConnect;

  /// No description provided for @serversWhich.
  ///
  /// In en, this message translates to:
  /// **'Which server is your community on?'**
  String get serversWhich;

  /// No description provided for @serversYours.
  ///
  /// In en, this message translates to:
  /// **'Your Servers'**
  String get serversYours;

  /// No description provided for @serversAddMenu.
  ///
  /// In en, this message translates to:
  /// **'Add a Server…'**
  String get serversAddMenu;

  /// No description provided for @serversAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a Server'**
  String get serversAddTitle;

  /// No description provided for @serversBadAddress.
  ///
  /// In en, this message translates to:
  /// **'Type the address of a server, like talk.example.com.'**
  String get serversBadAddress;

  /// No description provided for @serversTooNew.
  ///
  /// In en, this message translates to:
  /// **'This server is newer than this app. Update Wisetalk to join it.'**
  String get serversTooNew;

  /// No description provided for @serversTooOld.
  ///
  /// In en, this message translates to:
  /// **'This server runs an older Wisetalk. Ask its admins to update it.'**
  String get serversTooOld;

  /// No description provided for @serversTooOldVersion.
  ///
  /// In en, this message translates to:
  /// **'This server runs an older Wisetalk ({version}). Ask its admins to update it.'**
  String serversTooOldVersion(String version);

  /// The server address field.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get serversAddress;

  /// Tooltip of the ⋯ button next to a saved server.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get serversMore;

  /// No description provided for @serversRemoveServer.
  ///
  /// In en, this message translates to:
  /// **'Remove Server'**
  String get serversRemoveServer;

  /// Stands in for a channel name we cannot see, inside sentences.
  ///
  /// In en, this message translates to:
  /// **'a channel'**
  String get channelSomeChannel;

  /// System notification title for a new chat message: who wrote, in which channel.
  ///
  /// In en, this message translates to:
  /// **'{name} in {channel}'**
  String workspaceMessageTitle(String name, String channel);

  /// System notification body for a chat message this device cannot read; the title names the author.
  ///
  /// In en, this message translates to:
  /// **'Wrote an encrypted message.'**
  String get workspaceMessageEncrypted;

  /// System notification body for a chat message with only a picture; the title names the author.
  ///
  /// In en, this message translates to:
  /// **'Sent a picture.'**
  String get workspaceMessagePicture;

  /// After summoning someone whose device got a push notification.
  ///
  /// In en, this message translates to:
  /// **'{name} got a notification.'**
  String summonPushed(String name);

  /// As summonPushed, when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'They got a notification.'**
  String get summonPushedSomeone;

  /// After summoning someone who gets no push notifications: only a running Wisetalk (app or tab) shows the summons.
  ///
  /// In en, this message translates to:
  /// **'Summoned {name}. They have notifications off, so only an open Wisetalk shows it.'**
  String summonNotPushed(String name);

  /// As summonNotPushed, when the name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Summoned. They have notifications off, so only an open Wisetalk shows it.'**
  String get summonNotPushedSomeone;

  /// No description provided for @summonReceived.
  ///
  /// In en, this message translates to:
  /// **'{from} summons you to {channel}.'**
  String summonReceived(String from, String channel);

  /// System notification title when someone summons me; the body says who and where.
  ///
  /// In en, this message translates to:
  /// **'Summoned'**
  String get workspaceSummoned;

  /// No description provided for @workspaceRoleChangedOwner.
  ///
  /// In en, this message translates to:
  /// **'Your server role is now owner.'**
  String get workspaceRoleChangedOwner;

  /// No description provided for @workspaceRoleChangedAdmin.
  ///
  /// In en, this message translates to:
  /// **'Your server role is now admin.'**
  String get workspaceRoleChangedAdmin;

  /// No description provided for @workspaceRoleChangedModerator.
  ///
  /// In en, this message translates to:
  /// **'Your server role is now moderator.'**
  String get workspaceRoleChangedModerator;

  /// No description provided for @workspaceRoleChangedMember.
  ///
  /// In en, this message translates to:
  /// **'Your server role is now member.'**
  String get workspaceRoleChangedMember;

  /// No description provided for @workspaceRoleChangedGuest.
  ///
  /// In en, this message translates to:
  /// **'Your server role is now guest.'**
  String get workspaceRoleChangedGuest;

  /// No description provided for @takeOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Join from This Device?'**
  String get takeOverTitle;

  /// No description provided for @takeOverSameChannel.
  ///
  /// In en, this message translates to:
  /// **'You’re already in {channel} on another device or tab. Joining {channel} here takes you out of the call there.'**
  String takeOverSameChannel(String channel);

  /// {there}: the channel my account is in elsewhere; {here}: the one I am joining.
  ///
  /// In en, this message translates to:
  /// **'You’re in {there} on another device or tab. Joining {here} here takes you out of the call there.'**
  String takeOverOtherChannel(String there, String here);

  /// As takeOverOtherChannel, when a channel name is unknown.
  ///
  /// In en, this message translates to:
  /// **'You’re in a call on another device or tab. Joining here takes you out of the call there.'**
  String get takeOverElsewhere;

  /// No description provided for @takeOverJoinHere.
  ///
  /// In en, this message translates to:
  /// **'Join Here'**
  String get takeOverJoinHere;

  /// Screen reader: phones in a call, the row that unfolds the channel list.
  ///
  /// In en, this message translates to:
  /// **'Show channels'**
  String get workspaceShowChannels;

  /// Screen reader: phones in a call, the row that folds the channel list.
  ///
  /// In en, this message translates to:
  /// **'Hide channels'**
  String get workspaceHideChannels;

  /// How many people are in a voice channel, or in all channels of a folded space.
  ///
  /// In en, this message translates to:
  /// **'{count} in voice'**
  String workspaceInVoice(int count);

  /// No description provided for @workspaceCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Channel or Space'**
  String get workspaceCreateTitle;

  /// No description provided for @workspaceStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get workspaceStatusConnecting;

  /// Under the server name while the connection is down and being retried.
  ///
  /// In en, this message translates to:
  /// **'Offline…'**
  String get workspaceStatusOffline;

  /// No description provided for @workspaceEmptyAdmin.
  ///
  /// In en, this message translates to:
  /// **'No channels yet. Create one with the + button.'**
  String get workspaceEmptyAdmin;

  /// No description provided for @workspaceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No channels yet. An admin can add some.'**
  String get workspaceEmpty;

  /// Tooltip of the ⋯ menu next to my name.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get workspaceMore;

  /// No description provided for @workspaceCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get workspaceCheckForUpdates;

  /// No description provided for @workspaceChangeServer.
  ///
  /// In en, this message translates to:
  /// **'Change Server'**
  String get workspaceChangeServer;

  /// No description provided for @workspaceSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get workspaceSignOut;

  /// No description provided for @personMutedForYou.
  ///
  /// In en, this message translates to:
  /// **'Muted for you'**
  String get personMutedForYou;

  /// Status and button: microphone and sound off, stepped away.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get awayTitle;

  /// Screen reader label of the Away button.
  ///
  /// In en, this message translates to:
  /// **'Away: microphone and sound off'**
  String get awayDescription;

  /// No description provided for @callMutedByModerator.
  ///
  /// In en, this message translates to:
  /// **'Muted by a moderator'**
  String get callMutedByModerator;

  /// Tooltip of the handle that moves a channel or space; {name} is its name.
  ///
  /// In en, this message translates to:
  /// **'Drag {name}'**
  String workspaceDrag(String name);

  /// No description provided for @workspaceDropEndHint.
  ///
  /// In en, this message translates to:
  /// **'Drop here for the end of the list'**
  String get workspaceDropEndHint;

  /// No description provided for @workspaceUpdateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Wisetalk {version} is downloaded'**
  String workspaceUpdateDownloaded(String version);

  /// No description provided for @workspaceUpdateOut.
  ///
  /// In en, this message translates to:
  /// **'Wisetalk {version} is out'**
  String workspaceUpdateOut(String version);

  /// No description provided for @workspaceRestartToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Restart to Update'**
  String get workspaceRestartToUpdate;

  /// Opens the download of the new version, where the app cannot update itself.
  ///
  /// In en, this message translates to:
  /// **'Update to {version}'**
  String workspaceUpdateTo(String version);

  /// No description provided for @workspaceWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a Voice Channel'**
  String get workspaceWelcomeTitle;

  /// Under workspaceWelcomeTitle while in no call.
  ///
  /// In en, this message translates to:
  /// **'Click a channel to join.'**
  String get workspaceWelcomeHint;

  /// Above the stage while joining a voice channel.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get callJoining;

  /// No description provided for @callWaitingForKey.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the call key…'**
  String get callWaitingForKey;

  /// No description provided for @callEncrypted.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted'**
  String get callEncrypted;

  /// Name on a shared screen tile.
  ///
  /// In en, this message translates to:
  /// **'{name} · screen'**
  String videoScreen(String name);

  /// Connection quality, alone in the details and inside connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get connectionExcellent;

  /// Connection quality, alone in the details and inside connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get connectionGood;

  /// Connection quality, alone in the details and inside connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get connectionPoor;

  /// Connection quality, alone in the details and inside connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get connectionLost;

  /// Connection quality, alone in the details and inside connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get connectionChecking;

  /// {quality} is one of connectionExcellent, connectionGood, connectionPoor, connectionLost, connectionChecking.
  ///
  /// In en, this message translates to:
  /// **'Connection: {quality}'**
  String connectionStatus(String quality);

  /// Connection details: the row with the quality word.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connectionLabel;

  /// Next to the signal bars: {ping} like "42 ms", {loss} like "0.5%".
  ///
  /// In en, this message translates to:
  /// **'{ping} · {loss} loss'**
  String connectionShort(String ping, String loss);

  /// Screen reader version of connectionShort.
  ///
  /// In en, this message translates to:
  /// **'Ping {ping}, loss {loss}'**
  String connectionPingLoss(String ping, String loss);

  /// No description provided for @connectionPing.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get connectionPing;

  /// No description provided for @connectionOutgoingLoss.
  ///
  /// In en, this message translates to:
  /// **'Outgoing Loss'**
  String get connectionOutgoingLoss;

  /// No description provided for @connectionIncomingLoss.
  ///
  /// In en, this message translates to:
  /// **'Incoming Loss'**
  String get connectionIncomingLoss;

  /// No description provided for @connectionJitter.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get connectionJitter;

  /// No description provided for @connectionMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get connectionMicrophone;

  /// Connection details, Microphone row: no audio goes out.
  ///
  /// In en, this message translates to:
  /// **'Not sending'**
  String get connectionNotSending;

  /// Microphone bitrate in the connection details.
  ///
  /// In en, this message translates to:
  /// **'{value} kbps'**
  String connectionKilobits(int value);

  /// No description provided for @screenShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Screen'**
  String get screenShareTitle;

  /// Button that starts sharing the screen.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get screenShareAction;

  /// Header over the choice between text and motion.
  ///
  /// In en, this message translates to:
  /// **'Best For'**
  String get screenShareBestFor;

  /// No description provided for @screenShareAndroidHint.
  ///
  /// In en, this message translates to:
  /// **'Android asks next whether to share the entire screen or one app.'**
  String get screenShareAndroidHint;

  /// Linux on Wayland, where the system picks the screen.
  ///
  /// In en, this message translates to:
  /// **'The first time, your system asks which screen to share. Later shares reuse that screen until Wisetalk restarts. Whole screens only, without sound, for now.'**
  String get screenShareWaylandHint;

  /// No description provided for @screenShareText.
  ///
  /// In en, this message translates to:
  /// **'Text and Slides'**
  String get screenShareText;

  /// No description provided for @screenShareTextDetail.
  ///
  /// In en, this message translates to:
  /// **'Sharp and light: a few frames a second.'**
  String get screenShareTextDetail;

  /// No description provided for @screenShareMotion.
  ///
  /// In en, this message translates to:
  /// **'Video and Games'**
  String get screenShareMotion;

  /// No description provided for @screenShareMotionDetail.
  ///
  /// In en, this message translates to:
  /// **'Smooth: 30 frames a second, heavier on both ends.'**
  String get screenShareMotionDetail;

  /// No description provided for @screenShareSource.
  ///
  /// In en, this message translates to:
  /// **'Screen or Window'**
  String get screenShareSource;

  /// Switch: send the shared window or screen's sound too (Windows, Android).
  ///
  /// In en, this message translates to:
  /// **'Share Sound'**
  String get screenShareSound;

  /// Under Share Sound with a window picked: whose sound goes.
  ///
  /// In en, this message translates to:
  /// **'Only this window\'s app.'**
  String get screenShareSoundWindow;

  /// Under Share Sound with a screen picked.
  ///
  /// In en, this message translates to:
  /// **'Everything you hear, without the call.'**
  String get screenShareSoundScreen;

  /// Under Share Sound before anything is picked.
  ///
  /// In en, this message translates to:
  /// **'A window\'s app, or for a screen everything you hear, without the call.'**
  String get screenShareSoundAny;

  /// Under Share Sound on Android, which records all the phone plays.
  ///
  /// In en, this message translates to:
  /// **'Everything the phone plays, without the call. Some apps don\'t allow it.'**
  String get screenShareSoundPhone;

  /// No description provided for @screenShareListFailed.
  ///
  /// In en, this message translates to:
  /// **'Can\'t list screens and windows.'**
  String get screenShareListFailed;

  /// Linux on Wayland: waiting while the system asks which screen to share.
  ///
  /// In en, this message translates to:
  /// **'Choose a Screen'**
  String get screenShareChooseTitle;

  /// No description provided for @screenShareChooseHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the screen to share in your system\'s window.'**
  String get screenShareChooseHint;

  /// No description provided for @problemNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You’re not signed in.'**
  String get problemNotSignedIn;

  /// No description provided for @problemAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an account first.'**
  String get problemAccountRequired;

  /// No description provided for @problemAccountBanned.
  ///
  /// In en, this message translates to:
  /// **'This account is banned.'**
  String get problemAccountBanned;

  /// No description provided for @problemSignInCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This sign-in code is no longer valid. Sign in again.'**
  String get problemSignInCodeInvalid;

  /// No description provided for @problemBrowserCheckMissing.
  ///
  /// In en, this message translates to:
  /// **'The browser check is missing. Reload and try again.'**
  String get problemBrowserCheckMissing;

  /// No description provided for @problemBrowserCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'The browser check failed. Reload and try again.'**
  String get problemBrowserCheckFailed;

  /// No description provided for @problemBrowserCheckExpired.
  ///
  /// In en, this message translates to:
  /// **'The browser check expired. Try again.'**
  String get problemBrowserCheckExpired;

  /// No description provided for @problemGuestSignInClosed.
  ///
  /// In en, this message translates to:
  /// **'Guest sign-in is closed right now. Sign in with an account.'**
  String get problemGuestSignInClosed;

  /// No description provided for @problemGuestAddressBlocked.
  ///
  /// In en, this message translates to:
  /// **'Guests from this address are blocked for a while.'**
  String get problemGuestAddressBlocked;

  /// No description provided for @problemTooManyGuests.
  ///
  /// In en, this message translates to:
  /// **'Too many guests right now. Try again later or sign in with an account.'**
  String get problemTooManyGuests;

  /// No description provided for @problemTooManyGuestSignIns.
  ///
  /// In en, this message translates to:
  /// **'Too many guest sign-ins from this address. Try again later.'**
  String get problemTooManyGuestSignIns;

  /// No description provided for @problemNameBelongsToAccount.
  ///
  /// In en, this message translates to:
  /// **'This name belongs to an account.'**
  String get problemNameBelongsToAccount;

  /// No description provided for @problemAccountsCantBeGuests.
  ///
  /// In en, this message translates to:
  /// **'Accounts can’t be guests.'**
  String get problemAccountsCantBeGuests;

  /// No description provided for @problemNoSuchAccount.
  ///
  /// In en, this message translates to:
  /// **'This account doesn’t exist.'**
  String get problemNoSuchAccount;

  /// No description provided for @problemNoSuchChannel.
  ///
  /// In en, this message translates to:
  /// **'This channel doesn’t exist any more.'**
  String get problemNoSuchChannel;

  /// No description provided for @problemNoSuchSpace.
  ///
  /// In en, this message translates to:
  /// **'This space doesn’t exist any more.'**
  String get problemNoSuchSpace;

  /// No description provided for @problemNoSuchEmoji.
  ///
  /// In en, this message translates to:
  /// **'This emoji doesn’t exist.'**
  String get problemNoSuchEmoji;

  /// No description provided for @problemNoSuchGuest.
  ///
  /// In en, this message translates to:
  /// **'This guest isn’t online any more.'**
  String get problemNoSuchGuest;

  /// No description provided for @problemNoSuchPicture.
  ///
  /// In en, this message translates to:
  /// **'This picture is gone.'**
  String get problemNoSuchPicture;

  /// No description provided for @problemNoSuchMessage.
  ///
  /// In en, this message translates to:
  /// **'This message is gone.'**
  String get problemNoSuchMessage;

  /// No description provided for @problemNoAvatar.
  ///
  /// In en, this message translates to:
  /// **'There’s no avatar.'**
  String get problemNoAvatar;

  /// No description provided for @problemNotBanned.
  ///
  /// In en, this message translates to:
  /// **'This account isn’t banned.'**
  String get problemNotBanned;

  /// No description provided for @problemDisplayNameLength.
  ///
  /// In en, this message translates to:
  /// **'A name is 1 to 32 characters.'**
  String get problemDisplayNameLength;

  /// No description provided for @problemChannelNameLength.
  ///
  /// In en, this message translates to:
  /// **'A channel name is 1 to 64 characters.'**
  String get problemChannelNameLength;

  /// No description provided for @problemSpaceNameLength.
  ///
  /// In en, this message translates to:
  /// **'A space name is 1 to 64 characters.'**
  String get problemSpaceNameLength;

  /// No description provided for @problemEmojiNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'An emoji name is 2 to 32 of a–z, 0–9 and _.'**
  String get problemEmojiNameInvalid;

  /// No description provided for @problemIconInvalid.
  ///
  /// In en, this message translates to:
  /// **'An icon is one emoji or a :custom_emoji:.'**
  String get problemIconInvalid;

  /// No description provided for @problemBrandingInvalid.
  ///
  /// In en, this message translates to:
  /// **'Names are up to 40 characters, the tagline up to 120, without control characters.'**
  String get problemBrandingInvalid;

  /// No description provided for @problemChannelLimitInvalid.
  ///
  /// In en, this message translates to:
  /// **'A channel holds 1 to 99 people, or has no limit.'**
  String get problemChannelLimitInvalid;

  /// No description provided for @problemBitrateInvalid.
  ///
  /// In en, this message translates to:
  /// **'The audio bitrate must be 6 to 510 kbit/s.'**
  String get problemBitrateInvalid;

  /// No description provided for @problemPictureType.
  ///
  /// In en, this message translates to:
  /// **'The picture must be PNG, JPEG or WebP.'**
  String get problemPictureType;

  /// No description provided for @problemAvatarTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The picture is larger than 256 KB.'**
  String get problemAvatarTooLarge;

  /// No description provided for @problemEmojiTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The picture is larger than 128 KB.'**
  String get problemEmojiTooLarge;

  /// No description provided for @problemChatPictureTooLarge.
  ///
  /// In en, this message translates to:
  /// **'A picture can be up to 20 MB.'**
  String get problemChatPictureTooLarge;

  /// No description provided for @problemPictureIdTaken.
  ///
  /// In en, this message translates to:
  /// **'This picture is already there.'**
  String get problemPictureIdTaken;

  /// No description provided for @problemChatFullOfPictures.
  ///
  /// In en, this message translates to:
  /// **'This chat holds too many pictures until it clears.'**
  String get problemChatFullOfPictures;

  /// No description provided for @problemTooManyPictures.
  ///
  /// In en, this message translates to:
  /// **'That’s a lot of pictures. Wait a little.'**
  String get problemTooManyPictures;

  /// No description provided for @problemManageNotPerRole.
  ///
  /// In en, this message translates to:
  /// **'Managing can’t be given per role.'**
  String get problemManageNotPerRole;

  /// No description provided for @problemOwnersHaveEveryPermission.
  ///
  /// In en, this message translates to:
  /// **'Owners and admins always have every permission.'**
  String get problemOwnersHaveEveryPermission;

  /// No description provided for @problemOneOverridePerRole.
  ///
  /// In en, this message translates to:
  /// **'Only one rule per role.'**
  String get problemOneOverridePerRole;

  /// No description provided for @problemWhitelistUnknownAccount.
  ///
  /// In en, this message translates to:
  /// **'The whitelist names an account that doesn’t exist.'**
  String get problemWhitelistUnknownAccount;

  /// No description provided for @problemGuestsNeverWhitelisted.
  ///
  /// In en, this message translates to:
  /// **'Guests can never pass a whitelist.'**
  String get problemGuestsNeverWhitelisted;

  /// No description provided for @problemPushSubscriptionInvalid.
  ///
  /// In en, this message translates to:
  /// **'The browser sent a broken notification subscription.'**
  String get problemPushSubscriptionInvalid;

  /// No description provided for @problemPushEndpointNotPublic.
  ///
  /// In en, this message translates to:
  /// **'The notification address must be a public HTTPS address.'**
  String get problemPushEndpointNotPublic;

  /// No description provided for @problemNotAllowedInChannel.
  ///
  /// In en, this message translates to:
  /// **'You may not do this in this channel.'**
  String get problemNotAllowedInChannel;

  /// No description provided for @problemMayNotEnter.
  ///
  /// In en, this message translates to:
  /// **'You may not enter this channel.'**
  String get problemMayNotEnter;

  /// No description provided for @problemTheyMayNotEnter.
  ///
  /// In en, this message translates to:
  /// **'They may not enter this channel.'**
  String get problemTheyMayNotEnter;

  /// No description provided for @problemMayNotModerate.
  ///
  /// In en, this message translates to:
  /// **'You may not moderate this channel.'**
  String get problemMayNotModerate;

  /// No description provided for @problemCantModerateYourself.
  ///
  /// In en, this message translates to:
  /// **'You can’t moderate yourself.'**
  String get problemCantModerateYourself;

  /// No description provided for @problemModerateRank.
  ///
  /// In en, this message translates to:
  /// **'You may not moderate someone of your rank or above.'**
  String get problemModerateRank;

  /// No description provided for @problemBanRank.
  ///
  /// In en, this message translates to:
  /// **'You may not ban someone of your rank or above.'**
  String get problemBanRank;

  /// No description provided for @problemRoleRank.
  ///
  /// In en, this message translates to:
  /// **'You may only give roles below yours to people below you.'**
  String get problemRoleRank;

  /// No description provided for @problemOnlyAdminsManageServer.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins manage the server.'**
  String get problemOnlyAdminsManageServer;

  /// No description provided for @problemOnlyAdminsManageBans.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins manage bans.'**
  String get problemOnlyAdminsManageBans;

  /// No description provided for @problemOnlyAdminsManageEmoji.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins manage custom emoji.'**
  String get problemOnlyAdminsManageEmoji;

  /// No description provided for @problemOnlyAdminsManageSpaces.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins manage spaces.'**
  String get problemOnlyAdminsManageSpaces;

  /// No description provided for @problemOnlyAdminsChooseChannelOwners.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins choose channel owners.'**
  String get problemOnlyAdminsChooseChannelOwners;

  /// No description provided for @problemOnlyAdminsChooseSpaceOwners.
  ///
  /// In en, this message translates to:
  /// **'Only server owners and admins choose space owners.'**
  String get problemOnlyAdminsChooseSpaceOwners;

  /// No description provided for @problemOnlySpaceManagersManageSpace.
  ///
  /// In en, this message translates to:
  /// **'Only admins and the space’s owner manage it.'**
  String get problemOnlySpaceManagersManageSpace;

  /// No description provided for @problemOnlySpaceManagersCreateChannels.
  ///
  /// In en, this message translates to:
  /// **'Only admins, and space owners in their space, may create channels.'**
  String get problemOnlySpaceManagersCreateChannels;

  /// No description provided for @problemMoveIntoOwnSpace.
  ///
  /// In en, this message translates to:
  /// **'You may only move channels into a space you manage.'**
  String get problemMoveIntoOwnSpace;

  /// No description provided for @problemOnlyModeratorsInvite.
  ///
  /// In en, this message translates to:
  /// **'Only people who may moderate the channel hand out invites.'**
  String get problemOnlyModeratorsInvite;

  /// No description provided for @problemGuestsCantCreateChannels.
  ///
  /// In en, this message translates to:
  /// **'Guests may not create channels.'**
  String get problemGuestsCantCreateChannels;

  /// No description provided for @problemGuestsCantInvite.
  ///
  /// In en, this message translates to:
  /// **'Guests can’t invite.'**
  String get problemGuestsCantInvite;

  /// No description provided for @problemGuestsCantBan.
  ///
  /// In en, this message translates to:
  /// **'Guests can’t ban.'**
  String get problemGuestsCantBan;

  /// No description provided for @problemGuestsCantGetNotifications.
  ///
  /// In en, this message translates to:
  /// **'Guests can’t get notifications.'**
  String get problemGuestsCantGetNotifications;

  /// No description provided for @problemGuestsHaveNoAvatar.
  ///
  /// In en, this message translates to:
  /// **'Guests have no avatar.'**
  String get problemGuestsHaveNoAvatar;

  /// No description provided for @problemNotYourDevice.
  ///
  /// In en, this message translates to:
  /// **'That isn’t your device.'**
  String get problemNotYourDevice;

  /// No description provided for @problemDeviceOfAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'This device belongs to another account.'**
  String get problemDeviceOfAnotherAccount;

  /// No description provided for @problemOwnMessagesOnly.
  ///
  /// In en, this message translates to:
  /// **'You may only delete your own messages.'**
  String get problemOwnMessagesOnly;

  /// No description provided for @problemChannelFull.
  ///
  /// In en, this message translates to:
  /// **'This channel is full.'**
  String get problemChannelFull;

  /// No description provided for @problemInviteUsed.
  ///
  /// In en, this message translates to:
  /// **'This invite was already used or has expired.'**
  String get problemInviteUsed;

  /// No description provided for @problemTooManyInvites.
  ///
  /// In en, this message translates to:
  /// **'Too many unused invites. Wait until some expire.'**
  String get problemTooManyInvites;

  /// No description provided for @problemJoinChannelFirst.
  ///
  /// In en, this message translates to:
  /// **'Join the channel first.'**
  String get problemJoinChannelFirst;

  /// No description provided for @problemNotInVoice.
  ///
  /// In en, this message translates to:
  /// **'You’re not in a voice channel.'**
  String get problemNotInVoice;

  /// No description provided for @problemNotInThatChannel.
  ///
  /// In en, this message translates to:
  /// **'You’re not in that channel.'**
  String get problemNotInThatChannel;

  /// No description provided for @problemPersonNotInYourChannel.
  ///
  /// In en, this message translates to:
  /// **'That person isn’t in your channel.'**
  String get problemPersonNotInYourChannel;

  /// No description provided for @problemDeviceNotInChannel.
  ///
  /// In en, this message translates to:
  /// **'That device isn’t in the channel.'**
  String get problemDeviceNotInChannel;

  /// No description provided for @problemDeviceNotOnline.
  ///
  /// In en, this message translates to:
  /// **'That device isn’t online or may not enter.'**
  String get problemDeviceNotOnline;

  /// No description provided for @problemVoiceNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Voice isn’t set up on this server.'**
  String get problemVoiceNotConfigured;

  /// No description provided for @problemSummonNeedsAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with an account to summon.'**
  String get problemSummonNeedsAccount;

  /// No description provided for @problemCantSummonYourself.
  ///
  /// In en, this message translates to:
  /// **'You can’t summon yourself.'**
  String get problemCantSummonYourself;

  /// No description provided for @problemAlreadyHere.
  ///
  /// In en, this message translates to:
  /// **'They’re already here.'**
  String get problemAlreadyHere;

  /// No description provided for @problemSummonsOff.
  ///
  /// In en, this message translates to:
  /// **'They turned summons off.'**
  String get problemSummonsOff;

  /// No description provided for @problemSummonedRecently.
  ///
  /// In en, this message translates to:
  /// **'You summoned them less than 5 minutes ago.'**
  String get problemSummonedRecently;

  /// No description provided for @problemMessageLength.
  ///
  /// In en, this message translates to:
  /// **'A message is 1 to 2000 characters.'**
  String get problemMessageLength;

  /// No description provided for @problemUploadPictureFirst.
  ///
  /// In en, this message translates to:
  /// **'The picture didn’t upload.'**
  String get problemUploadPictureFirst;

  /// No description provided for @problemPictureNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'This chat doesn’t take this picture.'**
  String get problemPictureNotAccepted;

  /// No description provided for @problemChatHasNoKey.
  ///
  /// In en, this message translates to:
  /// **'This chat has no key yet.'**
  String get problemChatHasNoKey;

  /// No description provided for @problemNobodyHasChatKey.
  ///
  /// In en, this message translates to:
  /// **'Nobody online has this chat’s key.'**
  String get problemNobodyHasChatKey;

  /// No description provided for @problemNotCurrentChatKey.
  ///
  /// In en, this message translates to:
  /// **'That isn’t the chat’s current key.'**
  String get problemNotCurrentChatKey;

  /// No description provided for @problemChatKeyChanged.
  ///
  /// In en, this message translates to:
  /// **'The chat’s key changed. Try again.'**
  String get problemChatKeyChanged;

  /// No description provided for @problemEnvelopesForAnotherKey.
  ///
  /// In en, this message translates to:
  /// **'The keys were sealed for another chat key.'**
  String get problemEnvelopesForAnotherKey;

  /// No description provided for @problemSealForYourself.
  ///
  /// In en, this message translates to:
  /// **'Seal the key for yourself too.'**
  String get problemSealForYourself;

  /// No description provided for @problemSealDeviceCount.
  ///
  /// In en, this message translates to:
  /// **'A key is sealed for 1 to 1000 devices.'**
  String get problemSealDeviceCount;

  /// No description provided for @problemNoLongerAllowed.
  ///
  /// In en, this message translates to:
  /// **'You no longer have access to this channel.'**
  String get problemNoLongerAllowed;

  /// No description provided for @problemJoinedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'You joined from another device.'**
  String get problemJoinedElsewhere;

  /// No description provided for @problemKickedBy.
  ///
  /// In en, this message translates to:
  /// **'{by} removed you from the channel.'**
  String problemKickedBy(String by);

  /// No description provided for @problemGuestRemovedBy.
  ///
  /// In en, this message translates to:
  /// **'{by} removed you. Guests from your address are blocked for a day.'**
  String problemGuestRemovedBy(String by);

  /// No description provided for @problemBannedFromServer.
  ///
  /// In en, this message translates to:
  /// **'You’re banned from this server.'**
  String get problemBannedFromServer;

  /// No description provided for @problemGuestSignInClosedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'An admin closed guest sign-in.'**
  String get problemGuestSignInClosedByAdmin;

  /// No description provided for @problemHelloFirst.
  ///
  /// In en, this message translates to:
  /// **'The connection wasn’t ready. Reload the page.'**
  String get problemHelloFirst;

  /// No description provided for @problemUnreadableCommand.
  ///
  /// In en, this message translates to:
  /// **'The server couldn’t read that. Reload the page.'**
  String get problemUnreadableCommand;

  /// No description provided for @problemUnsupportedProtocol.
  ///
  /// In en, this message translates to:
  /// **'This version of Wisetalk is too old for the server. Reload the page.'**
  String get problemUnsupportedProtocol;

  /// No description provided for @problemSlowDown.
  ///
  /// In en, this message translates to:
  /// **'Slow down a little.'**
  String get problemSlowDown;

  /// No description provided for @problemTooManyCommands.
  ///
  /// In en, this message translates to:
  /// **'Too many actions at once. Slow down a little.'**
  String get problemTooManyCommands;

  /// No description provided for @problemGone.
  ///
  /// In en, this message translates to:
  /// **'That’s gone.'**
  String get problemGone;

  /// No description provided for @problemInternal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server.'**
  String get problemInternal;

  /// No description provided for @problemTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That’s too big to send.'**
  String get problemTooLarge;

  /// No description provided for @problemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The server isn’t answering. Try again in a minute.'**
  String get problemUnavailable;
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
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

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
