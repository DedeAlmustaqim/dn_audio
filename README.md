# DN Audio

**DN Audio** is a premium offline music player for Android, built by **Digital Native Dev**.

> Your Music. Your Experience.

## Product direction

- Offline-first playback from the device's local music library.
- Modern, minimal Premium Dark interface.
- Library browsing, playlists, queue and Now Playing.
- Background playback with notification and lock-screen controls.
- Equalizer and audio effects where supported by the device.
- Sleep timer designed for reliable operation while the screen is off.

## Tech stack

- Flutter
- GetX for state management and navigation
- just_audio for audio playback
- Android MediaStore through a platform MethodChannel
- Android-first development

## Implemented

- Premium Dark application shell and bottom navigation.
- Local audio library scanning through Android MediaStore.
- Audio permission handling when the Library tab is first opened.
- Song search by title, artist, and album.
- Audio playback with play, pause, seek, previous, and next controls.
- Shuffle and repeat modes.
- Persistent mini-player and expanded Now Playing view.

## Planned

- Background playback, media notification, and lock-screen controls.
- Playlist management and playback queue UI.
- Album artwork and richer metadata presentation.
- Equalizer and supported audio effects.
- Sleep timer.
- Listening history and recently played.

## Development

    flutter pub get
    dart format lib test
    flutter analyze
    flutter test
    flutter run

## Current status

Stages 1–3 are implemented. Stage 3.5 focuses on stabilization, error handling, and automated tests before background playback work begins.
