# Development Log

## 2026-11-25 — M01

### 1. Repository audit

- Inspected `C:\Dracy`: empty directory, no existing implementation to preserve.
- Confirmed Node.js 26.13.0 and Git 2.55.0.
- Godot was not on `PATH`; downloaded portable Godot 4.4.1 stable into the approved temporary directory for validation.
- Reported findings and staged implementation plan before creating project architecture.

### 2. Foundation

- Created separate Godot game and TypeScript backend projects.
- Implemented `GameState`, independent relationship dimensions, boundaries, memories, decision history, and validated authored effects.
- Implemented atomic checksummed saves, backups, recovery, version rejection, and v1/v2 migrations.
- Added settings, localization loader, audio manager, and reproducible asset tools.

### 3. Narrative engine

- Implemented data-driven line/choice/effect/jump/event/end execution.
- Added closed-vocabulary condition and effect validation.
- Added scene prerequisites, event triggers, choice-history conditions, and chapter endings.
- Authored the complete prologue and offline conversation fallbacks.
- Added three complete test routes covering every line, choice, scene, and ending.

### 4. Presentation and art

- Built main menu, 18+ confirmation, messaging interface, VN dialogue, choice list, transcript, save/load, settings, privacy, archive, ending, and free-chat panels.
- Generated original vector character art, ten expressions, two poses, four outfits, profile, five environments, menu art, cover, icon, and vignette.
- Downloaded Cormorant Garamond and Inter with OFL licenses.
- Synthesized original music, rain, and UI sounds.
- Rasterized representative art for visual review.

### 5. Optional AI backend

- Implemented provider-independent OpenAI-compatible adapter with no runtime SDK.
- Added signed pseudonymous sessions, token buckets, request limits, CORS, security headers, and timeouts.
- Added strict context validation and four-layer memory assembly.
- Added approved Dracy canon and response guard against species reveals, future lore, meta prompts, URLs, and state mutation.
- Added safe scripted fallback for provider errors and rejected replies.
- Added 23 backend tests and TypeScript type-checking.

### 6. Verification and fixes

- Fixed save checksum normalization across JSON integer/float parsing.
- Fixed pending-choice save/load cursor behavior.
- Fixed dialogue advancement so the current line clears before processing the next step.
- Fixed recursive choice-reference validation.
- Added distinct authored reactions for all 54 choices.
- Corrected the front-door branch narration.
- Added graceful audio shutdown and disabled audio in headless mode.
- Ran narrative/state tests: **147 checks, 0 failures**.
- Ran real-scene UI smoke: **17 checks, 0 failures** in headless and graphical OpenGL modes.
- Verified graphical main-menu startup and music/SFX playback with clean graceful shutdown.
- Ran backend tests: **23 tests, 0 failures**.
- Ran backend type-check: **pass**.

### 7. Documentation

- Added root setup README.
- Added architecture, narrative authoring, and AI backend documentation.
- Added Dracy character bible and Nocturne lore baseline.
- Added asset rights manifest and M01 development report.

### 8. Approved visual reference and art pass

- Preserved the user-supplied reference unchanged in `game/assets/characters/dracy/references/` and recorded its SHA-256.
- Added `design/character-bible/dracy-visual-spec.md` covering appearance, palette, injury rules, asset layout, and the non-crop policy.
- Rewrote the character generator for shared head anatomy, ten expression overlays, two poses, and four outfits.
- Confirmed all four configured image models are blocked by an insufficient account balance; the approved free Grok model fails the same way.
- Shipped the vector interpretation as the only available production fallback and documented that it is not reference-quality.
- Rebuilt Godot SVG imports and re-rendered review images.
- Re-ran verification after the art and content changes: narrative/state **147 checks, 0 failures**; UI smoke **17 checks, 0 failures**; backend **23 tests, 0 failures**; `tsc --noEmit` **pass**.
- Fixed a cold-cache startup parse failure by explicitly preloading `Localizer` in `settings_manager.gd`.

### 9. Anatomy and readability pass on the vector art

- Corrected head placement and neck width so the full-body sprites no longer show an over-long neck or a squared-off neck join.
- Reworked the mouth position, eye size, iris scale, nose line, and skin palette for a cooler, less doll-like portrait.
- Replaced the mitten hands with a thumb-and-finger hand shape and closed the gaps between sleeves and hands in the casual outfit.
- Closed the bare band between the casual and alternative skirts and their legwear, and darkened the seated pose's chair so it recedes.
- Extended `render_previews.gd` to rasterize all ten expressions into `user://art_review/expressions/` for review.
- The result is coherent and on-model but still flat cel-style vector art; it remains a documented placeholder for the approved painted reference.
- Re-tested image generation through the newer `generate_image` tool (`opencode/gemini-nano-banana-2.1`): it is blocked by the same insufficient-balance error, so no generated sprite exists.
- Rebuilt the eyes as clipped almonds with a crimson iris, heavy winged liner, layered lashes, and smoky socket shading; softened the jaw, widened the lips, and replaced the straight eyebrow bars with finer arches.

## Remaining after M01

- Author and implement Chapter 01.
- Expand art toward final painted key art while preserving the approved master.
- Add packaged desktop export and installer pipeline.
- Add additional locales and locale-completeness tests.
- Design persistent long-term memory and privacy controls before enabling cloud saves.
- Perform a live provider integration test when credentials are available.
- Conduct interactive desktop playtesting for pacing, readability, and audio mix.
