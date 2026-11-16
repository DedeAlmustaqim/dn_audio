# DN Audio Pro — Product & Monetization Plan

**Product:** DN Audio  
**Brand:** Digital Native Dev  
**Platform:** Android · Flutter · GetX  
**Document status:** Planning proposal  
**Implementation status:** Not started  
**Release dependency:** DN Audio 1.0.0 should be released and its initial user feedback reviewed before Pro implementation begins.

> Your Music. Your Experience.

This document records the proposed Free/Pro product boundary, candidate paid features, monetization approach, and a phased implementation direction. It is a planning baseline, not a promise that every candidate feature will ship.

---

## 1. Product principles

1. DN Audio remains a genuinely useful offline music player in the Free edition.
2. Core playback must not be paywalled: users should be able to browse and play local music without purchasing Pro.
3. Pro should add meaningful depth, customization, and convenience rather than artificially degrading Free.
4. Do not introduce disruptive advertising as a substitute for a clear Pro value proposition.
5. Do not market cloud, streaming, or synchronization capabilities unless they are actually implemented and supported.
6. Audio effects must respect Android device and audio-session capabilities. Never present an unsupported effect as active.
7. Keep the product offline-first. Any feature that requires a server must have a clear product and operating-cost justification.

## 2. Proposed Free edition

The following capabilities should remain available without payment. This list reflects the product's core direction; exact scope must continue to match implemented and verified behavior.

### Music library and playback
- Scan and browse music stored on the device.
- Browse Songs, Albums, and Artists.
- Search local tracks by title, artist, and album.
- Play, pause, seek, previous, and next.
- Shuffle and repeat.
- Background playback, media notification, and lock-screen controls.
- Mini-player and Now Playing screen.

### Playlists
- Create, rename, and delete playlists.
- Add and remove tracks.
- Play tracks and playlists.

### Audio and convenience
- Current basic equalizer experience, including the available standard presets and frequency controls, subject to device support.
- Basic sleep timer.
- Essential playback and library settings.

**Free edition promise:** a user can install DN Audio and enjoy a complete, practical offline music-player experience without paying.

## 3. Proposed DN Audio Pro features

These are candidates for the paid edition. They should be prioritized by user value, technical feasibility, and actual demand.

### 3.1 Advanced Equalizer

**Priority:** P1 — first Pro feature candidate

Potential scope:
- Expanded equalizer, such as a 10-band configuration, if supported by the chosen native audio-effects implementation.
- User-created custom presets.
- Save, rename, and delete custom presets.
- More detailed control over supported audio effects.

Notes:
- Validate the available Android effect APIs and device compatibility before promising a fixed band count or universal behavior.
- Keep the current basic equalizer useful in Free.
- Avoid claiming sound-quality improvements that cannot be consistently guaranteed across devices and headphones.

### 3.2 Premium Personalization

**Priority:** P1

Potential scope:
- Additional premium themes or visual styles.
- More accent-color choices.
- Additional Now Playing presentation options.
- Further interface personalization that preserves DN Audio's monochrome editorial identity.

Notes:
- The existing core interface and default dark experience remain available in Free.
- Premium visuals must not compromise readability, accessibility, or interaction consistency.

### 3.3 Advanced Sleep Timer

**Priority:** P1

Potential scope:
- More flexible timer configuration.
- Fade-out before playback stops, if technically reliable.
- Additional timer behavior or presets.

Notes:
- Keep a useful basic sleep timer in Free.
- Test timer behavior while the app is backgrounded, the screen is locked, and audio focus changes.

### 3.4 Advanced Playlist Management

**Priority:** P2

Potential scope:
- More flexible sorting and organization.
- Smart or rule-based playlists, if a clear local-only implementation is feasible.
- Additional playlist-management conveniences.

Notes:
- Do not impose arbitrary playlist limits in Free merely to create a Pro upsell.
- Confirm the user problem and implementation cost before deciding which playlist capabilities are Pro-only.

## 4. Future candidates — not part of the initial Pro commitment

These ideas may be evaluated after the first Pro release. They are not promised features.

| Candidate | Product value / consideration |
|---|---|
| Crossfade | Smooth transitions between tracks; requires playback-engine investigation and careful testing. |
| Gapless playback | Useful for continuous albums; validate source files and playback-engine behavior. |
| Additional audio effects | Depends on Android device support and audio-session behavior. |
| Android Auto | Potentially valuable, but requires a separate integration and compatibility/testing effort. |
| Playlist backup and restore | Prefer an export/import or local-file approach first; avoid assuming cloud infrastructure. |
| Audio visualization | Spectrum or waveform presentation; assess performance and battery impact. |

