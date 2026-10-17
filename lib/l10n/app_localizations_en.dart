// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get settingsStayConnected => 'Stay Connected';

  @override
  String get settingsStayConnectedDetail =>
      'Summons arrive while Wisetalk is closed';

  @override
  String get settingsStayConnectedHint =>
      'Wisetalk keeps one quiet connection and a notification of its own. Some phones put it to sleep anyway: on Samsung, keep it out of Sleeping apps; on Xiaomi, turn on Autostart.';

  @override
  String get settingsStayConnectedSteps => 'Steps for This Phone';

  @override
  String get stayConnectedTitle => 'Wisetalk is connected';

  @override
  String stayConnectedBody(String server) {
    return 'Waiting for summons from $server';
  }

  @override
  String get stayConnectedChannel => 'Staying connected';

  @override
  String get batteryTitle => 'Let Wisetalk Stay Connected?';

  @override
  String get batteryBody =>
      'Android puts apps to sleep to save battery, and a summons would wait until you open Wisetalk. Let it stay out of battery optimization: it keeps one quiet connection, a few kilobytes an hour.';

  @override
  String get batteryLater => 'Not Now';

  @override
  String get batteryContinue => 'Continue';

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
      'Android asks next whether to share the entire screen or one app.';

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
  String get screenShareSoundPhone =>
      'Everything the phone plays, without the call. Some apps don\'t allow it.';

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
