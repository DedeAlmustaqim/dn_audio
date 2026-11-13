# DN Audio — Final Design Direction & UX/UI Blueprint

**Product:** DN Audio  
**Brand:** Digital Native Dev  
**Tagline:** Your Music. Your Experience.  
**Platform:** Android · Flutter · GetX  
**Document status:** Approved design direction for Stage 9.6  
**Overall visual character:** Immersive Minimal  
**Now Playing character:** Editorial  
**Typography:** Poppins  
**Color direction:** Monochrome — black, white and grey  
**Scope:** All currently implemented MVP screens  
**Implementation policy:** Stage 9.6 is a visual and UX refinement pass. Preserve product behaviour and architecture; do not introduce unimplemented features under the guise of visual polish.

---

## 1. Purpose and product character

DN Audio is an offline-first music player for a user's local device library. It is a focused listening product, not a streaming service or a generic media dashboard.

The visual system combines two complementary characteristics:

- **Immersive Minimal across the application:** quiet surfaces, deliberate negative space, low visual noise, strong hierarchy and controls that appear only as needed.
- **Editorial in Now Playing:** expressive typography, confident composition, prominent artwork and carefully arranged metadata. This is the signature listening experience.

The application should feel cohesive and restrained from screen to screen, while Now Playing is allowed to have a more distinctive editorial composition. Premium quality comes from proportion, typography, alignment, consistency and interaction—not decoration.

## 2. Locked design decisions

| Decision | Final direction |
|---|---|
| Product identity | DN Audio by Digital Native Dev |
| Tagline | Your Music. Your Experience. |
| Overall visual character | Immersive Minimal |
| Now Playing character | Editorial |
| Typography | Poppins |
| Brand palette | Monochrome: black, white and grey |
| Theme | Premium Dark |
| Scope | All implemented MVP screens |
| Delivery | Stage 9.6, after core feature implementation |
| Product model | Offline-first, local music library |

These decisions are the source of truth for Stage 9.6. Do not reopen the visual direction or substitute a saturated brand accent during implementation without an explicit product decision.

## 3. Design principles

1. **Listening is the focus.** Artwork, track identity and playback state should be immediately understandable.
2. **Immersion through restraint.** Use negative space, tonal separation and quiet navigation instead of decorative containers.
3. **Editorial hierarchy where it matters.** Now Playing may use larger type, asymmetrical emphasis and more expressive spacing, while remaining readable and functional.
4. **Monochrome with purpose.** Use contrast, size, weight and surface tone to establish hierarchy. Semantic colors are reserved for success, warning and error feedback.
5. **Offline honesty.** Only represent local-library and implemented capabilities. Never imply streaming, cloud sync or online discovery.
6. **Functional integrity.** UI work must not regress playback, audio focus, background playback, notification controls, playlists, persistence or device audio effects.
7. **Consistency without sameness.** Shared components should behave consistently; individual screens may use distinct compositions appropriate to their tasks.
8. **Progressive refinement.** Implement and validate one Stage 9.6 slice at a time. Do not perform a broad unreviewed rewrite.

## 4. Visual system

### 4.1 Color tokens

The following are target tokens for the final theme migration. They supersede the earlier provisional purple-accent implementation.

| Token | Value | Usage |
|---|---|---|
| `background` | `#0B0B0F` | Main app canvas |
| `surface` | `#17171D` | Navigation, sheets and grouped surfaces |
| `surfaceElevated` | `#222229` | Elevated controls and selected surfaces |
| `textPrimary` | `#F5F3EF` | Primary text and high-emphasis icons |
| `textSecondary` | `#A5A1A0` | Metadata and supporting text |
| `textMuted` | `#77747A` | Tertiary labels; use sparingly |
| `borderSubtle` | `#302D2C` | Dividers and subtle outlines |
| `controlInactive` | `#77747A` | Inactive controls |
| `controlActive` | `#F5F3EF` | Active controls and selected states |
| `success` | Semantic green | Success feedback only |
| `warning` | Semantic amber/yellow | Warning feedback only |
| `error` | Semantic red | Errors and destructive feedback |

