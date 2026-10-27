# Design decisions and source status

## Evolution form names — owner-approved — 2026-10-26 America/Chicago

The official shared evolution form names are **Origin Form → Adapted Form → Signature Form → Requiem Form**. Older concept boards may use “Street / Combat / Military / Apex” as art-stage shorthand for those four positions in order; that shorthand does not rename the official forms or the progression UI. The tier order, existing wave/material feasibility gates, 1.0 twelve-recruit coverage, and character-specific design rule remain unchanged. These names do not imply universal cybernetic augmentation or new gameplay effects.

Existing saves containing the previous display strings remain readable. The loader normalizes these known labels in memory; raw save files are not rewritten merely by loading. The next ordinary save writes the new labels. Unknown tier strings remain unchanged and invalid for progression. The offline migration reconstruction and dated live-source readbacks remain historical evidence; canonical Notion/Drive reconciliation is queued. No art, gameplay behavior, stats, or balance changed with this naming decision.

## Owner-selected follow-ups — I-03, I-06, I-09 and evolution direction — 2026-10-26 America/Chicago

- **I-03 spatial behavior:** when ordered positions do not fit a preferred band, compress spacing first, then permit temporary band relaxation. Neighbor overlap is allowed only while recruit silhouettes remain legible, the UI remains unobscured, and collision/pathing stays usable. Passing behavior, the operational “no threat” predicate, air-lane geometry, and ECHO device/decoy visual mapping remain unresolved. No layout-test scaffold or runtime change is authorized by these selections.
- **I-06 roster progression:** keep functional level purchase/stat growth BREAKER-only until individualized combat and economy evidence supports expansion. Preserve all-twelve recruitment and evolution records. This selects scope only; it does not approve final stats, costs, curves, or caps.
- **I-09 endless progression:** preserve wave 126 as the design-approved endless start, while the runtime/save ceiling stays 125 pending a complete endless profile and compatible save policy. Defer scaling, generator/pool/composition, boss cadence, endless rewards/milestones, and above-125 offline reward inputs. Preserve the current credit-only, saved-holding-wave, claim-save, no-wave-advance, eight-hour offline-claim structure. Do not extrapolate provisional Undercity fixtures.
- **Character evolution art:** evolution remains character-specific; do not add cybernetics to every recruit by default. BREAKER's established progression is suitable. BULWARK's concept direction is medic-specific changes to armor, medical pack, and diagnostic bracer, preserving connected hose logic and the approved helmet-cross treatment. This is concept direction only; no gameplay healing effect, production art, or rig is approved. CIPHER and SPARK concept directions remain as recorded below and in the coverage map.
- **Remaining evolution direction:** future boards should give each character a cybernetic interface that visibly enhances that recruit's established signature accessories/gear, avoiding generic cybernetic plating. SPECTER's concept direction ties the interface to its established cloak and evolves one recognizable signature sword visually by grade. Preserve source-backed identity/count. Approval is concept direction only: stealth, ability, and blade mechanics are not canon; generated art remains quarantined. Any gameplay function or balance change remains proposal-only pending owner approval. Keep concept boards quarantined.
- **Netrunner family visual direction:** a digital transformation is a visual direction for CIPHER, ECHO, and GLITCH only, with distinct character-specific expressions rather than a shared copied treatment. CIPHER's established direction is precision-optic/data geometry and progression from HUD to integrated eye; ECHO's approved Requiem direction is an ascended digital-energy being with visual-only levitation, while physical sensory devices remain distinct from Signal Cascade decoys; GLITCH's approved glitch-signal language is the visual anchor and should not be copied wholesale. This direction creates no gameplay, targeting, stealth, flight, spatial, or rig behavior.
- **CIPHER revised four-form board:** owner-approved as visual direction only, completing the netrunner family's digital-direction approval at Requiem Form. It depicts grounded Origin/Adapted/Signature forms, HUD-to-integrated-eye progression, precision scan geometry, and controlled magenta/cyan data breakup at Requiem. The generated board remains outside the project and quarantined. No gameplay, targeting, production, rig, runtime, or integration approval is implied. See `docs/NETRUNNER_APEX_VISUAL_DIRECTION_REVIEW_2026-10-26.md`.
- **Save version note:** current `SaveService` writes schema version 2 and supports migration from known version 1. Older prose calling version 1 the current writer contract is superseded; no additional historical source version is implied.

## D-04 ability implementation defaults — owner-delegated playtest scope — 2026-10-26 America/Chicago

- Under the owner's standing authorization, the twelve recommended simulation contracts in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` are selected as owner-delegated playtest defaults. They are provisional and explicitly non-canon; numeric magnitudes, thresholds, durations, and profile values remain trial inputs, not release decisions.
- Shared contract: automatic action-boundary checks and target selection; no separate ability resource; no legal target means remain ready without cost/cooldown; cooldown starts on effect commit; commit gameplay state in authoritative simulation before emitting presentation. CIPHER's selected ordinary-precision-shot fallback consumes Ghost Round when no eligible cyberware target exists.
- Temporary ability effects/cooldowns clear at encounter end. Invalid pre-commit actions cancel without cost; committed effects resolve atomically. Qualifying committed HP/effective-combat-state changes report progress through I-05. Presentation events alone never change combat or reset timers.
- **Implementation readiness:** all twelve simulation contracts are ready for a configurable playtest profile. ECHO's abstract decoy simulation is ready, but attachment identity/count/mapping, air-lane presentation, and count-dependent art tests remain blocked on source/Character resolution. No ability code or art is approved by this decision record.
- **Authority/provenance:** owner-delegated selection in the project-manager conversation on 2026-10-26, based on the recorded local recommendation matrix. The offline roster reconstruction is non-verbatim and the prior live roster fetch is marked `unverified`; canon reconciliation remains queued in `docs/REMOTE_SYNC_QUEUE.md`.

## D-02 accessibility scope — approved, bounded — 2026-10-26 America/Chicago

- **Keyboard/mouse:** approved for 1.0; controller support is deferred.
- **Text scaling:** approved as continuous text-only scaling, not whole-interface scaling. Numeric limits, steps, and default remain unspecified.
- **Audio controls:** master volume and mute are approved. This does not decide the D-01 music/cue scope or numeric control range/default.
- Focus order/key bindings, redundant non-color cues, and caption scope remain open. Keyboard/mouse approval does not define navigation order or bindings.
- **Approval source:** owner selections in the Neon Requiem project-manager conversation on 2026-10-26. Local record only; canonical Notion reconciliation remains queued in `docs/REMOTE_SYNC_QUEUE.md`.

