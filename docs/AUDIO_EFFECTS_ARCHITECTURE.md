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

Flutter session binding is encapsulated by `AudioEffectsService`, which listens to the existing player's Android session ID stream and serializes native attach/release operations.

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
- Preserve per-effect failure reasons so Flutter can distinguish unavailable effects independently.
- Do not request audio recording permission; these effects process the player's output session.

## 6. MethodChannel Contract

Channel: `dn_audio/audio_effects`

Initial methods:

- `attachSession`: receives `sessionId`; releases previous effects and attaches supported effects.
- `getCapabilities`: returns support flags, band count, frequency ranges, level ranges and available platform preset metadata.
- `setEqualizerEnabled`: toggles Equalizer.
- `setBandLevel`: receives band index and level in millibels.
- `setBassBoost`: receives enabled state and strength within the device-reported range.
- `setVirtualizer`: receives enabled state and strength within the device-reported range.
- `release`: releases all effect instances.

### Implemented in Stage 7.1.1

Channel: `dn_audio/audio_effects`

- `attachSession`: accepts `sessionId`, releases effects from a previous session when the ID changes, then creates supported effect instances.
- `getCapabilities`: returns support flags and basic device-reported Equalizer band/frequency/level metadata, plus BassBoost and Virtualizer support information.
- `release`: releases all native effect instances and clears the attached session.

The channel is registered separately from `dn_audio/audio_library` in `MainActivity`.

### Implemented in Stage 7.1.2

- Added `AudioEffectsService` with the dedicated `dn_audio/audio_effects` MethodChannel.
- Bound `AudioPlayer.androidAudioSessionIdStream` from the existing `DnAudioHandler`; no second player or audio pipeline is created.
- Serialized session changes so rapid or duplicate stream events cannot race native attachment.
- Attached a new positive session ID, released the native manager when the stream becomes null, and released the active session during handler disposal.
- Treated native channel failures as optional-effect failures and logged them without changing playback state.
- Added service tests for duplicate IDs, session replacement, null-session release, and disposal.

### Implemented in Stage 7.1.3

- Added typed Flutter models for effect and band capabilities; the band list and ranges are parsed from native device data rather than a fixed layout.
- Exposed the latest capability snapshot and a broadcast capability stream from `AudioEffectsService`.
- Added an explicit `getCapabilities` request and safe unavailable-state reporting for missing channel responses and platform errors.
- Native initialization failures now include per-effect error reasons; one unsupported effect does not hide the others.
- Added tests for capability parsing, device-reported band metadata, independent optional-effect support, capability publication, and channel failure handling.

### Implemented in Stage 7.2 — Equalizer Engine & Controls

- Added native `setEqualizerEnabled` and `setBandLevel` operations to the existing audio-effects channel.
- Native commands validate the active Equalizer instance, band index, and device-reported millibel range before applying changes.
- Capability responses now include each band's current level and the Equalizer enabled state so Flutter can resynchronize after a command.
- Added `AudioEffectsService` methods that reject unsupported or out-of-range requests and treat channel failures as optional-feature failures.
- Added service tests for command arguments, capability refresh, and range validation.

- Added an Equalizer action to the Now Playing header that opens a dedicated responsive bottom sheet.
- Added device-aware band sliders, master enable/disable, current dB labels, flat reset, capability refresh, and an unavailable state.
- Exposed the existing handler-owned service to the UI; no second player, service, or audio pipeline is created.
- UI and engine changes are still subject to local Flutter and Android verification.

### Stage 7.3 — DN Audio Presets

- Added built-in Flat, Bass, Vocal, Treble and Rock sound curves.
- Curves are authored as five frequency anchors and interpolated logarithmically onto the active device's reported band centers.
- Preset gains are clamped to the active device's reported millibel range.
- Applying a preset sends each band through the existing AudioEffectsService and native Equalizer session; no second playback pipeline or Android vendor preset assumptions are introduced.
- The Equalizer view exposes preset chips and shows the selected profile; manual band changes clear the selected preset indicator.
- Preset mapping has unit tests for flat response, curve mapping, range clamping and unknown preset IDs.

Preset selection is currently an in-memory UI action. Persisting the selected profile and restoring it across sessions remains in Stage 7.5.

### Stage 7.4 — Bass Enhancement & Virtualizer

- Added native `setBassBoost` and `setVirtualizer` operations. Each effect is controlled independently and remains bound to the existing player's active audio session.
- Android exposes the strength domain as 0–1000 for these effects; the native capability response reports that domain, whether `strengthSupported` is true, and the current rounded strength.
- When strength control is unsupported, the native command can still toggle the effect without attempting to set its strength. Flutter hides the intensity slider and presents the ON/OFF-only state.
- Flutter service validates effect support, active session, and reported strength bounds before invoking the channel. Successful commands publish refreshed capabilities.
- The Equalizer screen shows Bass Enhancement and Virtualizer controls only when each effect is reported as supported. No additional player or audio pipeline is created.
- Added service tests for command payloads, refreshed state, unsupported effects, and out-of-range strengths.


All effect types are initialized independently. If one effect cannot be created, other supported effects remain available. A failed effect initialization is treated as an unavailable optional capability, not as a playback failure.

## 7. Non-Goals for Stage 7.1

- No Equalizer UI yet.
- No fixed five-band UI yet.
- No DN Audio preset tuning yet.
- No persistence yet.
- No iOS/macOS implementation in this Android-first stage.

## 8. Acceptance Criteria

- A valid player session can be attached without replacing or recreating the player.
- A changed session ID causes the old effects to be released and the new session to be rebound.
- A null session ID releases the active effects; handler disposal releases any remaining native effects.
- Unsupported effects are reported independently.
- Device-reported band count and ranges are returned without assumptions.
- Effect initialization failure does not pause, stop or otherwise interrupt playback.
- Releasing the effects manager leaves the playback engine usable.
