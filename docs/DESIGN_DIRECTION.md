# DN Audio — Design Direction & UI/UX Blueprint

**Product:** DN Audio  
**Brand:** Digital Native Dev  
**Tagline:** Your Music. Your Experience.  
**Platform:** Android (Flutter + GetX)  
**Document status:** Design direction approved; detailed UI polish deferred  
**Design direction:** Premium Editorial  
**Accent:** Warm Amber  
**Scope:** Entire application  
**Implementation policy:** Do not start the visual redesign now. Apply this blueprint during the final polish stage, after core product features and playback behaviour are stable.

---

## 1. Purpose

This document records the visual and UX direction for DN Audio so future implementation remains consistent. DN Audio is an offline-first music player for a user's local device library. The interface should make listening, discovering personal music, and managing playlists feel calm, intentional, and premium.

The design must support the product rather than distract from it. Album artwork and music metadata should be the primary visual content; controls and navigation should remain clear and familiar.

## 2. Design principles

1. **Music first:** artwork, song title, artist and playback state receive the strongest hierarchy.
2. **Editorial restraint:** strong typography, deliberate spacing, limited decoration and confident alignment.
3. **Premium, not ornamental:** avoid excessive gradients, glass effects, glowing borders, oversized cards and decorative animation.
4. **Consistent interaction:** the same action should look and behave consistently across Home, Library, Playlists and Now Playing.
5. **Offline-native:** do not imply streaming, cloud sync or online discovery. Empty states should guide users to local device music.
6. **Functional integrity:** visual work must preserve existing playback, queue, background audio and playlist behaviour.
7. **Progressive delivery:** defer broad UI changes until the final polish stage; do not disrupt current feature development.

## 3. Visual identity

### 3.1 Mood

Premium Editorial — dark, warm, minimal, tactile and music-led.

The visual language should feel closer to a carefully designed personal music collection than a generic media dashboard.

### 3.2 Proposed color tokens

These are target design tokens for the final polish phase, not an instruction to modify the current theme immediately.

| Token | Proposed value | Usage |
|---|---|---|
| `color.background` | `#0B0B0F` | Main app background |
| `color.surface` | `#17171D` | Navigation, sheets and grouped surfaces |
| `color.surfaceElevated` | `#222229` | Elevated controls and selected surfaces |
| `color.accent` | `#F2A65A` | Primary actions, active states, progress |
| `color.accentPressed` | `#D98A3D` | Pressed/strong accent state |
| `color.textPrimary` | `#F5F3EF` | Main text |
| `color.textSecondary` | `#A5A1A0` | Supporting metadata |
| `color.borderSubtle` | `#302D2C` | Dividers and subtle outlines |
| `color.success` | semantic green | Success feedback |
| `color.warning` | semantic amber/yellow | Warnings (distinct from brand accent where needed) |
| `color.error` | semantic red | Errors and destructive actions |

Amber is the brand accent, not a background color for large areas. Use it selectively to direct attention.

### 3.3 Typography

Preferred direction: **Poppins** or **Inter**. Select one family during implementation and use it consistently.

| Role | Suggested size | Weight |
|---|---:|---|
| Display / Home headline | 30–34 | Bold |
| Screen title | 26–30 | Bold |
| Section title | 17–20 | Semi-bold |
| Song title | 14–16 | Medium / Semi-bold |
| Body | 14–16 | Regular |
| Metadata / helper | 12–13 | Regular |
| Eyebrow / overline | 10–11 | Semi-bold, restrained tracking |

Avoid using all-caps for long labels. Metadata should remain legible and secondary.

### 3.4 Spacing, shape and elevation

- Use a 4 dp base grid and prefer 8 dp increments.
- Standard screen horizontal padding: 20–24 dp.
- Compact list row height: target 64–72 dp, adjusted for touch accessibility.
- Card/sheet radius: 16–20 dp; large artwork radius: 20–24 dp.
- Prefer subtle surface contrast over heavy shadows.
- Interactive touch targets: at least 48 dp on Android.
- Keep safe-area and system navigation insets respected.

## 4. Information architecture

### Primary navigation

Retain the current four destinations unless product testing later indicates a better structure:

1. **Home** — listening overview and entry points.
2. **Library** — local music collection and search.
3. **Playlists** — user-created collections.
4. **Equalizer** — audio controls and effects when supported.

The persistent mini-player remains above the bottom navigation while a track is active.

### Screen inventory