## D-01/D-02 follow-up — manager-selected provisional direction — local only — 2026-10-26

Under the user's prior authorization to select supported recommendations, the manager selected the following provisional 1.0 direction. These selections are not represented as direct owner-authored canon; canonical Notion reconciliation remains queued in `docs/REMOTE_SYNC_QUEUE.md`.

- **D-01 audio:** include gameplay-clarity SFX only. Defer the original soundtrack and in-engine victory, defeat, and stalemate sequences. This sets scope only; it does not define cue content, asset source, cost, or production readiness.
- **D-02 text scaling:** continuous text-only scaling from 100% to 150%, default 100%. Whole-interface scaling is not selected. Implementation needs a shared text-scaling helper and layout review before the numeric range is production-ready.
- **D-02 audio controls:** master volume from 0% to 100%, default 100%, plus a separate mute control. The current save convention stores volume as 0.0–1.0 with default 1.0; a separate persisted mute field and load/default handling are prerequisites.
- **D-02 keyboard/focus:** Tab / Shift+Tab traverse visible enabled controls in visual reading order; Enter / Space activate; Escape closes the topmost dialog or cancels a non-destructive prompt; arrow keys operate option selection and sliders where applicable. This does not define gameplay-action bindings. Dialog boundaries, focus restoration, and key behavior need implementation evidence.
- **D-02 redundant non-color cues:** each interactive or gameplay-critical state communicated by color should also have a non-color indicator. The actual state inventory and presentation treatments remain to be established from implementation evidence.
- **D-02 captions:** caption gameplay-critical non-speech SFX only. Do not add speech or music captions in this scope. Specific cues and caption labels remain undefined pending a cue inventory and implementation evidence.
- **D-02 mute default — manager-selected provisional follow-up:** use `muted = false` for new profiles and saves with no mute field; preserve the existing `master_volume` default of `1.0`. This avoids silently muting new or upgraded saves, at the cost of audio playing until the player mutes it. This selection is made under the user's prior authorization, remains provisional and local-only, and is not canonical remote confirmation.
- **Status:** product-direction recommendations only. No UI, input, audio, save-schema, or gameplay implementation is authorized or recorded here; no validation has been run. Keep the existing owner-approved D-02 scope above distinct from these manager-selected provisional details.

## Attachment ownership and identity — approved, scoped — 2026-10-26

- **BULWARK:** the white backing behind the helmet medical cross belongs to the helmet panel. A side-facing helmet cross is approved in addition to the front-view cross; require an artist-authored side-view version and do not reuse/paste the front crop. These approvals cover backing ownership and presence/direction only; exact pixel boundary, side placement, backing split, pivot, and production readiness remain open.
- **CIPHER:** the rifle held in the concept and the vertical item in the side-view reference are the same prop in different carry states. This resolves prop identity only; it does not approve the current isolated cutout, define part boundaries, or specify grip/stow attachment points or transitions.
- **DEADLOCK:** one rifle is shown held and back-mounted in different states. Do not create duplicate weapon art. This resolves identity/count/carry-state interpretation only; it does not specify attachment coordinates, pivots, or transition behavior.
- **GLITCH:** the held and back-mounted item is one rifle shown in two carry states. The owner-approved rifle identity replaces the roster's “sidearm” label. Do not duplicate the rifle; semantic cutout boundaries, authored grip/stow mounts, pivots, transition behavior, and artist provenance remain open.
- **ECHO:** Signal Cascade decoys are distinct from the physical sensory devices. Do not map/count visible spheres as decoys; count, view identity, and attachment mapping remain open.
- **IRONCLAD:** a back-stowed weapon state is approved as art direction. This does not supply a visible source mount, overlap construction, anchor/pivot coordinates, or transition evidence; keep those open.
- These decisions do not infer cutout boundaries, new attachment points, hidden geometry, or production readiness. Keep all candidates quarantined pending the remaining visual, semantic, authored-pivot, deformation, and source-provenance gates.
- **Approval source:** user approval in the Neon Requiem project-manager conversation on 2026-10-26. Local record only; canonical Notion/Drive reconciliation remains queued in `docs/REMOTE_SYNC_QUEUE.md`.

## Evolution art scope — owner-approved 1.0 requirement — 2026-10-26

All twelve recruits require distinct visible art changes at every evolution step in 1.0: Origin Form, Adapted Form, Signature Form, and Requiem Form. This supersedes the earlier C-05/post-1.0 deferral for the eleven recruits besides BREAKER. BREAKER may retain first production priority, but every recruit's four visual states and three evolution transitions are in 1.0 scope. This approves the coverage requirement, not specific tier designs or details; preserve each character's approved identity and establish each visual change through approved sources and review. Existing provenance, semantic-part, pivot, deformation, rig/animation, and production acceptance gates remain. No art is approved, generated, extracted, promoted, or integrated by this decision record.

**Additional visual direction and review state — owner-selected 2026-10-26:** An earlier revised CIPHER evolution board is approved as visual direction only and remains quarantined; it was not located in the project tree during C-05a reconciliation. It is separate from the latest approved concept direction: progress CIPHER's external HUD toward an integrated biomechanical eye, and show one rifle in one carry state per grade. SPARK's approved concept direction is a mechanic character accompanied by three distinct drones with staged hardware upgrades. BULWARK's approved concept direction is medic-specific armor, medical-pack, and diagnostic-bracer progression, preserving connected hose logic and the approved helmet-cross treatment. SPECTER's approved concept direction ties character-specific cybernetic interfaces to its established cloak and evolves one recognizable signature sword visually by grade. These approvals are concept direction only: no mechanics, balance, production art, or rig is approved; generated boards remain quarantined. The named CIPHER, SPARK, and BULWARK boards and two SPECTER proposals are present in the local Codex `generated_images` folder outside the project tree, not integrated/copied. Exact paths, dimensions, hashes, and approval distinction are recorded in `docs/ASSET_MANIFEST.md`. Evolution changes must be character-specific and draw from each recruit's established visual toolkit and attachments; do not assume every recruit gains more cybernetic parts. BREAKER's existing cybernetic progression is suitable. Preserve source-backed identity/count. See `docs/C05A_EVOLUTION_ART_COVERAGE_MAP.md`; canonical reconciliation remains queued in `docs/REMOTE_SYNC_QUEUE.md`.

## Squad preferences — approved implementation scope — 2026-10-26 America/Chicago

