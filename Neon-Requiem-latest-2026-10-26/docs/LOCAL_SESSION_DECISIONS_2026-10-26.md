# Local session decisions — 2026-10-26

## Owner-selected follow-ups — 2026-10-26 America/Chicago

- **I-03:** allow neighbor overlap only when recruit silhouettes remain legible, UI remains unobscured, and collision/pathing remains usable. Passing behavior, “no threat” semantics, air-lane geometry, and visible ECHO device/decoy mapping stay open. No layout-test scaffold, runtime change, or test work is authorized.
- **I-06:** keep functional level purchase/stat growth BREAKER-only until individualized combat/economy evidence supports expansion; retain all-twelve recruitment and evolution records. Final stats, costs, curves, and cap remain open.
- **I-09:** keep wave 126 as the design-approved endless start and the current runtime/save ceiling at 125 until a complete endless profile and compatible save policy exist. Defer scaling, generator/pool/composition, boss cadence, endless rewards/milestones, and above-125 offline reward inputs. Preserve credit-only rewards, saved holding wave, claim-save, no wave advance, and the eight-hour claim target; do not extrapolate Undercity placeholders.
- **Evolution concept direction:** BULWARK progresses through medic-specific armor, medical-pack, and diagnostic-bracer changes while preserving connected hose logic and the approved helmet-cross treatment. Concept direction only; no healing effect or production/rig approval.
- **Remaining evolution direction:** future character boards add character-specific cybernetic interfaces that visibly enhance established signature accessories/gear rather than generic cybernetic plating. SPECTER's approved concept direction ties interfaces to its established cloak and evolves one recognizable signature sword visually by grade. This approves no stealth, ability, or blade mechanic. Preserve source-backed identity/count; generated boards remain quarantined. Gameplay function or balance changes remain proposals pending owner approval.
- **Generated-board inventory:** CIPHER eye integration, SPARK drone upgrades, and BULWARK medic progression are owner-approved concepts; two SPECTER sword boards are generated proposals without a project-side approval record. Exact file paths, dimensions, hashes, and status are recorded in `docs/ASSET_MANIFEST.md`. All five remain outside the project tree, unintegrated, and quarantined.
- Current SaveService writes schema version 2 and migrates known version-1 saves. No remote reconciliation occurred; canonical reconciliation remains queued.
- **Evolution form labels:** preserve official Origin Form → Adapted Form → Signature Form → Requiem Form display names. Street/Combat/Military/Apex labels on older boards map to the four art stages in that order only; they are shorthand, not alternate official names.
- **Netrunner art direction:** digital transformation is visual-only and limited to CIPHER, ECHO, and GLITCH, expressed distinctly. CIPHER retains precision-optic/data geometry and HUD-to-integrated-eye direction; ECHO retains ascended digital-energy Requiem form and visual-only levitation, with sensory devices distinct from Signal Cascade decoys; GLITCH retains approved glitch-signal language. No mechanics, targeting, stealth, flight, or spatial behavior are approved. The revised CIPHER four-form board is approved for visual direction only; it remains quarantined outside the project. No production, rig, gameplay, mechanics, runtime, or integration approval is implied; see the review packet.

## D-04 twelve signature-ability contracts — owner-delegated playtest defaults

Under the owner's standing authorization to select supported recommendations, the D-04 rules in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` are selected for provisional playtest implementation across all twelve recruits. These are owner-delegated trial defaults, explicitly non-canon and not final balance or production approval. Shared rules: action-boundary checks, automatic targeting/activation, no separate resource, remain ready without cost/cooldown when no legal target exists, cooldown begins at committed effect, and authoritative simulation resolves before presentation. CIPHER's ordinary-precision-shot fallback consumes Ghost Round and is the explicit no-target exception. Temporary effects/cooldowns clear at encounter end; invalid pre-commit actions cancel without cost, and committed actions resolve atomically. ECHO's abstract decoy behavior is selected for simulation only; device identity/count/mapping and authored air-lane presentation remain unresolved pending Character/source evidence. No runtime, art, or test changes are implied; canonical Notion/Drive reconciliation remains queued.

## I-03c spatial follow-up — manager-selected provisional direction — local only

