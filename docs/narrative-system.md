# Narrative authoring system

## Files

- `game/content/narrative_catalog.json` — approved characters, expressions, backgrounds, music, flags, and memory IDs
- `game/content/chapters/prologue.json` — authored chapter
- `game/content/dialogue/offline_chat.json` — non-canonical offline conversation
- `game/localization/en.json` — UI strings and optional narrative overrides

## Scene shape

```json
{
  "id": "scene_id",
  "title": "Displayed chapter beat",
  "mode": "chat",
  "background": "bedroom",
  "music": "prologue_theme",
  "prerequisites": [],
  "on_enter": [],
  "steps": [],
  "next_scene": "next_scene_id",
  "ending": ""
}
```

A scene has either `next_scene` or `ending`, not both. `mode` is `chat`, `vn`, or `narration`.

## Steps

### Line

```json
{
  "type": "line",
  "id": "unique_line_id",
  "speaker": "dracy",
  "expression": "mischievous",
  "text": "Dialogue text.",
  "conditions": [],
  "delay": 1.2
}
```

Speakers are `narrator`, `player`, or a catalog character. `delay` is used for messaging typing pauses and must be 0–10 seconds.

### Choice

```json
{
  "type": "choice",
  "id": "unique_choice_id",
  "prompt": "What do you say?",
  "conditions": [],
  "options": [
    {
      "id": "unique_option_id",
      "text": "Player reply.",
      "conditions": [],
      "effects": [],
      "target": "target_scene_id"
    }
  ],
  "fallback": "optional_scene_if_no_option_is_available"
}
```

Selecting an option records its ID in `GameState.decisions`, applies authored effects, and jumps to its target. The target scene can begin with conditional reactions such as:

```json
{
  "type": "line",
  "id": "reaction_to_option",
  "speaker": "dracy",
  "expression": "smiling",
  "text": "A distinct reaction.",
  "conditions": [
    {"type": "choice_made", "key": "unique_option_id", "op": "eq", "value": true}
  ]
}
```

### Effect step

```json
{
  "type": "effect",
  "id": "unique_step_id",
  "effect": {"type": "set_flag", "key": "met_dracy", "value": true},
  "conditions": []
}
```

### Jump, event, and end

- `jump`: conditional scene transition with a validated `target`
- `event`: references a chapter-level event by `event_id`
- `end`: finishes a scene; the scene's `ending` completes the chapter

## Conditions

All conditions in an array must pass.

| Type | Key | Operators |
|---|---|---|
| `flag` | Catalog flag | `eq`, `neq` |
| `relationship` | One of the five dimensions | `eq`, `neq`, `gt`, `gte`, `lt`, `lte` |
| `boundary` | Approved boundary | `set`, `unset` |
| `scene_visited` | Scene ID | `eq`, `neq` |
| `choice_made` | Option ID | `eq`, `neq` |
| `not` | `condition` | — |
| `all` / `any` | `conditions` | — |

Relationship thresholds must be 0–10. Choice references are validated against every option in the chapter.

## Effects

| Type | Fields |
|---|---|
| `set_flag` | `key`, boolean `value` |
| `relationship` | `key`, `delta` (±1..3), authored `reason` |
| `add_boundary` / `remove_boundary` | approved boundary `key` |
| `memory` | catalog `id`, authored `text` (1–280 characters) |

Relationship changes are clamped to 0–10 and logged with their source and reason. AI has no API for applying effects.

## Validation rules

The validator rejects:

- Duplicate or malformed scene, step, line, choice, option, or event IDs
- Unknown speakers, expressions, backgrounds, music, flags, memories, or boundaries
- Broken scene targets or endings
- Unknown condition/effect types and invalid operators or ranges
- Empty dialogue, choices, or scenes
- A scene with both `next_scene` and `ending`
- Unreachable scenes
- Unknown `choice_made` references
- Self-jumps that can trap the player

Run the validator after every content change:

```bash
godot --headless --path game --script res://tests/run_tests.gd
```

The route tests assert that all 134 current lines, 54 options, 22 scenes, and both endings are reachable.

## Localization

Add `game/localization/<locale>.json`. Missing keys fall back to authored JSON text.

- UI keys use names such as `menu.new_game`
- Line overrides use `line.<line_id>`
- Choice overrides use `choice.<option_id>`
- `{player_name}` is substituted at presentation time

Set `language/locale` in Godot's settings file or extend the settings UI when adding a shipped locale. Narrative conditions and effects must never be translated.

## Content guardrails

- Do not resolve Dracy's species or origin.
- Do not invent a permanent Mobile Legends rank, main hero, or playstyle.
- Do not make Dracy constantly available or erase her independent life.
- Do not convert trust into attraction or affection into a dominance reward.
- Do not add exponential branch pairs for every line; prefer flags, optional scenes, conditional reactions, and a few substantial branches.
- Do not use AI to write canonical events or mutate state.