Rules:
- No purple, amber or other saturated hue as a brand accent.
- Do not use color alone to communicate selected, enabled, shuffle, repeat or playback states.
- Maintain readable contrast for secondary and muted text.
- Artwork may contain its own colors; do not tint or recolor album art to force monochrome consistency.
- Avoid gradients, glow, glassmorphism and heavy shadows as default styling.

### 4.2 Typography — Poppins

Use Poppins consistently throughout the app. Use the available bundled font assets if present; otherwise add the font through the project's established asset/dependency approach and document the source/licensing.

| Role | Target size | Weight | Guidance |
|---|---:|---|---|
| Hero / editorial headline | 30–36 sp | Bold / SemiBold | Home emphasis and Now Playing composition |
| Screen title | 26–30 sp | SemiBold | Main page titles |
| Section title | 17–20 sp | SemiBold | Section hierarchy |
| Track title | 15–18 sp | Medium / SemiBold | Increase selectively on Now Playing |
| Body | 14–16 sp | Regular | Main supporting content |
| Metadata | 12–13 sp | Regular / Medium | Artist, album, duration and counts |
| Eyebrow / overline | 10–11 sp | Medium / SemiBold | Short labels only; restrained tracking |

Typography rules:
- Prioritize legibility over stylistic tracking.
- Avoid all-caps for long labels.
- Use tabular figures where time, duration or numeric values benefit from stable alignment.
- Respect system text scaling; do not hardcode heights that clip enlarged text.

### 4.3 Spacing, shape and layout

- Use a 4 dp base grid; prefer 8 dp increments.
- Standard horizontal screen padding: 20–24 dp, adjusted for compact widths.
- Keep layouts breathable; do not wrap every section in a card.
- Standard surface radius: 16–20 dp.
- Artwork radius: 20–24 dp where the composition benefits from it.
- Compact song rows should remain easy to scan and comfortably tappable.
- Minimum interactive target: 48 × 48 dp.
- Respect safe areas, gesture/navigation insets and keyboard insets.
- Use subtle tonal contrast before adding borders or shadows.

### 4.4 Iconography and imagery

- Use one consistent icon family and consistent stroke/visual weight.
- Use familiar playback symbols and provide semantic labels for icon-only controls.
- Preserve artwork aspect ratio and use a consistent crop strategy.
- Missing artwork must use a deliberate neutral placeholder.
- Do not introduce remote image dependencies; retain the existing local artwork pipeline.

## 5. Information architecture and actual MVP inventory

### 5.1 Primary navigation

Keep the existing four primary destinations:

1. **Home** — personal listening overview and shortcuts.
2. **Library** — locally indexed Songs, Albums and Artists.
3. **Playlists** — user-created collections.
4. **Equalizer** — audio effects and device-supported controls.

The Mini Player is a persistent shared element when a track is active. It sits above the bottom navigation and must not obscure content or system insets.

### 5.2 Implemented screen inventory

| Screen / surface | Current MVP role |
|---|---|
| Home | Brand header, search entry, current Now Playing context when active, shortcuts to Songs/Albums/Artists, Settings and Sleep Timer access |
| Library | Local music browsing, search, Songs/Albums/Artists entry points |
| Album Detail | Browse and play songs belonging to an album |
| Artist Detail | Browse and play songs belonging to an artist |
| Now Playing | Current track, artwork, transport controls, progress, shuffle/repeat, Equalizer and Sleep Timer access |
| Mini Player | Persistent current-track summary and quick playback controls |
| Playlists | Create and manage user playlists |
| Playlist Detail | Play collection, inspect ordered tracks and remove tracks |
| Equalizer | Device capability state, presets, frequency bands, Bass Boost and Virtualizer where supported |
| Sleep Timer | Quick/custom duration and playback stop scheduling |
| Settings | Playback speed, audio effects entry, library preferences and maintenance, About |
| Storage & Maintenance panels | Library overview/rescan, artwork cache information and cache cleanup |
| About | Product identity, developer attribution, version/build information and open-source licenses |

### 5.3 Explicit non-goals for this polish pass

The following are not part of the current implemented screen inventory and must not be presented as existing features:
- Dedicated Queue management screen.
- Recently Played / listening history screen or history-driven Home feed.
- Folder browsing.
- Streaming, online discovery, cloud library or cloud sync.