Under the user's prior authorization to select supported recommendations, the manager selected: temporary passing only when required for authored-obstacle routing or the approved attack-range override, without changing founding-roster order as the preferred destination order; regroup only when no living enemy targets the recruit and no already-committed enemy attack/effect against them remains unresolved; and permission for a disposable geometry-only harness limited to representative positions, bands, authored obstacles, and the shared fixed boundary. The harness must remain isolated from production scenes and combat simulation and must not evaluate targeting, attacks, threat, balance, ECHO mapping, or numeric thresholds. These are manager-selected provisional decisions, not canonical confirmation. No harness has been created or run.

Exact contact/ranged thresholds, same-band offsets, and shared-boundary dimensions/coordinates remain deferred until layout evidence. ECHO identity mapping and all remaining air-lane/source gates remain open. No runtime behavior, test, or validation is implied; canonical reconciliation remains queued.
## I-05 timer-expiry terminal outcome — owner-delegated manager selection

Under the owner's standing instruction to automatically select supported Recommended options, manager recommendation A is selected: expiry of either the maximum-encounter timer or the no-progress timer resolves the encounter as defeat and follows the already-approved automatic retreat to the highest-cleared holding wave. The existing one-time stalemate cinematic remains associated with holding-wave arrival; after one holding-wave clear, the next uncleared wave is automatically retried. This is an owner-delegated manager selection, not a claim that the earlier timer-order replies selected the terminal outcome directly. Numeric timer thresholds, probability/damage coefficients, and other tuning values remain open for playtesting. No runtime change is implied.

## D-02 accessibility scope — owner-approved selections

In the Neon Requiem project-manager conversation on 2026-10-26, the owner selected keyboard/mouse for 1.0 and deferred controller support; selected continuous text-only scaling (not whole-interface scaling); and selected master volume plus mute. Numeric text-scale limits, steps, and default remain unselected. Audio-control range/default, focus order/key bindings, non-color cues, captions, and D-01 music/cue scope also remain open. This is a local decision record; no remote readback is claimed.

## D-01/D-02 manager-selected provisional follow-up — local only

Under the user's prior authorization to select supported recommendations, the manager selected this provisional direction for later local recording and canonical reconciliation: D-01 includes gameplay-clarity SFX only for 1.0; the original soundtrack and in-engine victory/defeat/stalemate sequences are deferred. D-02 recommends continuous text-only scaling at 100–150%, default 100%; master volume at 0–100%, default 100%, with separate mute; Tab / Shift+Tab focus traversal in visual reading order, Enter / Space activation, Escape close/cancel for the topmost dialog or a non-destructive prompt, and arrow-key operation of options/sliders where applicable; a non-color indicator for every interactive or gameplay-critical state communicated by color; and captions for gameplay-critical non-speech SFX only. These recommendations do not specify cue content or gameplay-action bindings and do not add speech.

Implementation prerequisites remain: a shared text-scaling helper and layout review; a persisted mute field with load/default handling; implementation evidence for focus traversal, dialog boundaries, and focus restoration; a state inventory for non-color cues; and a gameplay-critical SFX/caption inventory. These are manager-selected provisional recommendations, not direct owner-authored canon. No implementation or validation is recorded; canonical reconciliation is queued, and no remote readback is claimed.

**Mute default selection — manager-selected provisional follow-up:** use `muted = false` for new profiles and saves with no mute field; keep the existing `master_volume` default at `1.0`. This avoids silently muting new or upgraded saves, at the cost of audio playing until the player mutes it. The selection is local-only and is not canonical remote confirmation. No implementation or validation is implied.

## Character attachment ownership and identity — approved, scoped

The user approved three character-specific interpretations in the Neon Requiem project-manager conversation on 2026-10-26:

- BULWARK's white cross backing belongs to the helmet panel.
- CIPHER's held concept rifle and vertical side-view item are the same prop in different carry states.
- DEADLOCK has one rifle shown held and back-mounted in different states.

These approvals resolve only semantic ownership or prop identity/carry state. They do not define cutout boundaries, separate-part construction, new attachment points or coordinates, pivots, transition behavior, or production readiness. Preserve existing quarantine and authoring gates. No canonical Notion/Drive write is claimed; see `docs/REMOTE_SYNC_QUEUE.md`.

## Initial lineup deployment order — approved

