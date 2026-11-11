# DN Audio — Audio Effects Architecture

**Status:** Architecture baseline for Stage 7.1  
**Platform target for initial implementation:** Android  
**Playback engine:** Existing `just_audio` instance owned by `DnAudioHandler`

## 1. Goals

- Add system audio effects without creating a second player or audio pipeline.
- Bind every effect to the active Android audio session created by the existing player.
- Discover actual device capabilities instead of assuming a fixed equalizer layout.
- Keep playback independent from optional effects: an unavailable or failed effect must never stop music.
- Keep native effect lifecycle and Flutter state explicit and testable.

## 2. Existing Architecture

- `DnAudioHandler` owns the single `AudioPlayer`.
- `PlayerController` uses that same player through `DnAudioHandler`.
- `MainActivity` already hosts a MethodChannel for audio-library operations.
- `just_audio 0.10.6` exposes `androidAudioSessionId` and `androidAudioSessionIdStream`.

The audio session ID can change when Android audio attributes are changed. Therefore, effects must be rebound whenever the player emits a new non-null session ID.

## 3. Proposed Components

### Flutter

- `AudioEffectsService`: owns the effects MethodChannel contract and session binding.
- `AudioEffectsController`: GetX state holder for capability, enabled state, band values, preset and optional effects.
- `AudioEffectsSettings`: typed model for device capabilities and current user settings.
- UI widgets remain separate from the service and native bridge.

### Android

- A dedicated MethodChannel: `dn_audio/audio_effects`.
- Native manager owns Android `Equalizer`, `BassBoost`, and `Virtualizer` instances.
- Native manager releases old effect instances before binding to a new audio session.
- Native manager reports capability and device-reported ranges to Flutter.

The audio-library channel remains responsible only for media-library and artwork operations.

## 4. Session Lifecycle

1. Wait until `AudioPlayer.androidAudioSessionIdStream` emits a valid, non-null session ID.
2. Release effects attached to the previous session.
3. Create supported effects for the new session.
4. Query Equalizer band count, frequency range, level range and available platform presets.
5. Report capabilities to Flutter.
6. Apply the current enabled state and values.
7. On a later session ID change, repeat the binding process.
8. On service shutdown, release every native effect instance.

A missing or invalid session ID means effects are unavailable for now; it is not a playback error.

## 5. Device Capability Rules

- Never hardcode a five-band assumption in the native layer.
- Read band count and frequency/level ranges from the active Equalizer instance.
- Treat Equalizer, BassBoost and Virtualizer as independently optional.
- Treat platform presets as device-specific. DN Audio presets will be mapped to available bands in a later stage.
- Catch native initialization and parameter errors and return a structured unsupported/error result.
- Do not request audio recording permission; these effects process the player's output session.

## 6. MethodChannel Contract (proposed)

Channel: `dn_audio/audio_effects`

Initial methods:

- `attachSession`: receives `sessionId`; releases previous effects and attaches supported effects.
- `getCapabilities`: returns support flags, band count, frequency ranges, level ranges and available platform preset metadata.
- `setEqualizerEnabled`: toggles Equalizer.
- `setBandLevel`: receives band index and level in millibels.
- `setBassBoost`: receives enabled state and strength within the device-reported range.
- `setVirtualizer`: receives enabled state and strength within the device-reported range.
- `release`: releases all effect instances.

The exact response model and error codes will be finalized with the first native implementation. Method calls must be idempotent where practical.

## 7. Non-Goals for Stage 7.1

- No Equalizer UI yet.
- No fixed five-band UI yet.
- No DN Audio preset tuning yet.
- No persistence yet.
- No iOS/macOS implementation in this Android-first stage.

## 8. Acceptance Criteria

- A valid player session can be attached without replacing or recreating the player.
- A changed session ID causes the old effects to be released and the new session to be rebound.
- Unsupported effects are reported independently.
- Device-reported band count and ranges are returned without assumptions.
- Effect initialization failure does not pause, stop or otherwise interrupt playback.
- Releasing the effects manager leaves the playback engine usable.
