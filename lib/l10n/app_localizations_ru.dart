// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get brandingTagline => 'Голосовой и видеочат для вашего сообщества';

  @override
  String get brandingSignIn => 'Войти';

  @override
  String brandingSignInWith(String provider) {
    return 'Войти через $provider';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Сервер сообщества $community.';
  }

  @override
  String get signInServers => 'Серверы';

  @override
  String get signInUnreachable => 'Сервер не отвечает.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get signInInBrowser => 'Продолжите в браузере…';

  @override
  String get signInAccountHelp =>
      'Имя и аватар будут с вами на любом устройстве, и друзья смогут вас позвать.';

  @override
  String get signInOr => 'или';

  @override
  String get signInGuest => 'Войти гостем';

  @override
  String get signInGuestName => 'Ваше имя';

  @override
  String get signInGuestHelp =>
      'Гости могут говорить и слушать, но не показывать видео, и позвать их нельзя.';

  @override
  String get signInJoining => 'Входим…';

  @override
  String get signInAsGuest => 'Продолжить как гость';

  @override
  String get signInNobody => 'Этот сервер сейчас никого не пускает.';

  @override
  String get signInGuestsClosed => 'Гостевой вход сейчас закрыт.';

  @override
  String get signInEncrypted => 'Звонки защищены сквозным шифрованием.';

  @override
  String get signInNameLength => 'Имя должно быть от 1 до 32 символов.';

  @override
  String get callMute => 'Выключить микрофон';

  @override
  String get callUnmute => 'Включить микрофон';

  @override
  String get callCameraOn => 'Включить камеру';

  @override
  String get callCameraOff => 'Выключить камеру';

  @override
  String get callShareScreen => 'Показать экран';

  @override
  String get callStopSharing => 'Остановить показ';

  @override
  String get callLeave => 'Выйти';

  @override
  String get callServiceChannel => 'Звонки';

  @override
  String get callServiceInCall => 'Идёт голосовой звонок';

  @override
  String get callServiceSharing => 'Вы показываете экран';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSystemDefault => 'Как в системе';

  @override
  String get settingsDone => 'Готово';

  @override
  String get chatTitle => 'Чат';

  @override
  String get chatVanishes => 'Сообщения исчезают через 4 ч после последнего';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Очистится через $hours ч $minutes мин, если никто не напишет';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Очистится через $minutes мин, если никто не напишет';
  }

  @override
  String get chatClose => 'Закрыть чат';

  @override
  String get chatEmpty => 'Сообщений пока нет. Поздоровайтесь!';

  @override
  String get chatLoading => 'Загрузка…';

  @override
  String get chatGettingKey => 'Получаем ключ чата…';

  @override
  String get chatSendingPicture => 'Отправляем картинку…';

  @override
  String get chatPreparingPicture => 'Готовим картинку…';

  @override
  String get chatAddPicture => 'Добавить картинку';

  @override
  String chatMessageTo(String channel) {
    return 'Написать в $channel';
  }

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatLocked =>
      'Зашифровано ключом, которого нет на этом устройстве: отправлено до того, как оно вошло в чат.';

  @override
  String get chatGuest => 'гость';

  @override
  String get chatDeleteMessage => 'Удалить сообщение';

  @override
  String get chatPictures => 'Картинки';

  @override
  String get chatInvalidMessage =>
      'В сообщении от 1 до 2000 символов, без управляющих символов.';

  @override
  String chatPictureNotSent(String reason) {
    return 'Картинка не отправилась: $reason';
  }

  @override
  String get pictureFailed => 'Картинка не загрузилась';

  @override
  String get pictureTooLarge => 'Картинка слишком большая.';

  @override
  String get pictureUnreadable => 'Не удаётся прочитать эту картинку.';

  @override
  String trustNewDevice(String name) {
    return '$name: вход с нового устройства.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В ваш аккаунт вошли $count новых устройства.',
      many: 'В ваш аккаунт вошли $count новых устройств.',
      few: 'В ваш аккаунт вошли $count новых устройства.',
      one: 'В ваш аккаунт вошло $count новое устройство.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Осторожно: устройство вашего аккаунта пришло с другим ключом.';

  @override
  String get personKeyChanged =>
      'Осторожно: ключ устройства этого человека изменился.';

  @override
  String get notificationOpen => 'Открыть';

  @override
  String get notificationChannel => 'Сообщения и вызовы в канал';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller зовёт вас';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Зайдите в $channel';
  }

  @override
  String get signInErrorRefused => 'Вход отменён.';

  @override
  String get signInErrorExpired =>
      'Вход занял слишком много времени. Попробуйте ещё раз.';

  @override
  String get signInErrorBanned => 'Этот аккаунт заблокирован на сервере.';

  @override
  String get signInErrorUnavailable => 'Вход через аккаунт сейчас недоступен.';

  @override
  String get signInErrorFailed => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get signInNoBrowser => 'Не удаётся открыть браузер для входа.';

  @override
  String get signInBrowserDone =>
      'Вы вошли. Эту вкладку можно закрыть и вернуться в Wisetalk.';

  @override
  String get signInBrowserFailed =>
      'Войти не получилось. Вернитесь в Wisetalk и попробуйте ещё раз.';

  @override
  String get updatesNotSelfUpdating =>
      'Эта сборка Wisetalk не обновляется сама.';

  @override
  String get updatesCannotCheck =>
      'Не удаётся проверить обновления. Попробуйте позже.';

  @override
  String updatesReady(String version) {
    return 'Wisetalk $version готов: перезапустите, чтобы обновиться.';
  }

  @override
  String updatesAvailable(String version) {
    return 'Вышел Wisetalk $version: обновитесь до $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'Wisetalk $version — последняя версия.';
  }

  @override
  String get voiceMutedByModerator =>
      'Модератор выключил вам микрофон, и включить его может только он.';

  @override
  String get voiceCameraUnavailable => 'Камера недоступна.';

  @override
  String get voiceCannotSwitchCamera =>
      'Не удалось переключиться на эту камеру.';

  @override
  String get voiceScreenUnavailable => 'Показ экрана недоступен.';

  @override
  String get voiceServerMuted => 'Модератор выключил вам микрофон.';

  @override
  String get voiceServerUnmuted =>
      'Модератор вернул вам микрофон. Включите его, когда будете готовы.';

  @override
  String voiceKicked(String reason) {
    return 'Вы покинули канал: $reason.';
  }

  @override
  String get voiceCannotConnect =>
      'Не удалось подключиться к голосовому каналу.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Микрофон недоступен: вы можете слушать, но не говорить.';

  @override
  String get videoYou => 'Вы';

  @override
  String connectionMilliseconds(int value) {
    return '$value мс';
  }

  @override
  String get connectionSignedOut => 'Вы вышли из аккаунта.';

  @override
  String get apiUnreachable => 'Сервер не отвечает.';

  @override
  String get apiUnreachableCheck =>
      'Сервер не отвечает. Проверьте адрес и подключение.';

  @override
  String get apiNotWisetalk => 'Это не похоже на сервер Wisetalk.';

  @override
  String apiRefused(int status) {
    return 'Сервер отказал ($status).';
  }

  @override
  String get desktopComment => 'Голосовой и видеочат для одного сообщества';

  @override
  String personYou(String name) {
    return '$name (вы)';
  }

  @override
  String get personAudioVideoSettings => 'Настройки звука и видео…';

  @override
  String personVolume(int percent) {
    return 'Громкость $percent%';
  }

  @override
  String get personMuteForMe => 'Заглушить для себя';

  @override
  String get personUnmuteForMe => 'Вернуть звук для себя';

  @override
  String get moderationServerMute => 'Выключить микрофон';

  @override
  String get moderationLiftServerMute => 'Разрешить микрофон';

  @override
  String get moderationKick => 'Выгнать из канала';

  @override
  String get personMakeServerAdmin => 'Сделать админом сервера';

  @override
  String get personRemoveServerAdmin => 'Убрать из админов сервера';

  @override
  String personNowAdmin(String name) {
    return '$name теперь админ сервера.';
  }

  @override
  String personNowMember(String name) {
    return '$name теперь участник.';
  }

  @override
  String get moderationBan => 'Заблокировать на сервере…';

  @override
  String moderationBanTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String moderationBanConfirm(String name) {
    return 'Заблокировать $name на этом сервере? Все сеансы этого человека сразу завершатся.';
  }

  @override
  String get moderationBanAction => 'Заблокировать';

  @override
  String moderationBanned(String name) {
    return 'Доступ для $name закрыт.';
  }

  @override
  String get moderationBanGuest => 'Заблокировать гостя на сутки…';

  @override
  String moderationBanGuestConfirm(String name) {
    return 'Выгнать $name и закрыть гостям вход с этого адреса на сутки?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name больше нет на сервере, вход гостям с этого адреса закрыт на сутки.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Сделать владельцем канала «$channel»';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Убрать из владельцев канала «$channel»';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name теперь владеет каналом «$channel».';
  }

  @override
  String channelNoOwner(String channel) {
    return 'У канала «$channel» больше нет владельца.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Сделать владельцем пространства «$space»';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Убрать из владельцев пространства «$space»';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name теперь владеет пространством «$space».';
  }

  @override
  String spaceNoOwner(String space) {
    return 'У пространства «$space» больше нет владельца.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Звук до $kbps кбит/с, стерео';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Звук до $kbps кбит/с, моно';
  }

  @override
  String get channelJoin => 'Войти';

  @override
  String get channelOpenChat => 'Открыть чат';

  @override
  String get channelOpenSettings => 'Настройки канала…';

  @override
  String get inviteCopyLink => 'Скопировать ссылку-приглашение';

  @override
  String inviteCopied(String channel) {
    return 'Ссылка-приглашение в «$channel» скопирована.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Приглашение в «$channel» скопировано. После первого входа по нему 10 минут пускает кого угодно, а неиспользованное действует сутки.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Ссылка-приглашение в «$channel» скопирована. Она сработает только для тех, кого канал и так пускает.';
  }

  @override
  String get inviteCannotCreate => 'Не удалось создать приглашение.';

  @override
  String get spaceNewChannel => 'Новый канал в пространстве…';

  @override
  String get spaceOpenSettings => 'Настройки пространства…';

  @override
  String get spaceDelete => 'Удалить пространство…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'Удалить пространство «$space»? Его каналы переедут на верхний уровень.';
  }

  @override
  String get workspaceMoveUp => 'Переместить выше';

  @override
  String get workspaceMoveDown => 'Переместить ниже';

  @override
  String get workspaceCannotReorder => 'Не удалось изменить порядок.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps кбит/с';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps кбит/с (речь)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps кбит/с (музыка)';
  }

  @override
  String get createNewChannel => 'Новый канал';

  @override
  String get createNewSpace => 'Новое пространство';

  @override
  String get createSubmit => 'Создать';

  @override
  String get createChannel => 'Канал';

  @override
  String get createSpace => 'Пространство';

  @override
  String get createChannelHint =>
      'Голосовая комната, куда заходят люди, со своим чатом.';

  @override
  String get createSpaceHint =>
      'Папка, которая собирает каналы в боковой панели.';

  @override
  String get createChannelPlaceholder => 'Синие';

  @override
  String get channelSettingsTitle => 'Настройки канала';

  @override
  String get channelSettingsOwnerHint =>
      'Владелец управляет этим каналом. Выбирать владельца могут только админы.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return 'Удалить $name? Все, кто внутри, будут отключены.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'Люди и звук';

  @override
  String get channelSettingsMaxPeople => 'Максимум людей';

  @override
  String get channelSettingsNoLimit => 'Без ограничений';

  @override
  String get channelSettingsAudioQuality => 'Качество звука';

  @override
  String get channelSettingsStereo => 'Стерео';

  @override
  String get channelSettingsDelete => 'Удалить канал…';

  @override
  String get manageSpace => 'Пространство';

  @override
  String get manageOwner => 'Владелец';

  @override
  String get manageAccess => 'Доступ';

  @override
  String get spaceSettingsTitle => 'Настройки пространства';

  @override
  String get spaceSettingsOwnerHint =>
      'Владелец управляет пространством и всеми каналами в нём. Выбирать владельца могут только админы.';

  @override
  String get accessAccountsOnly => 'Только с аккаунтом';

  @override
  String get accessAccountsOnlyDetail => 'Без гостей';

  @override
  String get accessWhitelistOnly => 'Только по списку допуска';

  @override
  String get accessHidden => 'Скрытый';

  @override
  String get accessHiddenDetail => 'Не виден тем, кому нельзя войти';

  @override
  String get accessFromSpace => 'Задано пространством';

  @override
  String summonsTitle(String channel) {
    return 'Позвать в $channel';
  }

  @override
  String get summonsSummon => 'Позвать';

  @override
  String get summonsNickname => 'Ник';

  @override
  String get summonsNoMatch => 'Никого подходящего, кто мог бы сюда зайти.';

  @override
  String get summonsHint =>
      'Человек получит уведомление, что вы его ждёте. Не чаще раза в 5 минут на человека.';

  @override
  String get summonsSearchFailed => 'Поиск не удался.';

  @override
  String get manageDeviceKey => 'Ключ устройства';

  @override
  String manageDeleteTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get manageDelete => 'Удалить';

  @override
  String get manageSave => 'Сохранить';

  @override
  String get manageName => 'Название';

  @override
  String get manageNone => 'Нет';

  @override
  String get manageNobody => 'Никто';

  @override
  String get manageSomeoneElse => 'Кто-то другой';

  @override
  String get manageWhitelistInWeb =>
      'Список допуска пока редактируется в веб-клиенте.';

  @override
  String get channelSettingsLimitHint =>
      'Когда канал заполнен, войти могут только те, кто им управляет. От 1 до 99 человек или без ограничений.';

  @override
  String get spaceSettingsAccessHint =>
      'Эти ограничения действуют на все каналы пространства; канал может только добавить свои. Список допуска пока редактируется в веб-клиенте.';

  @override
  String get accessWhitelistOnlyListDetail =>
      'Только люди и роли из его списка';

  @override
  String get summonsWho => 'Кого?';

  @override
  String get settingsPictures => 'Изображения';

  @override
  String get profileAddPicture => 'Добавить фото…';

  @override
  String get profileChangePicture => 'Сменить фото…';

  @override
  String get profileRemovePicture => 'Удалить фото';

  @override
  String get profileUploadFailed => 'Не удалось загрузить фото.';

  @override
  String get profileRemoveFailed => 'Не удалось удалить фото.';

  @override
  String get saveFailed => 'Не удалось сохранить.';

  @override
  String get settingsAudioVideo => 'Звук и видео';

  @override
  String get settingsMicrophone => 'Микрофон';

  @override
  String get settingsCamera => 'Камера';

  @override
  String get settingsOutput => 'Вывод звука';

  @override
  String get settingsVoiceProcessing => 'Обработка голоса';

  @override
  String get settingsVoiceProcessingDetail => 'Шумоподавление и эхоподавление';

  @override
  String get settingsVoiceProcessingHint =>
      'Выключите её для лучшего звука, но тогда наденьте наушники: без эхоподавления другие будут слышать себя через ваши колонки.';

  @override
  String get settingsCues => 'Звуки входа и выхода';

  @override
  String get settingsCuesDetail =>
      'Сова ухает, когда кто-то приходит или уходит, а сочетания клавиш отвечают щелчком';

  @override
  String get settingsPingAndLoss => 'Показывать пинг и потери';

  @override
  String get settingsPingAndLossDetail => 'Рядом со значком связи в звонке';

  @override
  String get summonsHeader => 'Вызовы в канал';

  @override
  String get summonsAllow => 'Другие могут меня звать';

  @override
  String get settingsNotificationsHere => 'Уведомления на этом устройстве';

  @override
  String get settingsNotificationsHint =>
      'Приходят, пока Wisetalk работает в фоне.';

  @override
  String get settingsNotifyMessages => 'Новые сообщения';

  @override
  String get settingsNotifyMessagesDetail =>
      'В чате вашего звонка и в чатах, которые вы открывали';

  @override
  String get settingsNotifySummons => 'Вызовы в канал';

  @override
  String get settingsNotifySummonsDetail => 'Когда кто-то зовёт вас в канал';

  @override
  String get settingsStayConnected => 'Оставаться на связи';

  @override
  String get settingsStayConnectedDetail =>
      'Вас позовут, даже когда Wisetalk закрыт';

  @override
  String get settingsStayConnectedHint =>
      'Wisetalk держит одно тихое соединение и своё уведомление. Некоторые телефоны всё равно его усыпляют: на Samsung уберите его из «Спящих приложений», на Xiaomi включите автозапуск.';

  @override
  String get settingsStayConnectedSteps => 'Как настроить этот телефон';

  @override
  String get stayConnectedTitle => 'Wisetalk на связи';

  @override
  String stayConnectedBody(String server) {
    return 'Ждёт, когда вас позовут на $server';
  }

  @override
  String get stayConnectedChannel => 'На связи';

  @override
  String get batteryTitle => 'Оставить Wisetalk на связи?';

  @override
  String get batteryBody =>
      'Android усыпляет приложения ради батареи, и вызов дождётся, пока вы сами откроете Wisetalk. Разрешите ему работать без экономии батареи: он держит одно тихое соединение, несколько килобайт в час.';

  @override
  String get batteryLater => 'Не сейчас';

  @override
  String get batteryContinue => 'Продолжить';

  @override
  String get settingsPrivacy => 'Конфиденциальность';

  @override
  String get settingsCrashReports => 'Отправлять отчёты о сбоях';

  @override
  String get settingsCrashReportsHint =>
      'Когда в Wisetalk что-то ломается, его разработчики узнают, что сломалось и где в коде. Ваши сообщения, имена, ключи и серверы туда не попадают.';

  @override
  String get settingsShortcuts => 'Сочетания клавиш';

  @override
  String get settingsShortcutsRecording =>
      'Нажмите новые клавиши. Backspace удаляет сочетание, Esc оставляет прежнее.';

  @override
  String get settingsShortcutsGlobal =>
      'Во время звонка они работают, какое бы приложение ни было впереди, в остальное время — в окне Wisetalk. Нажмите на любое, чтобы изменить.';

  @override
  String get settingsShortcutsWayland =>
      'В Wayland они работают, только пока окно Wisetalk впереди. Нажмите на любое, чтобы изменить.';

  @override
  String get settingsShortcutPressKeys => 'Нажмите клавиши…';

  @override
  String get settingsShortcutNone => 'Нет';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys уже занято: $action.';
  }

  @override
  String get shortcutToggleMute => 'Включить или выключить микрофон';

  @override
  String get shortcutToggleAway => 'Отойти или вернуться';

  @override
  String get shortcutMute => 'Выключить микрофон';

  @override
  String get shortcutUnmute => 'Включить микрофон';

  @override
  String get shortcutUnusableKey =>
      'Эту клавишу нельзя использовать в сочетании.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Добавьте $first или $second либо используйте F1–F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys занято системой или всеми приложениями.';
  }

  @override
  String get sheetDiscardTitle => 'Не сохранять изменения?';

  @override
  String get sheetDiscardMessage => 'Ваши изменения здесь ещё не сохранены.';

  @override
  String get sheetDiscard => 'Не сохранять';

  @override
  String get sheetKeepEditing => 'Продолжить';

  @override
  String serversRemoveTitle(String server) {
    return 'Удалить $server?';
  }

  @override
  String get serversRemoveMessage =>
      'Это устройство выйдет с сервера и забудет его. Добавить его снова можно по адресу.';

  @override
  String get serversRemove => 'Удалить';

  @override
  String get serversAddressHelp =>
      'Спросите адрес у того, кто ведёт ваше сообщество.';

  @override
  String get serversConnecting => 'Подключаемся…';

  @override
  String get serversConnect => 'Подключиться';

  @override
  String get serversWhich => 'На каком сервере ваше сообщество?';

  @override
  String get serversYours => 'Ваши серверы';

  @override
  String get serversAddMenu => 'Добавить сервер…';

  @override
  String get serversAddTitle => 'Добавить сервер';

  @override
  String get serversBadAddress =>
      'Введите адрес сервера, например talk.example.com.';

  @override
  String get serversTooNew =>
      'Этот сервер новее приложения. Обновите Wisetalk, чтобы войти.';

  @override
  String get serversTooOld =>
      'На этом сервере старая версия Wisetalk. Попросите админов обновить её.';

  @override
  String serversTooOldVersion(String version) {
    return 'На этом сервере старая версия Wisetalk ($version). Попросите админов обновить её.';
  }

  @override
  String get serversAddress => 'Адрес';

  @override
  String get serversMore => 'Ещё';

  @override
  String get serversRemoveServer => 'Удалить сервер';

  @override
  String get channelSomeChannel => 'канал';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name в $channel';
  }

  @override
  String get workspaceMessageEncrypted => 'Новое зашифрованное сообщение.';

  @override
  String get workspaceMessagePicture => 'Новая картинка.';

  @override
  String summonPushed(String name) {
    return 'Уведомление для $name доставлено.';
  }

  @override
  String get summonPushedSomeone => 'Уведомление доставлено.';

  @override
  String summonNotPushed(String name) {
    return 'Зов отправлен: $name. Уведомления у этого человека выключены, так что его увидят, только если Wisetalk открыт.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Зов отправлен. Уведомления у этого человека выключены, так что его увидят, только если Wisetalk открыт.';

  @override
  String summonReceived(String from, String channel) {
    return '$from зовёт вас в $channel.';
  }

  @override
  String get workspaceRoleChangedOwner =>
      'Теперь ваша роль на сервере — владелец.';

  @override
  String get workspaceRoleChangedAdmin =>
      'Теперь ваша роль на сервере — админ.';

  @override
  String get workspaceRoleChangedModerator =>
      'Теперь ваша роль на сервере — модератор.';

  @override
  String get workspaceRoleChangedMember =>
      'Теперь ваша роль на сервере — участник.';

  @override
  String get workspaceRoleChangedGuest =>
      'Теперь ваша роль на сервере — гость.';

  @override
  String get takeOverTitle => 'Войти с этого устройства?';

  @override
  String takeOverSameChannel(String channel) {
    return 'Вы уже в канале $channel на другом устройстве или в другой вкладке. Если войти в $channel здесь, там вы из звонка выйдете.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'Вы в канале $there на другом устройстве или в другой вкладке. Если войти в $here здесь, там вы из звонка выйдете.';
  }

  @override
  String get takeOverElsewhere =>
      'Вы уже в звонке на другом устройстве или в другой вкладке. Если войти здесь, там вы из звонка выйдете.';

  @override
  String get takeOverJoinHere => 'Войти здесь';

  @override
  String get workspaceShowChannels => 'Показать каналы';

  @override
  String get workspaceHideChannels => 'Скрыть каналы';

  @override
  String workspaceInVoice(int count) {
    return '$count на связи';
  }

  @override
  String get workspaceCreateTitle => 'Новый канал или пространство';

  @override
  String get workspaceStatusConnecting => 'Подключение…';

  @override
  String get workspaceStatusOffline => 'Нет связи…';

  @override
  String get workspaceEmptyAdmin =>
      'Каналов пока нет. Создайте первый кнопкой +.';

  @override
  String get workspaceEmpty => 'Каналов пока нет. Их может добавить админ.';

  @override
  String get workspaceMore => 'Ещё';

  @override
  String get workspaceCheckForUpdates => 'Проверить обновления';

  @override
  String get workspaceChangeServer => 'Сменить сервер';

  @override
  String get workspaceSignOut => 'Выйти';

  @override
  String get personMutedForYou => 'Заглушён для вас';

  @override
  String get awayTitle => 'Нет на месте';

  @override
  String get awayDescription => 'Нет на месте: микрофон и звук выключены';

  @override
  String get callMutedByModerator => 'Микрофон выключил модератор';

  @override
  String workspaceDrag(String name) {
    return 'Перетащить «$name»';
  }

  @override
  String get workspaceDropEndHint => 'Перетащите сюда, чтобы поставить в конец';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'Wisetalk $version загружен';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Вышел Wisetalk $version';
  }

  @override
  String get workspaceRestartToUpdate => 'Перезапустить и обновить';

  @override
  String workspaceUpdateTo(String version) {
    return 'Обновить до $version';
  }

  @override
  String get workspaceWelcomeTitle => 'Выберите голосовой канал';

  @override
  String get workspaceWelcomeHint => 'Нажмите на канал, чтобы войти.';

  @override
  String get callJoining => 'Подключаемся…';

  @override
  String get callWaitingForKey => 'Ждём ключ звонка…';

  @override
  String get callEncrypted => 'Сквозное шифрование';

  @override
  String videoScreen(String name) {
    return '$name · экран';
  }

  @override
  String get connectionExcellent => 'отличное';

  @override
  String get connectionGood => 'хорошее';

  @override
  String get connectionPoor => 'плохое';

  @override
  String get connectionLost => 'потеряно';

  @override
  String get connectionChecking => 'проверяется';

  @override
  String connectionStatus(String quality) {
    return 'Соединение: $quality';
  }

  @override
  String get connectionLabel => 'Соединение';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · потери $loss';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Пинг $ping, потери $loss';
  }

  @override
  String get connectionPing => 'Пинг';

  @override
  String get connectionOutgoingLoss => 'Исходящие потери';

  @override
  String get connectionIncomingLoss => 'Входящие потери';

  @override
  String get connectionJitter => 'Джиттер';

  @override
  String get connectionMicrophone => 'Микрофон';

  @override
  String get connectionNotSending => 'Не передаётся';

  @override
  String connectionKilobits(int value) {
    return '$value кбит/с';
  }

  @override
  String get screenShareTitle => 'Показать экран';

  @override
  String get screenShareAction => 'Показать';

  @override
  String get screenShareBestFor => 'Для чего';

  @override
  String get screenShareAndroidHint =>
      'Дальше Android спросит, показать весь экран или одно приложение.';

  @override
  String get screenShareWaylandHint =>
      'В первый раз система спросит, какой экран показать. Дальше будет тот же экран, пока Wisetalk не перезапустится. Пока только весь экран и без звука.';

  @override
  String get screenShareText => 'Текст и слайды';

  @override
  String get screenShareTextDetail =>
      'Чётко и легко: несколько кадров в секунду.';

  @override
  String get screenShareMotion => 'Видео и игры';

  @override
  String get screenShareMotionDetail =>
      'Плавно: 30 кадров в секунду, но тяжелее для обеих сторон.';

  @override
  String get screenShareSource => 'Экран или окно';

  @override
  String get screenShareSound => 'Передавать звук';

  @override
  String get screenShareSoundWindow => 'Только звук приложения этого окна.';

  @override
  String get screenShareSoundScreen => 'Всё, что вы слышите, кроме звонка.';

  @override
  String get screenShareSoundAny =>
      'Для окна — звук его приложения, для экрана — всё, что вы слышите, кроме звонка.';

  @override
  String get screenShareSoundPhone =>
      'Всё, что играет на телефоне, кроме звонка. Некоторые приложения это запрещают.';

  @override
  String get screenShareListFailed =>
      'Не удалось получить список экранов и окон.';

  @override
  String get screenShareChooseTitle => 'Выберите экран';

  @override
  String get screenShareChooseHint => 'Выберите экран в окне системы.';

  @override
  String get problemNotSignedIn => 'Вы не вошли.';

  @override
  String get problemAccountRequired => 'Сначала войдите с аккаунтом.';

  @override
  String get problemAccountBanned => 'Этот аккаунт заблокирован.';

  @override
  String get problemSignInCodeInvalid =>
      'Код входа больше не действует. Войдите снова.';

  @override
  String get problemBrowserCheckMissing =>
      'Нет проверки браузера. Перезагрузите страницу и попробуйте ещё раз.';

  @override
  String get problemBrowserCheckFailed =>
      'Браузер не прошёл проверку. Перезагрузите страницу и попробуйте ещё раз.';

  @override
  String get problemBrowserCheckExpired =>
      'Проверка браузера устарела. Попробуйте ещё раз.';

  @override
  String get problemGuestSignInClosed =>
      'Гостевой вход сейчас закрыт. Войдите с аккаунтом.';

  @override
  String get problemGuestAddressBlocked =>
      'Гостей с этого адреса временно не пускают.';

  @override
  String get problemTooManyGuests =>
      'Сейчас слишком много гостей. Попробуйте позже или войдите с аккаунтом.';

  @override
  String get problemTooManyGuestSignIns =>
      'С этого адреса слишком много гостевых входов. Попробуйте позже.';

  @override
  String get problemNameBelongsToAccount => 'Это имя занято аккаунтом.';

  @override
  String get problemAccountsCantBeGuests => 'С аккаунтом нельзя войти гостем.';

  @override
  String get problemNoSuchAccount => 'Такого аккаунта нет.';

  @override
  String get problemNoSuchChannel => 'Этого канала больше нет.';

  @override
  String get problemNoSuchSpace => 'Этого пространства больше нет.';

  @override
  String get problemNoSuchEmoji => 'Такого эмодзи нет.';

  @override
  String get problemNoSuchGuest => 'Этого гостя уже нет в сети.';

  @override
  String get problemNoSuchPicture => 'Этой картинки больше нет.';

  @override
  String get problemNoSuchMessage => 'Этого сообщения больше нет.';

  @override
  String get problemNoAvatar => 'Аватара нет.';

  @override
  String get problemNotBanned => 'Этот аккаунт не заблокирован.';

  @override
  String get problemDisplayNameLength => 'Имя — от 1 до 32 символов.';

  @override
  String get problemChannelNameLength =>
      'Название канала — от 1 до 64 символов.';

  @override
  String get problemSpaceNameLength =>
      'Название пространства — от 1 до 64 символов.';

  @override
  String get problemEmojiNameInvalid =>
      'Название эмодзи — от 2 до 32 символов из a–z, 0–9 и _.';

  @override
  String get problemIconInvalid =>
      'Иконка — это один эмодзи или :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Названия — до 40 символов, слоган — до 120, без управляющих символов.';

  @override
  String get problemChannelLimitInvalid =>
      'В канале может быть от 1 до 99 человек или без ограничения.';

  @override
  String get problemBitrateInvalid => 'Битрейт звука — от 6 до 510 кбит/с.';

  @override
  String get problemPictureType => 'Картинка должна быть в PNG, JPEG или WebP.';

  @override
  String get problemAvatarTooLarge => 'Картинка больше 256 КБ.';

  @override
  String get problemEmojiTooLarge => 'Картинка больше 128 КБ.';

  @override
  String get problemChatPictureTooLarge => 'Картинка может весить до 20 МБ.';

  @override
  String get problemPictureIdTaken => 'Эта картинка уже загружена.';

  @override
  String get problemChatFullOfPictures =>
      'В этом чате слишком много картинок. Подождите, пока он очистится.';

  @override
  String get problemTooManyPictures => 'Многовато картинок. Подождите немного.';

  @override
  String get problemManageNotPerRole =>
      'Право управлять нельзя выдать отдельной роли.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'У владельцев и админов всегда есть все права.';

  @override
  String get problemOneOverridePerRole =>
      'Для каждой роли — только одно правило.';

  @override
  String get problemWhitelistUnknownAccount =>
      'В списке допуска есть аккаунт, которого не существует.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Гостей список допуска не пропускает никогда.';

  @override
  String get problemPushSubscriptionInvalid =>
      'Браузер прислал неправильную подписку на уведомления.';

  @override
  String get problemPushEndpointNotPublic =>
      'Адрес для уведомлений должен быть публичным HTTPS-адресом.';

  @override
  String get problemNotAllowedInChannel => 'В этом канале вам это нельзя.';

  @override
  String get problemMayNotEnter => 'Вам нельзя в этот канал.';

  @override
  String get problemTheyMayNotEnter => 'Этому человеку нельзя в этот канал.';

  @override
  String get problemMayNotModerate => 'Вы не можете модерировать этот канал.';

  @override
  String get problemCantModerateYourself => 'Нельзя модерировать самого себя.';

  @override
  String get problemModerateRank =>
      'Нельзя модерировать тех, чья роль равна вашей или выше.';

  @override
  String get problemBanRank =>
      'Нельзя заблокировать того, чья роль равна вашей или выше.';

  @override
  String get problemRoleRank =>
      'Выдавать можно только роли ниже вашей и только тем, кто ниже вас.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Управлять сервером могут только его владельцы и админы.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Блокировками управляют только владельцы и админы сервера.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Своими эмодзи управляют только владельцы и админы сервера.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Пространствами управляют только владельцы и админы сервера.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Владельцев каналов назначают только владельцы и админы сервера.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Владельцев пространств назначают только владельцы и админы сервера.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Пространством управляют только админы и его владелец.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Создавать каналы могут только админы, а владельцы пространств — в своём пространстве.';

  @override
  String get problemMoveIntoOwnSpace =>
      'Переносить каналы можно только в пространство, которым вы управляете.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Приглашать могут только те, кто может модерировать канал.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Гости не могут создавать каналы.';

  @override
  String get problemGuestsCantInvite => 'Гости не могут приглашать.';

  @override
  String get problemGuestsCantBan => 'Гости не могут блокировать.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Гости не могут получать уведомления.';

  @override
  String get problemGuestsHaveNoAvatar => 'У гостей нет аватара.';

  @override
  String get problemNotYourDevice => 'Это не ваше устройство.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'Это устройство принадлежит другому аккаунту.';

  @override
  String get problemOwnMessagesOnly => 'Удалять можно только свои сообщения.';

  @override
  String get problemChannelFull => 'Канал заполнен.';

  @override
  String get problemInviteUsed => 'Приглашение уже использовано или истекло.';

  @override
  String get problemTooManyInvites =>
      'Слишком много неиспользованных приглашений. Подождите, пока часть из них истечёт.';

  @override
  String get problemJoinChannelFirst => 'Сначала зайдите в канал.';

  @override
  String get problemNotInVoice => 'Вы не в голосовом канале.';

  @override
  String get problemNotInThatChannel => 'Вы не в этом канале.';

  @override
  String get problemPersonNotInYourChannel =>
      'Этого человека нет в вашем канале.';

  @override
  String get problemDeviceNotInChannel => 'Этого устройства нет в канале.';

  @override
  String get problemDeviceNotOnline =>
      'Это устройство не в сети, или ему нельзя в канал.';

  @override
  String get problemVoiceNotConfigured =>
      'Голосовая связь на этом сервере не настроена.';

  @override
  String get problemSummonNeedsAccount =>
      'Чтобы звать людей, войдите с аккаунтом.';

  @override
  String get problemCantSummonYourself => 'Нельзя позвать самого себя.';

  @override
  String get problemAlreadyHere => 'Этот человек уже здесь.';

  @override
  String get problemSummonsOff => 'Этот человек запретил себя звать.';

  @override
  String get problemSummonedRecently =>
      'Вы уже звали этого человека меньше 5 минут назад.';

  @override
  String get problemMessageLength => 'Сообщение — от 1 до 2000 символов.';

  @override
  String get problemUploadPictureFirst => 'Картинка не загрузилась.';

  @override
  String get problemPictureNotAccepted => 'Этот чат не принимает эту картинку.';

  @override
  String get problemChatHasNoKey => 'У этого чата ещё нет ключа.';

  @override
  String get problemNobodyHasChatKey =>
      'Ни у кого в сети нет ключа этого чата.';

  @override
  String get problemNotCurrentChatKey => 'Это не текущий ключ чата.';

  @override
  String get problemChatKeyChanged => 'Ключ чата сменился. Попробуйте ещё раз.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'Ключи запечатаны для другого ключа чата.';

  @override
  String get problemSealForYourself => 'Запечатайте ключ и для себя.';

  @override
  String get problemSealDeviceCount =>
      'Ключ можно запечатать для 1–1000 устройств.';

  @override
  String get problemNoLongerAllowed =>
      'У вас больше нет доступа к этому каналу.';

  @override
  String get problemJoinedElsewhere => 'Вы зашли с другого устройства.';

  @override
  String problemKickedBy(String by) {
    return '$by: вас убрали из канала.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by: вас убрали с сервера. Гостям с вашего адреса вход закрыт на сутки.';
  }

  @override
  String get problemBannedFromServer => 'Вы заблокированы на этом сервере.';

  @override
  String get problemGuestSignInClosedByAdmin => 'Админ закрыл гостевой вход.';

  @override
  String get problemHelloFirst =>
      'Соединение ещё не было готово. Перезагрузите страницу.';

  @override
  String get problemUnreadableCommand =>
      'Сервер не понял запрос. Перезагрузите страницу.';

  @override
  String get problemUnsupportedProtocol =>
      'Эта версия Wisetalk слишком старая для сервера. Перезагрузите страницу.';

  @override
  String get problemSlowDown => 'Чуть помедленнее.';

  @override
  String get problemTooManyCommands =>
      'Слишком много действий сразу. Чуть помедленнее.';

  @override
  String get problemGone => 'Этого уже нет.';

  @override
  String get problemInternal => 'На сервере что-то пошло не так.';

  @override
  String get problemTooLarge => 'Слишком большой объём для отправки.';

  @override
  String get problemUnavailable =>
      'Сервер не отвечает. Попробуйте через минуту.';
}