| Screen | Purpose | Current status |
|---|---|---|
| Home | Recently played, quick access and library overview | Implemented foundation |
| Library | Scan, search and play local songs | Implemented |
| Now Playing | Current track and playback controls | Implemented foundation |
| Mini Player | Persistent playback summary and quick controls | Implemented |
| Playlists | Create, rename, delete and browse playlists | Implementation available; local verification pending |
| Playlist Detail | Ordered songs, play all and remove song | Implementation available; local verification pending |
| Queue | View and manage upcoming playback | Planned / needs product definition |
| Album Detail | Browse songs by album | Planned |
| Artist Detail | Browse songs by artist | Planned |
| Equalizer | Presets and supported audio effects | Planned |
| Sleep Timer | Stop playback after a chosen duration | Planned |
| Settings | App preferences and library/audio options | To be defined |

Do not present planned screens as completed functionality.

## 5. Screen-by-screen design intent

### 5.1 Home

**User goal:** quickly resume listening or enter their music collection.

Proposed hierarchy:
1. Compact DN Audio brand/header area.
2. Editorial headline or concise welcome line; avoid repeating the tagline excessively.
3. Search entry point.
4. Recently Played section, only when listening history exists.
5. A featured/recently played item or compact artwork-led row.
6. Library shortcuts (Songs, Albums, Artists and Folders only when supported).
7. Optional playlist preview when playlist data is available.

UX rules:
- Do not show fake recently played content.
- If history is not implemented, use a useful library-first Home rather than an empty decorative section.
- Keep the first meaningful action visible without excessive scrolling.

### 5.2 Library

**User goal:** find and play a song stored on the device.

Proposed hierarchy:
1. Screen title and local song count.
2. Search field for title, artist and album.
3. Sort/filter controls when implemented (e.g. title, artist, recently added).
4. Song list with artwork thumbnail, title, artist and duration.
5. Per-song overflow actions including Add to playlist.

UX states to design:
- Initial permission request / permission denied.
- Scanning/loading.
- Library populated.
- No audio found.
- No search results.
- Scan failure and retry.
- Missing metadata or artwork.

Do not imply cloud music access. Preserve Android MediaStore as the source of the local collection.

### 5.3 Now Playing

**User goal:** enjoy and control the current track with minimal distraction.

This is the signature screen of DN Audio and should receive the strongest visual craft during final polish.

Proposed hierarchy:
1. Compact top bar with dismiss/back affordance and Now Playing context.
2. Large square album artwork, ideally the dominant visual element.
3. Track title and artist, with clear truncation rules.
4. Playback progress and elapsed/remaining duration.
5. Primary transport controls: Previous, Play/Pause, Next.
6. Secondary controls: Shuffle and Repeat.
7. Optional queue and more-actions entry points only when their behaviour exists.

Interaction rules:
- Play/Pause must remain the strongest control.
- Buffering must have a visible but unobtrusive state.
- Seek must remain responsive and show accurate position/duration.
- Active shuffle/repeat states must be distinguishable without relying on color alone.
- Missing artwork uses a designed neutral placeholder, not a broken image.
- Playback errors should be understandable and recoverable.

Artwork must be sourced from the existing metadata/artwork pipeline; do not introduce a network dependency.

### 5.4 Mini Player

**User goal:** control or reopen the current track from anywhere in the main app.

Proposed hierarchy:
- Small artwork thumbnail.
- Track title and artist.
- Play/Pause as the primary quick action.
- Optional next action if it remains useful and does not overcrowd the bar.
- Thin progress indicator if reliable playback position is available.

The entire non-control area should open Now Playing. Controls must remain independently tappable. Ensure the mini-player does not conflict with bottom navigation or system insets.

### 5.5 Playlists

**User goal:** create and manage personal song collections.

Proposed hierarchy:
- Page title and Create action.
- Playlist collection with artwork treatment.
- Playlist name and song count.
- Overflow actions for Rename and Delete.

Use actual playlist songs for artwork where available. Until artwork composition is implemented, use a consistent branded placeholder. Avoid inventing cover art or metadata.

States:
- Loading.
- No playlists, with a clear Create Playlist action.
- Populated list.
- Create/rename validation.
- Duplicate-name error.
- Delete confirmation.
- Persistence/database error.

### 5.6 Playlist Detail

**User goal:** play a collection in order and maintain its contents.

Proposed hierarchy:
- Back navigation.
- Playlist artwork/visual identity.
- Name and song count.
- Play All action.
- Ordered song list with artwork, title, artist and duration.
- Per-song Remove from playlist action.

Preserve current playlist order. Tapping a song should start playback from that index while retaining the playlist sequence. Empty and load-error states must remain distinct.

### 5.7 Equalizer

This screen is planned, not yet a completed audio feature.

Design direction:
- Clear enabled/disabled or unsupported state.
- Preset selection.
- Frequency controls only when supported by the device/audio implementation.
- Reset action and concise explanatory copy.

Do not display functional-looking controls before the underlying audio effects are implemented and verified. Explain device limitations honestly.

### 5.8 Future screens

