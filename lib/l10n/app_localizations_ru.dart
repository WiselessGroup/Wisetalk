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
}