If one of these is approved as future product scope, it must be added to the roadmap separately. Do not create placeholder navigation or controls for it during Stage 9.6.

## 6. Screen-by-screen UX direction

### 6.1 Home — quiet listening dashboard

**Purpose:** help the user resume or reach a part of their local music library quickly.

Direction:
- Keep the DN Audio identity clear but compact.
- Use a restrained headline and avoid repeating the tagline in multiple places.
- Make search easy to discover.
- When a track is active, present the current listening context without duplicating the Mini Player unnecessarily.
- Keep Songs, Albums and Artists shortcuts clear and immediately scannable.
- Provide deliberate access to Settings and Sleep Timer.
- Use editorial spacing and typography rather than a stack of decorative cards.

Do not fabricate recently played, recommendations or listening statistics. The Home screen must reflect real available state and data.

### 6.2 Library — efficient local collection browsing

**Purpose:** find music stored on the device.

Direction:
- Clear title and useful library context/count where available.
- Search should be prominent and have clear focus, query and no-result states.
- Songs, Albums and Artists entry points should be visually distinct but part of one system.
- Song rows prioritize title and artist; artwork and duration are supporting information.
- Keep overflow actions discoverable without making every row visually busy.
- Preserve existing scan and permission flows.

Required states:
- Initial/permission state.
- Scanning/loading.
- Populated library.
- Empty library/no supported audio.
- No search results.
- Permission denied.
- Scan failure and retry.
- Missing artwork or metadata.

### 6.3 Album Detail and Artist Detail — collection context

**Purpose:** browse a meaningful subset of the local library and play it.

Direction:
- Strong collection title and relevant metadata.
- Artwork should establish identity without overwhelming song access.
- Provide an obvious Play All action where supported.
- Song list follows the same row language as Library.
- Keep back navigation predictable.
- Empty or incomplete metadata should degrade gracefully.

Do not add unsupported sort, filter or collection actions during visual polish.

### 6.4 Now Playing — editorial signature experience

**Purpose:** make listening feel focused, expressive and effortless.

This screen intentionally differs from the rest of the app: it is the editorial centerpiece within an otherwise immersive-minimal product.

Direction:
- Give album artwork the strongest visual presence, with balanced breathing room.
- Use Poppins with expressive but disciplined scale contrast for track title, artist and contextual labels.
- Arrange content as a considered composition, not a generic stack of cards.
- Keep progress, elapsed/total duration and seeking easy to read and operate.
- Play/Pause is the primary action; Previous and Next remain immediately accessible.
- Shuffle and Repeat are secondary controls with clearly distinguishable active states.
- Equalizer and Sleep Timer remain accessible without competing with transport controls.
- Use subtle transitions only where they reinforce the listening experience.

Behavioural constraints:
- Preserve current playback source of truth and handler/controller responsibilities.
- Preserve seek accuracy, playback state, track changes, background playback and audio focus behaviour.
- Represent buffering, loading and playback errors clearly.
- Missing artwork uses a neutral fallback.
- Do not add a Queue screen or queue-management affordance unless that feature exists and is approved.
- Do not let animation delay or intercept essential playback controls.

### 6.5 Mini Player — persistent and unobtrusive

**Purpose:** provide quick playback control and a path back to Now Playing.

Direction:
- Compact artwork, track title and artist.
- Play/Pause as the primary quick action.
- Optional progress line only if it remains accurate and visually quiet.
- Tapping the non-control area opens Now Playing.
- Controls must be independently tappable.
- Visually integrate with bottom navigation as one continuous Bottom Dock: use a shared surface tone, avoid a hard divider between Mini Player and NavigationBar, and retain clear internal hierarchy.
- Keep the Mini Player controls independently tappable and preserve safe-area/system-inset behaviour.

### 6.6 Playlists and Playlist Detail — personal collection management

**Purpose:** create and maintain collections of local tracks.

Playlists:
- Clear page title and Create action.
- Show actual playlist name and song count.
- Use real playlist artwork where available; otherwise use a consistent neutral branded fallback.
- Keep Rename and Delete discoverable in overflow actions.

Playlist Detail:
- Clear playlist identity, name and song count.
- Play All action.
- Ordered track list using shared song-row components.
- Remove-from-playlist action with clear feedback.
- Preserve playlist order and existing playback semantics.

