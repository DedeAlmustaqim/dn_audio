# DN Audio

**DN Audio** is an offline-first music player for Android, developed by **Digital Native Dev**.

> Your Music. Your Experience.

DN Audio plays music stored on the user's device. It is designed around a focused local listening experience, with library browsing, playlists, playback controls, background audio, and device-supported audio effects.

## Product direction

- **Product model:** offline-first; music is read from the device's local audio library.
- **Visual direction:** Immersive Minimal across the app, with an Editorial Now Playing experience.
- **Theme:** Premium Dark, using a monochrome palette of black, white, and grey.
- **Typography direction:** Poppins.
- **Localization:** English and Bahasa Indonesia.
- **Platform:** Android.

DN Audio is not a streaming service. It does not advertise cloud music, online discovery, or cloud library synchronization.

## Features

### Music library
- Scan and browse local audio through Android MediaStore.
- Browse Songs, Albums, and Artists.
- Search local tracks by title, artist, and album.
- Handle audio-library permission states and library refresh.
- Display available track metadata and local album artwork.

### Playback
- Play, pause, seek, previous, and next.
- Shuffle and repeat modes.
- Persistent mini-player and expanded Now Playing screen.
- Background playback through Android media playback service integration.
- Media notification and lock-screen playback controls.
- Audio-session handling, including pausing when headphones or an audio route are disconnected where supported by the platform.

### Playlists
- Create, rename, and delete user playlists.
- Add and remove tracks.
- Play a playlist or an individual track.
- Persist playlist data locally.

### Audio experience
- Equalizer presets and frequency-band controls where supported by the device.
- Bass Boost and Virtualizer controls where supported by the device and audio session.
- Playback speed preference.
- Sleep timer with quick/custom duration and cancellation.

Audio-effect availability depends on the Android device and active audio session. The app should not represent an unsupported effect as active.

### Settings and maintenance
- English and Bahasa Indonesia interface.
- Library preferences and rescan.
- Artwork-cache information and cleanup.
- About screen with app version/build information and open-source licenses.

## Technology

- **Flutter** — Android application UI and application framework.
- **Dart** — application language.
- **GetX** — state management, dependency management, navigation, and translations.
- **just_audio** — audio playback engine.
- **audio_service** — background audio and media-session integration.
- **audio_session** — audio-session configuration.
- **sqflite** — local settings and playlist persistence.
- **Android MediaStore** — access to indexed local audio and artwork metadata.
- **Kotlin / MethodChannel** — Android platform integration, including native audio-library and audio-effects operations.

## Requirements

- Flutter SDK compatible with the project configuration.
- Android SDK and Android toolchain.
- Android device or emulator.
- Android minimum SDK: **24**.
- The app requests access to local audio using the Android media permissions appropriate to the OS version.

## Getting started

Install dependencies:

```bash
flutter pub get
```

Run static analysis and tests:

```bash
dart format lib test
flutter analyze
flutter test
```

Run on a connected Android device or emulator:

```bash
flutter run
```

Build a debug APK:

```bash
flutter build apk --debug
```

For a Play Store release, configure a private upload keystore and release signing locally before building an Android App Bundle:

```bash
flutter build appbundle --release
```

Never commit signing keys, passwords, or other release credentials to the repository.

## Project structure

The application is organized by core infrastructure and feature modules. The project uses GetX-based controllers and separates UI from services and local persistence. Android-specific functionality is implemented in the Android host project and accessed through platform channels where required.

## Privacy Policy

The DN Audio Privacy Policy is published separately and is also accessible from **Settings → About → Privacy Policy**:

https://dedealmustaqim.github.io/dn_audio_privacy/

## Quality and release status

DN Audio is in **release preparation**. A successful debug build does not by itself mean that a production release is ready.

Before release, the project still requires the applicable checks to be completed and recorded, including:

- Full automated test run and review of any failures.
- Physical-device regression for permissions, library scanning, playback, background playback, notifications, playlists, sleep timer, and audio effects.
- Release-manifest and permission review.
- Production upload-key configuration and signed AAB validation.
- Privacy Policy and Google Play Data Safety / app-content declarations.
- Store listing assets and final Play Console review.

See [ROADMAP.md](ROADMAP.md) for development stages and [docs/DESIGN_DIRECTION.md](docs/DESIGN_DIRECTION.md) for the approved UX/UI direction.

## License

No license is specified in this README. Refer to the repository's license file, if present, for the applicable terms.
