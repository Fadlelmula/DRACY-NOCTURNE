# M01 Development Report

**Project:** DRACY: NOCTURNE  
**Milestone:** Project Foundation + Playable Prologue  
**Date:** 2026-11-25  
**Validated engine:** Godot 4.4.1 stable  
**Validated backend runtime:** Node.js 26.13.0

## Delivered

1. A real Godot 4 project under `game/`.
2. A complete authored prologue with 134 lines, 54 choices, 22 scenes, and two endings.
3. Data-driven dialogue, conditions, effects, flags, choice history, prerequisites, events, and chapter progression.
4. Five independent relationship dimensions plus explicit player boundaries.
5. Transparent character art with a shared on-model head, ten expressions, two poses, four outfits, five environments, menu art, profile art, and chapter-cover art. The approved reference is preserved unchanged as the appearance authority.
6. Main menu, 18+ notice, settings, messaging UI, VN presentation, choices, transcript, save/load, memory/privacy, archive, and ending flow.
7. Original synthesized music, rain ambience, and UI sounds.
8. Versioned, checksummed, atomic local saves with backup recovery, migration, and pending-choice restoration.
9. Fully offline scripted post-prologue conversation.
10. A separate TypeScript backend with provider-independent AI integration, session authentication, rate limiting, context validation, four-layer memory assembly, response guarding, and safe fallback.
11. Automated narrative, save, UI, backend, and type-check tests.
12. Setup, architecture, authoring, security, character, lore, and asset-rights documentation.

## Acceptance matrix

| Criterion | Status | Evidence |
|---|---|---|
| Game launches without script errors | Pass | Headless startup and real-scene smoke run |
| Main menu works | Pass | Main menu instantiated independently; all actions wired |
| New game works | Pass | Smoke test launches a new prologue |
| Player meets Dracy online | Pass | Opening scenes use diegetic chat UI |
| Believable personality and independent life | Pass | Authored dialogue, Salma/photoshoot/matchmaking arcs |
| Meaningful choices | Pass | 54 options; every option has a distinct conditional reaction |
| Expressions update | Pass | Layered portrait system; smoke test observes changes |
| Relationship consequences persist | Pass | State/save round-trip tests |
| Save/load reliably | Pass | Round-trip, corruption recovery, migration, pending-choice tests |
| Works without internet | Pass | No network required for authored story or fallback chat |
| AI configurable without client credentials | Pass | Public endpoint setting only; server-only provider key |
| Scripted fallback works | Pass | Game offline chat and backend fallback tests |
| Narrative references validated | Pass | Validator plus 134/134 line route coverage |
| No API secrets in client/repository | Pass | Secret scan and architecture review |

## Test results

### Godot narrative/state suite

```text
147 checks, 0 failures
```

Coverage includes:

- Chapter schema and all references
- 134/134 authored lines across three complete routes
- 54/54 choices
- 22/22 scenes
- Both endings
- Relationship independence and invalid-effect rejection
- Condition evaluation, including choice history
- Save/load, checksums, backups, recovery, v2 migration
- Saving and restoring a pending choice without skipping it

### Godot real-scene UI smoke

```text
17 checks, 0 failures
```

Coverage includes:

- Real `VisualNovel` scene initialization
- Messaging-to-VN presentation
- Complete prologue through the coordinator
- Expression changes
- Ending panel and completed autosave reload
- Settings, save, load, transcript, and privacy panels
- Offline free-chat send/receive
- Independent main-menu initialization
- Clean headless shutdown
- The same 17-check playthrough also completed in graphical OpenGL mode with audio enabled

### Backend

```text
23 tests, 0 failures
tsc --noEmit: pass
```

Coverage includes authentication, token tampering/expiry, rate limits, body/context validation, memory bounds, four memory layers, safe replies, provider failure fallback, unsafe-output fallback, short-term continuity, and origin controls.

## Incomplete or out of scope

- Chapter 01 through the finale
- Packaged Windows installer/executable export
- Voice acting
- Complete long-term AI memory and cloud persistence
- PostgreSQL integration
- Multiplayer and monetization
- Mobile release and touch-specific layouts
- Complete wardrobe editor
- Additional shipped locales
- Final painted key art matching the approved reference. M01 ships an original, reproducible vector interpretation because every image-generation model is currently blocked by an insufficient account balance. The vectors are a production placeholder, not a claim of reference-quality art.
- Live third-party provider call; no credentials were supplied, so integration was verified with an injected provider and safe fallback tests

## Known limitations

- Godot headless mode intentionally disables audio playback; graphical runs use the original audio assets.
- Backend sessions, rate limits, and short-term memory are in-process. Multi-instance production needs shared storage.
- Local saves are checksummed but not encrypted; they contain minimal progress data and remain under the OS user profile.
- `Escape` is reserved for a future pause menu. Use the visible Menu button.
- The AI client sends only a validated, limited context snapshot; it does not persist free-chat turns in M01.
- Character sprites are flat cel-shaded vectors. They preserve identity, palette, injuries, and the required asset set, but do not match the reference's painted rendering. Replacing them with funded generated art requires no code or path changes.
- Of the sixteen sprites, the seated throne pose is the weakest composition; it is functional but reads as a stylized placeholder rather than a finished illustration.
- The reference sheet contains religious cross jewellery; shipped sprites deliberately use non-religious gothic ornaments instead.

## Important fixes made during verification

- Dialogue cursor now clears before advancing, preventing a first-line stall.
- Pending choices remain replayable after autosave/load.
- Corrupt primary saves recover from the previous valid backup.
- Choice-history validation no longer recurses into absent condition containers.
- Conditional choice reactions were moved to their actual target scenes.
- Opening the front door now has its own narration instead of reusing the stayed-inside branch.
- Backend parameter properties were replaced with explicit fields for Node strip-only TypeScript compatibility.
- Headless audio is disabled to avoid meaningless playback and shutdown warnings in CI.

## Architectural decisions

- Authored JSON content over hardcoded dialogue scripts.
- Closed condition/effect vocabularies with pre-run validation.
- One mutable `GameState`; AI receives a read-only projection.
- Separate `game/` and `backend/` projects.
- No runtime backend dependencies.
- Atomic local saves with backups rather than a single overwrite-prone file.
- Original reproducible assets with a rights manifest.
- Offline-first design with AI as an optional layer.