Required states include loading, empty, populated, validation errors, duplicate name, delete confirmation and persistence/database errors. Do not alter playlist business rules during visual-only work.

### 6.7 Equalizer — clear capability-aware controls

**Purpose:** make supported audio customization understandable and reliable.

Direction:
- Clearly communicate whether effects are supported/enabled on the current device/session.
- Present presets as a compact, scannable selection.
- Frequency-band controls should be precise and easy to adjust.
- Bass Boost and Virtualizer should have clear enabled/disabled states.
- Capability refresh and retry states must be understandable.
- Use monochrome active-state styling; do not rely on a colored slider alone.

Preserve native audio effect integration, session restoration, saved preferences and device capability handling. Never imply an effect is active when unsupported.

### 6.8 Sleep Timer — simple time-based control

**Purpose:** schedule playback to stop after a chosen duration.

Direction:
- Make quick duration choices immediately understandable.
- Keep custom duration entry clear and low-friction.
- Clearly distinguish inactive, active/countdown and completed/cancelled states.
- Use concise labels and visible confirmation of the selected duration.

Preserve existing timer semantics and playback integration.

### 6.9 Settings, Storage & Maintenance, About

**Purpose:** expose preferences and maintenance without turning Settings into a dashboard.

Direction:
- Group options by user intent: Playback, Audio Experience, Library, Storage & Maintenance, About.
- Use clear section headings, concise descriptions and consistent trailing controls.
- Playback speed should show the current selected value.
- Audio effects should lead to the existing Equalizer experience.
- Library overview and rescan should communicate progress, result and failure.
- Artwork cache information and cleanup must make scope and consequences explicit.
- About should retain product name, tagline, developer attribution, dynamic version/build and open-source licenses.

Never imply that cache cleanup deletes music, playlists or listening preferences. Preserve the existing confirmation and safety messaging.

## 7. Shared component system

| Component | Direction |
|---|---|
| Primary action | High-contrast monochrome treatment, clear label and 48–52 dp target |
| Secondary action | Tonal surface or subtle outline; no competing accent |
| Icon button | Consistent icon style, semantic label and 48 dp target |
| Song row | Artwork, title, artist, optional duration/action; consistent alignment |
| Artwork tile | Square crop, consistent radius and neutral fallback |
| Search field | Visible hint, focus state and clear-query affordance |
| Bottom navigation | Four destinations, restrained selected indicator and clear labels |
| Mini Player | Compact persistent surface above navigation |
| Bottom sheet | Dark surface, clear title/actions, predictable dismissal |
| Dialog | Concise explanation and explicit primary/cancel actions |
| Empty state | Useful explanation and one relevant next action |
| Error state | Plain-language message and recovery action |
| Loading state | Calm progress indication; avoid layout jumps |

Avoid card proliferation. Prefer open sections, dividers and aligned content when they make the interface quieter and easier to scan.

## 8. Motion and interaction

- Use short, purposeful transitions, generally around 160–240 ms for simple UI changes.
- Use restrained fade/slide transitions for navigation and sheets.
- Avoid continuous decorative animation, parallax for its own sake or glowing effects.
- Provide pressed, selected, disabled, loading, success and error feedback as relevant.
- Respect system animation/reduced-motion preferences where feasible.
- Keep playback, seek and timer controls responsive regardless of visual transitions.
- Avoid layout shifts when artwork or asynchronous data loads.

## 9. Accessibility and responsive behaviour

- Maintain strong contrast for primary text and sufficient contrast for metadata.
- Never communicate state by color alone; pair it with iconography, labels or shape.
- Provide semantic labels/tooltips for icon-only controls.
- Maintain at least 48 dp touch targets.
- Support text scaling without clipping titles, buttons or controls.
- Test long song titles, long artist names, missing metadata and large playlists.
- Ensure sheets, dialogs, keyboard and system insets behave predictably.
- Verify compact-width layouts and both portrait and landscape where the existing app supports them.
- Keep focus order and screen-reader descriptions meaningful.

## 10. Flutter implementation constraints

Architecture remains Flutter + GetX with feature modules and shared theme/constants.

