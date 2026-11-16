# DN Audio — Android Release Checklist

This checklist governs preparation of a signed Android App Bundle for Google Play. It is a release procedure, not evidence that any item has already passed.

**Current application identity (audit baseline)**

- Application ID: `com.digitalnative.dn_audio`
- Current version: `1.0.0+1` (`versionName=1.0.0`, `versionCode=1`)
- Minimum Android SDK: 24
- SDK values are supplied through the Flutter Gradle configuration; re-check the effective values in the release artifact before upload.

## 1. Pre-release repository and environment

- [ ] Pull the latest `main` branch and confirm the working tree is clean.
- [ ] Confirm Flutter, Dart, Android SDK, Java, Gradle, and Android licenses are healthy.
- [ ] Run `flutter pub get`.
- [ ] Run `dart format --output=none --set-exit-if-changed .` and resolve formatting issues.
- [ ] Run `flutter analyze` and resolve errors and relevant warnings.
- [ ] Run the complete `flutter test` suite; record the final pass/fail result.
- [ ] Review the final diff and ensure no debug-only code, test data, credentials, or local paths are included.
- [ ] Confirm the product name, application ID, version name, version code, icon, and launch experience.

## 2. Production upload key and credential safety

**Release blocker:** the audited `android/app/build.gradle.kts` currently signs the release build with the debug signing configuration. Do not upload an artifact built with that configuration.

Before creating or storing signing credentials:

- [ ] Update the repository `.gitignore` to exclude the local signing properties file (for example, `android/key.properties`) and keystore files (for example, `*.jks` and `*.keystore`).
- [ ] Verify those ignore rules with `git check-ignore` before placing credentials in the repository directory.
- [ ] Generate a dedicated production upload keystore using a secure local process.
- [ ] Store the keystore and passwords outside version control, in a secure backup location.
- [ ] Use a strong unique keystore password and key password; retain them in a password manager.
- [ ] Record the keystore alias and certificate details securely.
- [ ] Never paste credentials into chat, source code, commits, screenshots, issue reports, or build logs.
- [ ] Never commit the keystore, signing properties, or passwords to GitHub.

Google Play App Signing is recommended: the upload key signs the submitted bundle, while Google Play manages the app signing key used for distribution. Keep the upload key protected because losing it can complicate future updates.

## 3. Configure release signing

- [ ] Add a local-only signing properties file, such as `android/key.properties`, containing the keystore path, store password, key alias, and key password.
- [ ] Configure `android/app/build.gradle.kts` to load those values from the local properties file (or a secure CI secret store).
- [ ] Define a dedicated release signing config and assign it to the release build type.
- [ ] Remove the current release-to-debug signing assignment.
- [ ] Fail the release build clearly when required signing properties are absent; do not silently fall back to debug signing.
- [ ] Keep debug signing unchanged for debug builds.
- [ ] Confirm the local properties file and keystore are ignored by Git and absent from the staged diff.
- [ ] Review the effective Gradle configuration without printing passwords or other secrets.

Do not copy a signing snippet blindly: adapt it to the repository's Kotlin DSL and Gradle plugin versions, then run a real release build.

## 4. Versioning and Android configuration

Before each Play Store upload:

- [ ] Increase `versionCode` (the integer after `+` in `pubspec.yaml`).
- [ ] Set the intended user-facing `versionName` (the value before `+`).
- [ ] Confirm `applicationId` remains `com.digitalnative.dn_audio`.
- [ ] Confirm `minSdk`, `targetSdk`, and `compileSdk` meet current Google Play requirements.
- [ ] Review the main and merged release manifests for permissions, exported components, foreground service declarations, and intent filters.
- [ ] Confirm media playback foreground service declarations and notification behavior are appropriate for the target Android versions.
- [ ] Check that no development-only permissions or components have leaked into the release manifest.
- [ ] Review dependency updates and their Android permission/transitive dependency impact.

Do not rely on the debug APK's metadata as proof of the release AAB configuration.

## 5. Final functional and device regression

- [ ] Fresh install and first-run audio permission flow.
- [ ] Permission denied, retry/grant, revoke in Android Settings, and relaunch.
- [ ] Scan, refresh, empty library, and library scan error handling.
- [ ] Songs, Albums, Artists, search, and collection playback.
- [ ] Play/pause, seek, next/previous, shuffle, and repeat.
- [ ] Background playback, notification controls, lock screen, and process/lifecycle behavior.
- [ ] Headset/Bluetooth media controls, audio focus, becoming-noisy, and interruption behavior.
- [ ] Playlist create, rename, delete, add/remove songs, ordering, and persistence after app restart.
- [ ] Equalizer bands/presets, Bass Boost, Virtualizer, unsupported effects, and session changes.
- [ ] Sleep Timer quick/custom durations, replace/cancel, and expiry while backgrounded.
- [ ] Playback speed and settings persistence after restart.
- [ ] Library rescan, artwork cache information, and artwork cache cleanup.
- [ ] Localization, text scaling, safe areas, accessibility, and compact-screen layouts.
- [ ] Confirm no unexpected crashes, stuck playback, corrupted local data, or regressions.

Record device model, Android version, app build, test scenario, result, and any issue found. Do not mark a scenario passed unless it was actually performed.

## 6. Build the signed release bundle

After signing is configured and all required checks pass:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```

- [ ] Confirm the command completes successfully.
- [ ] Confirm the expected bundle exists at `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Confirm the bundle is signed with the intended upload certificate.
- [ ] Inspect the bundle with Android Studio's Analyze APK/Bundle workflow or `bundletool`.
- [ ] Verify package/application ID, version name, version code, min SDK, target SDK, and included permissions.
- [ ] Test the release build on a physical device (for example, install a generated APK set from the AAB using bundletool).
- [ ] Exercise core playback, library, playlist, audio effects, and timer behavior in release mode.
- [ ] Archive the exact AAB, build commit SHA, version details, and test record securely.

The debug APK previously built successfully is a development validation only; it is not a substitute for this signed release AAB process.

## 7. Google Play Console handoff

- [ ] Confirm Play App Signing setup and upload certificate.
- [ ] Prepare store listing assets and localized descriptions.
- [ ] Publish a public Privacy Policy URL and verify it is accessible.
- [ ] Complete Data Safety, Ads, App Access, Content Rating, target audience, and other declarations truthfully as applicable.
- [ ] Review permission declarations and provide required explanations.
- [ ] Upload the signed AAB to an internal testing track first.
- [ ] Review Play Console validation messages and pre-launch report.
- [ ] Test installation/update from the Play testing track.
- [ ] Resolve critical issues before promoting to wider testing or production.

## 8. Release approval record

Complete this section for each release candidate.

| Field | Record |
|---|---|
| Release version | Pending |
| Version code | Pending |
| Source commit SHA | Pending |
| Build date | Pending |
| AAB SHA-256 | Pending |
| Upload certificate fingerprint | Pending |
| Automated tests | Pending |
| Physical-device regression | Pending |
| Play Console track | Pending |
| Release decision / approver | Pending |

## Release gate

A release candidate is ready for Play Console submission only when:

1. The production upload key is configured and protected.
2. The release AAB is successfully built and verified with the expected identity and signing certificate.
3. Automated tests and required physical-device regression checks have passed.
4. Privacy and Play Console declarations are complete and accurate.
5. The exact release artifact and its source commit are recorded.

**Never treat a successful debug build, a GitHub commit, or a static repository audit as proof that the production release is ready.**