These features should only be promoted after implementation, verification, and release.

## 5. Proposed monetization model

### Recommended direction: one-time Pro unlock

A one-time purchase is the preferred model to evaluate for DN Audio because the product is an offline-first local music player and its core value does not depend on a continuously operated cloud service.

**Decision status: proposed, not yet locked.**

Questions to settle before implementation:
- Whether Pro is a lifetime entitlement.
- Whether a purchase unlocks all Pro features available at the time of purchase.
- Whether future Pro features are included in that purchase or may be sold separately.
- How purchase restoration and entitlement recovery will work after reinstalling or changing devices.
- How refunds, billing errors, and pending purchases are handled.

Do not describe the purchase as lifetime or promise all future features until this policy is explicitly approved.

### Exploratory price range

The following figures are hypotheses for market testing, not final prices:

| Pricing idea | Exploratory price |
|---|---:|
| Early-adopter offer | Rp19.000 |
| Initial standard price | Rp29.000 |
| Possible later price as value grows | Rp39.000–49.000 |

Before setting a final price, review comparable Android music-player apps, local purchasing behavior, Play Billing fees/tax implications, and early user feedback.

## 6. Purchase and entitlement requirements

When Pro implementation is approved, the technical design should cover:

- Google Play Billing integration for a one-time in-app product, if the one-time model is confirmed.
- Clear Free and Pro entitlement states.
- Purchase pending, successful, cancelled, failed, and refunded/revoked states.
- Restore/re-query purchases for the signed-in Google Play account.
- Safe handling of reinstall and app-data clearing.
- A Pro screen that explains benefits and price transparently.
- No false-positive Pro unlock when billing cannot verify the entitlement.
- Tests for billing state transitions and entitlement persistence.
- Localization in English and Bahasa Indonesia.

The exact product ID, billing architecture, and verification strategy must be decided during technical design. Do not store billing secrets in the client or repository.

## 7. Proposed phased roadmap

This work is intentionally sequenced after the 1.0.0 release.

### Phase A — Post-1.0.0 learning
- Release DN Audio 1.0.0.
- Review early ratings, reviews, support messages, and user feedback.
- Identify the most requested improvements.
- Reassess the proposed Free/Pro boundary.

### Phase B — Pro foundation
- Confirm one-time purchase policy and price.
- Define Pro product identity and store presentation.
- Design entitlement and Google Play Billing architecture.
- Implement purchase, restore, and failure states.
- Add localization and automated tests.

### Phase C — First paid value
- Implement Advanced Equalizer capabilities that are technically verified.
- Implement custom preset management.
- Test on representative Android devices.
- Release only after billing and feature regression pass.

### Phase D — Pro experience expansion
- Add approved personalization features.
- Add advanced sleep-timer capabilities.
- Evaluate playlist enhancements based on user demand.

### Phase E — Long-term candidates
- Reassess crossfade, gapless playback, visualization, Android Auto, and backup/restore.
- Prioritize based on actual demand, feasibility, battery/performance impact, and maintenance cost.

## 8. Product acceptance principles

Before a capability is labelled Pro and sold:

1. Its Free/Pro boundary is documented and understandable.
2. The feature is implemented, not merely represented in the UI.
3. It works on supported devices and degrades honestly on unsupported devices.
4. Purchase and restore flows are tested.
5. Free users retain a dependable core offline-player experience.
6. Store descriptions and screenshots accurately represent the released product.
7. No future capability is advertised as available before it ships.

## 9. Current decisions and open questions

| Topic | Current position |
|---|---|
| Free edition | Keep core offline playback and essential player functions free. |
| Pro value | Advanced audio control, personalization, and convenience. |
| First feature candidate | Advanced Equalizer and custom presets. |
| Purchase model | One-time unlock recommended; owner approval pending. |
| Pricing | Rp19.000–49.000 exploratory range; final price pending. |
| Initial release timing | After DN Audio 1.0.0 release and initial feedback. |
| Implementation | Not started. |

## 10. Scope control

This plan is a product proposal, not authorization to start implementation immediately. DN Audio 1.0.0 release preparation remains the immediate priority. Revisit this document after release and update it when decisions are explicitly approved.

---

**Related documents**
- [Development Roadmap](../ROADMAP.md)
- [Design Direction](DESIGN_DIRECTION.md)
- [Release Checklist](RELEASE_CHECKLIST.md)
