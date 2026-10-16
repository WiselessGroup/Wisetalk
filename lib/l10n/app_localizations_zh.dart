// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatVanishes => 'Messages vanish 4 h after the last one';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Clears in $hours h $minutes min unless someone writes';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Clears in $minutes min unless someone writes';
  }

  @override
  String get chatClose => 'Close Chat';

  @override
  String get chatEmpty => 'No messages yet. Say hi!';

  @override
  String get chatLoading => 'Loading…';

  @override
  String get chatGettingKey => 'Getting the chat key…';

  @override
  String get chatSendingPicture => 'Sending the picture…';

  @override
  String get chatPreparingPicture => 'Preparing the picture…';

  @override
  String get chatAddPicture => 'Add Picture';

  @override
  String chatMessageTo(String channel) {
    return 'Message $channel';
  }

  @override
  String get chatSend => 'Send';

  @override
  String get chatLocked =>
      'Encrypted with a key this device doesn\'t have: sent before it joined the chat.';

  @override
  String get chatGuest => 'guest';

  @override
  String get chatDeleteMessage => 'Delete Message';

  @override
  String get chatPictures => 'Pictures';

  @override
  String get chatInvalidMessage =>
      'A message is 1 to 2000 characters, without control characters.';

  @override
  String chatPictureNotSent(String reason) {
    return 'The picture didn\'t go out: $reason';
  }

  @override
  String get pictureFailed => 'Picture didn\'t load';

  @override
  String get pictureTooLarge => 'This picture is too large.';

  @override
  String get pictureUnreadable => 'This picture can\'t be read.';

  @override
  String trustNewDevice(String name) {
    return '$name joined from a new device.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new devices signed in to your account.',
      one: 'A new device signed in to your account.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Careful: a device of your account came with another key.';

  @override
  String get personKeyChanged => 'Careful: their device key has changed.';

  @override
  String get notificationOpen => 'Open';

  @override
  String get notificationChannel => 'Messages and summons';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller is calling you';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Join $channel';
  }

  @override
  String get signInErrorRefused => 'Sign-in was cancelled.';

  @override
  String get signInErrorExpired => 'Sign-in took too long. Try again.';

  @override
  String get signInErrorBanned => 'This account is banned on this server.';

  @override
  String get signInErrorUnavailable =>
      'Account sign-in is not available right now.';

  @override
  String get signInErrorFailed => 'Sign-in failed. Try again.';

  @override
  String get signInNoBrowser => 'Can\'t open the browser to sign in.';

  @override
  String get signInBrowserDone =>
      'You\'re signed in. You can close this tab and go back to Wisetalk.';

  @override
  String get signInBrowserFailed =>
      'Signing in did not work. Go back to Wisetalk to try again.';

  @override
  String get updatesNotSelfUpdating =>
      'This build of Wisetalk doesn’t update itself.';

  @override
  String get updatesCannotCheck => 'Cannot check for updates. Try again later.';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version is ready: Restart to Update.';
  }

  @override
  String updatesAvailable(String version) {
    return 'Wisetalk $version is out: Update to $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version is the latest.';
  }

  @override
  String get voiceMutedByModerator =>
      'A moderator muted you; only they can lift it.';

  @override
  String get voiceCameraUnavailable => 'Camera unavailable.';

  @override
  String get voiceCannotSwitchCamera => 'Cannot switch to that camera.';

  @override
  String get voiceScreenUnavailable => 'Screen sharing unavailable.';

  @override
  String get voiceServerMuted => 'A moderator muted you.';

  @override
  String get voiceServerUnmuted =>
      'A moderator lifted your mute. Unmute when you are ready.';

  @override
  String voiceKicked(String reason) {
    return 'You left the channel: $reason.';
  }

  @override
  String get voiceCannotConnect => 'Cannot connect to voice.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Microphone unavailable: you can listen, but not speak.';

  @override
  String get videoYou => 'You';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'You were signed out.';

  @override
  String get apiUnreachable => 'Can\'t reach the server.';

  @override
  String get apiUnreachableCheck =>
      'Can\'t reach the server. Check the address and your connection.';

  @override
  String get apiNotWisetalk => 'That doesn\'t look like a Wisetalk server.';

  @override
  String apiRefused(int status) {
    return 'The server said no ($status).';
  }

  @override
  String get desktopComment => 'Voice and video chat for one community';

  @override
  String personYou(String name) {
    return '$name (you)';
  }

  @override
  String get personAudioVideoSettings => 'Audio and Video Settings…';

  @override
  String personVolume(int percent) {
    return 'Volume $percent%';
  }

  @override
  String get personMuteForMe => 'Mute for Me';

  @override
  String get personUnmuteForMe => 'Unmute for Me';

  @override
  String get moderationServerMute => 'Server Mute';

  @override
  String get moderationLiftServerMute => 'Lift Server Mute';

  @override
  String get moderationKick => 'Kick from Channel';

  @override
  String get personMakeServerAdmin => 'Make Server Admin';

  @override
  String get personRemoveServerAdmin => 'Remove Server Admin';

  @override
  String personNowAdmin(String name) {
    return '$name is now a server admin.';
  }

  @override
  String personNowMember(String name) {
    return '$name is now a member.';
  }

  @override
  String get moderationBan => 'Ban from Server…';

  @override
  String moderationBanTitle(String name) {
    return 'Ban $name?';
  }

  @override
  String moderationBanConfirm(String name) {
    return 'Ban $name from this server? Their sessions end right away.';
  }

  @override
  String get moderationBanAction => 'Ban';

  @override
  String moderationBanned(String name) {
    return '$name is banned.';
  }

  @override
  String get moderationBanGuest => 'Ban Guest for a Day…';

  @override
  String moderationBanGuestConfirm(String name) {
    return 'Remove $name and block guests from their address for a day?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name is out; their address is blocked for a day.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Make Owner of $channel';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Remove as Owner of $channel';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name now owns $channel.';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel has no owner now.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Make Owner of $space';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Remove as Owner of $space';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name now owns $space.';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space has no owner now.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Audio up to $kbps kbps, stereo';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Audio up to $kbps kbps, mono';
  }

  @override
  String get channelJoin => 'Join';

  @override
  String get channelOpenChat => 'Open Chat';

  @override
  String get channelOpenSettings => 'Channel Settings…';

  @override
  String get inviteCopyLink => 'Copy Invite Link';

  @override
  String inviteCopied(String channel) {
    return 'Invite link to $channel copied.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Invite to $channel copied. Once someone uses it, it lets anyone in for 10 minutes; unused, it lasts a day.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Invite link to $channel copied. It only works for people the channel already lets in.';
  }

  @override
  String get inviteCannotCreate => 'Cannot create an invite.';

  @override
  String get spaceNewChannel => 'New Channel in Space…';

  @override
  String get spaceOpenSettings => 'Space Settings…';

  @override
  String get spaceDelete => 'Delete Space…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'Delete the space $space? Its channels move to the top level.';
  }

  @override
  String get workspaceMoveUp => 'Move Up';

  @override
  String get workspaceMoveDown => 'Move Down';

  @override
  String get workspaceCannotReorder => 'Cannot reorder.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbps (speech)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbps (music)';
  }

  @override
  String get createNewChannel => 'New Channel';

  @override
  String get createNewSpace => 'New Space';

  @override
  String get createSubmit => 'Create';

  @override
  String get createChannel => 'Channel';

  @override
  String get createSpace => 'Space';

  @override
  String get createChannelHint =>
      'A voice room people join, with its own chat.';

  @override
  String get createSpaceHint => 'A folder that groups channels in the sidebar.';

  @override
  String get createChannelPlaceholder => 'Team Blue';

  @override
  String get channelSettingsTitle => 'Channel Settings';

  @override
  String get channelSettingsOwnerHint =>
      'The owner manages this channel. Only admins choose who owns it.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return 'Delete $name? Everyone inside is dropped.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'People and Sound';

  @override
  String get channelSettingsMaxPeople => 'Max People';

  @override
  String get channelSettingsNoLimit => 'No limit';

  @override
  String get channelSettingsAudioQuality => 'Audio Quality';

  @override
  String get channelSettingsStereo => 'Stereo';

  @override
  String get channelSettingsDelete => 'Delete Channel…';

  @override
  String get manageSpace => 'Space';

  @override
  String get manageOwner => 'Owner';

  @override
  String get manageAccess => 'Access';

  @override
  String get spaceSettingsTitle => 'Space Settings';

  @override
  String get spaceSettingsOwnerHint =>
      'The owner manages the space and every channel in it. Only admins choose who owns it.';

  @override
  String get accessAccountsOnly => 'Accounts Only';

  @override
  String get accessAccountsOnlyDetail => 'No guests';

  @override
  String get accessWhitelistOnly => 'Whitelist Only';

  @override
  String get accessHidden => 'Hidden';

  @override
  String get accessHiddenDetail => 'Invisible to those who may not enter';

  @override
  String get accessFromSpace => 'Set by the space';

  @override
  String summonsTitle(String channel) {
    return 'Summon to $channel';
  }

  @override
  String get summonsSummon => 'Summon';

  @override
  String get summonsNickname => 'Nickname';

  @override
  String get summonsNoMatch => 'Nobody matching who could come here.';

  @override
  String get summonsHint =>
      'They get a notification that you are waiting. Once per 5 minutes per person.';

  @override
  String get summonsSearchFailed => 'Cannot search.';

  @override
  String get manageDeviceKey => 'Device Key';

  @override
  String manageDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get manageDelete => 'Delete';

  @override
  String get manageSave => 'Save';

  @override
  String get manageName => 'Name';

  @override
  String get manageNone => 'None';

  @override
  String get manageNobody => 'Nobody';

  @override
  String get manageSomeoneElse => 'Someone else';

  @override
  String get manageWhitelistInWeb =>
      'Edit the whitelist in the web client for now.';

  @override
  String get channelSettingsLimitHint =>
      'When the channel is full, only people who manage it can still join. From 1 to 99 people, or no limit.';

  @override
  String get spaceSettingsAccessHint =>
      'These limits apply to every channel in the space; a channel can only add its own. Edit the whitelist in the web client for now.';

  @override
  String get accessWhitelistOnlyListDetail =>
      'Only the people and roles on its list';

  @override
  String get summonsWho => 'Who?';

  @override
  String get settingsPictures => 'Pictures';

  @override
  String get profileAddPicture => 'Add Picture…';

  @override
  String get profileChangePicture => 'Change Picture…';

  @override
  String get profileRemovePicture => 'Remove Picture';

  @override
  String get profileUploadFailed => 'Cannot upload the picture.';

  @override
  String get profileRemoveFailed => 'Cannot remove the picture.';

  @override
  String get saveFailed => 'Cannot save.';

  @override
  String get settingsAudioVideo => 'Audio and Video';

  @override
  String get settingsMicrophone => 'Microphone';

  @override
  String get settingsCamera => 'Camera';

  @override
  String get settingsOutput => 'Output';

  @override
  String get settingsVoiceProcessing => 'Voice Processing';

  @override
  String get settingsVoiceProcessingDetail =>
      'Noise suppression and echo cancellation';

  @override
  String get settingsVoiceProcessingHint =>
      'Turn it off for the best sound, and wear headphones then: without echo cancellation others hear themselves through your speakers.';

  @override
  String get settingsCues => 'Join and Leave Sounds';

  @override
  String get settingsCuesDetail =>
      'An owl hoots when someone comes or goes, and shortcuts tick';

  @override
  String get settingsPingAndLoss => 'Show Ping and Loss';

  @override
  String get settingsPingAndLossDetail =>
      'Next to the connection icon in a call';

  @override
  String get summonsHeader => 'Summons';

  @override
  String get summonsAllow => 'Others May Summon Me';

  @override
  String get settingsNotificationsHere => 'Notifications on This Device';

  @override
  String get settingsNotificationsHint =>
      'Shown while Wisetalk is in the background.';

  @override
  String get settingsNotifyMessages => 'New Messages';

  @override
  String get settingsNotifyMessagesDetail =>
      'In your call’s chat and chats you opened';

  @override
  String get settingsNotifySummons => 'Summons';

  @override
  String get settingsNotifySummonsDetail =>
      'When someone calls you into a channel';

  @override
  String get settingsPushHeader => 'While Wisetalk Is Closed';

  @override
  String get settingsPushApp => 'Push App';

  @override
  String get settingsPushAppNone => 'None';

  @override
  String get settingsPushAppChoose => 'Choose…';

  @override
  String get settingsGetNtfy => 'Get ntfy';

  @override
  String settingsPushVia(String app) {
    return 'Summons reach this phone through $app, even while Wisetalk is closed.';
  }

  @override
  String get settingsPushChooseHint =>
      'Choose the app that brings summons while Wisetalk is closed.';

  @override
  String get settingsPushNoneHint =>
      'Without a push app, summons show only while Wisetalk runs. Install ntfy, then in its settings make your community’s ntfy server the default server.';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsCrashReports => 'Send Crash Reports';

  @override
  String get settingsCrashReportsHint =>
      'When something in Wisetalk breaks, tell its developers what broke and where in the code. Never your messages, names, keys or servers.';

  @override
  String get settingsShortcuts => 'Shortcuts';

  @override
  String get settingsShortcutsRecording =>
      'Press the new keys. Backspace removes the shortcut, Esc keeps it.';

  @override
  String get settingsShortcutsGlobal =>
      'In a call they work whatever app is in front, otherwise in Wisetalk’s window. Click one to change it.';

  @override
  String get settingsShortcutsWayland =>
      'On Wayland they work only while Wisetalk’s window is in front. Click one to change it.';

  @override
  String get settingsShortcutPressKeys => 'Press keys…';

  @override
  String get settingsShortcutNone => 'None';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys is already $action.';
  }

  @override
  String get shortcutToggleMute => 'Microphone On or Off';

  @override
  String get shortcutToggleAway => 'Away or Back';

  @override
  String get shortcutMute => 'Microphone Off';

  @override
  String get shortcutUnmute => 'Microphone On';

  @override
  String get shortcutUnusableKey => 'That key can’t be used for a shortcut.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Add $first or $second, or use F1 to F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys belongs to the system or to every app.';
  }

  @override
  String get sheetDiscardTitle => 'Discard Changes?';

  @override
  String get sheetDiscardMessage => 'What you changed here is not saved yet.';

  @override
  String get sheetDiscard => 'Discard';

  @override
  String get sheetKeepEditing => 'Keep Editing';

  @override
  String serversRemoveTitle(String server) {
    return 'Remove $server?';
  }

  @override
  String get serversRemoveMessage =>
      'This device signs out of it and forgets it. You can add it again with its address.';

  @override
  String get serversRemove => 'Remove';

  @override
  String get serversAddressHelp =>
      'Ask whoever runs your community for its address.';

  @override
  String get serversConnecting => 'Connecting…';

  @override
  String get serversConnect => 'Connect';

  @override
  String get serversWhich => 'Which server is your community on?';

  @override
  String get serversYours => 'Your Servers';

  @override
  String get serversAddMenu => 'Add a Server…';

  @override
  String get serversAddTitle => 'Add a Server';

  @override
  String get serversBadAddress =>
      'Type the address of a server, like talk.example.com.';

  @override
  String get serversTooNew =>
      'This server is newer than this app. Update Wisetalk to join it.';

  @override
  String get serversTooOld =>
      'This server runs an older Wisetalk. Ask its admins to update it.';

  @override
  String serversTooOldVersion(String version) {
    return 'This server runs an older Wisetalk ($version). Ask its admins to update it.';
  }

  @override
  String get serversAddress => 'Address';

  @override
  String get serversMore => 'More';

  @override
  String get serversRemoveServer => 'Remove Server';

  @override
  String get channelSomeChannel => 'a channel';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name in $channel';
  }

  @override
  String get workspaceMessageEncrypted => 'Wrote an encrypted message.';

  @override
  String get workspaceMessagePicture => 'Sent a picture.';

  @override
  String summonPushed(String name) {
    return '$name got a notification.';
  }

  @override
  String get summonPushedSomeone => 'They got a notification.';

  @override
  String summonNotPushed(String name) {
    return 'Summoned $name. They have notifications off, so only an open Wisetalk shows it.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Summoned. They have notifications off, so only an open Wisetalk shows it.';

  @override
  String summonReceived(String from, String channel) {
    return '$from summons you to $channel.';
  }

  @override
  String get workspaceSummoned => 'Summoned';

  @override
  String get workspaceRoleChangedOwner => 'Your server role is now owner.';

  @override
  String get workspaceRoleChangedAdmin => 'Your server role is now admin.';

  @override
  String get workspaceRoleChangedModerator =>
      'Your server role is now moderator.';

  @override
  String get workspaceRoleChangedMember => 'Your server role is now member.';

  @override
  String get workspaceRoleChangedGuest => 'Your server role is now guest.';

  @override
  String get takeOverTitle => 'Join from This Device?';

  @override
  String takeOverSameChannel(String channel) {
    return 'You’re already in $channel on another device or tab. Joining $channel here takes you out of the call there.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'You’re in $there on another device or tab. Joining $here here takes you out of the call there.';
  }

  @override
  String get takeOverElsewhere =>
      'You’re in a call on another device or tab. Joining here takes you out of the call there.';

  @override
  String get takeOverJoinHere => 'Join Here';

  @override
  String get workspaceShowChannels => 'Show channels';

  @override
  String get workspaceHideChannels => 'Hide channels';

  @override
  String workspaceInVoice(int count) {
    return '$count in voice';
  }

  @override
  String get workspaceCreateTitle => 'New Channel or Space';

  @override
  String get workspaceStatusConnecting => 'Connecting…';

  @override
  String get workspaceStatusOffline => 'Offline…';

  @override
  String get workspaceEmptyAdmin =>
      'No channels yet. Create one with the + button.';

  @override
  String get workspaceEmpty => 'No channels yet. An admin can add some.';

  @override
  String get workspaceMore => 'More';

  @override
  String get workspaceCheckForUpdates => 'Check for Updates';

  @override
  String get workspaceChangeServer => 'Change Server';

  @override
  String get workspaceSignOut => 'Sign Out';

  @override
  String get personMutedForYou => 'Muted for you';

  @override
  String get awayTitle => 'Away';

  @override
  String get awayDescription => 'Away: microphone and sound off';

  @override
  String get callMutedByModerator => 'Muted by a moderator';

  @override
  String workspaceDrag(String name) {
    return 'Drag $name';
  }

  @override
  String get workspaceDropEndHint => 'Drop here for the end of the list';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version is downloaded';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Wisetalk $version is out';
  }

  @override
  String get workspaceRestartToUpdate => 'Restart to Update';

  @override
  String workspaceUpdateTo(String version) {
    return 'Update to $version';
  }

  @override
  String get workspaceWelcomeTitle => 'Pick a Voice Channel';

  @override
  String get workspaceWelcomeHint => 'Click a channel to join.';

  @override
  String get callJoining => 'Joining…';

  @override
  String get callWaitingForKey => 'Waiting for the call key…';

  @override
  String get callEncrypted => 'End-to-end encrypted';

  @override
  String videoScreen(String name) {
    return '$name · screen';
  }

  @override
  String get connectionExcellent => 'Excellent';

  @override
  String get connectionGood => 'Good';

  @override
  String get connectionPoor => 'Poor';

  @override
  String get connectionLost => 'Lost';

  @override
  String get connectionChecking => 'Checking';

  @override
  String connectionStatus(String quality) {
    return 'Connection: $quality';
  }

  @override
  String get connectionLabel => 'Connection';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · $loss loss';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping, loss $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => 'Outgoing Loss';

  @override
  String get connectionIncomingLoss => 'Incoming Loss';

  @override
  String get connectionJitter => 'Jitter';

  @override
  String get connectionMicrophone => 'Microphone';

  @override
  String get connectionNotSending => 'Not sending';

  @override
  String connectionKilobits(int value) {
    return '$value kbps';
  }

  @override
  String get screenShareTitle => 'Share Your Screen';

  @override
  String get screenShareAction => 'Share';

  @override
  String get screenShareBestFor => 'Best For';

  @override
  String get screenShareAndroidHint =>
      'Android asks next whether to share the entire screen or one app. Without sound, for now.';

  @override
  String get screenShareWaylandHint =>
      'The first time, your system asks which screen to share. Later shares reuse that screen until Wisetalk restarts. Whole screens only, without sound, for now.';

  @override
  String get screenShareText => 'Text and Slides';

  @override
  String get screenShareTextDetail => 'Sharp and light: a few frames a second.';

  @override
  String get screenShareMotion => 'Video and Games';

  @override
  String get screenShareMotionDetail =>
      'Smooth: 30 frames a second, heavier on both ends.';

  @override
  String get screenShareSource => 'Screen or Window';

  @override
  String get screenShareSound => 'Share Sound';

  @override
  String get screenShareSoundWindow => 'Only this window\'s app.';

  @override
  String get screenShareSoundScreen => 'Everything you hear, without the call.';

  @override
  String get screenShareSoundAny =>
      'A window\'s app, or for a screen everything you hear, without the call.';

  @override
  String get screenShareListFailed => 'Can\'t list screens and windows.';

  @override
  String get screenShareChooseTitle => 'Choose a Screen';

  @override
  String get screenShareChooseHint =>
      'Pick the screen to share in your system\'s window.';

  @override
  String get problemNotSignedIn => 'You’re not signed in.';

  @override
  String get problemAccountRequired => 'Sign in with an account first.';

  @override
  String get problemAccountBanned => 'This account is banned.';

  @override
  String get problemSignInCodeInvalid =>
      'This sign-in code is no longer valid. Sign in again.';

  @override
  String get problemBrowserCheckMissing =>
      'The browser check is missing. Reload and try again.';

  @override
  String get problemBrowserCheckFailed =>
      'The browser check failed. Reload and try again.';

  @override
  String get problemBrowserCheckExpired =>
      'The browser check expired. Try again.';

  @override
  String get problemGuestSignInClosed =>
      'Guest sign-in is closed right now. Sign in with an account.';

  @override
  String get problemGuestAddressBlocked =>
      'Guests from this address are blocked for a while.';

  @override
  String get problemTooManyGuests =>
      'Too many guests right now. Try again later or sign in with an account.';

  @override
  String get problemTooManyGuestSignIns =>
      'Too many guest sign-ins from this address. Try again later.';

  @override
  String get problemNameBelongsToAccount => 'This name belongs to an account.';

  @override
  String get problemAccountsCantBeGuests => 'Accounts can’t be guests.';

  @override
  String get problemNoSuchAccount => 'This account doesn’t exist.';

  @override
  String get problemNoSuchChannel => 'This channel doesn’t exist any more.';

  @override
  String get problemNoSuchSpace => 'This space doesn’t exist any more.';

  @override
  String get problemNoSuchEmoji => 'This emoji doesn’t exist.';

  @override
  String get problemNoSuchGuest => 'This guest isn’t online any more.';

  @override
  String get problemNoSuchPicture => 'This picture is gone.';

  @override
  String get problemNoSuchMessage => 'This message is gone.';

  @override
  String get problemNoAvatar => 'There’s no avatar.';

  @override
  String get problemNotBanned => 'This account isn’t banned.';

  @override
  String get problemDisplayNameLength => 'A name is 1 to 32 characters.';

  @override
  String get problemChannelNameLength =>
      'A channel name is 1 to 64 characters.';

  @override
  String get problemSpaceNameLength => 'A space name is 1 to 64 characters.';

  @override
  String get problemEmojiNameInvalid =>
      'An emoji name is 2 to 32 of a–z, 0–9 and _.';

  @override
  String get problemIconInvalid => 'An icon is one emoji or a :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Names are up to 40 characters, the tagline up to 120, without control characters.';

  @override
  String get problemChannelLimitInvalid =>
      'A channel holds 1 to 99 people, or has no limit.';

  @override
  String get problemBitrateInvalid =>
      'The audio bitrate must be 6 to 510 kbit/s.';

  @override
  String get problemPictureType => 'The picture must be PNG, JPEG or WebP.';

  @override
  String get problemAvatarTooLarge => 'The picture is larger than 256 KB.';

  @override
  String get problemEmojiTooLarge => 'The picture is larger than 128 KB.';

  @override
  String get problemChatPictureTooLarge => 'A picture can be up to 20 MB.';

  @override
  String get problemPictureIdTaken => 'This picture is already there.';

  @override
  String get problemChatFullOfPictures =>
      'This chat holds too many pictures until it clears.';

  @override
  String get problemTooManyPictures =>
      'That’s a lot of pictures. Wait a little.';

  @override
  String get problemManageNotPerRole => 'Managing can’t be given per role.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'Owners and admins always have every permission.';

  @override
  String get problemOneOverridePerRole => 'Only one rule per role.';

  @override
  String get problemWhitelistUnknownAccount =>
      'The whitelist names an account that doesn’t exist.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Guests can never pass a whitelist.';

  @override
  String get problemPushSubscriptionInvalid =>
      'The browser sent a broken notification subscription.';

  @override
  String get problemPushEndpointNotPublic =>
      'The notification address must be a public HTTPS address.';

  @override
  String get problemNotAllowedInChannel =>
      'You may not do this in this channel.';

  @override
  String get problemMayNotEnter => 'You may not enter this channel.';

  @override
  String get problemTheyMayNotEnter => 'They may not enter this channel.';

  @override
  String get problemMayNotModerate => 'You may not moderate this channel.';

  @override
  String get problemCantModerateYourself => 'You can’t moderate yourself.';

  @override
  String get problemModerateRank =>
      'You may not moderate someone of your rank or above.';

  @override
  String get problemBanRank => 'You may not ban someone of your rank or above.';

  @override
  String get problemRoleRank =>
      'You may only give roles below yours to people below you.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Only server owners and admins manage the server.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Only server owners and admins manage bans.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Only server owners and admins manage custom emoji.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Only server owners and admins manage spaces.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Only server owners and admins choose channel owners.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Only server owners and admins choose space owners.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Only admins and the space’s owner manage it.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Only admins, and space owners in their space, may create channels.';

  @override
  String get problemMoveIntoOwnSpace =>
      'You may only move channels into a space you manage.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Only people who may moderate the channel hand out invites.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Guests may not create channels.';

  @override
  String get problemGuestsCantInvite => 'Guests can’t invite.';

  @override
  String get problemGuestsCantBan => 'Guests can’t ban.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Guests can’t get notifications.';

  @override
  String get problemGuestsHaveNoAvatar => 'Guests have no avatar.';

  @override
  String get problemNotYourDevice => 'That isn’t your device.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'This device belongs to another account.';

  @override
  String get problemOwnMessagesOnly => 'You may only delete your own messages.';

  @override
  String get problemChannelFull => 'This channel is full.';

  @override
  String get problemInviteUsed =>
      'This invite was already used or has expired.';

  @override
  String get problemTooManyInvites =>
      'Too many unused invites. Wait until some expire.';

  @override
  String get problemJoinChannelFirst => 'Join the channel first.';

  @override
  String get problemNotInVoice => 'You’re not in a voice channel.';

  @override
  String get problemNotInThatChannel => 'You’re not in that channel.';

  @override
  String get problemPersonNotInYourChannel =>
      'That person isn’t in your channel.';

  @override
  String get problemDeviceNotInChannel => 'That device isn’t in the channel.';

  @override
  String get problemDeviceNotOnline =>
      'That device isn’t online or may not enter.';

  @override
  String get problemVoiceNotConfigured => 'Voice isn’t set up on this server.';

  @override
  String get problemSummonNeedsAccount => 'Sign in with an account to summon.';

  @override
  String get problemCantSummonYourself => 'You can’t summon yourself.';

  @override
  String get problemAlreadyHere => 'They’re already here.';

  @override
  String get problemSummonsOff => 'They turned summons off.';

  @override
  String get problemSummonedRecently =>
      'You summoned them less than 5 minutes ago.';

  @override
  String get problemMessageLength => 'A message is 1 to 2000 characters.';

  @override
  String get problemUploadPictureFirst => 'The picture didn’t upload.';

  @override
  String get problemPictureNotAccepted =>
      'This chat doesn’t take this picture.';

  @override
  String get problemChatHasNoKey => 'This chat has no key yet.';

  @override
  String get problemNobodyHasChatKey => 'Nobody online has this chat’s key.';

  @override
  String get problemNotCurrentChatKey => 'That isn’t the chat’s current key.';

  @override
  String get problemChatKeyChanged => 'The chat’s key changed. Try again.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'The keys were sealed for another chat key.';

  @override
  String get problemSealForYourself => 'Seal the key for yourself too.';

  @override
  String get problemSealDeviceCount => 'A key is sealed for 1 to 1000 devices.';

  @override
  String get problemNoLongerAllowed =>
      'You no longer have access to this channel.';

  @override
  String get problemJoinedElsewhere => 'You joined from another device.';

  @override
  String problemKickedBy(String by) {
    return '$by removed you from the channel.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by removed you. Guests from your address are blocked for a day.';
  }

  @override
  String get problemBannedFromServer => 'You’re banned from this server.';

  @override
  String get problemGuestSignInClosedByAdmin =>
      'An admin closed guest sign-in.';

  @override
  String get problemHelloFirst =>
      'The connection wasn’t ready. Reload the page.';

  @override
  String get problemUnreadableCommand =>
      'The server couldn’t read that. Reload the page.';

  @override
  String get problemUnsupportedProtocol =>
      'This version of Wisetalk is too old for the server. Reload the page.';

  @override
  String get problemSlowDown => 'Slow down a little.';

  @override
  String get problemTooManyCommands =>
      'Too many actions at once. Slow down a little.';

  @override
  String get problemGone => 'That’s gone.';

  @override
  String get problemInternal => 'Something went wrong on the server.';

  @override
  String get problemTooLarge => 'That’s too big to send.';

  @override
  String get problemUnavailable =>
      'The server isn’t answering. Try again in a minute.';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get brandingTagline => '為你的社群打造的語音與視訊聊天';

  @override
  String get brandingSignIn => '登入';

  @override
  String brandingSignInWith(String provider) {
    return '使用 $provider 登入';
  }

  @override
  String brandingHostedBy(String community) {
    return '由 $community 託管。';
  }

  @override
  String get signInServers => '伺服器';

  @override
  String get signInUnreachable => '無法連線到伺服器。';

  @override
  String get tryAgain => '再試一次';

  @override
  String get cancel => '取消';

  @override
  String get signInInBrowser => '請在瀏覽器中繼續…';

  @override
  String get signInAccountHelp => '你的名稱、頭像和呼叫，走到哪裡都跟著你。';

  @override
  String get signInOr => '或';

  @override
  String get signInGuest => '以訪客身分加入';

  @override
  String get signInGuestName => '你的名稱';

  @override
  String get signInGuestHelp => '訪客可以說話和收聽，但無法分享視訊，也無法被呼叫。';

  @override
  String get signInJoining => '正在加入…';

  @override
  String get signInAsGuest => '以訪客身分繼續';

  @override
  String get signInNobody => '這個伺服器目前不讓任何人進入。';

  @override
  String get signInGuestsClosed => '訪客登入暫時關閉。';

  @override
  String get signInEncrypted => '通話採用端對端加密。';

  @override
  String get signInNameLength => '名稱長度須為 1 到 32 個字元。';

  @override
  String get callMute => '靜音';

  @override
  String get callUnmute => '取消靜音';

  @override
  String get callCameraOn => '開啟攝影機';

  @override
  String get callCameraOff => '關閉攝影機';

  @override
  String get callShareScreen => '分享螢幕';

  @override
  String get callStopSharing => '停止分享';

  @override
  String get callLeave => '離開';

  @override
  String get callServiceChannel => '通話';

  @override
  String get callServiceInCall => '語音通話中';

  @override
  String get callServiceSharing => '正在分享你的螢幕';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsSystemDefault => '系統預設';

  @override
  String get settingsDone => '完成';

  @override
  String get chatTitle => '聊天';

  @override
  String get chatVanishes => '訊息會在最後一則發出 4 小時後消失';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return '若無人發言，將於 $hours 小時 $minutes 分鐘後清除';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return '若無人發言，將於 $minutes 分鐘後清除';
  }

  @override
  String get chatClose => '關閉聊天';

  @override
  String get chatEmpty => '還沒有訊息，打聲招呼吧！';

  @override
  String get chatLoading => '載入中…';

  @override
  String get chatGettingKey => '正在取得聊天金鑰…';

  @override
  String get chatSendingPicture => '正在傳送圖片…';

  @override
  String get chatPreparingPicture => '正在準備圖片…';

  @override
  String get chatAddPicture => '加入圖片';

  @override
  String chatMessageTo(String channel) {
    return '傳訊息到 $channel';
  }

  @override
  String get chatSend => '傳送';

  @override
  String get chatLocked => '以此裝置沒有的金鑰加密：在此裝置加入聊天前傳送。';

  @override
  String get chatGuest => '訪客';

  @override
  String get chatDeleteMessage => '刪除訊息';

  @override
  String get chatPictures => '圖片';

  @override
  String get chatInvalidMessage => '訊息長度須為 1 到 2000 個字元，且不得含控制字元。';

  @override
  String chatPictureNotSent(String reason) {
    return '圖片未送出：$reason';
  }

  @override
  String get pictureFailed => '圖片未載入';

  @override
  String get pictureTooLarge => '此圖片太大。';

  @override
  String get pictureUnreadable => '無法讀取此圖片。';

  @override
  String trustNewDevice(String name) {
    return '$name 從新裝置加入。';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 個新裝置登入了你的帳號。',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged => '注意：你帳號中的某個裝置使用了不同的金鑰。';

  @override
  String get personKeyChanged => '注意：這個人的裝置金鑰已變更。';

  @override
  String get notificationOpen => '開啟';

  @override
  String get notificationChannel => '訊息與呼叫';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller 正在呼叫你';
  }

  @override
  String notificationSummonBody(String channel) {
    return '加入 $channel';
  }

  @override
  String get signInErrorRefused => '已取消登入。';

  @override
  String get signInErrorExpired => '登入逾時，請再試一次。';

  @override
  String get signInErrorBanned => '這個帳號已被此伺服器封鎖。';

  @override
  String get signInErrorUnavailable => '目前無法使用帳號登入。';

  @override
  String get signInErrorFailed => '登入失敗，請再試一次。';

  @override
  String get signInNoBrowser => '無法開啟瀏覽器進行登入。';

  @override
  String get signInBrowserDone => '你已登入。可以關閉這個分頁，回到 Wisetalk。';

  @override
  String get signInBrowserFailed => '登入沒有成功。請回到 Wisetalk 再試一次。';

  @override
  String get updatesNotSelfUpdating => '這個 Wisetalk 版本不會自動更新。';

  @override
  String get updatesCannotCheck => '無法檢查更新，請稍後再試。';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version 已就緒：重新啟動即可更新。';
  }

  @override
  String updatesAvailable(String version) {
    return 'Wisetalk $version 已推出：請更新至 $version。';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version 已是最新版本。';
  }

  @override
  String get voiceMutedByModerator => '版主已將你靜音，只有版主能解除。';

  @override
  String get voiceCameraUnavailable => '無法使用攝影機。';

  @override
  String get voiceCannotSwitchCamera => '無法切換到該攝影機。';

  @override
  String get voiceScreenUnavailable => '無法使用螢幕分享。';

  @override
  String get voiceServerMuted => '版主已將你靜音。';

  @override
  String get voiceServerUnmuted => '版主已解除你的靜音。準備好後再開啟麥克風。';

  @override
  String voiceKicked(String reason) {
    return '你已離開頻道：$reason。';
  }

  @override
  String get voiceCannotConnect => '無法連線到語音頻道。';

  @override
  String get voiceMicrophoneUnavailable => '無法使用麥克風：你可以聆聽，但無法發言。';

  @override
  String get videoYou => '你';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => '你已被登出。';

  @override
  String get apiUnreachable => '無法連線到伺服器。';

  @override
  String get apiUnreachableCheck => '無法連線到伺服器。請檢查位址和網路連線。';

  @override
  String get apiNotWisetalk => '這看起來不像 Wisetalk 伺服器。';

  @override
  String apiRefused(int status) {
    return '伺服器拒絕了請求（$status）。';
  }

  @override
  String get desktopComment => '為一個社群打造的語音與視訊聊天';

  @override
  String personYou(String name) {
    return '$name（你）';
  }

  @override
  String get personAudioVideoSettings => '音訊與視訊設定…';

  @override
  String personVolume(int percent) {
    return '音量 $percent%';
  }

  @override
  String get personMuteForMe => '為我靜音';

  @override
  String get personUnmuteForMe => '為我取消靜音';

  @override
  String get moderationServerMute => '伺服器靜音';

  @override
  String get moderationLiftServerMute => '解除伺服器靜音';

  @override
  String get moderationKick => '踢出頻道';

  @override
  String get personMakeServerAdmin => '設為伺服器管理員';

  @override
  String get personRemoveServerAdmin => '移除伺服器管理員';

  @override
  String personNowAdmin(String name) {
    return '$name 現在是伺服器管理員。';
  }

  @override
  String personNowMember(String name) {
    return '$name 現在是成員。';
  }

  @override
  String get moderationBan => '從伺服器封鎖…';

  @override
  String moderationBanTitle(String name) {
    return '要封鎖 $name 嗎？';
  }

  @override
  String moderationBanConfirm(String name) {
    return '要在這個伺服器封鎖 $name 嗎？對方的工作階段會立即結束。';
  }

  @override
  String get moderationBanAction => '封鎖';

  @override
  String moderationBanned(String name) {
    return '已封鎖 $name。';
  }

  @override
  String get moderationBanGuest => '封鎖訪客一天…';

  @override
  String moderationBanGuestConfirm(String name) {
    return '要移除 $name，並封鎖該位址的訪客一天嗎？';
  }

  @override
  String moderationGuestBanned(String name) {
    return '已移除 $name，該位址封鎖一天。';
  }

  @override
  String channelMakeOwner(String channel) {
    return '設為 $channel 的擁有者';
  }

  @override
  String channelRemoveOwner(String channel) {
    return '移除 $channel 的擁有者身分';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name 現在是 $channel 的擁有者。';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel 現在沒有擁有者。';
  }

  @override
  String spaceMakeOwner(String space) {
    return '設為 $space 的擁有者';
  }

  @override
  String spaceRemoveOwner(String space) {
    return '移除 $space 的擁有者身分';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name 現在是 $space 的擁有者。';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space 現在沒有擁有者。';
  }

  @override
  String channelAudioStereo(int kbps) {
    return '音訊最高 $kbps kbps，立體聲';
  }

  @override
  String channelAudioMono(int kbps) {
    return '音訊最高 $kbps kbps，單聲道';
  }

  @override
  String get channelJoin => '加入';

  @override
  String get channelOpenChat => '開啟聊天';

  @override
  String get channelOpenSettings => '頻道設定…';

  @override
  String get inviteCopyLink => '複製邀請連結';

  @override
  String inviteCopied(String channel) {
    return '已複製 $channel 的邀請連結。';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return '已複製 $channel 的邀請。有人使用後，10 分鐘內任何人都能進入；若未使用，效期為一天。';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return '已複製 $channel 的邀請連結。只有頻道原本就允許的人能使用。';
  }

  @override
  String get inviteCannotCreate => '無法建立邀請。';

  @override
  String get spaceNewChannel => '在空間中新增頻道…';

  @override
  String get spaceOpenSettings => '空間設定…';

  @override
  String get spaceDelete => '刪除空間…';

  @override
  String spaceDeleteConfirm(String space) {
    return '要刪除空間「$space」嗎？其中的頻道會移到最上層。';
  }

  @override
  String get workspaceMoveUp => '上移';

  @override
  String get workspaceMoveDown => '下移';

  @override
  String get workspaceCannotReorder => '無法重新排序。';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbps（語音）';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbps（音樂）';
  }

  @override
  String get createNewChannel => '新增頻道';

  @override
  String get createNewSpace => '新增空間';

  @override
  String get createSubmit => '建立';

  @override
  String get createChannel => '頻道';

  @override
  String get createSpace => '空間';

  @override
  String get createChannelHint => '大家可以加入的語音房間，附有專屬聊天。';

  @override
  String get createSpaceHint => '在側邊欄中將頻道分組的資料夾。';

  @override
  String get createChannelPlaceholder => '藍隊';

  @override
  String get channelSettingsTitle => '頻道設定';

  @override
  String get channelSettingsOwnerHint => '擁有者管理這個頻道。只有管理員能指定擁有者。';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return '要刪除 $name 嗎？裡面的人都會被中斷連線。';
  }

  @override
  String get channelSettingsPeopleAndSound => '人數與聲音';

  @override
  String get channelSettingsMaxPeople => '人數上限';

  @override
  String get channelSettingsNoLimit => '無限制';

  @override
  String get channelSettingsAudioQuality => '音質';

  @override
  String get channelSettingsStereo => '立體聲';

  @override
  String get channelSettingsDelete => '刪除頻道…';

  @override
  String get manageSpace => '空間';

  @override
  String get manageOwner => '擁有者';

  @override
  String get manageAccess => '存取';

  @override
  String get spaceSettingsTitle => '空間設定';

  @override
  String get spaceSettingsOwnerHint => '擁有者管理這個空間和其中所有頻道。只有管理員能指定擁有者。';

  @override
  String get accessAccountsOnly => '僅限帳號';

  @override
  String get accessAccountsOnlyDetail => '不允許訪客';

  @override
  String get accessWhitelistOnly => '僅限白名單';

  @override
  String get accessHidden => '隱藏';

  @override
  String get accessHiddenDetail => '不能進入的人看不到';

  @override
  String get accessFromSpace => '由空間設定';

  @override
  String summonsTitle(String channel) {
    return '呼叫到 $channel';
  }

  @override
  String get summonsSummon => '呼叫';

  @override
  String get summonsNickname => '暱稱';

  @override
  String get summonsNoMatch => '沒有符合且能進入這裡的人。';

  @override
  String get summonsHint => '對方會收到你正在等待的通知。每人每 5 分鐘一次。';

  @override
  String get summonsSearchFailed => '無法搜尋。';

  @override
  String get manageDeviceKey => '裝置金鑰';

  @override
  String manageDeleteTitle(String name) {
    return '要刪除 $name 嗎？';
  }

  @override
  String get manageDelete => '刪除';

  @override
  String get manageSave => '儲存';

  @override
  String get manageName => '名稱';

  @override
  String get manageNone => '無';

  @override
  String get manageNobody => '無人';

  @override
  String get manageSomeoneElse => '其他人';

  @override
  String get manageWhitelistInWeb => '白名單目前請在網頁版中編輯。';

  @override
  String get channelSettingsLimitHint => '頻道滿了之後，只有管理它的人還能加入。可設 1 到 99 人，或不限制。';

  @override
  String get spaceSettingsAccessHint =>
      '這些限制適用於空間內的每個頻道；頻道只能再加上自己的限制。白名單目前請在網頁版中編輯。';

  @override
  String get accessWhitelistOnlyListDetail => '只有名單上的人員和角色';

  @override
  String get summonsWho => '誰？';

  @override
  String get settingsPictures => '圖片';

  @override
  String get profileAddPicture => '加入頭像…';

  @override
  String get profileChangePicture => '更換頭像…';

  @override
  String get profileRemovePicture => '移除頭像';

  @override
  String get profileUploadFailed => '無法上傳圖片。';

  @override
  String get profileRemoveFailed => '無法移除圖片。';

  @override
  String get saveFailed => '無法儲存。';

  @override
  String get settingsAudioVideo => '音訊與視訊';

  @override
  String get settingsMicrophone => '麥克風';

  @override
  String get settingsCamera => '攝影機';

  @override
  String get settingsOutput => '輸出';

  @override
  String get settingsVoiceProcessing => '語音處理';

  @override
  String get settingsVoiceProcessingDetail => '降噪與回音消除';

  @override
  String get settingsVoiceProcessingHint =>
      '關閉可獲得最佳音質，但請戴上耳機：沒有回音消除，其他人會從你的喇叭聽到自己的聲音。';

  @override
  String get settingsCues => '加入與離開提示音';

  @override
  String get settingsCuesDetail => '有人加入或離開時，貓頭鷹會叫一聲；快捷鍵也會發出滴答聲';

  @override
  String get settingsPingAndLoss => '顯示延遲與封包遺失';

  @override
  String get settingsPingAndLossDetail => '在通話中的連線圖示旁';

  @override
  String get summonsHeader => '呼叫';

  @override
  String get summonsAllow => '允許他人呼叫我';

  @override
  String get settingsNotificationsHere => '在此裝置上通知';

  @override
  String get settingsNotificationsHint => 'Wisetalk 在背景執行時顯示。';

  @override
  String get settingsNotifyMessages => '新訊息';

  @override
  String get settingsNotifyMessagesDetail => '你通話中的聊天，以及你開過的聊天';

  @override
  String get settingsNotifySummons => '呼叫';

  @override
  String get settingsNotifySummonsDetail => '有人呼叫你進入頻道時';

  @override
  String get settingsPushHeader => 'Wisetalk 關閉時';

  @override
  String get settingsPushApp => '推播應用程式';

  @override
  String get settingsPushAppNone => '無';

  @override
  String get settingsPushAppChoose => '選擇…';

  @override
  String get settingsGetNtfy => '取得 ntfy';

  @override
  String settingsPushVia(String app) {
    return '即使 Wisetalk 已關閉，呼叫也會透過 $app 送到這支手機。';
  }

  @override
  String get settingsPushChooseHint => '選擇在 Wisetalk 關閉時接收呼叫的應用程式。';

  @override
  String get settingsPushNoneHint =>
      '沒有推播應用程式時，只有在 Wisetalk 執行中才會顯示呼叫。請安裝 ntfy，並在它的設定中將你社群的 ntfy 伺服器設為預設伺服器。';

  @override
  String get settingsPrivacy => '隱私權';

  @override
  String get settingsCrashReports => '傳送當機報告';

  @override
  String get settingsCrashReportsHint =>
      'Wisetalk 出問題時，告訴開發者哪裡壞了、在程式碼的哪個位置。絕不包含你的訊息、名稱、金鑰或伺服器。';

  @override
  String get settingsShortcuts => '快捷鍵';

  @override
  String get settingsShortcutsRecording =>
      '按下新的按鍵。Backspace 移除快捷鍵，Esc 保留原本的設定。';

  @override
  String get settingsShortcutsGlobal =>
      '通話中，無論哪個 App 在前景都能使用；其他時候僅限 Wisetalk 視窗。點一下即可更改。';

  @override
  String get settingsShortcutsWayland =>
      '在 Wayland 上，只有 Wisetalk 視窗在前景時才能使用。點一下即可更改。';

  @override
  String get settingsShortcutPressKeys => '請按下按鍵…';

  @override
  String get settingsShortcutNone => '無';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys 已用於「$action」。';
  }

  @override
  String get shortcutToggleMute => '開啟或關閉麥克風';

  @override
  String get shortcutToggleAway => '暫時離開或回來';

  @override
  String get shortcutMute => '關閉麥克風';

  @override
  String get shortcutUnmute => '開啟麥克風';

  @override
  String get shortcutUnusableKey => '這個按鍵無法用於快捷鍵。';

  @override
  String shortcutTyping(String first, String second) {
    return '請加上 $first 或 $second，或改用 F1 到 F24。';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys 已被系統或所有 App 使用。';
  }

  @override
  String get sheetDiscardTitle => '要捨棄變更嗎？';

  @override
  String get sheetDiscardMessage => '你在這裡的變更尚未儲存。';

  @override
  String get sheetDiscard => '捨棄';

  @override
  String get sheetKeepEditing => '繼續編輯';

  @override
  String serversRemoveTitle(String server) {
    return '要移除 $server 嗎？';
  }

  @override
  String get serversRemoveMessage => '此裝置會登出並忘記這個伺服器。之後可以用它的位址再次加入。';

  @override
  String get serversRemove => '移除';

  @override
  String get serversAddressHelp => '請向管理你社群的人詢問位址。';

  @override
  String get serversConnecting => '連線中…';

  @override
  String get serversConnect => '連線';

  @override
  String get serversWhich => '你的社群在哪個伺服器上？';

  @override
  String get serversYours => '你的伺服器';

  @override
  String get serversAddMenu => '加入伺服器…';

  @override
  String get serversAddTitle => '加入伺服器';

  @override
  String get serversBadAddress => '請輸入伺服器位址，例如 talk.example.com。';

  @override
  String get serversTooNew => '這個伺服器比此 App 新。請更新 Wisetalk 後再加入。';

  @override
  String get serversTooOld => '這個伺服器執行的是舊版 Wisetalk。請它的管理員更新。';

  @override
  String serversTooOldVersion(String version) {
    return '這個伺服器執行的是舊版 Wisetalk（$version）。請它的管理員更新。';
  }

  @override
  String get serversAddress => '位址';

  @override
  String get serversMore => '更多';

  @override
  String get serversRemoveServer => '移除伺服器';

  @override
  String get channelSomeChannel => '某個頻道';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name 在 $channel';
  }

  @override
  String get workspaceMessageEncrypted => '傳送了一則加密訊息。';

  @override
  String get workspaceMessagePicture => '傳送了一張圖片。';

  @override
  String summonPushed(String name) {
    return '$name 已收到通知。';
  }

  @override
  String get summonPushedSomeone => '已送出通知。';

  @override
  String summonNotPushed(String name) {
    return '已呼叫 $name。對方關閉了通知，只有開著的 Wisetalk 會顯示。';
  }

  @override
  String get summonNotPushedSomeone => '已呼叫。對方關閉了通知，只有開著的 Wisetalk 會顯示。';

  @override
  String summonReceived(String from, String channel) {
    return '$from 呼叫你到 $channel。';
  }

  @override
  String get workspaceSummoned => '有人呼叫你';

  @override
  String get workspaceRoleChangedOwner => '你在伺服器的角色現在是擁有者。';

  @override
  String get workspaceRoleChangedAdmin => '你在伺服器的角色現在是管理員。';

  @override
  String get workspaceRoleChangedModerator => '你在伺服器的角色現在是版主。';

  @override
  String get workspaceRoleChangedMember => '你在伺服器的角色現在是成員。';

  @override
  String get workspaceRoleChangedGuest => '你在伺服器的角色現在是訪客。';

  @override
  String get takeOverTitle => '要從此裝置加入嗎？';

  @override
  String takeOverSameChannel(String channel) {
    return '你已在另一部裝置或分頁上的 $channel 中。在這裡加入 $channel 會讓你離開那邊的通話。';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return '你正在另一部裝置或分頁上的 $there 中。在這裡加入 $here 會讓你離開那邊的通話。';
  }

  @override
  String get takeOverElsewhere => '你已在另一部裝置或分頁上通話中。在這裡加入會讓你離開那邊的通話。';

  @override
  String get takeOverJoinHere => '在這裡加入';

  @override
  String get workspaceShowChannels => '顯示頻道';

  @override
  String get workspaceHideChannels => '隱藏頻道';

  @override
  String workspaceInVoice(int count) {
    return '$count 人在語音中';
  }

  @override
  String get workspaceCreateTitle => '新增頻道或空間';

  @override
  String get workspaceStatusConnecting => '連線中…';

  @override
  String get workspaceStatusOffline => '離線…';

  @override
  String get workspaceEmptyAdmin => '還沒有頻道。用 + 按鈕建立一個。';

  @override
  String get workspaceEmpty => '還沒有頻道。管理員可以新增。';

  @override
  String get workspaceMore => '更多';

  @override
  String get workspaceCheckForUpdates => '檢查更新';

  @override
  String get workspaceChangeServer => '切換伺服器';

  @override
  String get workspaceSignOut => '登出';

  @override
  String get personMutedForYou => '已為你靜音';

  @override
  String get awayTitle => '暫時離開';

  @override
  String get awayDescription => '暫時離開：麥克風和聲音已關閉';

  @override
  String get callMutedByModerator => '已被版主靜音';

  @override
  String workspaceDrag(String name) {
    return '拖曳 $name';
  }

  @override
  String get workspaceDropEndHint => '拖放到這裡即可移到清單最後';

  @override
  String workspaceUpdateDownloaded(String version) {
    return '已下載 Wisetalk $version';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Wisetalk $version 已推出';
  }

  @override
  String get workspaceRestartToUpdate => '重新啟動以更新';

  @override
  String workspaceUpdateTo(String version) {
    return '更新至 $version';
  }

  @override
  String get workspaceWelcomeTitle => '選擇語音頻道';

  @override
  String get workspaceWelcomeHint => '點選頻道即可加入。';

  @override
  String get callJoining => '正在加入…';

  @override
  String get callWaitingForKey => '正在等待通話金鑰…';

  @override
  String get callEncrypted => '端對端加密';

  @override
  String videoScreen(String name) {
    return '$name · 螢幕';
  }

  @override
  String get connectionExcellent => '極佳';

  @override
  String get connectionGood => '良好';

  @override
  String get connectionPoor => '不佳';

  @override
  String get connectionLost => '中斷';

  @override
  String get connectionChecking => '檢查中';

  @override
  String connectionStatus(String quality) {
    return '連線：$quality';
  }

  @override
  String get connectionLabel => '連線';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · 封包遺失 $loss';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return '延遲 $ping，封包遺失 $loss';
  }

  @override
  String get connectionPing => '延遲';

  @override
  String get connectionOutgoingLoss => '上傳封包遺失';

  @override
  String get connectionIncomingLoss => '下載封包遺失';

  @override
  String get connectionJitter => '抖動';

  @override
  String get connectionMicrophone => '麥克風';

  @override
  String get connectionNotSending => '未傳送';

  @override
  String connectionKilobits(int value) {
    return '$value kbps';
  }

  @override
  String get screenShareTitle => '分享螢幕';

  @override
  String get screenShareAction => '分享';

  @override
  String get screenShareBestFor => '最適合';

  @override
  String get screenShareAndroidHint => '接下來 Android 會詢問要分享整個螢幕還是單一應用程式。目前沒有聲音。';

  @override
  String get screenShareWaylandHint =>
      '第一次分享時，系統會詢問要分享哪個螢幕。之後會沿用同一個螢幕，直到 Wisetalk 重新啟動。目前只能分享整個螢幕，且沒有聲音。';

  @override
  String get screenShareText => '文字與投影片';

  @override
  String get screenShareTextDetail => '清晰又輕量：每秒幾格畫面。';

  @override
  String get screenShareMotion => '影片與遊戲';

  @override
  String get screenShareMotionDetail => '流暢：每秒 30 格畫面，兩端的負擔都較重。';

  @override
  String get screenShareSource => '螢幕或視窗';

  @override
  String get screenShareSound => '分享聲音';

  @override
  String get screenShareSoundWindow => '只有這個視窗的應用程式。';

  @override
  String get screenShareSoundScreen => '你聽到的所有聲音，不含通話。';

  @override
  String get screenShareSoundAny => '視窗：該應用程式的聲音；螢幕：你聽到的所有聲音，不含通話。';

  @override
  String get screenShareListFailed => '無法列出螢幕和視窗。';

  @override
  String get screenShareChooseTitle => '選擇螢幕';

  @override
  String get screenShareChooseHint => '請在系統視窗中選擇要分享的螢幕。';

  @override
  String get problemNotSignedIn => '你尚未登入。';

  @override
  String get problemAccountRequired => '請先使用帳號登入。';

  @override
  String get problemAccountBanned => '這個帳號已被封鎖。';

  @override
  String get problemSignInCodeInvalid => '這個登入代碼已失效，請重新登入。';

  @override
  String get problemBrowserCheckMissing => '缺少瀏覽器檢查。請重新載入後再試一次。';

  @override
  String get problemBrowserCheckFailed => '瀏覽器檢查未通過。請重新載入後再試一次。';

  @override
  String get problemBrowserCheckExpired => '瀏覽器檢查已逾時，請再試一次。';

  @override
  String get problemGuestSignInClosed => '目前暫停訪客登入，請使用帳號登入。';

  @override
  String get problemGuestAddressBlocked => '來自此位址的訪客暫時被封鎖。';

  @override
  String get problemTooManyGuests => '目前訪客太多。請稍後再試，或使用帳號登入。';

  @override
  String get problemTooManyGuestSignIns => '此位址的訪客登入次數過多，請稍後再試。';

  @override
  String get problemNameBelongsToAccount => '這個名稱已屬於某個帳號。';

  @override
  String get problemAccountsCantBeGuests => '帳號無法以訪客身分登入。';

  @override
  String get problemNoSuchAccount => '這個帳號不存在。';

  @override
  String get problemNoSuchChannel => '這個頻道已不存在。';

  @override
  String get problemNoSuchSpace => '這個空間已不存在。';

  @override
  String get problemNoSuchEmoji => '這個表情符號不存在。';

  @override
  String get problemNoSuchGuest => '這位訪客已不在線上。';

  @override
  String get problemNoSuchPicture => '這張圖片已不存在。';

  @override
  String get problemNoSuchMessage => '這則訊息已不存在。';

  @override
  String get problemNoAvatar => '沒有頭像。';

  @override
  String get problemNotBanned => '這個帳號沒有被封鎖。';

  @override
  String get problemDisplayNameLength => '名稱長度須為 1 到 32 個字元。';

  @override
  String get problemChannelNameLength => '頻道名稱長度須為 1 到 64 個字元。';

  @override
  String get problemSpaceNameLength => '空間名稱長度須為 1 到 64 個字元。';

  @override
  String get problemEmojiNameInvalid => '表情符號名稱須為 2 到 32 個字元，只能使用 a–z、0–9 和 _。';

  @override
  String get problemIconInvalid => '圖示必須是一個表情符號或 :custom_emoji:。';

  @override
  String get problemBrandingInvalid => '名稱最多 40 個字元，標語最多 120 個字元，且不得包含控制字元。';

  @override
  String get problemChannelLimitInvalid => '頻道可容納 1 到 99 人，或不設上限。';

  @override
  String get problemBitrateInvalid => '音訊位元率必須介於 6 到 510 kbit/s。';

  @override
  String get problemPictureType => '圖片必須是 PNG、JPEG 或 WebP 格式。';

  @override
  String get problemAvatarTooLarge => '圖片超過 256 KB。';

  @override
  String get problemEmojiTooLarge => '圖片超過 128 KB。';

  @override
  String get problemChatPictureTooLarge => '圖片最大為 20 MB。';

  @override
  String get problemPictureIdTaken => '這張圖片已經存在。';

  @override
  String get problemChatFullOfPictures => '這個聊天的圖片已達上限，要等聊天清空後才能再傳。';

  @override
  String get problemTooManyPictures => '圖片太多了，請稍等一下。';

  @override
  String get problemManageNotPerRole => '管理權限無法依角色個別授予。';

  @override
  String get problemOwnersHaveEveryPermission => '擁有者和管理員永遠擁有所有權限。';

  @override
  String get problemOneOverridePerRole => '每個角色只能有一條規則。';

  @override
  String get problemWhitelistUnknownAccount => '白名單中有不存在的帳號。';

  @override
  String get problemGuestsNeverWhitelisted => '訪客永遠無法通過白名單。';

  @override
  String get problemPushSubscriptionInvalid => '瀏覽器送出的通知訂閱無效。';

  @override
  String get problemPushEndpointNotPublic => '通知位址必須是公開的 HTTPS 位址。';

  @override
  String get problemNotAllowedInChannel => '你不能在這個頻道執行此操作。';

  @override
  String get problemMayNotEnter => '你不能進入這個頻道。';

  @override
  String get problemTheyMayNotEnter => '對方不能進入這個頻道。';

  @override
  String get problemMayNotModerate => '你沒有這個頻道的版主權限。';

  @override
  String get problemCantModerateYourself => '你不能對自己執行版主操作。';

  @override
  String get problemModerateRank => '你不能對與你同級或更高階的人執行版主操作。';

  @override
  String get problemBanRank => '你不能封鎖與你同級或更高階的人。';

  @override
  String get problemRoleRank => '你只能將比你低的角色指派給比你低階的人。';

  @override
  String get problemOnlyAdminsManageServer => '只有伺服器擁有者和管理員可以管理伺服器。';

  @override
  String get problemOnlyAdminsManageBans => '只有伺服器擁有者和管理員可以管理封鎖。';

  @override
  String get problemOnlyAdminsManageEmoji => '只有伺服器擁有者和管理員可以管理自訂表情符號。';

  @override
  String get problemOnlyAdminsManageSpaces => '只有伺服器擁有者和管理員可以管理空間。';

  @override
  String get problemOnlyAdminsChooseChannelOwners => '只有伺服器擁有者和管理員可以指定頻道擁有者。';

  @override
  String get problemOnlyAdminsChooseSpaceOwners => '只有伺服器擁有者和管理員可以指定空間擁有者。';

  @override
  String get problemOnlySpaceManagersManageSpace => '只有管理員和空間擁有者可以管理這個空間。';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      '只有管理員，以及空間擁有者在自己的空間裡，可以建立頻道。';

  @override
  String get problemMoveIntoOwnSpace => '你只能將頻道移到你管理的空間。';

  @override
  String get problemOnlyModeratorsInvite => '只有能管理這個頻道的人可以發出邀請。';

  @override
  String get problemGuestsCantCreateChannels => '訪客不能建立頻道。';

  @override
  String get problemGuestsCantInvite => '訪客不能發出邀請。';

  @override
  String get problemGuestsCantBan => '訪客不能封鎖他人。';

  @override
  String get problemGuestsCantGetNotifications => '訪客無法接收通知。';

  @override
  String get problemGuestsHaveNoAvatar => '訪客沒有頭像。';

  @override
  String get problemNotYourDevice => '那不是你的裝置。';

  @override
  String get problemDeviceOfAnotherAccount => '這個裝置屬於另一個帳號。';

  @override
  String get problemOwnMessagesOnly => '你只能刪除自己的訊息。';

  @override
  String get problemChannelFull => '這個頻道已滿。';

  @override
  String get problemInviteUsed => '這個邀請已被使用或已過期。';

  @override
  String get problemTooManyInvites => '未使用的邀請太多，請等部分邀請過期。';

  @override
  String get problemJoinChannelFirst => '請先加入頻道。';

  @override
  String get problemNotInVoice => '你不在語音頻道中。';

  @override
  String get problemNotInThatChannel => '你不在那個頻道中。';

  @override
  String get problemPersonNotInYourChannel => '對方不在你的頻道中。';

  @override
  String get problemDeviceNotInChannel => '那個裝置不在頻道中。';

  @override
  String get problemDeviceNotOnline => '那個裝置不在線上，或無權進入。';

  @override
  String get problemVoiceNotConfigured => '這個伺服器尚未設定語音。';

  @override
  String get problemSummonNeedsAccount => '請使用帳號登入才能呼叫他人。';

  @override
  String get problemCantSummonYourself => '你不能呼叫自己。';

  @override
  String get problemAlreadyHere => '對方已經在這裡了。';

  @override
  String get problemSummonsOff => '對方已關閉呼叫。';

  @override
  String get problemSummonedRecently => '你在 5 分鐘內已呼叫過對方。';

  @override
  String get problemMessageLength => '訊息長度須為 1 到 2000 個字元。';

  @override
  String get problemUploadPictureFirst => '圖片沒有上傳成功。';

  @override
  String get problemPictureNotAccepted => '這個聊天不接受這張圖片。';

  @override
  String get problemChatHasNoKey => '這個聊天還沒有金鑰。';

  @override
  String get problemNobodyHasChatKey => '線上沒有人持有這個聊天的金鑰。';

  @override
  String get problemNotCurrentChatKey => '那不是這個聊天目前的金鑰。';

  @override
  String get problemChatKeyChanged => '聊天金鑰已變更，請再試一次。';

  @override
  String get problemEnvelopesForAnotherKey => '這些金鑰封裝對應的是另一個聊天金鑰。';

  @override
  String get problemSealForYourself => '請也為自己封裝金鑰。';

  @override
  String get problemSealDeviceCount => '金鑰只能為 1 到 1000 個裝置封裝。';

  @override
  String get problemNoLongerAllowed => '你已無權進入這個頻道。';

  @override
  String get problemJoinedElsewhere => '你已從另一個裝置加入。';

  @override
  String problemKickedBy(String by) {
    return '$by 將你移出了頻道。';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by 將你移出。來自你位址的訪客將被封鎖一天。';
  }

  @override
  String get problemBannedFromServer => '你已被這個伺服器封鎖。';

  @override
  String get problemGuestSignInClosedByAdmin => '管理員已關閉訪客登入。';

  @override
  String get problemHelloFirst => '連線尚未就緒，請重新載入頁面。';

  @override
  String get problemUnreadableCommand => '伺服器無法讀取這個請求，請重新載入頁面。';

  @override
  String get problemUnsupportedProtocol => '這個版本的 Wisetalk 對伺服器來說太舊了，請重新載入頁面。';

  @override
  String get problemSlowDown => '請放慢一點。';

  @override
  String get problemTooManyCommands => '同時操作太多，請放慢一點。';

  @override
  String get problemGone => '那已經不存在了。';

  @override
  String get problemInternal => '伺服器發生錯誤。';

  @override
  String get problemTooLarge => '內容太大，無法傳送。';

  @override
  String get problemUnavailable => '伺服器沒有回應，請一分鐘後再試。';
}
