# Zone Transition Presentation Prototype 01

**Status:** isolated presentation prototype; not production integration  
**Date:** 2026-10-25  
**Spend:** $0

## Scope

This prototype demonstrates a smooth camera framing handoff alongside the project's existing provisional environment palette crossfade. It lives in `tests/presentation/zone_transition_prototype_01/` and is not referenced by the main game scene. It does not edit combat, characters, project settings, or canonical location content.

Open `res://tests/presentation/zone_transition_prototype_01/zone_transition_prototype.tscn` in Godot and run the scene. An abstract marker traverses a test lane; Space is described by the overlay as a trigger, while this minimal harness currently triggers automatically after the marker reaches its threshold. The camera priority then moves from framing A to B using Phantom Camera's tween resource, while the environment director crossfades its existing palette modules.

## How the handoff is structured

- Two Phantom Camera 2D nodes follow the same abstract target with different framing offsets. Raising the second camera's priority asks the plugin to blend to its framing over 1.25 seconds.
- The existing `EnvironmentDirector` is instantiated beneath a screen-space CanvasLayer. Its own palette transition runs independently of the world camera and uses the existing procedural Undercity backdrops.
- A `Parallax2D` skyline provides a slower-moving depth layer. Continuous lane markings and a shared horizon keep the test composition visually coherent across the palette change.
- The isolated harness does not instantiate or query `CombatDirector`. It directly asks the presentation-only environment director to select the second test palette. The `apply_wave(13)` argument is only the existing QA fixture selector; it does not advance or mutate combat state.
- A production caller can coordinate environment-module replacement and camera handoff from a presentation transition request/event. The modules can load/fade in their own layer while combat continues to own its state and timing. This prototype does not define that production event API.

## Provisional fixture boundary

The existing data labels `undercity_proto_01` and `undercity_proto_02` as prototype-only palette modules. Their wave 1-to-13 split is a reversible test boundary, not approved pacing, a canonical zone split, or final environment content. No new zone names or combat rules are introduced.

## Validation

Focused check run with Godot 4.7.2:

```powershell
& 'C:\Users\Work\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/presentation/zone_transition_prototype_01/test_zone_transition_prototype.gd
```

Result: `PASS: isolated Phantom Camera priority handoff and existing environment-module crossfade completed.` Godot also reported that it could not open `user://logs/godot.log` for writing; this did not prevent the focused check from passing. No full project suite was run.

## Limitations and risks

- The check is headless and validates camera priority selection, provisional module selection, and transition completion. It does not verify the rendered look, motion smoothness by eye, frame pacing, or platform performance.
- The test's marker and lane are abstract placeholders. They are not character art, gameplay units, or final environment assets.
- The transition currently starts from a test threshold (or explicit test method call); input text is illustrative and does not implement a manual Space-key handler.
- The environment director API selects palettes by wave number. Production integration should use an explicit presentation transition request or stable zone identifier so a test fixture's wave boundary does not become a gameplay dependency.
- When run outside the editor, the isolated harness supplies the Phantom Camera manager node if the plugin autoload is absent. Normal editor/plugin execution should use the installed plugin's own manager setup.
- Local Notion and Google Drive staging copies are refreshed; no remote write or upload was performed or verified. Reconcile this prototype note with the live project sources when connector access is available.