- When a new profile or supported migrated save has no saved active lineup, auto-fill up to six currently owned recruits in stable founding-roster order.
- Leave remaining slots vacant when fewer than six recruits are owned; excess owned recruits remain in reserve.
- This supersedes the earlier starter-priority order (VECTOR, SPARK, RECOIL first).
- A recruit purchased during combat still joins only at the next encounter boundary when a slot is open; a full lineup leaves it in reserve.
- No combat-time spatial preferences, targeting changes, or manual combat controls are added by this decision.
- **Source:** User-approved answer in the Neon Requiem project-manager conversation on 2026-10-26. Local implementation and documentation are updated; Test Lane regression validation is pending. No canonical Notion/Drive write is claimed.

## Spatial formation direction — partial approval

- Soft Front/Middle/Rear band geometry uses fixed battlefield depth plus enemy-relative distance. Depth bands stay fixed as combat advances. Working interpretation: measure from the enemy's current position as it moves; no contrary source/user wording was found. Exact contact/ranged thresholds are deferred until after layout testing; no values are approved.
- Collision/pathing uses local avoidance while preserving the recruit's preferred band; route around authored obstacles and wait if no route exists. One shared fixed boundary shape applies to every encounter; dimensions/coordinates are deferred until layout testing. If ordered positions do not fit, compress spacing, then temporarily relax the preferred band if needed. Overlap and passing remain open.
- After target changes, regroup only when enemies pose no threat; finish the current attack or ability before regrouping. Defeated recruits stop moving. The operational meaning of “no threat” remains open.
- Vanguard and Assault are non-ranged/contact-start roles: favor the enemy-facing side within a selected band, close to melee contact without a band, and attack at contact. Support and Control are ranged-start roles: favor the rear/outer side within a selected band and attack at configured ranged engagement distance when possible; without a band, hold and attack at that distance.
- Conservative optional-role fallback: if no role is selected, preserve the character's existing attack-range configuration. This is not a new role rule and remains open to contrary user instruction.
- If a preferred band conflicts with role attack-start distance, temporarily leave the band to enter attack range, then regroup. Tune contact/ranged thresholds and same-band offsets after layout testing. Exact boundary dimensions/coordinates are also deferred until layout testing; overlap/passing and “no threat” operational details remain open.
- These approvals do not authorize runtime movement changes yet; continue using selector storage/persistence only and preserve automatic targeting.
- **Source:** User selections in the Neon Requiem project-manager conversation on 2026-10-26. No canonical Notion/Drive write is claimed.

## Spatial movement follow-up — additional partial approval

The user additionally approved three rules through the project manager on 2026-10-26: temporarily leave a preferred band to enter role attack range, then regroup; finish the current attack or ability before regrouping; route around authored obstacles and wait if no route exists. No spatial runtime implementation is authorized until the full contract is approved.

## Spatial movement follow-up — layout, boundaries, floating — historical; partly superseded by later decisions

The user chose to tune contact/ranged thresholds and offsets after layout testing and approved fixed battlefield boundaries. A later attachment-hover decision briefly superseded the earlier body-lane proposal; both are now superseded by the latest explicit decision recorded below. No spatial runtime/tests are authorized by these choices.

## Ability implementation scope — all twelve contracts first — selected; later D-04 trial defaults supersede the initial mechanics hold

The user selected scope B on 2026-10-26: define all twelve signature-ability contracts before implementing any skill. This initially established sequencing only. Under the owner's later standing authorization, the supported recommendations in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` are now selected as owner-delegated, provisional playtest defaults. They remain non-canon and do not set release balance. ECHO's abstract decoy simulation is selected; source-specific device identity/count/mapping and art/air-lane integration remain unresolved. No runtime or art change is implied by this decision record.

## Spatial floating exception — attachment-only presentation hover — historical; superseded

This was an intermediate approval and is superseded by the latest decision below. Do not use presentation-hover semantics as current spatial canon.

## Spatial movement follow-up — latest clarified decisions — 2026-10-26 America/Chicago