Implementation rules:
- Preserve GetX MVC/module boundaries.
- Reuse existing controllers, services and repositories; do not move business logic into widgets.
- Keep `DnAudioHandler` / `just_audio` as the playback foundation.
- Preserve Android MediaStore and offline artwork resolution.
- Preserve SQLite playlist persistence and existing settings/preferences storage.
- Keep native Android audio effects and MethodChannel contracts intact.
- Centralize colors, typography, spacing and shape tokens; avoid repeated hardcoded style values.
- Prefer small reusable UI components over broad architecture changes.
- Keep UI commits scoped by Stage 9.6 sub-phase.
- Do not modify playback engine, database schema, permissions, native audio lifecycle or feature semantics as part of a visual-only task unless a separately identified bug is reviewed and approved.
- Add or update widget/unit tests when a refactor changes state rendering or interaction contracts.

## 11. Final Stage 9.6 implementation blueprint

Execute in order. Each sub-phase should be audited, implemented, formatted, analyzed, tested where applicable, and locally verified before moving to the next.

### 9.6.1 — Design System Foundation
**Scope**
- Introduce final monochrome color tokens.
- Lock Poppins typography and text styles.
- Define spacing, radius, border, elevation and motion tokens.
- Migrate the shared app theme from the provisional purple accent to Premium Dark monochrome.

**Acceptance criteria**
- No legacy purple brand accent remains in shared theme/components.
- Shared tokens are the source of truth for new/refined UI.
- Text styles and component states are consistent.
- No functional behaviour changes.

### 9.6.2 — Navigation & Shared Components
**Scope**
- Refine four-item bottom navigation.
- Refine Mini Player layout and interaction affordances.
- Standardize buttons, icon buttons, song rows, artwork tiles, search fields, sheets, dialogs and empty/error/loading patterns.

**Acceptance criteria**
- Navigation and Mini Player coexist without overlap or inset issues.
- Shared components have consistent dimensions, states and semantics.
- Existing navigation and playback actions remain unchanged.

### 9.6.3 — Home & Library
**Scope**
- Refine Home hierarchy and library shortcuts.
- Refine Library browsing, search, collection entry points and all relevant states.
- Refine Album Detail and Artist Detail using shared patterns.

**Acceptance criteria**
- Real data only; no fabricated history or recommendations.
- Search, scan, permissions and playback entry points continue to work.
- Empty, loading, error and populated states are visually complete.

### 9.6.4 — Now Playing (Editorial Signature)
**Scope**
- Establish artwork-led editorial composition.
- Refine typography, metadata, progress, transport and secondary controls.
- Refine buffering, missing-artwork and error states.

**Acceptance criteria**
- Play/Pause, Previous/Next, seek, shuffle and repeat work as before.
- Equalizer and Sleep Timer entry points remain functional.
- Background playback and system playback integration are not regressed.
- No unsupported Queue UI is introduced.

### 9.6.5 — Playlist & Collection Detail
**Scope**
- Refine Playlists and Playlist Detail.
- Standardize collection artwork, metadata, actions, validation and empty/error states.

**Acceptance criteria**
- Create, rename, delete, play all and remove-track flows remain correct.
- Playlist order and persistence remain intact.
- No database or business-rule change is introduced.

### 9.6.6 — Equalizer & Sleep Timer
**Scope**
- Refine capability-aware Equalizer states, presets, bands and effect toggles.
- Refine Sleep Timer quick choices, custom duration and active/cancelled states.

**Acceptance criteria**
- Device support and unsupported states are honest and clear.
- Effect preferences and session restoration remain intact.
- Timer scheduling/cancellation semantics remain intact.

### 9.6.7 — Settings, Storage & About
**Scope**
- Refine Settings grouping and preference controls.
- Refine library rescan, artwork cache information and cleanup feedback.
- Refine About identity, version/build and license entry.

**Acceptance criteria**
- Playback speed and audio preferences persist and apply correctly.
- Rescan and cache operations retain their existing safety behaviour.
- About metadata and license navigation remain available.

### 9.6.8 — Visual QA, Accessibility & Regression
**Scope**
- Review every implemented screen in populated, empty, loading, error and disabled states as applicable.
- Check text scaling, contrast, semantics, touch targets, insets and compact layouts.
- Perform visual consistency and playback regression passes.

