# DN Audio — Development Roadmap

**Product:** DN Audio  
**Brand:** Digital Native Dev  
**Tagline:** Your Music. Your Experience.  
**Platform:** Android · Flutter · GetX  
**Product model:** Premium offline music player

This document is the current source of truth for development progress. It distinguishes implementation in the repository from local automated tests and physical-device verification.

## Status definitions

- **Complete:** implementation and the required verification for that scope have been confirmed.
- **Implemented — verification pending:** code is present, but the required local/device checks have not all been confirmed.
- **In progress:** work is actively being performed.
- **Not started:** work has not begun.
- **Release blocker:** must be resolved before production release.

---

## Stage 1 — Project Foundation

- Flutter application foundation and GetX MVC structure.
- Core theme, navigation, and shared application shell.

**Status: Complete**

## Stage 2 — Local Music Library

- Android MediaStore integration and local audio scanning.
- Android-version-aware audio permission handling.
- Songs, Albums, and Artists browsing.
- Search, refresh, metadata, and artwork presentation.

**Status: Implemented. Core library and collection flows have been confirmed during earlier device checks. Final permission grant/deny/revoke regression remains part of Stage 10 and Stage 11.**

## Stage 3 — Audio Playback Engine

- just_audio playback engine.
- Play, pause, seek, previous, next, shuffle, and repeat.
- Mini Player and Now Playing.
- Collection and playlist playback integration.

**Status: Implemented. Full release regression remains in Stage 11.**

## Stage 3.5 — Stabilization & Refinement

- Library loading and playback error handling.
- Song and metadata validation.
- Automated tests and iterative stabilization.

**Status: Complete for the original stabilization scope. Ongoing regression is tracked in Stage 10–11.**

## Stage 4 — Background Audio Experience

### 4.1 — Audio Service Architecture

- audio_service integration and DnAudioHandler.
- Shared playback engine and media-session state bridge.
- Android foreground media playback service declarations.

**Status: Complete — local device verification was reported.**

### 4.2 — Background Playback

- Playback while the app is minimized and the screen is locked.

**Status: Complete — local device verification was reported.**

### 4.3 — Media Notification & Artwork

- Track title, artist, album, duration, playback controls, and artwork metadata.
- Native artwork resolution and cache fallback.
- Synchronization between notification and Now Playing artwork/playback state.

**Status: Implemented. Notification controls and artwork display were reported working. Some metadata quality (for example, missing artist tags in source files) depends on the local media metadata. Include this scope in final regression.**

### 4.4 — Lock Screen, Headset & Audio Focus

- Audio session configuration and becoming-noisy handling are implemented.
- Headset/Bluetooth media-button verification, lock-screen verification, and interruption behavior remain device-test items.

**Status: Partially implemented — verification pending.**

---

## Stage 5 — Playlist Management

- SQLite playlist database and repository.
- Create, rename, delete, duplicate-name validation.
- Add/remove tracks and playlist detail.
- Ordered playlist playback and persistence.

**Status: Implemented in the repository. Automated controller tests exist; full SQLite persistence and end-to-end device regression remain required before release.**

## Stage 6 — Artwork, Metadata & Collections

- Shared artwork resolution and caching.
- MediaStore album/artist identity and grouping.
- Album and Artist browsing and detail screens.
- Play All and collection-based playback.

**Status: Core implementation complete. Earlier device checks for artwork and collection flows were reported successful. Include in final regression.**

## Stage 7 — Equalizer & Audio Effects

- Native Android audio-effects manager and MethodChannel.
- Audio session binding and capability detection.
- Equalizer bands, presets, Bass Boost, and Virtualizer where supported.
- SQLite persistence and restoration across audio sessions.

**Status: Implemented. Earlier service/preset tests and local checks were reported clean. Physical-device capability and regression checks remain required across supported and unsupported devices.**

## Stage 8 — Sleep Timer

- Monotonic countdown service owned by the audio handler.
- Quick and custom durations.
- Start, replace, cancel, expiry, and pause playback.
- UI state and countdown.

**Status: Implemented. Automated service/controller tests exist; final background and expiry regression remains part of Stage 11.**

## Stage 9 — Product Completion, Settings & UI/UX

### 9.1 — Home Functional Completion

- Home search entry point and library shortcuts.
- Real current playback context instead of fabricated history.
- Settings access and removal of unsupported folder/history affordances.

**Status: Implemented.**

### 9.2 — Settings & Audio Library Preferences

- SQLite settings repository and audio-format preferences.
- Native MediaStore format filtering.
- Playback speed and audio-experience preferences.

**Status: Implemented. Automated and device verification is included in final regression.**

### 9.4 — Storage & Maintenance

- Library overview and rescan.
- Artwork cache size/count information.
- Safe artwork cache cleanup with explicit scope and confirmation.

**Status: Implemented. Final device regression for scan failure/retry and cache cleanup remains required.**

### 9.5 — About DN Audio

- Product identity and developer attribution.
- Dynamic app version/build.
- Open-source license information.

**Status: Implemented.**

### 9.6 — Final UI/UX Refinement

Approved design source: [docs/DESIGN_DIRECTION.md](docs/DESIGN_DIRECTION.md).