- Implement per-recruit optional Front/Middle/Rear band and Vanguard/Assault/Support/Control role selectors, with data persistence across System Reboot.
- This scope records preferences only. It does not add spatial behavior, coordinates, targeting changes, or player control over automatic combat. Spatial effects remain an open design task.
- **Approval source:** user selected “Selectors and persistence only” in this conversation on 2026-10-26. No remote Notion write is claimed; see `docs/REMOTE_SYNC_QUEUE.md`.

### Spatial implementation direction — partial approval — 2026-10-26 America/Chicago

- The user approved combined depth-and-distance geometry for soft Front/Middle/Rear bands and local avoidance that preserves the preferred band.
- The depth axis is fixed to the battlefield and bands remain fixed as combat advances; distance is enemy-relative. **Working interpretation:** evaluate distance against the enemy's current position as it moves; no contrary source/user wording was found. Exact contact/ranged threshold values are deferred until after layout testing; no numeric threshold is selected now. This interpretation is not a separate user-approved measurement rule.
- The user also approved ordered positions for recruits sharing a band; founding-roster order is the working stable order. Exact same-band offsets are deliberately deferred until after layout testing; no numeric offset is approved.
- Regroup after target changes only when enemies pose no threat; finish the current attack or ability before regrouping. Defeated recruits stop moving. The operational meaning of “no threat” remains open.
- **Role movement and attack-start mapping approved:** Vanguard and Assault are non-ranged/contact-start roles; within a selected band, favor its enemy-facing side, and with no band, close to melee contact before attacking. Support and Control are ranged-start roles; within a selected band, favor its rear/outer side while attacking at their configured ranged engagement distance when possible, and with no band, hold that distance and may attack there.
- **Optional-role fallback assumption:** if no role is selected, preserve the character's existing attack-range configuration. This is a conservative fallback, not a new role rule, and remains open to contrary user instruction.
- Contact/ranged threshold values and same-band offsets are deliberately deferred until after layout testing. The user approved one shared fixed battlefield-boundary shape across all encounters; exact boundary dimensions/coordinates remain deferred to layout testing. If ordered positions do not fit the preferred band, compress spacing first, then temporarily relax the band if needed. Overlap and passing behavior remain open.
- These are direction-level approvals plus the labeled enemy-position interpretation. User-approved follow-up: tune contact/ranged thresholds and offsets after layout tests; regroup after target changes only when enemies pose no threat; and keep defeated recruits from moving. The operational meaning of “no threat” remains open. All recruit bodies remain grounded; SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane. This is a spatial, not presentation-only, exception. Exact lane geometry, transitions, collision/pathing, interaction with fixed depth bands, targeting/attack geometry, activation timing, and ECHO's drone/decoy mapping remain open. No other recruit or attachment has an approved air-lane exception. Do not implement spatial behavior until the full contract is approved.
- **Approval source:** user selections in the Neon Requiem project-manager conversation on 2026-10-26. No remote Notion update/readback is claimed.

### I-03c — spatial follow-up — manager-selected provisional direction — local only — 2026-10-26

Under the user's prior authorization to select supported recommendations, the manager selected these provisional rules. They are distinct from the owner-selected spatial directions above and are not direct owner-authored canon; canonical reconciliation remains queued.

- **Passing:** allow temporary passing only when required to route around an authored obstacle or satisfy the approved role attack-range override. Founding-roster order remains the preferred destination order; passing does not change or persistently reorder the roster formation.
- **No-threat regroup predicate:** after a target change, regroup only when no living enemy currently targets that recruit and no already-committed enemy attack/effect against them remains unresolved. Evaluate from authoritative simulation state; do not substitute a new distance threshold or presentation-only proxy.
- **Layout harness:** permit a disposable geometry-only layout harness limited to representative positions, bands, authored obstacles, and the shared fixed boundary. Keep it isolated from production scenes and combat simulation. It must not evaluate targeting, attacks, threat, balance, ECHO mapping, or numeric thresholds. No harness has been created or run.
- Exact contact/ranged thresholds, same-band offsets, and shared-boundary dimensions/coordinates remain deferred to layout evidence. ECHO identity mapping, air-lane geometry/behavior, and other source-gated choices remain open. No spatial runtime behavior or validation is approved or claimed by these provisional selections.

## Active recruit roster — user-approved workflow — 2026-10-26 America/Chicago

- A successful recruit purchase automatically places that recruit into the first open active slot. If all six slots are occupied, the new recruit remains in reserve until the player swaps the lineup between encounters.
- Empty active slots remain vacant when fewer than six recruits are owned. Only owned and deployed recruits fight; the generic placeholder actors remain prototype fixtures, not production recruits.
- Lineup changes are locked during combat. The selected lineup persists through System Reboot.
- **Initial lineup:** new profiles and supported saves without a saved active lineup auto-fill up to six currently owned recruits in the stable founding-roster order. Slots remain vacant when fewer than six recruits are owned; additional owned recruits remain in reserve. This supersedes the earlier starter-priority default.
- A recruit purchased during combat is added to the first open slot in saved/pending lineup state but is not inserted into the live encounter; deployment takes effect at the next encounter. When all six are occupied, the purchase remains in reserve.
- Current HP follows recruit identity across swaps. Benching a recruit does not heal it. System Reboot restores every owned recruit, including reserves, to full HP; the existing approved retreat rule continues to restore the deployed squad on holding-wave re-entry.
- This is the user's latest selection (“actually, autofill”), superseding the earlier manual-only workflow selection. The user separately selected vacancies and identity-based HP with Reboot healing all owned recruits on 2026-10-26. The user later approved roster-order auto-fill when no saved lineup exists, replacing the prior starter-priority order. For v1 save migration, map the one source-defined BREAKER slot to BREAKER, preserve the five placeholder-slot HP values as legacy data, and initialize all other owned recruits at full HP. Migration must use copy/validate/rollback safety.
- **Source status:** these choices were made in the current conversation after the available live Notion reads; they have not been written to canonical Notion. See `docs/REMOTE_SYNC_QUEUE.md`.
- **Status:** selectors and persistence have been added locally, but this integration is not validated until the assigned Test Lane runs its focused checks.

## Local save protection and recovery policy — user-approved — 2026-10-26 UTC