Album Detail, Artist Detail, Queue, Sleep Timer and Settings should follow the same editorial system when their product scope and behaviour are defined. Their visual design must not be used to imply that these capabilities are already available.

## 6. Component direction

| Component | Design guidance |
|---|---|
| Primary button | Amber fill, dark readable label, 48–52 dp height |
| Secondary button | Subtle surface or outline; no competing accent |
| Icon button | Consistent icon family and 48 dp touch target |
| Song row | Artwork, two-line metadata, optional trailing action |
| Artwork tile | Square crop, consistent radius, graceful fallback |
| Search field | Clear label/hint, visible focus and clear action |
| Bottom navigation | Four destinations, restrained selected indicator |
| Mini player | Compact elevated surface, separated from navigation |
| Bottom sheet | Dark surface, rounded top corners, clear drag/dismiss affordance |
| Dialog | Short copy, clear primary and cancel actions |
| Empty state | Simple icon/artwork, useful explanation and one next action |
| Error state | Plain-language message and recovery action |

Avoid creating a card for every piece of content. Use flat editorial sections and list layouts where they improve scanning.

## 7. Motion and interaction

- Use short, purposeful transitions (roughly 160–240 ms for simple UI changes).
- Use subtle fade/slide transitions for screen or sheet changes.
- Avoid continuous decorative animation.
- Provide clear pressed, selected, disabled, loading and error states.
- Respect Android reduced-motion/system animation preferences where applicable.
- Never delay playback controls with decorative transitions.

## 8. Accessibility and usability requirements

- Maintain readable contrast for primary and secondary text.
- Do not communicate playback state using color alone; pair color with icon/state.
- Provide semantic labels/tooltips for icon-only controls.
- Maintain minimum 48 dp touch targets.
- Support text scaling and prevent important controls from clipping.
- Ensure song title/artist truncation does not hide all useful context.
- Provide distinct loading, empty, permission, error and success states.
- Ensure bottom sheets and dialogs can be dismissed and navigated predictably.

## 9. Flutter implementation guidance

Current architecture: Flutter + GetX, with feature modules and shared theme/constants.

Implementation should:
- Preserve GetX MVC/module boundaries.
- Reuse existing controllers and services; do not move playback logic into widgets.
- Keep `DnAudioHandler` / `just_audio` as the playback foundation.
- Preserve Android MediaStore integration and offline-first behaviour.
- Keep SQLite playlist persistence and repository boundaries.
- Introduce shared design tokens and reusable widgets during the final polish phase.
- Avoid screen-specific hardcoded colors and repeated style definitions after the design system is introduced.
- Keep UI refactors separate from audio engine or database changes where possible.

Current theme uses a dark palette with purple accent (`#B794F6`). This is the current implementation, not the final brand decision. Do not change it as part of ongoing feature work; migrate to the approved amber tokens in a dedicated visual-polish pass.

## 10. Delivery plan and timing

**Important:** DN Audio is still under active feature development. The visual redesign is intentionally deferred.

### Now — feature completion and stability
- Continue the active roadmap, currently Stage 5.6 (playlist persistence, validation and testing).
- Complete remaining background audio, lock-screen, audio focus and device verification tasks as scheduled.
- Implement and verify the remaining planned capabilities according to the product roadmap.
- Fix functional bugs and stabilize data/playback behaviour.
- Keep UI changes limited to functional fixes and essential usability corrections.

### Final stage — UI/UX polish
1. Reconfirm this design direction against the finished feature set.
2. Finalize design tokens and typography.
3. Build reusable components and migrate the app theme from purple to amber.
4. Polish Home and Library.
5. Polish Now Playing and Mini Player.
6. Polish Playlists and Playlist Detail.
7. Design and implement Equalizer, Sleep Timer, Queue and other screens only if their features are complete.
8. Complete accessibility, responsive layout, motion and visual QA.
9. Run `dart format lib test`, `flutter analyze`, `flutter test`, then perform device testing for playback and UI regression.

### Definition of done
- Every shipped feature has a clear, consistent interface.
- No screen advertises a feature that is not implemented.
- Playback, queue, notification and lock-screen behaviour remain intact.
- All key screens have loading, empty, error and populated states as relevant.
- Design tokens are consistently used across the app.
- Accessibility and device regression checks pass.

## 11. Design decision record

| Decision | Agreed direction |
|---|---|
| Product identity | DN Audio by Digital Native Dev |
| Tagline | Your Music. Your Experience. |
| Visual style | Premium Editorial |
| Accent color | Warm Amber (`#F2A65A` proposed) |
| Overall theme | Premium Dark |
| Scope | Entire application |
| Implementation timing | Final polish stage, after feature development |
| Current task | Document design direction only; no broad UI refactor now |

---

**Status:** Direction documented. Visual redesign and implementation are deferred until the final UI polish stage. Update this document if the product scope changes before that stage.