**Acceptance criteria**
- No clipped or overlapping content on supported device sizes.
- Icon-only controls have accessible labels.
- No feature is represented as available when unsupported.
- Playback, background audio, notification/lock-screen controls, playlists, settings, library scan, artwork cache and audio effects regressions are checked.
- Run:
  ```bash
  dart format lib test
  flutter analyze
  flutter test
  flutter run
  ```
- Record device/manual test results; do not mark QA complete based on static analysis alone.

## 12. Definition of done

Stage 9.6 is complete when:
- The Immersive Minimal system is consistently applied across all implemented MVP screens.
- Now Playing has a distinctive, polished Editorial composition.
- Poppins and monochrome tokens are used consistently.
- Every implemented feature has appropriate populated, empty, loading, disabled and error states.
- No unimplemented capability is advertised.
- Existing playback, background audio, audio effects, playlist persistence, library scan and maintenance behaviour remain intact.
- Accessibility and device regression checks are completed and recorded.

---

**Final decision:** Immersive Minimal overall · Poppins typography · Editorial Now Playing · Premium Dark monochrome palette.  
**Implementation status:** Blueprint approved. Stage 9.6.1 foundation, Stage 9.6.2 shared-component slice and Stage 9.6.3 Home & Library visual refinement have been committed. Poppins font binaries are not yet bundled; device-level typography verification remains pending.


## 13. Stage 9.6.1 implementation record

Initial foundation changes:
- Added `AppSpacing`, `AppRadius` and `AppMotion` token classes.
- Added semantic monochrome control aliases while retaining compatibility aliases for existing widgets.
- Added dedicated editorial-title and eyebrow typography styles.
- Standardized Material button, icon button, slider, progress, divider, navigation, dialog and snackbar themes.
- Kept the existing dark palette and semantic feedback colors.

Outstanding validation:
- Bundle the actual Poppins font files and declare their weights in `pubspec.yaml`. No font binaries were present in the repository when this slice was implemented.
- Run `dart format`, `flutter analyze`, `flutter test` and a device build from the developer's Flutter environment.
- Verify contrast, text scaling and component states on-device before marking 9.6.1 complete.

No playback, persistence, routing, database or native audio code was changed in this slice.


## 14. Stage 9.6.2 implementation record

Completed in this slice:
- Refined the shared empty state with a neutral monochrome icon surface, consistent spacing and constrained message width.
- Standardized the loading indicator and added a live-region semantic label.
- Standardized the shared search field using design-system spacing, radius and monochrome focus treatment.
- Standardized song list row spacing, artwork shape, text hierarchy and minimum row height.
- Aligned Mini Player spacing, artwork shape and play-state animation timing with shared design tokens.
- Preserved the four existing navigation destinations and all existing navigation/playback callbacks. The shared Material theme continues to define NavigationBar, buttons, icon buttons, sheets and dialogs.

Remaining in Stage 9.6.2:
- Review any screen-local button, icon-button, sheet and dialog variants that do not yet use shared theme styles.
- Verify Mini Player and NavigationBar together on a physical device, including system insets and compact widths.
- Run formatter, analyzer, tests and device interaction checks in the local Flutter environment.

No playback engine, queue, navigation destination, persistence, database schema or native audio behavior was changed in this slice.


## 15. Stage 9.6.3 implementation record

Completed in this slice:
- Refined Home's editorial heading hierarchy and applied shared spacing and radius tokens to the header, shortcuts and Continue Listening surface.
- Refined Library's title hierarchy, section count typography, section chips and album grid spacing.
- Changed the selected Library section chip to a solid monochrome treatment with a contrasting dark label; removed the translucent accent-tint selection treatment.
- Refined Album Detail and Artist Detail heading hierarchy, artwork radii, content spacing and album grid surfaces.
- Changed missing-artwork placeholder icon treatment to neutral secondary text while retaining album artwork in its original colors.
- Preserved existing search submission, section selection, scan/permission flow, album/artist navigation, play-all and song playback callbacks.

Validation still required locally:
- Run `dart format lib test`, `flutter analyze` and `flutter test`.
- Verify Home, Library, Album Detail and Artist Detail on device with real local music, no permission, empty library, search with no matches, long titles and narrow screen widths.
- Check that the shared Mini Player and bottom navigation remain visible without content/inset overlap.