- Saves from newer or unknown schema versions remain readable as raw files only: ordinary save/load validation does not rewrite them. Migrate an older version only after that source version has an explicit supported migration path. Current SaveService writes version 2 and supports migration from the known version-1 shape with optional fields.
- Any future migration must operate on a copy, validate the migrated copy, keep the original recoverable, and roll back if migration or commit validation fails.
- Recovery reads primary → `.bak` → `.bak.prev`, reports when it loaded a recovery copy, does not rewrite the primary during recovery, and ignores temporary files.
- If no valid primary or recovery copy exists, ordinary saving is blocked. Replacement is allowed only through an explicit confirmed Reset Save flow; cancel leaves all save files untouched.
- During an explicitly confirmed Reset Save, unsupported or invalid `.bak` and `.bak.prev` sidecars are copied to adjacent, content-hash-named quarantine files. The copy is byte-compared and hash-verified before the active sidecar is removed, and removal occurs only after the new primary save validates. A content-hash-named primary snapshot supports rollback. Failed commit or sidecar removal restores the original primary and active sidecars; if restoration cannot complete, the verified snapshot/quarantine copies remain available for recovery.
- Preserve unrecognized fields through supported load/update/save operations, including nested fields. Unknown schema versions remain protected from ordinary writes regardless of such field preservation.
- The current implementation and regression evidence are summarized in `docs/IMPLEMENTATION_STATUS.md` and `docs/MIGRATION_REPORT.md`. The known version-1 roster shape now has a version-2 migration; other historical versions remain unsupported. The new migration has not yet been validated by Test Lane.

### Roster save migration follow-up — implementation added; validation pending — 2026-10-26 America/Chicago

- Supported version-1 saves are migrated on a validated copy to version 2. Only the source-defined first positional HP value maps to BREAKER; the other five values are retained in `legacy_placeholder_squad_hp` without assigning them to recruits. Owned recruits without saved identity HP start at full HP.
- The existing staged SaveService transaction is used for migration and retains recovery copies. Unknown/newer schemas and recovery-only loads are not rewritten by migration.
- This compatibility implementation is not validated yet. See the new Test Lane handoff recorded in `docs/WORK_LANE_ASSIGNMENTS.md`.

## Research catalog scope — approved branches, node definitions deferred — 2026-10-25 America/Chicago

- The four approved research branches are Combat Protocols, Underground Economy, Network Infrastructure, and Personnel Development. Research spending uses spendable Network Influence; research and both Influence balances persist through System Reboot.
- The 1.0 planning decision explicitly defers node definitions until combat/economy testing informs the catalog. No node identity, cost, rank cap, gameplay effect, prerequisite, or branch/node unlock rule is approved in the live pages fetched for this audit or in the offline reconstruction.
- Keep `data/progression/research_catalog.json` empty and the Research UI read-only until the required node rules are approved. The four branch names and persistence rules are not permission to invent effects or access gates.
- **Live source readback:** Game Design & Progression (`2026-10-26T03:12:05.596Z`), Decision Log & Change Control (`2026-10-26T03:12:02.885Z`), Production Roadmap (`2026-10-26T03:12:09.241Z`), Project HQ (`2026-10-25T08:37:55.243Z`), and Codex Reconstruction Handoff (`2026-10-24T04:00:51.261Z`). All fetch results report `verification.state: unverified`. URLs are listed in `docs/MIGRATION_REPORT.md`.

## Recruit run-level cost candidate — approved for playtesting only — 2026-10-26

