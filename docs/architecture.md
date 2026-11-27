# Architecture

## Goals

- Authored narrative is the source of truth.
- The game is fully playable offline.
- AI is optional, isolated, and unable to mutate canonical state.
- Saves survive content updates and recover from corruption.
- Systems remain small enough to test and extend chapter by chapter.

## Runtime ownership

| System | Owns | Must not own |
|---|---|---|
| `GameState` | Player progress, flags, relationships, boundaries, memories, choice history | Rendering, provider calls |
| `NarrativeEngine` | Execution of validated authored steps and effects | AI output, direct file saves |
| `VisualNovel` | Scene coordination, input, presentation, autosave calls | Narrative rules |
| `SaveManager` | Versioned local files, checksums, atomic writes, backups, migration | Story logic |
| `SettingsManager` | Device preferences and public backend URL | Secrets, story state |
| `AiClient` | Requests to the project backend and client-side reply checks | Canonical state changes |
| Backend | Provider calls, context assembly, validation, short-term memory, rate limits | Chapter unlocking or relationship mutation |

## Game flow

1. `MainMenu` starts a new game or loads the latest valid slot.
2. `VisualNovel` loads the chapter and catalog, then asks `NarrativeValidator` to validate all references.
3. `NarrativeEngine` executes line, choice, effect, jump, event, and end steps.
4. UI components render the current scene mode: `chat`, `vn`, or `narration`.
5. Every progress signal writes an autosave. Manual slots use the same envelope.
6. At chapter completion, the ending panel offers optional non-canonical conversation or a return to the menu.

## Narrative data

A chapter is a JSON object with:

- `schema_version`, `id`, `title`, `start_scene`, `endings`
- `scenes`: unique IDs, presentation mode, background, music, prerequisites, enter effects, steps, exit
- `events`: condition-driven one-time authored effects
- Steps: `line`, `choice`, `effect`, `jump`, `event`, `end`

Conditions and effects are closed vocabularies. Unknown keys, operators, references, expressions, or effect types fail validation. This prevents a typo from becoming a soft-locked player save.

`choice_made` conditions use the saved decision history rather than proliferating one-off boolean flags. Every choice in the prologue has a distinct conditional reaction in its target scene.

## Relationship model

Trust, attraction, dominance dynamic, curiosity, and suspicion are independent integers from 0 to 10. Only validated authored effects can change them, and every change records an authored reason and source ID.

Boundaries are a separate collection. Setting `friendly_only` or `no_pressure` changes later authored conditions and AI guidance. Dominance is never granted as a reward for affection.

## Save format

Each save is an envelope:

```json
{
  "envelope_version": 1,
  "payload": { "save_version": 3, "...": "player progress" },
  "checksum": "sha256-of-canonical-json"
}
```

- Writes go to a temporary file, then atomically replace the target.
- The previous valid save is rotated to `.bak`.
- Load verifies the checksum before accepting data.
- A corrupt primary file automatically attempts backup recovery and repairs the primary slot.
- Unknown or future save versions are rejected rather than silently misinterpreted.
- v1 and v2 migrations preserve progress while upgrading relationships and boundaries.
- Pending choices remain replayable after save/load.

Save files live under Godot's `user://saves/` directory. Tests redirect this to isolated directories.

## AI boundary

The game client has no provider SDK, API key, or provider URL setting. It can enable conversation and configure a public backend URL.

The backend:

1. Issues a signed, short-lived pseudonymous session.
2. Enforces per-session and per-IP token buckets.
3. Validates body size, message length, character, chapter, flags, relationship ranges, boundaries, and memory provenance.
4. Assembles four memory layers.
5. Calls a provider-independent adapter.
6. Validates the response for length, markup/URLs, meta prompts, premature species reveals, restricted future lore, and state-mutation language.
7. Falls back to authored scripted dialogue on provider or validation failure.

The client performs a second defensive reply check. Even a valid AI reply is rendered as conversation only; it is never passed to `GameState.apply_effect`.

## Memory layers

1. **Short-term:** bounded server-side turns with TTL; not persisted in M01.
2. **Episodic:** authored memories supplied by the validated game state.
3. **Relationship:** read-only relationship snapshot and boundaries.
4. **World:** approved canon plus unlocked story facts.

M01 does not claim a complete long-term memory product. PostgreSQL persistence, memory ranking, user-facing AI-history controls, and cross-device sync are future work.

## Performance and future mobile compatibility

- UI uses anchors, containers, and a 1280×720 expandable canvas rather than fixed pixel dialogs.
- Character art is layered once per expression rather than duplicated full-body images.
- SVG assets are imported once; audio loops are streamed by Godot.
- Narrative data is loaded per chapter, not as one giant script.
- AI requests are opt-in and never block authored progression.
- Touch-specific layouts, safe-area handling, and mobile export are intentionally out of scope.

## Deliberate constraints

- No runtime game dependencies beyond Godot.
- No runtime backend dependencies; Node's built-in HTTP, crypto, and test runner are used.
- No database in M01.
- No client-side secrets.
- No AI-generated canonical events.
