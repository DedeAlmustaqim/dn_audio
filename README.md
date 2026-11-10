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
- audio_service for the Android background audio service and media session
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
- Background audio handler foundation with a shared just_audio engine and media queue/state bridge.
- Android media playback foreground service and media button receiver declarations.
- Media notification metadata includes track title, artist, album, duration, and available MediaStore album artwork URI.

## Planned

- Background playback and lifecycle validation (Stage 4.2).
- Media notification metadata and album artwork integration (Stage 4.3).
- Lock-screen controls and audio focus refinements (Stage 4.4).
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

Stages 1–3.5 and Stage 4.1 are complete. Stage 4.2 background playback has passed local device verification. Stage 4.3 adds media notification metadata and album artwork; local verification is pending.
