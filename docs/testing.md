# Testing and verification

## Godot narrative/state tests

```bash
godot --headless --path game --script res://tests/run_tests.gd
```

Expected: `147 checks, 0 failures`.

The suite is dependency-light and runs without GUT. It covers validation, graph structure, complete authored routes, relationships, conditions, save round-trips, corruption recovery, migrations, and pending choices.

## Godot UI smoke playthrough

```bash
godot --headless --path game res://tests/smoke_playthrough.tscn
```

Expected: `UI smoke: 17 checks, 0 failures`.

This is a normal Godot scene rather than a `--script` MainLoop so autoloads and real UI scripts are present. It uses an isolated save directory and restores settings afterward. The same smoke playthrough was also completed in graphical OpenGL mode with audio enabled.

## Graphical startup/audio checks

```bash
godot --path game res://tests/windowed_startup.tscn
godot --path game res://tests/windowed_audio.tscn
```

These open a real window, initialize the main menu or audio playback, and exit through the game's graceful quit path.

## Backend tests

```bash
cd backend
npm test
npm run typecheck
```

Expected: `23 tests, 0 failures` and a clean type-check.

## Import/startup check

```bash
godot --headless --path game --editor --quit --import
godot --headless --path game --quit-after 120
```

## Manual checks still recommended

- Play a full route in a graphical window at 1280×720 and at another window size.
- Confirm audio mix on real speakers/headphones.
- Test controller support and future touch layouts.
- Test a live AI provider with appropriate cost limits and moderation.
- Export a Windows build and verify installation/update behavior.
