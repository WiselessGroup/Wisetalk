<p align="center">
  <img src="docs/logo.svg" width="160" alt="Логотип Wisetalk: сова в наушниках">
</p>

<h1 align="center">Wisetalk</h1>

<p align="center">
  Голосовой и видеочат для одного сообщества на сервере, который принадлежит вам.<br>
  Linux · Windows · macOS · Android<br>
  Сквозное шифрование · Через сервер, без пиринга · Открытый код
</p>

<p align="center">
  <a href="README.md">English</a> &nbsp;|&nbsp; <b>Русский</b>
</p>

<p align="center">
  <a href="https://github.com/WiselessGroup/Wisetalk/releases/latest"><img alt="Последний релиз" src="https://img.shields.io/github/v/release/WiselessGroup/Wisetalk?label=release&color=cba6f7"></a>
  <a href="https://github.com/WiselessGroup/Wisetalk/releases"><img alt="Скачивания" src="https://img.shields.io/github/downloads/WiselessGroup/Wisetalk/total?color=fe640b"></a>
  <a href="https://github.com/WiselessGroup/Wisetalk/actions/workflows/build.yml"><img alt="Сборка" src="https://img.shields.io/github/actions/workflow/status/WiselessGroup/Wisetalk/build.yml"></a>
  <a href="https://github.com/WiselessGroup/Wisetalk/commits/master"><img alt="Последний коммит" src="https://img.shields.io/github/last-commit/WiselessGroup/Wisetalk?color=8839ef"></a>
  <a href="https://github.com/WiselessGroup/Wisetalk/stargazers"><img alt="Звёзды" src="https://img.shields.io/github/stars/WiselessGroup/Wisetalk?style=flat&color=cba6f7"></a>
  <a href="LICENSE"><img alt="Лицензия" src="https://img.shields.io/github/license/WiselessGroup/Wisetalk?color=555"></a>
</p>

<p align="center">
  <img src="docs/owl.webp" width="640" alt="Сова Wisetalk в наушниках и игровом кресле играет за столом с кружкой и ведёрком снеков">
</p>

Мы сидели на TeamSpeak 6, и его пиринговое видео постоянно отваливалось на симметричных NAT. Поэтому команда Wiseless написала себе замену и с тех пор каждый день созванивается в ней.

Один сервер, одно сообщество: никаких гильдий и воркспейсов, никуда не надо вступать и ничего не надо искать. Голосовые каналы лежат в спейсах, у каждого канала есть короткоживущий чат, можно включать камеру и показывать экран. Всё идёт через ретранслятор самого сервера, включая TURN на 443-м порту, так что работает и там, где пиринг сдаётся. Звонки и чаты зашифрованы сквозным шифрованием: сервер хранит шифротекст и передаёт ключи, которые сам открыть не может.