Locked design direction:
- Immersive Minimal across the application.
- Editorial Now Playing.
- Premium Dark monochrome palette: black, white, and grey.
- Poppins typography direction.
- Preserve feature behavior and architecture; do not invent unsupported features.

Implementation slices recorded:
- 9.6.1 — design foundation and shared tokens.
- 9.6.2 — shared components.
- 9.6.3 — Home, Library, Album, and Artist surfaces.
- 9.6.4 — Now Playing.
- 9.6.5 — Playlists and Playlist Detail.
- 9.6.6 — Equalizer and Sleep Timer.
- 9.6.7 — Settings, Storage, and About.
- 9.6.8 — visual QA refinements and regression checklist.

**Status: Implementation slices recorded in the repository. Final visual/accessibility QA and physical-device regression are not yet declared complete.**

---

## Stage 10 — Final Repository Audit & Release Preparation

### 10.1 — Android Configuration & Dependencies

- Flutter/Android toolchain review.
- Application ID, version, SDK configuration.
- Debug APK build validation.

**Status: Audit complete for the checked environment.**  
The user's local debug APK was reported built successfully with application ID com.digitalnative.dn_audio, version 1.0.0+1, minSdk 24, compileSdk 36, and targetSdk 36. This does not certify a production release artifact.

### 10.2 — Permissions, Manifest & Data Behavior

- Main manifest and permission declarations reviewed.
- Android MediaStore permission handling reviewed.
- Local SQLite settings and playlist storage reviewed.
- No direct analytics/ad/Firebase dependency was identified in the reviewed dependency manifest.

**Status: Static audit complete; device permission regression and merged release manifest review pending.**  
This static review is not a complete privacy audit.

### 10.3 — Test Coverage & Feature Verification

- Repository inventory identified 17 Dart test files and 89 declared test cases at the audit baseline.
- No integration-test directory or GitHub Actions workflow was found at that baseline.
- Four test failures were identified and test-only fixes were committed:
  - initialize GetX translations in playlist controller tests;
  - align the Home widget smoke test with the current UI rather than a removed tagline.

**Status: In progress — the updated test suite must be rerun locally and results recorded.**  
Test inventory counts describe source declarations, not passing test results.

### 10.4 — Documentation & Release Checklist

- 10.4.1 — README reconstruction.
- 10.4.2 — Roadmap synchronization.
- 10.4.3 — Release checklist and signing/AAB documentation.
- 10.4.4 — Privacy Policy and Play Store preparation notes.

**Status: In progress. 10.4.1, 10.4.2, and 10.4.3 are committed; 10.4.4 remains.**

---

## Stage 11 — QA & Regression Testing

Planned final regression scope:

- First-launch permission, deny, grant, revoke, and retry.
- Library scan, refresh, empty library, and scan errors.
- Songs, Albums, Artists, search, and collection playback.
- Play/pause, seek, next/previous, shuffle, and repeat.
- Background playback, notification, lock screen, audio focus, and headset behavior.
- Playlist create/rename/delete, add/remove tracks, order, and persistence after restart.
- Equalizer presets/bands and supported/unsupported effects.
- Sleep Timer quick/custom duration, cancellation, and expiry while backgrounded.
- Playback speed, settings persistence, library rescan, and artwork cache cleanup.
- Localization, text scaling, accessibility, insets, and compact screen layouts.

**Status: Not started as a formal release regression pass.**

## Stage 12 — Android Release Engineering

- Create and securely store production upload keystore.
- Replace debug signing configuration with production release signing.
- Verify release build type, merged manifest, permissions, and app bundle.
- Build and validate signed Android App Bundle (AAB).
- Verify version code/name and signing certificate.

**Status: Not started.**

**Release blocker:** the previously audited release build configuration used the debug signing config. Production signing must be configured before a Play Store release. Never commit keystores or passwords.

## Stage 13 — Google Play Store Preparation

- Final app name, short/full description, screenshots, icon, and feature graphic.
- Privacy Policy hosted at a public URL.
- Data Safety, Ads, App Access, Content Rating, and target audience declarations as applicable.
- Permission rationale and store compliance review.
- Internal/closed testing track preparation.

**Status: Not started.**

## Stage 14 — Release & Post-release Monitoring

- Upload to Play Console testing track.
- Resolve pre-launch report and tester feedback.
- Production rollout after approval.
- Monitor crashes, ANRs, reviews, and user-reported issues.
- Plan patch releases and post-release improvements.

**Status: Not started.**

---

## Current Development Position

**Current stage: Stage 10.4 — Documentation & Release Checklist Audit**

- 10.4.1 README reconstruction: committed.
- 10.4.2 ROADMAP synchronization: in progress.
- 10.4.3 Release checklist: pending.
- 10.4.4 Privacy and Play Store preparation: pending.

The next work item is **Stage 10.4.3 — create the release checklist**.

## Completion Rules

1. A commit on GitHub proves that a change is present in the repository; it does not prove local build or device verification.
2. Mark a stage complete only when its stated acceptance checks have been performed and results recorded.
3. Do not claim tests, builds, signing, or device checks passed unless the developer reports the result or an available tool verifies it.
4. Keep changes small, scoped, and reviewable.
5. Develop on the main branch unless the project owner explicitly changes this decision.
6. Never commit private signing credentials, keystores, passwords, or personal secrets.