- The user-approved moderate economy playtest candidate is `round(20 × 1.12^(level - 1))` for individual recruit level-ups. It is a trial value, not final balance.
- The live Notion Decision Log's 1.0 planning section contains this candidate. The older canonical recruit-level section still leaves exact scaling and caps open; the candidate does not approve a level cap.
- The current BREAKER prototype applies the candidate curve to BREAKER only. Other recruits do not yet have individual level state or purchase paths.
- Sources: [Decision Log & Change Control](https://app.notion.com/p/40394c5658c88127b755c01197ff628d), [Game Design & Progression](https://app.notion.com/p/40394c5658c88159962fee5423c311de), and `docs/LOCAL_SESSION_DECISIONS_2026-10-25.md`.

## Founding recruit availability and prototype prices — live Notion approval — 2026-10-25 America/Chicago

- All twelve founding recruits are available to purchase from the start; the playtest begins with VECTOR, SPARK, and RECOIL owned.
- Trial-only prices follow rarity: Common 300 credits, Rare 600 credits, Epic 1,200 credits. Starting playtest credits: 600. These values are for prototype feasibility only, not final balance.
- The approved 1.0 roster is the twelve founding recruits plus five named boss recruits. Generic recruits are deferred. Named boss identities remain outside this implementation because boss content and defeat/recruit rules are not part of the twelve-recruit slice.
- Founding recruits are unique; each can be purchased once. There is no random draw or gacha.
- **Source:** live [Founding Recruit Roster](https://app.notion.com/p/40394c5658c8812d849be3d32629920e), edited `2026-10-26T03:12:07.445Z`; fetched read-only during implementation on 2026-10-25 America/Chicago. The live Game Design & Progression page reconfirms deterministic credit recruitment and guaranteed named-boss recruitment on defeat.

## CIPHER candidate 07 hand-over-jacket occlusion interpretation — user-approved — 2026-10-25 UTC

- The visible `near_hand` is its own foreground semantic part. Treat the jacket as continuing behind the hand; do not assign visible hand pixels to `pelvis_belt_gear`.
- Any jacket surface authored beneath the hand is inferred underpaint because the approved flattened turnaround does not reveal those occluded pixels. Label that provenance explicitly and preserve the foreground hand/jacket draw order.
- This resolves the intended real-world ownership interpretation for CIPHER candidate 07 only. It does not supply the hidden pixels, approve candidate 07, or clear semantic, pivot, deformation, or production gates. The candidate remains quarantined until authored and visually reviewed.
- **Approval source:** User clarification in this conversation on 2026-10-25.

## Character-art occlusion review method — user-approved — 2026-10-25 UTC

- For future character-art issues of this same kind, interpret visible overlaps by real-world semantic ownership: the foreground object owns its pixels and remains in front of the surface it covers.
- If approved source views flatten and hide the covered surface, a separate conservative underpaint may represent its continuation when the user's direction or approved references establish that continuation. Label all such hidden pixels as inferred, preserve the original source layers, and avoid inventing unsupported details.
- Review the neutral composite at intended gameplay scale and review any exposed underpaint in motion. This method does not authorize guessing unresolved design ownership, changing canon, or promoting a candidate to production.
- **Scope example approved for now:** CIPHER candidate 08's hand-over-jacket underpaint is accepted as a quarantined visual approach at the intended display scale, where the user expects it to be nearly invisible. This is not a measured gameplay-scale pass or rig/production approval.
- **Approval source:** User direction in this conversation on 2026-10-25.

## CIPHER Tier I knee guard ownership — user-approved — 2026-10-25 UTC

- The visible armored kneecap is a distinct `near_knee_guard` part anchored at the knee, separate from `near_thigh` and `near_shin`.
- `near_knee_guard` owns the front armor plate/red optic and upper side lug. The lower round hinge and wrap strap remain with the leg layers.
- Preserve the approved visible source RGB. The user approved candidate 09B's traced `near_knee_guard` boundary after viewing the source/isolated/reassembled comparison. Motion seam and deformation remain under review.
- The user approved source pixel `(770, 665)` as the knee guard pivot, centered on the leg-owned lower hinge. Candidate 09B records it at part-local pixel `(77, 115)`; see `docs/visual_qa/CIPHER_T1_CANDIDATE_09B_PIVOT_APPROVED_QUARANTINED.png`. This approves the pivot point only, not deformation or production readiness.
- The user requested and approved an inferred underpaint for the source-hidden trouser surface exposed by knee flex. Candidate 09B has a separately labeled, flat fill review layer clipped to the flex-exposed wedge inside the approved source silhouette. Approval applies to this quarantined review layer and shown pose range; it remains excluded from neutral/runtime art. See the underpaint review entry in `parts_manifest.json`.
- **Approval source:** User approved the separate knee guard and clarified “Leg” for the lower hinge/strap in this conversation on 2026-10-25.

## Eleven approved Tier I visual references and anatomy turnarounds — 2026-10-25 UTC

The user approved the individual Tier I concept designs and matching anatomy turnarounds for BULWARK, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH. The turnarounds may guide visible proportions and anatomy for these recruits. Neither approval makes the flattened images production sprites, verifies concealed anatomy, approves part boundaries/pivots/deformation, or marks any production-art gate complete. BREAKER's existing art decision remains separately recorded.

## Character-part atlas pilot remains quarantined — 2026-10-25 UTC

CIPHER was selected as the first non-BREAKER modular-part intake pilot. Two generated transparent atlas candidates were alpha-segmented into numbered review crops. Candidate 01 was rejected; candidate 02 also fails semantic-part readiness: its crop sheet contains visibly clipped/duplicated or ambiguous limb elements, and the 18 alpha-connected components cannot yet be mapped reliably to a complete rig. This is a production-art gate finding, not a change to CIPHER's approved visual direction. Keep both atlases and crops quarantined. No authored pivots, final part mapping, or runtime assets are approved.

## Candidate01 v20 review disposition — 2026-10-25 UTC

The user chose to retain candidate01 v20 as a review candidate rather than continue revising its hidden-arm shape at this time. This is an art-review disposition, not a canon or production-acceptance decision. Keep v20 and its evidence quarantined; continue to mark hidden anatomy and production readiness unverified. The 100-contact elbow test passing in the provisional rig does not change those gates.

**Status:** Foundational design sources were reconciled against the brief, offline reconstruction package, and live Notion readback on 2026-10-24. A newer BREAKER arm-boundary choice and candidate 09 v2 status were published and read back from live Notion on 2026-10-25. All eight canonical child pages and Project HQ are saved under `Notion/Live Readbacks/`. This session did not verify or upload remote Google Drive assets.

## Approved identity and gameplay constraints

- Cyberpunk 2.5D endless idle army RPG; dark gunmetal/black setting with crimson, cyan, pink, purple, and layered rainy city environments.
- Six active squad slots from the beginning; fully automatic targeting and ability activation; dynamic squad formation with optional position preferences; hybrid power-driven combat.
- **User-approved on 2026-10-24; supersedes the earlier same-day full-heal rule:** carry each ally's remaining HP across successful wave transitions; allies at 0 HP remain defeated and do not fight. On full-squad defeat, retreat immediately to the highest previously cleared holding wave, then restore the squad to full HP on holding-wave re-entry so it can retry. Current HP is run state and is saved per squad slot. Numeric damage tuning remains provisional.
- Walking speeds are selected internally and applied by automatic combat simulation; players have no control for changing unit movement speeds.
- Ranged units may hold a configured engagement distance from their target; melee units close to contact distance. The simulation controls movement and attacks automatically. Exact distances are data-configurable prototype values.
- No gacha. Deterministic credit-based recruitment. Defeating a named boss guarantees its unique recruit.
- Modular, evolving characters with four permanent visual tiers: Origin Form, Adapted Form, Signature Form, Requiem Form. Evolution improves visuals and stats; selected milestones affect traits/abilities; cyberware supports specialization.
- System Reboot prestige; permanent Network Influence and research; offline credit farming, no offline wave advancement; current target cap of eight offline hours; total additional spending ceiling $25, target $0.
- Individual recruit run-levels, bulk upgrades, hybrid exponential credit economy, automatic retreat to the highest previously cleared holding wave after defeat. The reconstructed design also specifies a one-time stalemate cinematic on arrival.
- Network Influence is awarded at reboot. Lifetime Influence gives a passive permanent benefit; spendable Influence buys research in four branches: Combat Protocols, Underground Economy, Network Infrastructure, and Personnel Development. Manual reboot initially; optional automation may unlock later but must not spend Influence automatically. Reboot resets credits and run-levels, not permanent unlocks, research, or evolution. **User-approved on 2026-10-24:** first System Reboot eligibility begins after the player clears wave 25 for the first time.
- **User-approved on 2026-10-24:** each successful System Reboot starts the run at wave 1 and resets the run's highest-cleared-wave counter to 0. Calculate its Influence award from the run's pre-reset highest-cleared wave since the previous Reboot.
- **Approved for prototype feasibility testing only on 2026-10-24:** award 1 Influence per completed 25-wave band since the previous Reboot; lifetime Influence grants `min(0.5% × sqrt(lifetime Influence), 25%)` bonus to outgoing squad damage only; each successful wave clear grants 1 shared Evolution Data, plus 1 extra for each first-cleared district milestone or named boss. District milestone points use the supplied band endpoints (25, 50, 75, 100, 125); boss first-clear IDs are data-driven and no boss content/placement is invented. These trial values are not final balance/canon. The evolution gate feasibility values are specified in the following decision; release tuning remains open.
- **User-approved for prototype feasibility testing on 2026-10-24:** per-recruit evolution unlocks use permanent first-clear milestones and shared earned Evolution Data: Adapted Form at wave 25 for 1 data, Signature Form at wave 75 for 2, Requiem Form at wave 125 for 3. These are trial values, not final balance/canon. The local transaction records an unlocked tier only; no tier stat values or evolution art are approved or implemented by this decision.
- **User-approved on 2026-10-24:** evolution progression milestones are satisfied permanently after their first clear, including across System Reboots. Each evolution still requires its earned-material cost.
- **User-approved for prototype feasibility testing on 2026-10-24:** offline credits accrue at 1.0 ordinary encounter reward per hour, priced from the ordinary reward at the saved highest-cleared holding wave (minimum wave 1), capped at eight hours. Claim on load and atomically persist the updated credit balance and claim timestamp before applying it to live state. Offline claims never advance waves or simulate encounters. This rate is configurable and is not final balance. Existing saves without an offline timestamp establish a baseline on first load and receive no retroactive payout.
- **User-approved on 2026-10-24:** atomically autosave run and permanent rewards after every successful wave clear, before the next intermission continues. Keep completed rewards available in the current session if the save fails, and tell the player to press Save; SaveService keeps the previous valid file authoritative. Every wave-clear save also resets the offline-claim timestamp.
- **User-approved on 2026-10-24:** implement a permanent research framework and read-only UI using the four approved branches, without inventing node costs, effects, prerequisites, or balance values. No purchase is enabled until those node definitions are approved.
- Character rendering: hybrid modular 2D skeletal animation with reusable rigs/swappable body parts, specialized poses/effects, evolution-compatible visual components, and character-specific animation when anatomy requires it.
- Combat: independent real-time simulation is authoritative; animation/effects visualize events; Combat Director controls encounters and waves; fixed-step updates and reproducible randomness where appropriate; no preselected winner, manual targeting, or manual special-ability triggers.
- Battlefield presentation: hybrid advancing side view with camera-following parallax and loose encounter battle lines.
- **User-approved visual rule (2026-10-24):** characters should appear grounded by default. A character may float only when a defined ability, anatomy, equipment, or other clear in-world reason supports it; presentation and animation should communicate that reason. This is a character/presentation rule, not permission to alter combat formation or add a float mechanic to the current placeholders.
- **User-approved on 2026-10-24:** use modular encounter zones with seamless-looking transitions. Zone selection and environmental presentation remain separate from authoritative combat state. Specific zone names, art, content, and wave boundaries are not approved by this decision.
- Roster names: BULWARK, BREAKER, CIPHER, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, GLITCH. Prototype focus: BREAKER, Tier I.
- **User-approved on 2026-10-25 — 1.0 Windows release target:** direct-download Windows installer, x86_64 only; Windows 11 is the supported OS family. Presentation target: 16:9, minimum viewport 1280×720 with scalable window sizing. Mobile is outside the 1.0 release scope. Minimum hardware, the exact supported Windows 11 build, additional supported resolution/aspect-ratio combinations, and the build/update procedure remain open. Hardware testing should cover low-end, typical, and high-end Windows 11 x86_64 devices before setting the minimum. Approval source: docs/LOCAL_SESSION_DECISIONS_2026-10-25.md.
- **Historical user-approved scope, 2026-10-24 — superseded for visual completeness on 2026-10-26:** all twelve founding recruits are playable and can use evolution progression in 1.0, with Tier I production art targeted for each; BREAKER was first for four-tier art and the other eleven were deferred to post-1.0. The 2026-10-26 owner decision now requires distinct visible art changes at every evolution step for all twelve in 1.0 (see “Evolution art scope” above). The hybrid milestone-plus-material evolution gate remains approved; exact release balance remains open. No paid purchase or gacha is added.
- District ranges: Undercity 1–25; Neon Row 26–50; Black Grid 51–75; Enforcement Zone 76–100; The Spire 101–125; procedural endless progression afterward.

## Proposals and provisional choices

- **Approved architecture; provisional sample only:** modular encounter zones with seamless-looking transitions. The wave-13 prototype boundary exists only to exercise the presentation system; it does not approve a named location split or production pacing.
- **Prototype architecture remains provisional:** versioned local save schema with separate permanent/run/settings sections. The local save protection/recovery policy is user-approved as recorded above; production compatibility scope, supported historical source versions, and durability requirements remain unimplemented and open.
- **Provisional implementation detail:** scalable UI and data-driven character/enemy/wave definitions.
- **Provisional offline payout rate for feasibility testing:** `data/progression/progression_prototype_profile.json` configures one ordinary holding-wave reward per hour; this implements the user's recommended trial and does not settle release balance.
- **Research framework only:** `data/progression/research_catalog.json` lists the four approved branches with empty node arrays. Node details and gameplay effects await explicit design values.
- **Provisional prototype presentation:** six combat slots are active; until canonical member data/art is available, slots 2–6 use generic placeholder actors with sample stats, individually tuned internal movement speeds, combat styles, and staggered depth positions. Slots 2 and 3 currently exercise ranged stand-off behavior; slots 4–6 exercise melee contact behavior. These assignments do not define the characters or implement player-defined formation preferences. Movement speeds and engagement distances are not exposed as player controls or save/settings values.
- **Prototype-only placeholders:** BREAKER combat numbers, enemy numbers (including the current 1.6 attack-damage increase per wave), attack timing, and credit costs/rewards are tunable stand-ins, not approved balance or full character canon. Code-drawn shapes are not production art, transparent sprite parts, or a completed animation rig.

## Unresolved contradictions or missing evidence

- The offline Notion reconstruction remains an imperfect copy, so use live canonical sources when available. The BREAKER arm-boundary question is resolved by the explicit user approval recorded below and in the Decision Log; older notes describing it as open are historical only.
- The concept sheet `03_breaker_evolution_reference.png` visibly includes gacha recruitment UI, which conflicts with the approved no-gacha design. Treat that panel as rejected concept material; do not implement it.
- Concept-sheet filenames and visible contents do not fully match: `01_world_roster_concept_sheet.png` is largely BREAKER production/evolution content, while `03_breaker_evolution_reference.png` includes roster/gameplay UI. Use filenames only as inventory identifiers, not as proof of approved content.
- Character-stage labels differ among sources: approved global tiers are Origin Form, Adapted Form, Signature Form, Requiem Form; the reconstructed BREAKER page and concept sheets use other stage labels. Keep the approved global tier names; whether the alternate labels are character-specific subtitles remains unresolved.
- **User-approved on 2026-10-24:** evolution uses a hybrid gate of permanent progression milestones plus earned materials. Prototype feasibility thresholds/costs are approved in the decision above; release balance, material naming/acquisition tuning, and tier effects remain undecided.
- **Still open:** whether prototype-tested Influence/material reward and evolution milestone/cost values are suitable for release; tier stat/trait effects and production visuals; and canonical named-boss roster/placement. Reboot reset/high-water semantics, outgoing-damage-only bonus scope, first-clear material scope, and permanent first-clear evolution milestone behavior are approved for prototype testing.
- Save architecture remains provisional, not approved, despite its use as a reversible prototype default. The approved 1.0 release target is a direct-download Windows installer for x86_64 on Windows 11, with a scalable 16:9 presentation and minimum 1280×720 viewport. Minimum hardware, exact Windows 11 build, wider display-support matrix, and build/update procedure remain open; see docs/LOCAL_SESSION_DECISIONS_2026-10-25.md.
- The offline Notion reconstruction may omit later decisions; current live Notion pages were read on 2026-10-24 and text-only status updates were published/read back on five pages. Modular encounter zones are directly approved in this conversation. Drive asset reconciliation remains outstanding.
- **Resolved BREAKER Tier I arm boundary (user-approved 2026-10-25):** retain an external shoulder shell over a biological right upper arm; the mechanical prosthesis begins at the elbow and includes the forearm/fist. This reconciles the approved profile silhouette with the written Tier I description. Earlier “open arm reconciliation” notes below are historical and superseded by this explicit choice. Candidate 09 v2 tests visible layer ownership against this rule; it does not make the art production-ready.

## Provenance

Sources: user-provided migration brief; user's 2026-10-24 direction on ranged stand-off and melee contact; `migration_package/notion_reconstruction/01_Game_Design.md`; `migration_package/notion_reconstruction/03_Breaker.md`; `migration_package/notion_reconstruction/07_Decision_Log.md`; `migration_package/docs/DECISION_STATUS.md`; and `migration_package/drive_assets/Breaker_Tier1_Godot_Production_Spec.md`. The package is dated 2026-10-24. Canonical source links and access limits are recorded in `MIGRATION_REPORT.md`.

## User-approved BREAKER Tier I profile reference — 2026-10-24

The user approved `BREAKER_T1_profile_rebuild_candidate_01.png` as the Tier I visual direction. This approval supersedes the previous local audit label that rejected its appearance. Keep the image as the current visual target for the modular art pass. Its visible background still needs removal and no parts have been extracted or rig-tested, so approval is for appearance only, not production readiness or runtime integration.

## BREAKER source recheck — 2026-10-25 UTC — HISTORICAL, SUPERSEDED

A live Notion search at this time found no explicit arm-extent approval. The user later resolved it directly in this conversation; see the approved decision below.


## BREAKER Tier I visual boundary evidence recheck — 2026-10-25 UTC — HISTORICAL, SUPERSEDED

Live Notion re-fetch confirmed the written Tier I forearm/fist language and profile imagery. At that time the explicit choice had not yet been recorded; the user subsequently approved the external-shell / biological-upper-arm / elbow-start-prosthesis interpretation below.


## Approved BREAKER Tier I shoulder/arm interpretation — 2026-10-25 UTC

- **Approved:** Keep the visible shoulder piece as external armor over a biological human upper arm. The right mechanical prosthesis begins at the elbow and includes the forearm/fist.
- **Approval source:** The user selected “External shoulder shell over human upper arm; prosthesis starts at elbow” in response to the explicit arm-boundary choice.
- **Rationale:** Preserves the previously approved profile's shoulder-shell silhouette while honoring the written Tier I requirement for a mostly human figure and mechanical right forearm/fist.
- **Scope:** This resolves the Tier I cyberware boundary only. It does not approve candidate 05 or 09 as final production art, prove concealed anatomy, or change the production-art acceptance gate.
- **Validation state (updated 2026-10-25):** candidate 09 v4 assigns visible bicep pixels to a biological layer and separates a provisional shoulder-shell layer while preserving the thresholded neutral composite; the canon ROI contains 5,796 classified skin pixels on the biological layer and zero on the shell/forearm. A v5 generated underpaint study adds a continuous skin-colored surface beneath the unchanged source shell, but it is inferred and awaiting visual proportion review. Hidden anatomy is still not canonically authored or production-verified; all draft layers remain quarantined.

## BREAKER arm evidence update — 2026-10-25 UTC

Following the user's approval of the external shoulder-shell / biological upper-arm / elbow-start prosthesis boundary, v4 visible ownership and v5 inferred-underpaint audits pass their scoped checks. A new 2D mask audit confirms the inferred and visible biological surface forms a 27,550-pixel largest 8-connected region and both substantial visible skin regions join it. Godot 4.7.2 passes the focused v4/v5 registration tests and full prototype suite. These checks do not validate anatomy accuracy, independent shell fit, authored pivots, or deformation. The v5 donor remains quarantined; production art is not approved.

## BREAKER hidden-anatomy fit trials — 2026-10-25 UTC

The arm boundary decision is unchanged. v6–v9 add no canon: Python confirms source-visible fidelity and connected masks; scoped Godot registration also passes for v9. Visual comparison still rejects the hidden donor fit. Keep the flattened candidate 09 as the approved visible reference, keep all hidden-surface trials quarantined, and leave production art/rig not passed.

## Live canon recheck — 2026-10-25 UTC

Fetched the live BREAKER Character & Sprite Specification (edited/read `2026-10-25T09:55:56.561Z`) and Decision Log (`2026-10-25T08:38:04.547Z`). The current Notion spec confirms the user-approved boundary—external shoulder shell over biological upper arm; prosthesis begins at elbow—and repeats that hidden anatomy, pivots, production parts, and animation seams remain unverified. No newer hidden-arm contour or proportion approval was found. This recheck does not approve any local v7/v10/v11 art study. No remote write was made.

## Live Notion milestone readback — 2026-10-25 UTC

The user-approved arm-boundary decision is unchanged. Text-only v20 status was appended to the live BREAKER Character & Sprite Specification, Asset Library & Artwork Manifest, and Production Roadmap. Readback confirmed the new content at BREAKER Specification `2026-10-25T12:15:27.563Z`, Asset Library `2026-10-25T12:15:36.798Z`, and Roadmap `2026-10-25T12:15:45.519Z`. No decision-log update was needed because the boundary already matches the user choice; no new design decision was recorded. Google Drive file tools are not exposed in this session, so no binary upload or backup is claimed.

## Local session decision record — 1.0 planning — 2026-10-25 America/Chicago

The current conversation approved additional 1.0 scope and a playtest plan. Full details are in `docs/LOCAL_SESSION_DECISIONS_2026-10-25.md`. The matching sections were appended to the live Notion Decision Log, Game Design & Progression, Founding Recruit Roster, and Production Roadmap pages; readback confirmed all four updates. GitHub was not accessed. Numeric combat, economy, evolution, and Reboot settings recorded there remain trial values, not release balance or canon.

## Automatic ability and formation source reconciliation — 2026-10-26 UTC

Live-source reconciliation established the automatic ability policy and squad preference contract. At the time of that source audit, no character ability had a complete canonical trigger/effect/cooldown/target contract; roster labels remained summaries. D-04 now supplies separate owner-delegated provisional playtest defaults in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md`. These do not settle canon meanings for “priority,” “strongest,” or “frontline,” or resolve ECHO's device/art mapping. The source audit and its unverified fetch provenance remain at docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md.

Sources fetched read-only on 2026-10-26 UTC: Game Design & Progression (https://app.notion.com/p/40394c5658c88159962fee5423c311de), Decision Log & Change Control (https://app.notion.com/p/40394c5658c88127b755c01197ff628d), and Founding Recruit Roster (https://app.notion.com/p/40394c5658c8812d849be3d32629920e). Fetch metadata reports verification.state: unverified. Historical “formation still undecided” statements are superseded by the later preference contract; movement parameters remain open.

## I-05 hybrid combat outcomes — semantic selections recorded — 2026-10-26

The owner selected a likelihood-based hybrid outcome: squad power influences the encounter outcome without guaranteeing a win. The first trial score uses current HP, maximum HP, attack power, and attack interval; movement, style, range, and formation are logged as telemetry. The score is sampled at each committed attack. The bounded-monotonic mapping applies the same relative-power rule to allied and enemy attacks. Use an encounter-local seeded Godot `RandomNumberGenerator` for reproducible playtests, consuming draws in deterministic action order. Resolve fixed-step actions before checking timers; reset the no-progress timer on HP/defeat changes and qualifying ability/status effects; if both timers expire on the same step, report maximum timeout as primary and no-progress as also expired.

Under the owner's standing authorization to select supported Recommended options, timer expiry is now recorded as defeat for either the maximum-encounter timer or the no-progress timer. Apply the approved defeat flow: retreat automatically to the highest-cleared holding wave, restore the squad on holding-wave re-entry, show the one-time stalemate cinematic on arrival, and after one holding-wave clear automatically retry the next uncleared wave. The terminal-outcome selection is an owner-delegated manager selection; the earlier direct thread replies specified timer reset/order/logging but did not themselves select the terminal outcome.

This closes policy-level semantics only. A bounded first runtime experiment is implemented in `scripts/combat/combat_director.gd` behind the provisional `data/combat/hybrid_combat_trial.json` profile; `direct_damage` remains the default control. Test Lane focused/full verification passed per `docs/IMPLEMENTATION_STATUS.md`. Formula coefficients, bounds, seed pattern, and timer values remain trial inputs, not approved balance or canon. Cross-engine RNG replay and individual defense/ability/synergy mechanics remain open. D-04 now defines the owner-delegated playtest ability/status changes that can use the qualifying-progress hook.

## Launch district and boss scope — live-source reconciliation — 2026-10-26 UTC

The source-approved launch bands are Undercity 1–25, Neon Row 26–50, Black Grid 51–75, Enforcement Zone 76–100, and The Spire 101–125, with endless progression from 126. The 1.0 visual plan specifies two modules per district with a transition on district-local wave 13; module descriptions do not approve location names or art. One named boss per district is approved, with the district endpoint as a trial placement baseline. Five approved names are Patchwork (replacing Nacre), Ghostlight, Chainbreak, Civic Warden, and Sable Venn; no boss-to-district assignment or combat definition is source-complete. Scope-only data is in data/world/district_scope.json; it does not drive runtime. Keep the current Undercity palette fixture and its boundary explicitly provisional.

The source guarantees that a named boss is recruitable on first defeat and that a recruited identity is removed from the enemy generator. **Owner decision, 2026-10-26:** first defeat immediately grants permanent ownership and immediately excludes that unique identity from enemy generation. Apply the existing roster rules: fill the first open active slot; when all six are occupied, place the recruit in reserve; if acquired during combat, deploy at the next encounter. This closes the separate claim-action and pending-unclaimed replay branches. District mapping, encounter records, spawn/cadence, boss-specific rewards, and art remain open; no runtime behavior is implemented by this record.

## Endless progression boundary and unresolved rules — source-backed — 2026-10-25 America/Chicago

Procedural endless progression begins after the five approved district bands, at wave 126. The design also approves endless procedural waves and highest-cleared holding-wave retreat. This approves the start boundary and high-level direction only. Enemy scaling/generator rules, boss cadence, reward and milestone formulas, high-wave numeric bounds, and save expansion/migration remain unspecified. The runtime and version-1 save validator therefore retain their 125 prototype cap. See `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md`; no mechanics or values were added by this audit.

## Spatial movement follow-up — partial user approval — 2026-10-26

When a preferred band conflicts with a role's attack-start distance, a recruit may temporarily leave the band to enter attack range, then regroup. Regrouping finishes the current attack or ability before moving. Actors route around authored obstacles and wait if no route exists. Latest follow-up: one shared fixed boundary shape applies to all encounters; compress ordered spacing first, then temporarily relax the preferred band if needed; after a target change, regroup only when enemies pose no threat; defeated recruits stop moving. All recruit bodies remain grounded. SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane; this is not presentation-only hover. Exact contact/ranged thresholds, offsets, and boundary dimensions/coordinates will be tuned after layout testing. Overlap/passing, operational no-threat condition, air-lane geometry/transitions/collision/targeting/attack interactions, activation timing, and ECHO drone/decoy mapping remain open. No other recruit/attachment has an approved air-lane exception. This remains a partial contract; no spatial runtime behavior is approved until the remaining choices are resolved.

The chosen post-layout-testing tuning sequence does not authorize a layout-test scaffold or specify its scope. That prerequisite remains unresolved and must be approved before creating/running the scaffold or deriving spatial rules from it.

## Ability implementation sequencing — scope B selected; D-04 trial contracts now complete — 2026-10-26

The user selected defining all twelve signature-ability contracts before implementing any skill. The later owner-delegated D-04 defaults in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` complete the simulation contract set for provisional playtesting; they remain explicitly non-canon. Runtime behavior is still unimplemented and focused tests remain. ECHO's abstract decoy simulation is ready, while device/art mapping and air-lane presentation remain gated on Character/source evidence. The automatic activation/target policy remains; no manual triggers or target overrides are added.
