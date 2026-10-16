// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get brandingTagline => 'コミュニティのためのボイス・ビデオチャット';

  @override
  String get brandingSignIn => 'サインイン';

  @override
  String brandingSignInWith(String provider) {
    return '$provider でサインイン';
  }

  @override
  String brandingHostedBy(String community) {
    return '$community が運営しています。';
  }

  @override
  String get signInServers => 'サーバー';

  @override
  String get signInUnreachable => 'サーバーに接続できません。';

  @override
  String get tryAgain => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get signInInBrowser => 'ブラウザで続行…';

  @override
  String get signInAccountHelp => '名前、アバター、呼び出しはどこでも引き継がれます。';

  @override
  String get signInOr => 'または';

  @override
  String get signInGuest => 'ゲストとして参加';

  @override
  String get signInGuestName => '名前';

  @override
  String get signInGuestHelp => 'ゲストは話したり聞いたりできますが、ビデオの共有や呼び出しの受信はできません。';

  @override
  String get signInJoining => '参加しています…';

  @override
  String get signInAsGuest => 'ゲストとして続行';

  @override
  String get signInNobody => 'このサーバーは現在だれも入れません。';

  @override
  String get signInGuestsClosed => 'ゲストのログインは現在停止中です。';

  @override
  String get signInEncrypted => '通話はエンドツーエンドで暗号化されます。';

  @override
  String get signInNameLength => '名前は 1～32 文字です。';

  @override
  String get callMute => 'ミュート';

  @override
  String get callUnmute => 'ミュート解除';

  @override
  String get callCameraOn => 'カメラをオン';

  @override
  String get callCameraOff => 'カメラをオフ';

  @override
  String get callShareScreen => '画面共有';

  @override
  String get callStopSharing => '共有を停止';

  @override
  String get callLeave => '退出';

  @override
  String get callServiceChannel => '通話';

  @override
  String get callServiceInCall => 'ボイス通話中';

  @override
  String get callServiceSharing => '画面を共有中';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsSystemDefault => 'システムのデフォルト';

  @override
  String get settingsDone => '完了';

  @override
  String get chatTitle => 'チャット';

  @override
  String get chatVanishes => 'メッセージは最後の投稿から 4 時間後に消えます';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return '誰も書き込まなければ $hours 時間 $minutes 分後に消去されます';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return '誰も書き込まなければ $minutes 分後に消去されます';
  }

  @override
  String get chatClose => 'チャットを閉じる';

  @override
  String get chatEmpty => 'まだメッセージはありません。挨拶してみましょう！';

  @override
  String get chatLoading => '読み込み中…';

  @override
  String get chatGettingKey => 'チャットの鍵を取得中…';

  @override
  String get chatSendingPicture => '画像を送信中…';

  @override
  String get chatPreparingPicture => '画像を準備中…';

  @override
  String get chatAddPicture => '画像を追加';

  @override
  String chatMessageTo(String channel) {
    return '$channel にメッセージを送信';
  }

  @override
  String get chatSend => '送信';

  @override
  String get chatLocked => 'このデバイスにない鍵で暗号化されています。このデバイスがチャットに参加する前に送信されました。';

  @override
  String get chatGuest => 'ゲスト';

  @override
  String get chatDeleteMessage => 'メッセージを削除';

  @override
  String get chatPictures => '画像';

  @override
  String get chatInvalidMessage => 'メッセージは 1〜2000 文字で、制御文字は使えません。';

  @override
  String chatPictureNotSent(String reason) {
    return '画像を送信できませんでした: $reason';
  }

  @override
  String get pictureFailed => '画像を読み込めませんでした';

  @override
  String get pictureTooLarge => 'この画像は大きすぎます。';

  @override
  String get pictureUnreadable => 'この画像を読み込めません。';

  @override
  String trustNewDevice(String name) {
    return '$name さんが新しいデバイスから参加しました。';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あなたのアカウントに新しいデバイスが $count 台ログインしました。',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged => '注意: あなたのアカウントのデバイスが別の鍵で接続しました。';

  @override
  String get personKeyChanged => '注意：この人のデバイス鍵が変わりました。';

  @override
  String get notificationOpen => '開く';

  @override
  String get notificationChannel => 'メッセージと呼び出し';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller さんがあなたを呼んでいます';
  }

  @override
  String notificationSummonBody(String channel) {
    return '$channel に参加';
  }

  @override
  String get signInErrorRefused => 'サインインがキャンセルされました。';

  @override
  String get signInErrorExpired => 'サインインに時間がかかりすぎました。もう一度お試しください。';

  @override
  String get signInErrorBanned => 'このアカウントはこのサーバーで BAN されています。';

  @override
  String get signInErrorUnavailable => '現在、アカウントでのサインインは利用できません。';

  @override
  String get signInErrorFailed => 'サインインに失敗しました。もう一度お試しください。';

  @override
  String get signInNoBrowser => 'サインイン用のブラウザーを開けません。';

  @override
  String get signInBrowserDone => 'サインインしました。このタブを閉じて Wisetalk に戻ってください。';

  @override
  String get signInBrowserFailed => 'サインインできませんでした。Wisetalk に戻ってもう一度お試しください。';

  @override
  String get updatesNotSelfUpdating => 'この Wisetalk のビルドは自動でアップデートされません。';

  @override
  String get updatesCannotCheck => 'アップデートを確認できません。しばらくしてからもう一度お試しください。';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version の準備ができました。再起動するとアップデートされます。';
  }

  @override
  String updatesAvailable(String version) {
    return 'Wisetalk $version が公開されました。$version にアップデートしてください。';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version は最新です。';
  }

  @override
  String get voiceMutedByModerator => 'モデレーターにミュートされました。解除できるのはモデレーターだけです。';

  @override
  String get voiceCameraUnavailable => 'カメラを使用できません。';

  @override
  String get voiceCannotSwitchCamera => 'そのカメラに切り替えられません。';

  @override
  String get voiceScreenUnavailable => '画面共有を使用できません。';

  @override
  String get voiceServerMuted => 'モデレーターにミュートされました。';

  @override
  String get voiceServerUnmuted => 'モデレーターがミュートを解除しました。準備ができたらマイクをオンにしてください。';

  @override
  String voiceKicked(String reason) {
    return 'チャンネルから退出しました: $reason。';
  }

  @override
  String get voiceCannotConnect => 'ボイスチャンネルに接続できません。';

  @override
  String get voiceMicrophoneUnavailable => 'マイクを使用できません。聞くことはできますが、話すことはできません。';

  @override
  String get videoYou => 'あなた';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'ログアウトされました。';

  @override
  String get apiUnreachable => 'サーバーに接続できません。';

  @override
  String get apiUnreachableCheck => 'サーバーに接続できません。アドレスと接続を確認してください。';

  @override
  String get apiNotWisetalk => 'Wisetalk のサーバーではないようです。';

  @override
  String apiRefused(int status) {
    return 'サーバーに拒否されました（$status）。';
  }

  @override
  String get desktopComment => 'ひとつのコミュニティのためのボイス・ビデオチャット';

  @override
  String personYou(String name) {
    return '$name（あなた）';
  }

  @override
  String get personAudioVideoSettings => 'オーディオとビデオの設定…';

  @override
  String personVolume(int percent) {
    return '音量 $percent%';
  }

  @override
  String get personMuteForMe => '自分だけミュート';

  @override
  String get personUnmuteForMe => '自分だけミュート解除';

  @override
  String get moderationServerMute => 'サーバーミュート';

  @override
  String get moderationLiftServerMute => 'サーバーミュートを解除';

  @override
  String get moderationKick => 'チャンネルからキック';

  @override
  String get personMakeServerAdmin => 'サーバー管理者にする';

  @override
  String get personRemoveServerAdmin => 'サーバー管理者から外す';

  @override
  String personNowAdmin(String name) {
    return '$name はサーバー管理者になりました。';
  }

  @override
  String personNowMember(String name) {
    return '$name はメンバーになりました。';
  }

  @override
  String get moderationBan => 'サーバーから BAN…';

  @override
  String moderationBanTitle(String name) {
    return '$name を BAN しますか？';
  }

  @override
  String moderationBanConfirm(String name) {
    return '$name をこのサーバーから BAN しますか？ セッションはすぐに終了します。';
  }

  @override
  String get moderationBanAction => 'BAN';

  @override
  String moderationBanned(String name) {
    return '$name を BAN しました。';
  }

  @override
  String get moderationBanGuest => 'ゲストを 1 日 BAN…';

  @override
  String moderationBanGuestConfirm(String name) {
    return '$name を退出させ、そのアドレスからのゲスト参加を 1 日ブロックしますか？';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name を退出させました。アドレスは 1 日ブロックされます。';
  }

  @override
  String channelMakeOwner(String channel) {
    return '$channel のオーナーにする';
  }

  @override
  String channelRemoveOwner(String channel) {
    return '$channel のオーナーから外す';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name が $channel のオーナーになりました。';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel のオーナーはいなくなりました。';
  }

  @override
  String spaceMakeOwner(String space) {
    return '$space のオーナーにする';
  }

  @override
  String spaceRemoveOwner(String space) {
    return '$space のオーナーから外す';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name が $space のオーナーになりました。';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space のオーナーはいなくなりました。';
  }

  @override
  String channelAudioStereo(int kbps) {
    return '音声 最大 $kbps kbps、ステレオ';
  }

  @override
  String channelAudioMono(int kbps) {
    return '音声 最大 $kbps kbps、モノラル';
  }

  @override
  String get channelJoin => '参加';

  @override
  String get channelOpenChat => 'チャットを開く';

  @override
  String get channelOpenSettings => 'チャンネル設定…';

  @override
  String get inviteCopyLink => '招待リンクをコピー';

  @override
  String inviteCopied(String channel) {
    return '$channel への招待リンクをコピーしました。';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return '$channel への招待をコピーしました。最初に使われてから 10 分間は誰でも入れます。使われなければ 1 日で失効します。';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return '$channel への招待リンクをコピーしました。このチャンネルにもともと入れる人だけが使えます。';
  }

  @override
  String get inviteCannotCreate => '招待を作成できませんでした。';

  @override
  String get spaceNewChannel => 'スペースに新規チャンネル…';

  @override
  String get spaceOpenSettings => 'スペース設定…';

  @override
  String get spaceDelete => 'スペースを削除…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'スペース「$space」を削除しますか？ 中のチャンネルは最上位に移動します。';
  }

  @override
  String get workspaceMoveUp => '上へ移動';

  @override
  String get workspaceMoveDown => '下へ移動';

  @override
  String get workspaceCannotReorder => '並べ替えできませんでした。';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbps（会話）';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbps（音楽）';
  }

  @override
  String get createNewChannel => '新しいチャンネル';

  @override
  String get createNewSpace => '新しいスペース';

  @override
  String get createSubmit => '作成';

  @override
  String get createChannel => 'チャンネル';

  @override
  String get createSpace => 'スペース';

  @override
  String get createChannelHint => '参加して話せるボイスルーム。専用のチャット付きです。';

  @override
  String get createSpaceHint => 'サイドバーでチャンネルをまとめるフォルダーです。';

  @override
  String get createChannelPlaceholder => 'ブルーチーム';

  @override
  String get channelSettingsTitle => 'チャンネル設定';

  @override
  String get channelSettingsOwnerHint =>
      'オーナーはこのチャンネルを管理します。オーナーを決められるのは管理者だけです。';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return '$name を削除しますか？中にいる全員が切断されます。';
  }

  @override
  String get channelSettingsPeopleAndSound => '人数と音声';

  @override
  String get channelSettingsMaxPeople => '最大人数';

  @override
  String get channelSettingsNoLimit => '制限なし';

  @override
  String get channelSettingsAudioQuality => '音質';

  @override
  String get channelSettingsStereo => 'ステレオ';

  @override
  String get channelSettingsDelete => 'チャンネルを削除…';

  @override
  String get manageSpace => 'スペース';

  @override
  String get manageOwner => 'オーナー';

  @override
  String get manageAccess => 'アクセス';

  @override
  String get spaceSettingsTitle => 'スペース設定';

  @override
  String get spaceSettingsOwnerHint =>
      'オーナーはスペースとその中のすべてのチャンネルを管理します。オーナーを決められるのは管理者だけです。';

  @override
  String get accessAccountsOnly => 'アカウントのみ';

  @override
  String get accessAccountsOnlyDetail => 'ゲスト不可';

  @override
  String get accessWhitelistOnly => '許可リストのみ';

  @override
  String get accessHidden => '非表示';

  @override
  String get accessHiddenDetail => '入れない人には見えません';

  @override
  String get accessFromSpace => 'スペースで設定済み';

  @override
  String summonsTitle(String channel) {
    return '$channel に呼び出す';
  }

  @override
  String get summonsSummon => '呼び出す';

  @override
  String get summonsNickname => 'ニックネーム';

  @override
  String get summonsNoMatch => 'ここに来られる人の中に一致する人はいません。';

  @override
  String get summonsHint => '相手に、あなたが待っていることが通知されます。1 人につき 5 分に 1 回までです。';

  @override
  String get summonsSearchFailed => '検索できません。';

  @override
  String get manageDeviceKey => 'デバイス鍵';

  @override
  String manageDeleteTitle(String name) {
    return '$name を削除しますか？';
  }

  @override
  String get manageDelete => '削除';

  @override
  String get manageSave => '保存';

  @override
  String get manageName => '名前';

  @override
  String get manageNone => 'なし';

  @override
  String get manageNobody => 'なし';

  @override
  String get manageSomeoneElse => 'ほかの人';

  @override
  String get manageWhitelistInWeb => '許可リストは今のところウェブ版で編集してください。';

  @override
  String get channelSettingsLimitHint =>
      'チャンネルが満員のときは、管理できる人だけが参加できます。1〜99 人、または制限なし。';

  @override
  String get spaceSettingsAccessHint =>
      'これらの制限はスペース内のすべてのチャンネルに適用されます。チャンネル側では制限を追加することしかできません。許可リストは今のところウェブ版で編集してください。';

  @override
  String get accessWhitelistOnlyListDetail => 'リストにある人とロールのみ';

  @override
  String get summonsWho => '誰を？';

  @override
  String get settingsPictures => '画像';

  @override
  String get profileAddPicture => '画像を追加…';

  @override
  String get profileChangePicture => '画像を変更…';

  @override
  String get profileRemovePicture => '画像を削除';

  @override
  String get profileUploadFailed => '画像をアップロードできません。';

  @override
  String get profileRemoveFailed => '画像を削除できません。';

  @override
  String get saveFailed => '保存できませんでした。';

  @override
  String get settingsAudioVideo => 'オーディオとビデオ';

  @override
  String get settingsMicrophone => 'マイク';

  @override
  String get settingsCamera => 'カメラ';

  @override
  String get settingsOutput => '出力';

  @override
  String get settingsVoiceProcessing => '音声処理';

  @override
  String get settingsVoiceProcessingDetail => 'ノイズ抑制とエコーキャンセル';

  @override
  String get settingsVoiceProcessingHint =>
      'オフにすると音質が最も良くなりますが、その場合はヘッドホンを使ってください。エコーキャンセルがないと、相手の声があなたのスピーカーから戻って聞こえてしまいます。';

  @override
  String get settingsCues => '入室・退室の効果音';

  @override
  String get settingsCuesDetail => '誰かが来たり去ったりするとフクロウが鳴き、ショートカットではカチッと音がします';

  @override
  String get settingsPingAndLoss => 'Ping とパケットロスを表示';

  @override
  String get settingsPingAndLossDetail => '通話中の接続アイコンの横に表示';

  @override
  String get summonsHeader => '呼び出し';

  @override
  String get summonsAllow => '他の人からの呼び出しを許可';

  @override
  String get settingsNotificationsHere => 'このデバイスで通知';

  @override
  String get settingsNotificationsHint => 'Wisetalk がバックグラウンドにあるときに表示します。';

  @override
  String get settingsNotifyMessages => '新しいメッセージ';

  @override
  String get settingsNotifyMessagesDetail => '参加中の通話のチャットと、開いたチャット';

  @override
  String get settingsNotifySummons => '呼び出し';

  @override
  String get settingsNotifySummonsDetail => '誰かがあなたをチャンネルに呼び出したとき';

  @override
  String get settingsPushHeader => 'Wisetalk を閉じているとき';

  @override
  String get settingsPushApp => 'プッシュ通知アプリ';

  @override
  String get settingsPushAppNone => 'なし';

  @override
  String get settingsPushAppChoose => '選択…';

  @override
  String get settingsGetNtfy => 'ntfy を入手';

  @override
  String settingsPushVia(String app) {
    return 'Wisetalk を閉じていても、呼び出しは $app 経由でこのスマートフォンに届きます。';
  }

  @override
  String get settingsPushChooseHint =>
      'Wisetalk を閉じているときに呼び出しを受け取るアプリを選んでください。';

  @override
  String get settingsPushNoneHint =>
      'プッシュ通知アプリがないと、呼び出しは Wisetalk の実行中にしか表示されません。ntfy をインストールし、その設定でコミュニティの ntfy サーバーをデフォルトのサーバーにしてください。';

  @override
  String get settingsPrivacy => 'プライバシー';

  @override
  String get settingsCrashReports => 'クラッシュレポートを送信';

  @override
  String get settingsCrashReportsHint =>
      'Wisetalk で問題が起きたとき、何がコードのどこで壊れたかを開発者に伝えます。メッセージ、名前、鍵、サーバーは送信しません。';

  @override
  String get settingsShortcuts => 'ショートカット';

  @override
  String get settingsShortcutsRecording =>
      '新しいキーを押してください。Backspace でショートカットを削除、Esc でそのままにします。';

  @override
  String get settingsShortcutsGlobal =>
      '通話中はどのアプリが前面にあっても使えます。それ以外は Wisetalk のウインドウ内でのみ使えます。クリックして変更できます。';

  @override
  String get settingsShortcutsWayland =>
      'Wayland では Wisetalk のウインドウが前面にあるときだけ使えます。クリックして変更できます。';

  @override
  String get settingsShortcutPressKeys => 'キーを押してください…';

  @override
  String get settingsShortcutNone => 'なし';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys はすでに「$action」に使われています。';
  }

  @override
  String get shortcutToggleMute => 'マイクのオン／オフ';

  @override
  String get shortcutToggleAway => '離席／復帰';

  @override
  String get shortcutMute => 'マイクをオフ';

  @override
  String get shortcutUnmute => 'マイクをオン';

  @override
  String get shortcutUnusableKey => 'そのキーはショートカットに使えません。';

  @override
  String shortcutTyping(String first, String second) {
    return '$first か $second を加えるか、F1〜F24 を使ってください。';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys はシステムまたはすべてのアプリで使われています。';
  }

  @override
  String get sheetDiscardTitle => '変更を破棄しますか？';

  @override
  String get sheetDiscardMessage => 'ここでの変更はまだ保存されていません。';

  @override
  String get sheetDiscard => '破棄';

  @override
  String get sheetKeepEditing => '編集を続ける';

  @override
  String serversRemoveTitle(String server) {
    return '$server を削除しますか？';
  }

  @override
  String get serversRemoveMessage =>
      'このデバイスはサーバーからサインアウトし、登録を削除します。アドレスを入力すれば、また追加できます。';

  @override
  String get serversRemove => '削除';

  @override
  String get serversAddressHelp => 'コミュニティの運営者にアドレスを聞いてください。';

  @override
  String get serversConnecting => '接続中…';

  @override
  String get serversConnect => '接続';

  @override
  String get serversWhich => 'あなたのコミュニティはどのサーバーにありますか？';

  @override
  String get serversYours => 'あなたのサーバー';

  @override
  String get serversAddMenu => 'サーバーを追加…';

  @override
  String get serversAddTitle => 'サーバーを追加';

  @override
  String get serversBadAddress => 'サーバーのアドレスを入力してください（例: talk.example.com）。';

  @override
  String get serversTooNew =>
      'このサーバーはこのアプリより新しいバージョンです。参加するには Wisetalk をアップデートしてください。';

  @override
  String get serversTooOld => 'このサーバーは古い Wisetalk で動いています。管理者にアップデートを依頼してください。';

  @override
  String serversTooOldVersion(String version) {
    return 'このサーバーは古い Wisetalk（$version）で動いています。管理者にアップデートを依頼してください。';
  }

  @override
  String get serversAddress => 'アドレス';

  @override
  String get serversMore => 'その他';

  @override
  String get serversRemoveServer => 'サーバーを削除';

  @override
  String get channelSomeChannel => 'チャンネル';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$channel の $name';
  }

  @override
  String get workspaceMessageEncrypted => '暗号化されたメッセージを送信しました。';

  @override
  String get workspaceMessagePicture => '画像を送信しました。';

  @override
  String summonPushed(String name) {
    return '$name に通知が届きました。';
  }

  @override
  String get summonPushedSomeone => '通知が届きました。';

  @override
  String summonNotPushed(String name) {
    return '$name を呼び出しました。通知がオフのため、開いている Wisetalk にだけ表示されます。';
  }

  @override
  String get summonNotPushedSomeone =>
      '呼び出しました。通知がオフのため、開いている Wisetalk にだけ表示されます。';

  @override
  String summonReceived(String from, String channel) {
    return '$from があなたを $channel に呼び出しています。';
  }

  @override
  String get workspaceSummoned => '呼び出されています';

  @override
  String get workspaceRoleChangedOwner => 'サーバーでのあなたのロールがオーナーになりました。';

  @override
  String get workspaceRoleChangedAdmin => 'サーバーでのあなたのロールが管理者になりました。';

  @override
  String get workspaceRoleChangedModerator => 'サーバーでのあなたのロールがモデレーターになりました。';

  @override
  String get workspaceRoleChangedMember => 'サーバーでのあなたのロールがメンバーになりました。';

  @override
  String get workspaceRoleChangedGuest => 'サーバーでのあなたのロールがゲストになりました。';

  @override
  String get takeOverTitle => 'このデバイスから参加しますか？';

  @override
  String takeOverSameChannel(String channel) {
    return 'すでに別のデバイスまたはタブで $channel にいます。ここで $channel に参加すると、そちらの通話から抜けます。';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return '別のデバイスまたはタブで $there にいます。ここで $here に参加すると、そちらの通話から抜けます。';
  }

  @override
  String get takeOverElsewhere => '別のデバイスまたはタブで通話中です。ここで参加すると、そちらの通話から抜けます。';

  @override
  String get takeOverJoinHere => 'ここで参加';

  @override
  String get workspaceShowChannels => 'チャンネルを表示';

  @override
  String get workspaceHideChannels => 'チャンネルを隠す';

  @override
  String workspaceInVoice(int count) {
    return '$count 人が通話中';
  }

  @override
  String get workspaceCreateTitle => '新規チャンネルまたはスペース';

  @override
  String get workspaceStatusConnecting => '接続中…';

  @override
  String get workspaceStatusOffline => 'オフライン…';

  @override
  String get workspaceEmptyAdmin => 'チャンネルはまだありません。+ ボタンで作成できます。';

  @override
  String get workspaceEmpty => 'チャンネルはまだありません。管理者が追加できます。';

  @override
  String get workspaceMore => 'その他';

  @override
  String get workspaceCheckForUpdates => 'アップデートを確認';

  @override
  String get workspaceChangeServer => 'サーバーを変更';

  @override
  String get workspaceSignOut => 'サインアウト';

  @override
  String get personMutedForYou => '自分だけミュート中';

  @override
  String get awayTitle => '離席中';

  @override
  String get awayDescription => '離席中：マイクとサウンドはオフ';

  @override
  String get callMutedByModerator => 'モデレーターによりミュート中';

  @override
  String workspaceDrag(String name) {
    return '$name をドラッグ';
  }

  @override
  String get workspaceDropEndHint => 'ここにドロップすると末尾に移動します';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version をダウンロードしました';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Wisetalk $version が公開されました';
  }

  @override
  String get workspaceRestartToUpdate => '再起動してアップデート';

  @override
  String workspaceUpdateTo(String version) {
    return '$version にアップデート';
  }

  @override
  String get workspaceWelcomeTitle => 'ボイスチャンネルを選択';

  @override
  String get workspaceWelcomeHint => 'チャンネルをクリックすると参加します。';

  @override
  String get callJoining => '参加しています…';

  @override
  String get callWaitingForKey => '通話の鍵を待っています…';

  @override
  String get callEncrypted => 'エンドツーエンド暗号化';

  @override
  String videoScreen(String name) {
    return '$name · 画面';
  }

  @override
  String get connectionExcellent => '非常に良好';

  @override
  String get connectionGood => '良好';

  @override
  String get connectionPoor => '不安定';

  @override
  String get connectionLost => '切断';

  @override
  String get connectionChecking => '確認中';

  @override
  String connectionStatus(String quality) {
    return '接続: $quality';
  }

  @override
  String get connectionLabel => '接続';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · ロス $loss';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping、ロス $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => '送信パケットロス';

  @override
  String get connectionIncomingLoss => '受信パケットロス';

  @override
  String get connectionJitter => 'ジッター';

  @override
  String get connectionMicrophone => 'マイク';

  @override
  String get connectionNotSending => '送信していません';

  @override
  String connectionKilobits(int value) {
    return '$value kbps';
  }

  @override
  String get screenShareTitle => '画面を共有';

  @override
  String get screenShareAction => '共有';

  @override
  String get screenShareBestFor => '用途';

  @override
  String get screenShareAndroidHint =>
      '次に Android が、画面全体と 1 つのアプリのどちらを共有するか尋ねます。';

  @override
  String get screenShareWaylandHint =>
      '初回は、共有する画面をシステムが尋ねます。以降は Wisetalk を再起動するまで同じ画面を使います。今のところ画面全体のみで、音声はありません。';

  @override
  String get screenShareText => 'テキストとスライド';

  @override
  String get screenShareTextDetail => '鮮明で軽量：毎秒数フレーム。';

  @override
  String get screenShareMotion => '動画とゲーム';

  @override
  String get screenShareMotionDetail => 'なめらか：毎秒 30 フレーム。送る側と受ける側の負荷が増えます。';

  @override
  String get screenShareSource => '画面またはウィンドウ';

  @override
  String get screenShareSound => '音声を共有';

  @override
  String get screenShareSoundWindow => 'このウィンドウのアプリの音だけです。';

  @override
  String get screenShareSoundScreen => '聞こえているすべての音（通話を除く）。';

  @override
  String get screenShareSoundAny => 'ウィンドウならそのアプリの音、画面なら聞こえているすべての音（通話を除く）。';

  @override
  String get screenShareSoundPhone =>
      'スマートフォンで再生中のすべての音（通話を除く）。許可していないアプリもあります。';

  @override
  String get screenShareListFailed => '画面とウィンドウの一覧を取得できません。';

  @override
  String get screenShareChooseTitle => '画面を選択';

  @override
  String get screenShareChooseHint => 'システムのウィンドウで共有する画面を選んでください。';

  @override
  String get problemNotSignedIn => 'サインインしていません。';

  @override
  String get problemAccountRequired => '先にアカウントでサインインしてください。';

  @override
  String get problemAccountBanned => 'このアカウントは BAN されています。';

  @override
  String get problemSignInCodeInvalid => 'このサインインコードは無効になりました。もう一度サインインしてください。';

  @override
  String get problemBrowserCheckMissing =>
      'ブラウザーの確認が行われていません。再読み込みしてもう一度お試しください。';

  @override
  String get problemBrowserCheckFailed => 'ブラウザーの確認に失敗しました。再読み込みしてもう一度お試しください。';

  @override
  String get problemBrowserCheckExpired => 'ブラウザーの確認の有効期限が切れました。もう一度お試しください。';

  @override
  String get problemGuestSignInClosed =>
      '現在、ゲストのサインインは停止中です。アカウントでサインインしてください。';

  @override
  String get problemGuestAddressBlocked => 'このアドレスからのゲストは一時的にブロックされています。';

  @override
  String get problemTooManyGuests => '現在ゲストが多すぎます。後でもう一度試すか、アカウントでサインインしてください。';

  @override
  String get problemTooManyGuestSignIns =>
      'このアドレスからのゲストのサインインが多すぎます。後でもう一度お試しください。';

  @override
  String get problemNameBelongsToAccount => 'この名前はアカウントで使われています。';

  @override
  String get problemAccountsCantBeGuests => 'アカウントはゲストになれません。';

  @override
  String get problemNoSuchAccount => 'このアカウントは存在しません。';

  @override
  String get problemNoSuchChannel => 'このチャンネルはもう存在しません。';

  @override
  String get problemNoSuchSpace => 'このスペースはもう存在しません。';

  @override
  String get problemNoSuchEmoji => 'この絵文字は存在しません。';

  @override
  String get problemNoSuchGuest => 'このゲストはもうオンラインではありません。';

  @override
  String get problemNoSuchPicture => 'この画像はもうありません。';

  @override
  String get problemNoSuchMessage => 'このメッセージはもうありません。';

  @override
  String get problemNoAvatar => 'アバターがありません。';

  @override
  String get problemNotBanned => 'このアカウントは BAN されていません。';

  @override
  String get problemDisplayNameLength => '名前は 1～32 文字です。';

  @override
  String get problemChannelNameLength => 'チャンネル名は 1～64 文字です。';

  @override
  String get problemSpaceNameLength => 'スペース名は 1～64 文字です。';

  @override
  String get problemEmojiNameInvalid => '絵文字名は a–z、0–9、_ を使った 2～32 文字です。';

  @override
  String get problemIconInvalid => 'アイコンは絵文字 1 つか :custom_emoji: です。';

  @override
  String get problemBrandingInvalid =>
      '名前は 40 文字まで、キャッチフレーズは 120 文字までで、制御文字は使えません。';

  @override
  String get problemChannelLimitInvalid => 'チャンネルの定員は 1～99 人、または無制限です。';

  @override
  String get problemBitrateInvalid => '音声のビットレートは 6～510 kbit/s にしてください。';

  @override
  String get problemPictureType => '画像は PNG、JPEG、WebP のいずれかにしてください。';

  @override
  String get problemAvatarTooLarge => '画像が 256 KB を超えています。';

  @override
  String get problemEmojiTooLarge => '画像が 128 KB を超えています。';

  @override
  String get problemChatPictureTooLarge => '画像は 20 MB までです。';

  @override
  String get problemPictureIdTaken => 'この画像はすでにあります。';

  @override
  String get problemChatFullOfPictures =>
      'このチャットの画像が上限に達しました。チャットが消去されるまで追加できません。';

  @override
  String get problemTooManyPictures => '画像が多すぎます。少しお待ちください。';

  @override
  String get problemManageNotPerRole => '管理権限はロールごとには付与できません。';

  @override
  String get problemOwnersHaveEveryPermission => 'オーナーと管理者は常にすべての権限を持っています。';

  @override
  String get problemOneOverridePerRole => 'ルールはロールごとに 1 つだけです。';

  @override
  String get problemWhitelistUnknownAccount => '許可リストに存在しないアカウントが含まれています。';

  @override
  String get problemGuestsNeverWhitelisted => 'ゲストは許可リストを通過できません。';

  @override
  String get problemPushSubscriptionInvalid => 'ブラウザーから送られた通知の登録情報が壊れています。';

  @override
  String get problemPushEndpointNotPublic => '通知先は公開された HTTPS アドレスである必要があります。';

  @override
  String get problemNotAllowedInChannel => 'このチャンネルではこの操作はできません。';

  @override
  String get problemMayNotEnter => 'このチャンネルには入れません。';

  @override
  String get problemTheyMayNotEnter => 'その人はこのチャンネルに入れません。';

  @override
  String get problemMayNotModerate => 'このチャンネルをモデレートする権限がありません。';

  @override
  String get problemCantModerateYourself => '自分自身をモデレートすることはできません。';

  @override
  String get problemModerateRank => '自分と同じかそれより上の人はモデレートできません。';

  @override
  String get problemBanRank => '自分と同じかそれより上の人は BAN できません。';

  @override
  String get problemRoleRank => '自分より下のロールを、自分より下の人にだけ付与できます。';

  @override
  String get problemOnlyAdminsManageServer => 'サーバーを管理できるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlyAdminsManageBans => 'BAN を管理できるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'カスタム絵文字を管理できるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlyAdminsManageSpaces => 'スペースを管理できるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'チャンネルのオーナーを決められるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'スペースのオーナーを決められるのは、サーバーのオーナーと管理者だけです。';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'このスペースを管理できるのは、管理者とスペースのオーナーだけです。';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'チャンネルを作成できるのは、管理者と、自分のスペース内でのスペースオーナーだけです。';

  @override
  String get problemMoveIntoOwnSpace => 'チャンネルは自分が管理するスペースにのみ移動できます。';

  @override
  String get problemOnlyModeratorsInvite => '招待を作成できるのは、このチャンネルをモデレートできる人だけです。';

  @override
  String get problemGuestsCantCreateChannels => 'ゲストはチャンネルを作成できません。';

  @override
  String get problemGuestsCantInvite => 'ゲストは招待できません。';

  @override
  String get problemGuestsCantBan => 'ゲストは BAN できません。';

  @override
  String get problemGuestsCantGetNotifications => 'ゲストは通知を受け取れません。';

  @override
  String get problemGuestsHaveNoAvatar => 'ゲストにはアバターがありません。';

  @override
  String get problemNotYourDevice => 'それはあなたのデバイスではありません。';

  @override
  String get problemDeviceOfAnotherAccount => 'このデバイスは別のアカウントのものです。';

  @override
  String get problemOwnMessagesOnly => '削除できるのは自分のメッセージだけです。';

  @override
  String get problemChannelFull => 'このチャンネルは満員です。';

  @override
  String get problemInviteUsed => 'この招待は使用済みか、有効期限が切れています。';

  @override
  String get problemTooManyInvites => '未使用の招待が多すぎます。いくつか期限切れになるまでお待ちください。';

  @override
  String get problemJoinChannelFirst => '先にチャンネルに参加してください。';

  @override
  String get problemNotInVoice => 'ボイスチャンネルに参加していません。';

  @override
  String get problemNotInThatChannel => 'そのチャンネルに参加していません。';

  @override
  String get problemPersonNotInYourChannel => 'その人はあなたのチャンネルにいません。';

  @override
  String get problemDeviceNotInChannel => 'そのデバイスはチャンネルにいません。';

  @override
  String get problemDeviceNotOnline => 'そのデバイスはオンラインでないか、入室できません。';

  @override
  String get problemVoiceNotConfigured => 'このサーバーでは音声が設定されていません。';

  @override
  String get problemSummonNeedsAccount => '呼び出すにはアカウントでサインインしてください。';

  @override
  String get problemCantSummonYourself => '自分自身は呼び出せません。';

  @override
  String get problemAlreadyHere => 'その人はすでにここにいます。';

  @override
  String get problemSummonsOff => 'その人は呼び出しをオフにしています。';

  @override
  String get problemSummonedRecently => '5 分以内にすでに呼び出しています。';

  @override
  String get problemMessageLength => 'メッセージは 1～2000 文字です。';

  @override
  String get problemUploadPictureFirst => '画像がアップロードされませんでした。';

  @override
  String get problemPictureNotAccepted => 'このチャットではこの画像を受け付けられません。';

  @override
  String get problemChatHasNoKey => 'このチャットにはまだ鍵がありません。';

  @override
  String get problemNobodyHasChatKey => 'オンラインの人は誰もこのチャットの鍵を持っていません。';

  @override
  String get problemNotCurrentChatKey => 'それはチャットの現在の鍵ではありません。';

  @override
  String get problemChatKeyChanged => 'チャットの鍵が変わりました。もう一度お試しください。';

  @override
  String get problemEnvelopesForAnotherKey => '鍵は別のチャット鍵向けに封印されていました。';

  @override
  String get problemSealForYourself => '自分用にも鍵を封印してください。';

  @override
  String get problemSealDeviceCount => '鍵は 1～1000 台のデバイス向けに封印できます。';

  @override
  String get problemNoLongerAllowed => 'このチャンネルへのアクセス権がなくなりました。';

  @override
  String get problemJoinedElsewhere => '別のデバイスから参加しました。';

  @override
  String problemKickedBy(String by) {
    return '$by さんがあなたをチャンネルから退出させました。';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by さんがあなたを退出させました。あなたのアドレスからのゲストは 1 日ブロックされます。';
  }

  @override
  String get problemBannedFromServer => 'このサーバーから BAN されています。';

  @override
  String get problemGuestSignInClosedByAdmin => '管理者がゲストのサインインを停止しました。';

  @override
  String get problemHelloFirst => '接続の準備ができていませんでした。ページを再読み込みしてください。';

  @override
  String get problemUnreadableCommand =>
      'サーバーがリクエストを読み取れませんでした。ページを再読み込みしてください。';

  @override
  String get problemUnsupportedProtocol =>
      'この Wisetalk はサーバーに対してバージョンが古すぎます。ページを再読み込みしてください。';

  @override
  String get problemSlowDown => '少しペースを落としてください。';

  @override
  String get problemTooManyCommands => '一度に操作が多すぎます。少しペースを落としてください。';

  @override
  String get problemGone => 'それはもうありません。';

  @override
  String get problemInternal => 'サーバーで問題が発生しました。';

  @override
  String get problemTooLarge => '大きすぎて送信できません。';

  @override
  String get problemUnavailable => 'サーバーが応答していません。1 分後にもう一度お試しください。';
}