No library scanning rules, search matching, collection grouping, playback behavior, persistence, database schema or native audio code was changed in this slice.


## 16. Stage 9.6.4 implementation record

Completed in this slice:
- Reworked Now Playing into an artwork-led editorial composition with a restrained monochrome header, prominent square artwork and centered track identity.
- Applied shared spacing, radius and typography tokens to the player surface.
- Refined the seekbar and time labels, including tabular time figures for steadier visual alignment.
- Refined the primary play/pause control and secondary transport controls while retaining clear active states for shuffle and repeat.
- Kept buffering feedback and playback errors visible in the player surface.
- Preserved the existing Sleep Timer and Equalizer entry points and their callbacks.
- Kept missing-artwork rendering delegated to the existing SongArtwork component.

Validation still required locally:
- Run `dart format lib test`, `flutter analyze` and `flutter test`.
- Verify Now Playing on a physical device with artwork present and missing, long title/artist metadata, short and long tracks, buffering, playback errors, and compact screen height.
- Manually verify play/pause, previous/next, seek, shuffle, repeat, Equalizer and Sleep Timer entry points.
- Confirm background playback and Android notification/lock-screen controls remain unaffected.

No playback controller, audio handler, queue, sleep timer logic, Equalizer logic, persistence, database schema or native audio code was changed in this slice.


## 17. Stage 9.6.5 implementation record

Completed in this slice:
- Refined the Playlists index with the shared monochrome palette, spacing and radius language.
- Replaced the tinted playlist artwork tile with a neutral elevated surface.
- Simplified collection rows and clarified the collection heading while retaining actual playlist names and song counts.
- Refined Playlist Detail identity, typography, metadata and the Play All action.
- Applied shared spacing and typography tokens to the ordered track list and duration labels.
- Preserved create, rename, duplicate-name validation, delete confirmation, refresh/retry, Play All, indexed track playback and remove-from-playlist callbacks.
- Kept playlist ordering and persistence delegated to the existing controller and repository.

Validation still required locally:
- Run `dart format lib test`, `flutter analyze` and `flutter test`.
- Verify create, rename, duplicate-name validation, delete confirmation, Play All, selecting a track, removing a track and refresh on a physical device.
- Verify empty, populated, loading and database-error states, including long playlist names and large collections.
- Confirm the Mini Player remains visible and does not overlap playlist content.

No playlist controller, repository, model, database schema, playback controller, queue semantics or persistence logic was changed in this slice.


## 18. Stage 9.6.6 implementation record

Completed in this slice:
- Migrated Equalizer screen accent treatments to monochrome control tokens and neutral selected surfaces.
- Standardized Equalizer spacing, radii and section hierarchy with shared design tokens.
- Replaced the hardcoded red error text with the semantic error token.
- Refined Sleep Timer spacing, quick-duration chips, custom duration fields, active timer surface and primary/cancel actions to match the Premium Dark design system.
- Preserved capability refresh, preset application, band-level updates, Bass Boost and Virtualizer toggles, persistence calls, timer start/cancel and countdown rendering.

Validation still required locally:
- Run `dart format lib test`, `flutter analyze` and `flutter test`.
- On a physical device verify Equalizer available/unavailable states, enabled/disabled state, preset selection, each band adjustment, Bass Boost/Virtualizer support and strength controls, capability refresh and restoration.
- Verify Sleep Timer quick presets, custom hours/minutes, zero-duration disabled state, active countdown, cancel and completed state.
- Confirm the Equalizer and Sleep Timer sheets respect keyboard/system insets and compact-height screens.

No equalizer controller, audio effects service, native Android effects manager, MethodChannel, settings repository, sleep timer controller/service, playback engine or persistence semantics were changed.


## 19. Stage 9.6.7 implementation record

Completed in this slice:
- Refined Settings page spacing and section rhythm using the shared spacing tokens.
- Standardized settings surfaces, intro panel, format panel, library overview, artwork cache panel and About panel with shared radius tokens.
- Replaced legacy redAccent styling with the semantic error token for cache and scan failures, while preserving distinct success/error feedback.
- Kept playback speed selection, Equalizer navigation, audio format switches and reset defaults actions intact.
- Preserved library rescan progress/result/error messaging and the existing permission-aware scan flow.
- Preserved artwork cache size/count reporting, refresh, confirmation dialog, cleanup operation and explicit statement that music files, playlists and preferences are not affected.
- Preserved dynamic package version/build display and Open-source licenses navigation.