Это нативное приложение, в нём звук и видео настолько хороши, насколько позволяет машина. Есть ещё [веб-клиент](https://git.wiseless.net/Wisetalk/webclient), которому не нужна установка, и оба сидят в одних и тех же звонках. Подключаться нужно к [серверу](https://git.wiseless.net/Wisetalk/server): вашего сообщества или своему.

## Скачать

Файлы лежат в [последнем релизе](https://github.com/WiselessGroup/Wisetalk/releases/latest), в их именах есть версия.

| Система | Файл |
|---|---|
| Linux, x86_64 | `Wisetalk-X.Y.Z-x86_64.AppImage` |
| Windows 10 / 11, x64 | `Wisetalk-X.Y.Z-x64-Setup.exe` |
| macOS, Apple silicon | `Wisetalk-X.Y.Z-arm64.dmg` |
| Android 11+ | `Wisetalk-X.Y.Z.apk` |

iOS будет позже.

На компьютере приложение скачивает обновления в фоне, а кнопка «Restart to Update» их применяет (при следующем запуске они применятся и так). На Android оно сообщит о новом APK. Интерфейс есть на английском, русском, традиционном китайском, японском, бразильском португальском, немецком, французском и испанском.

### Первый запуск

- **Linux.** Сделайте AppImage исполняемым и запустите или отдайте его [Gear Lever](https://flathub.org/apps/it.mijorus.gearlever): он сделает одну рабочую иконку и сам будет находить новые версии.
- **Windows.** Установщик пока не подписан, поэтому SmartScreen предупредит: «Подробнее», затем «Выполнить в любом случае».
- **macOS.** Перетащите Wisetalk в «Программы». Приложение не нотаризовано, и первый запуск macOS заблокирует; разрешите его в «Системные настройки» → «Конфиденциальность и безопасность» → «Всё равно открыть».
- **Android.** Разрешите браузеру установить APK. Вызовы дойдут и при закрытом приложении, если оставить включённым Stay Connected; один раз оно попросит не ограничивать его в оптимизации батареи.

Дальше введите адрес сервера и войдите через браузер или гостем, просто с именем, если сервер это разрешает.

## Что умеет

- Звонки с камерой и показом экрана, для каждого звонка свой ключ. На Windows показанное окно приносит с собой звук своего приложения. На Linux и Windows при выключенной обработке голоса микрофон идёт в стерео.
- Чаты каналов с картинками, уведомления о вызовах и сообщениях. На Android звонки держит foreground-сервис, а вызовы приходят при закрытом приложении, без Google и отдельных пуш-приложений.
- Несколько серверов в одном клике друг от друга. Ссылки `wisetalk://` со страницы сервера добавляют его или открывают.
- Away: один клик выключает микрофон и звук всех остальных. Другие видят перечёркнутые наушники и слышат сонную сову.
- Полоски соединения с пингом и потерями, чтобы было понятно, у кого проблемы с сетью.
- Ctrl+Shift+M и Ctrl+Shift+A (⌘ на Mac), пока окно на переднем плане, и глобальные клавиши на Windows, macOS и X11.
- Гостевые паспорта: гостя, которого сервер знает и ни разу не выгонял, не держат лимиты общего адреса.
- Модерация и повседневное администрирование: заглушить, выгнать, забанить, назначить владельцев, настроить, создать и переставить каналы и спейсы. Белые списки, права по ролям и установка иконок каналов остаются в веб-клиенте: все функции администрирования появляются сначала там.
- Настройки устройств, обработки голоса, звуков, вызовов и уведомлений. На телефонах интерфейс в одну колонку и полноэкранные листы.
- Почти ничего не потребляет, пока никто не говорит. Свёрнутое окно на Wayland вообще перестаёт рисовать.

Всё по релизам: [CHANGELOG.md](CHANGELOG.md).

## Вопросы

**Сервер идёт в комплекте?** Нет. Wisetalk это одно сообщество на одном сервере, так что кто-то должен его поднять. У [сервера](https://git.wiseless.net/Wisetalk/server) есть набор для самостоятельного развёртывания на Docker Compose.

**Может ли сервер слушать мои звонки?** Он передаёт медиа, но ключей у него нет. Звонки шифруются на вашем устройстве ключом, которым участники обмениваются между собой. С чатами то же самое, а картинки шифруются вместе с текстом.

**Заработает ли за моей сетью?** Ради этого всё и затевалось. Пиринга нет: медиа идёт на ретранслятор сервера, а для сетей, где закрыто всё остальное, есть TURN поверх TLS на 443-м порту.

**Куда приложение подключается само?** Вот весь список:

- к серверам, которые вы добавили, и их медиаретрансляторам;
- к GitHub за обновлениями на компьютере (Android спрашивает ваш сервер);
- к нашему сборщику падений, только если вы включили отчёты. В них не бывает сообщений, имён, ключей и адресов серверов.

**Есть веб-версия?** Да, устанавливаемое PWA по адресу вашего сервера. В нём самое полное администрирование, а звук и видео по максимуму выжимаются в приложении.

## Как устроено

```
lib/                приложение на Flutter; в lib/theme.dart токены дизайна
lib/src/rust/       Dart-сторона моста, генерируется, руками не править
rust/               wisetalk_bridge: ключи устройств, шифрование звонков и чатов,
                    proof of work, проверка имён, всё из core
hook/build.dart     собирает rust/ во время flutter build и кладёт библиотеку
android/ linux/
macos/ windows/     раннеры платформ
packaging/linux/    ярлык, metainfo, AppRun и иконка для AppImage
scripts/            проверки, замеры, сборка пакетов
```

Один код на Flutter для всех платформ. На Dart ничего не шифруется: вся криптография приходит из [core](https://git.wiseless.net/Wisetalk/core) через flutter_rust_bridge, это та же библиотека, которую веб-клиент собирает в WebAssembly. Медиа идёт через [LiveKit](https://livekit.io).

## Сборка из исходников

Нужны Flutter 3.47, `rustup` (версию и цели задаёт `rust/rust-toolchain.toml`) и `cargo install flutter_rust_bridge_codegen --version 2.13.0 --locked`.

- **Linux на Fedora:** `clang cmake ninja-build pkgconf-pkg-config gtk3-devel libstdc++-devel mesa-libGLU libsecret-devel libayatana-appindicator-gtk3-devel pulseaudio-libs-devel`.
- **macOS:** Xcode.
- **Windows:** Visual Studio 2022 с «Desktop development with C++».
- **Android:** Android Studio, SDK API 36, NDK, cmdline-tools.

`flutter doctor -v` подскажет, чего ещё не хватает.

```bash
flutter run -d linux                    # или macos, windows; мост собирается сам
flutter test                            # виджетные тесты грузят rust/target/release
cd rust && cargo test                   # только мост
flutter_rust_bridge_codegen generate    # после изменений в rust/src/api
scripts/check.sh                        # всё, что должно пройти перед пушем
```

Библиотека моста ищется в `rust/target/release` относительно рабочей папки раньше, чем встроенная копия. Устаревшая сборка там побеждает свежую из приложения; лечится `cargo build --release` в `rust/`. На Mac виджетный тест с мостом и тесты уведомлений через D-Bus падают, так что `flutter test` и `scripts/check.sh` рассчитаны на Linux.

Как выходят релизы, написано в [docs/releasing.md](docs/releasing.md).

## Как помочь

Больше всего помогают сообщения об ошибках, особенно про сети, из которых мы сами проверить не можем. Пишите в [issues на GitHub](https://github.com/WiselessGroup/Wisetalk/issues).

Этот репозиторий на GitHub это зеркало того, где идёт работа: [git.wiseless.net/Wisetalk/client](https://git.wiseless.net/Wisetalk/client). Пул-реквесты мы применяем там, с вашим именем в коммитах, и сюда они возвращаются через зеркало.

Если Wisetalk спас ваш созвон от вечных обрывов, поставьте звезду: так его найдут другие.

## Лицензия

[AGPL-3.0](LICENSE). Если вы запускаете изменённую версию для других людей, вы должны предложить им её исходный код. [core](https://git.wiseless.net/Wisetalk/core) под MIT или Apache-2.0, так что можно написать свой клиент.