- One shared fixed battlefield-boundary shape applies across all encounters. Exact dimensions/coordinates remain deferred until layout testing.
- When ordered positions do not fit their preferred band, compress spacing first, then temporarily relax the band if needed. Overlap and passing behavior remain open.
- After target changes, regroup only when enemies pose no threat; finish the current attack or ability first. Defeated recruits stop moving. The operational “no threat” predicate remains open.
- All twelve recruit bodies remain grounded. SPARK's three attack-drone attachments and ECHO's decoy attachments use a separate spatial height/air lane. This is not presentation-only hover. No other recruit or attachment exception is selected. ECHO's drone/decoy mapping remains unresolved; lane geometry, activation, movement, collision/pathing, band interaction, and targeting/attack effects remain undefined.
- Contact/ranged thresholds, same-band offsets, and boundary dimensions/coordinates are deferred until layout testing. These direction-level selections do not authorize runtime behavior or tests.

## I-03 layout-test scaffold boundary — unresolved — 2026-10-26 America/Chicago

The decision to tune thresholds, offsets, and boundary dimensions after layout testing does not itself authorize creating or running a layout-test scaffold. No direct approval for that scaffold or its scope was found in the current decision record. Keep the scaffold prerequisite unresolved; do not create it or use it to derive spatial rules until its permitted scope is explicitly approved. This does not reopen the settled grounded-body/attachment-only air-lane direction.

## I-07b named-boss first-defeat lifecycle — owner-selected — 2026-10-26 America/Chicago

- First defeat immediately grants permanent ownership of that unique named boss.
- The identity is excluded from enemy generation as part of the ownership grant.
- Apply the existing roster rules: fill the first open active slot; if all six are occupied, keep the recruit in reserve; if acquired during combat, deployment begins next encounter.
- This closes the separate claim-action option and pending-unclaimed replay question. It does not choose boss-to-district mapping, encounter profile, stats, spawn/cadence, rewards, or identity-specific art.
- No runtime or test change is authorized or recorded here. Canonical Notion/Drive reconciliation remains queued.

## Character art scope and carry-state decisions — owner-selected — 2026-10-26 America/Chicago

- **GLITCH:** the held/back-mounted item is one rifle in two carry states, replacing the roster's “sidearm” label. Do not duplicate it; semantic boundaries, mounts, pivots, transitions, and artist provenance remain open.
- **BULWARK:** a side-facing helmet cross is approved in addition to the front-view cross. Require an artist-authored side view; do not paste/reuse the front crop. Exact pixel boundary, side placement, backing split, pivot, and production readiness remain open.
- **ECHO:** Signal Cascade decoys are distinct from physical sensory devices. Do not map/count the visible spheres as decoys; count, view identity, and attachment mapping remain open.
- **IRONCLAD:** a back-stowed weapon state is approved as art direction. Exact mount, overlap, anchors, pivots, and transition evidence remain open.
- **Evolution art:** all twelve recruits need distinct visible art changes at every evolution step for 1.0. This supersedes the old post-1.0 deferral for the eleven non-BREAKER higher-tier sets. It approves no tier-specific design or candidate; all source, semantic, provenance, pivot, deformation, rig, and production gates remain.
- **Additional visual direction and board status:** an earlier revised CIPHER evolution board is approved as direction only and remains quarantined; it is separate from the latest approved concept direction for CIPHER's external HUD progressing into an integrated biomechanical eye, with one rifle in one carry state per grade. SPARK's approved concept direction is a mechanic character with three distinct drones receiving staged hardware upgrades. The generated eye-integration and drone-upgrade boards remain quarantined and are not production/rig approvals; exact stage implementations still need authoring/mapping. Evolution visuals must be character-specific; do not assume all recruits gain cybernetic parts. BREAKER's existing progression is suitable. Proposed mechanics remain provisional/non-canon and proposed mechanical upgrades are not canon. C-05a did not locate project-local board paths/hashes. No individual production asset or rig is approved.
- This is a local owner-decision record; the offline source reconstruction remains non-verbatim and canonical reconciliation is queued. No art, runtime, tests, or remote source changed in recording these decisions.

## Evolution form naming — owner-approved — 2026-10-26 America/Chicago

The global four-form sequence is **Origin Form, Adapted Form, Signature Form, Requiem Form**, replacing Street/Combat/Military/Apex Grade labels. This changes names only; order, trial gates, all-twelve visual coverage, and character-specific art direction are preserved. Existing known labels are normalized in memory on load without rewriting raw saves; a later normal save records the new names. Unknown labels and unknown save fields are preserved. No mechanics, stats, balance, art, or rig approval is implied. Local sources and staging were updated; canonical reconciliation remains queued.