Validation still required locally:
- Run `dart format lib test`, `flutter analyze` and `flutter test`.
- Verify playback speed changes apply and persist; Equalizer entry opens.
- Toggle supported formats individually and reset defaults; confirm library refresh and rollback/error feedback.
- Verify scan progress, permission-denied result, scan error and successful indexed song count.
- Verify artwork cache loading, refresh, read failure/retry, clear confirmation, cancel, success and failure states. Confirm the confirmation copy continues to make clear that only artwork cache files are removed.
- Verify About version/build and Open-source licenses on device, plus compact width and text scaling.

No settings controller, repository, preference model, library scanner, artwork service, cache deletion behavior, audio handler, playback semantics or persistence contract was changed.


## 20. Stage 9.6.8 — Visual QA & regression checklist

Cross-screen audit finding and fix:
- Additional QA finding: the default/missing-artwork fallback still appears purple in the running app, which conflicts with the approved monochrome palette. The shared fallback is rendered by `SongArtwork` in `lib/modules/library/widgets/song_artwork.dart`; inspect this component and any other collection-specific artwork fallbacks during the next visual fix. Target: neutral monochrome placeholder only (black/charcoal/grey/white), with no purple tint or gradient.
- Album and Artist collection detail shared a Play All button using a white foreground over the off-white primary control surface. Updated it to use the explicit `controlActive` / `onControlActive` pair, with neutral disabled-state colors, a 52 px minimum height and pill shape.
- Added design-system assertions for the monochrome active-control foreground/background relationship and selected-surface distinction.

Visual QA scope:
- Home: brand header, search, now-playing preview, library shortcuts, sleep timer state and bottom navigation.
- Library: Songs / Albums / Artists switching, search, refresh, loading, permission denied, scan failure, empty library and no-results states.
- Album / Artist detail: artwork, metadata, Play All contrast, album cards, song rows and playback selection.
- Playlists: collection list, create/rename/delete, detail header without oversized icon, Play All contrast, track menu and remove action.
- Player: artwork, long title/artist, seekbar, playback controls, shuffle/repeat active states, buffering and playback errors.
- Artwork fallback: verify missing/default artwork is fully monochrome across Home, Library, Album/Artist, Playlist and Mini Player; no residual purple background, gradient, tint or icon treatment.
- Equalizer: device capability unavailable/available, preset, band sliders, Bass Boost and Virtualizer states.
- Sleep Timer: quick durations, custom duration, active countdown, cancel and completion.
- Settings: playback speed, audio format toggles, reset, scan progress/errors, artwork cache clear confirmation and About.

Accessibility and responsive checks:
- Verify all IconButtons have tooltips/semantic labels and interactive controls have practical touch targets (aim for at least 48 logical px).
- Check text contrast on primary, secondary, muted, disabled and semantic feedback states.
- Check text scaling at 1.0x and 1.3x, narrow device width, long song/playlist names, landscape and keyboard/system insets.
- Ensure focus order is logical and no text or controls clip/overflow.
- Verify selected states are communicated by more than color alone where applicable.

Local automated validation required:
- `dart format lib test`
- `flutter analyze`
- `flutter test`

Manual device regression required:
- Complete the flows listed above on a real Android device, especially permission denial/regrant, rescan, playback queue/selection, playlist mutations, Equalizer unsupported capability, timer cancellation/completion and artwork-cache cleanup.
- Confirm the Mini Player remains visible and does not cover scrollable content on every main tab.
- Bottom Dock: verify Mini Player and NavigationBar read as one continuous surface without a harsh seam; verify the transition remains clear, controls stay independently tappable, and the dock respects gesture/system insets.

Limitations:
- Repository review cannot replace runtime screenshot review, TalkBack testing, device-specific audio effects testing or manual playback regression.
- Poppins is referenced by the app theme; confirm font assets are actually bundled and render on device rather than relying on fallback.
- No controller, service, native audio integration, route, model, persistence or database schema was changed in this QA slice.
