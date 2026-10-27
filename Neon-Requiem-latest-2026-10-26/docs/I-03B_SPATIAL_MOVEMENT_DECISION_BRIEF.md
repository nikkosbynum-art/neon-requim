# I-03b — Spatial movement choices for review

## Owner-selected follow-up — 2026-10-26 America/Chicago

Neighbor overlap is permitted only while recruit silhouettes remain legible, the UI remains unobscured, and collision/pathing stays usable. Passing behavior remains unresolved. The operational no-threat predicate, air-lane geometry, and visible ECHO device/decoy mapping remain open. No layout-test scaffold or spatial runtime work is authorized by this selection.

**Status:** Partially approved. Later I-03c manager-selected provisional rules resolve passing and the no-threat predicate and permit a narrowly scoped disposable geometry-only harness; they do not authorize spatial runtime behavior. The harness has not been created or run.  
**Source:** `docs/I-03A_SPATIAL_FORMATION_EVIDENCE_AUDIT.md`, live Notion readbacks retrieved 2026-10-26 (fetch metadata says `verification.state=unverified`), and user-approved decisions recorded locally.  
**Scope:** Spatial movement only. Current selector persistence stays as implemented; no runtime or test files changed.

**I-03c update:** Later manager-selected provisional recommendations under the user's prior authorization resolve the passing and no-threat questions below and provisionally permit a narrowly scoped disposable geometry-only harness. See `docs/DESIGN_DECISIONS.md`, `docs/OPEN_QUESTIONS.md`, and `docs/IMPLEMENTATION_STATUS.md`. This does not change owner-selected rules or claim canonical reconciliation. Numeric layout values and ECHO/source gates remain open; the harness has not been created or run.

## Rules already approved

- Combat remains automatic. No manual targeting or player-triggered abilities.
- Front/Middle/Rear are optional soft bands; a selected band guides placement except that role attack-start distance may temporarily move a recruit outside it until the recruit enters attack range, after which it regroups. The role guides movement within a selected band and by itself when no band is selected. Band membership has no recruit limit.
- Preferences are set outside combat and persist per recruit through System Reboot. Their current implementation stores preferences only.
- Ranged units hold their configured engagement distance; melee units close to contact distance. Walking speed stays an internal setting.
- **User-approved air-lane direction (supersedes both the earlier body-lane and presentation-hover choices):** all recruit bodies remain grounded. SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane; this is spatial, not presentation-only hover. No other recruit or attachment has an approved exception. Exact lane geometry and behavior remain open. ECHO's drone/decoy mapping is unresolved, so do not assume which ECHO devices use the lane.
- Preferences do not change targeting under the approved selector-only scope. Any future spatial implementation must preserve automatic combat unless the user explicitly changes that policy.
- **User-approved geometry:** depth is fixed to the battlefield and bands stay fixed as combat advances; distance is enemy-relative. **Working interpretation:** evaluate distance against the enemy's current position as it moves; no contrary source/user wording was found. Exact contact/ranged thresholds are deferred until after layout testing.
- **User-approved tuning sequence:** tune exact contact/ranged thresholds and same-band offsets later, after layout testing. No numeric thresholds or offsets are selected now.
- **User-approved same-band direction:** ordered positions, using founding-roster order as the working stable order. If ordered positions do not fit the preferred band, compress spacing first, then temporarily relax the band if needed. Exact offsets are deferred until after layout testing; overlap and passing rules remain open.
- **User-approved collision/pathing direction:** use local avoidance while preserving the preferred band; route around authored obstacles and wait if no route exists; use one shared fixed battlefield-boundary shape for all encounters. Exact boundary dimensions/coordinates are deferred until layout testing; behavior around obstacle types not covered by “authored obstacles,” and overlap/passing rules remain open.
- **User-approved cohesion and defeat direction:** regroup after target changes only when enemies pose no threat; finish the current attack or ability before regrouping. Defeated recruits stop moving. The operational meaning of “no threat” remains open.
- **User-approved role/attack-start mapping:** Vanguard/Assault are non-ranged and attack at contact; Support/Control are ranged and attack at configured ranged engagement distance when possible. The selected band affects enemy-facing vs rear/outer position as described in section 5. If role attack-start distance conflicts with the preferred band, temporarily leave the band to enter attack range, then regroup.
- **Conservative unset-role fallback:** preserve the character's existing attack-range configuration when no role is selected. This fallback remains open to contrary user instruction.

## Remaining choices and deferred tuning

The options below are neutral policy shapes for review, not source approvals. They contain no numeric tuning values.

### 1. Band geometry

**Approved:** depth is fixed to the battlefield and bands remain fixed as combat advances; distance is enemy-relative. A preferred band guides placement, but a conflicting role attack-start distance may temporarily move a recruit outside the band until it enters attack range; the recruit then regroups.  
**Approved:** exact contact/ranged threshold tuning is deferred until after layout testing. No numeric value is selected now.  
**Unspecified:** the enemy-current-position interpretation is a working interpretation, not a separately approved measurement threshold; exact values must be tuned after layout testing.  
**Choice:** no range value is requested now; tune after layout tests using the approved boundary and role rules.

### 2. Spacing and occupancy

**Approved:** any number of recruits may prefer the same band; only six can be active at once. Members receive ordered positions, using founding-roster order as the working stable order. Readability and usable collision are constraints; whether units may overlap or pass one another remains unselected.  
**Approved:** same-band ordering uses founding-roster order; exact offsets are deferred until after layout testing.  
**Approved constrained-fit order:** compress same-band spacing first, then temporarily relax the preferred band if positions still do not fit.
**Unspecified:** overlap behavior beyond the existing legibility/UI/collision constraint, plus exact offsets (deferred until after layout testing).
**Manager-selected provisional:** temporary passing only when required to route around an authored obstacle or satisfy the approved attack-range override; preserve founding-roster order as the preferred destination order.
**Choice:** exact offset values remain deferred until after layout testing.

### 3. Collision and pathing

**Approved:** local avoidance while preserving the preferred band; no player-controlled movement and automatic simulation remains authoritative.  
**Approved:** route around authored obstacles; wait if no route exists.  
**Approved:** use one shared fixed battlefield-boundary shape for all encounters.  
**Deferred to layout testing:** exact boundary dimensions and coordinates; no values are selected now.  
**Approved constrained-fit behavior:** compress spacing, then temporarily relax the preferred band if necessary.
**Unspecified:** behavior around obstacle types not covered by “authored obstacles,” and overlap/passing behavior.

### 4. Cohesion and regrouping

**Approved:** after a target change, regroup only when enemies pose no threat; finish the current attack or ability before regrouping. Defeated recruits stop moving.
**Manager-selected provisional:** after a target change, regroup only when no living enemy currently targets the recruit and no already-committed enemy attack/effect against them remains unresolved. Use authoritative simulation state, not a new distance threshold or presentation proxy.

### 5. Role movement

**Approved:** Vanguard/Assault are non-ranged/contact-start roles: favor the enemy-facing side within a selected band, close to melee contact and attack at contact without a band. Support/Control are ranged-start roles: favor the rear/outer side within a selected band and attack at configured ranged engagement distance when possible; without a band, hold and attack there. If role attack-start distance conflicts with the preferred band, temporarily leave the band to enter attack range, then regroup. If no role is selected, the conservative fallback is the character's existing attack-range configuration, pending contrary instruction.  
**Approved:** tune exact contact/ranged attack thresholds after layout testing; no numeric value is selected now.  
**Unspecified:** exact locations and preference strength within a band.

| Role | Within a selected band | With no band | Attack start |
|---|---|---|---|
| Vanguard | Favor the band's enemy-facing side | Close to melee contact | Contact |
| Assault | Favor the band's enemy-facing side | Close to melee contact | Contact |
| Support | Favor the band's rear/outer side; maintain ranged engagement when possible | Hold configured ranged engagement distance | Configured ranged engagement distance when possible |
| Control | Favor the band's rear/outer side; maintain ranged engagement when possible | Hold configured ranged engagement distance | Configured ranged engagement distance when possible |

If no role is selected, preserving the character's existing attack-range configuration is the conservative fallback, pending contrary user instruction.

### 6. Remaining movement edges and thresholds

**Approved:** the preferred band guides placement, except that a conflicting role attack-start distance may temporarily move the recruit outside it until attack range is reached, then the recruit regroups. Finish the current attack or ability before regrouping. Vanguard/Assault attack at contact; Support/Control attack at configured ranged engagement when possible; target/ability automation remains authoritative. Route around authored obstacles; wait if no route exists.  
**Approved:** the role-range exception and current-action completion rule are settled; fixed battlefield boundaries are selected. Attack thresholds are deferred until after layout testing.  
**Deferred to layout testing:** exact boundary dimensions and coordinates.  
**Unspecified:** defeat handling and the exact safe-state condition for regrouping. Keep preference choices out of target selection.

### 7. Grounding and air-lane exception

**Approved direction:** all recruit bodies remain grounded. SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane. This supersedes earlier choices that assigned the lane to bodies or treated attachment hover as presentation-only. No other recruit or attachment receives an approved air-lane exception.  
**Unspecified:** ECHO's drone/decoy mapping; lane geometry, movement and transitions; collision/pathing and obstacle behavior; interaction with fixed depth bands; targeting and attack geometry; and activation timing. Do not infer missing rules from concept art or roster labels.

| Recruit | Spatial disposition | Notes |
|---|---|---|
| BULWARK | Grounded | No air-lane exception selected |
| BREAKER | Grounded | No air-lane exception selected |
| CIPHER | Grounded | No air-lane exception selected |
| SPARK | Body grounded; three roster-listed attack-drone attachments use a separate spatial height/air lane | Drone count is roster-backed; lane geometry, activation, collision and combat interactions unresolved |
| SPECTER | Grounded | No air-lane exception selected |
| IRONCLAD | Grounded | No air-lane exception selected |
| STITCH | Grounded | No air-lane exception selected |
| RECOIL | Grounded | No air-lane exception selected |
| ECHO | Body grounded; decoy attachments use a separate spatial height/air lane | Decoy/device mapping unresolved; lane geometry, activation, collision and combat interactions unresolved |
| VECTOR | Grounded | No air-lane exception selected |
| DEADLOCK | Grounded | No air-lane exception selected |
| GLITCH | Grounded | No air-lane exception selected |

This table records only the approved attachment spatial exception. It does not define attachment animation, targeting, attack reach, vulnerability, collision, or ability timing. ECHO's roster separately mentions remote drones as sensory extensions and a decoy skill; it does not resolve whether those are the same attachments or specify their count.

**User-approved direction (2026-10-26):** SPARK drone attachments and ECHO decoy attachments use a separate spatial height/air lane; all recruit bodies remain grounded. This is spatial, not presentation-only hover. No other recruit or attachment exception is selected. This direction is not a complete movement/combat contract: ECHO device mapping, exact lane height/bounds, transitions, collision/pathing, relation to fixed depth bands, targeting/attack geometry, and activation timing remain unresolved. Do not infer that the lane has no targeting/combat-position effect; those interactions have not been defined. Do not implement until the spatial contract is complete.

## Dependencies and smallest coherent answer

The geometry axes, same-band ordering direction, compress-then-relax fit rule, role-range exception, finish-current-action regroup rule, defeated-stop rule, authored-obstacle route/wait rule, one shared fixed-boundary shape, and attachment-only spatial air-lane direction are owner-selected. All bodies remain grounded; SPARK drones and ECHO decoys use the separate lane. The enemy-current-position measurement remains a working interpretation. Exact contact/ranged thresholds, offsets, and boundary dimensions/coordinates are intentionally deferred until layout testing; no values are selected now. Manager-selected provisional I-03c rules allow temporary passing only for authored-obstacle routing or the approved attack-range override while preserving founding-roster destination order, and define no-threat as no living enemy target plus no unresolved committed enemy attack/effect against the recruit. The manager also provisionally permits the bounded geometry-only harness described below. Air-lane geometry/transitions/collision/targeting interactions, attachment activation timing, and ECHO drone/decoy mapping remain open.

The remaining source/owner-input list is: **(1)** overlap behavior beyond the approved legibility/UI/collision constraint; **(2)** air-lane geometry, transitions, collision/pathing, relation to bands, and targeting/attack interactions; **(3)** attachment activation timing; and **(4)** ECHO's unresolved drone-versus-decoy mapping (coordinate with I-04/source review). The shared boundary shape applies to all encounters; its dimensions/coordinates and exact contact/ranged thresholds and offsets are explicitly deferred until after layout testing. The I-03c manager selections remain provisional and do not reopen the approved grounded-body/attachment-lane rule, compress-then-relax fit rule, defeated-stop rule, role-range exception, current-action completion rule, or authored-obstacle route/wait rule.

**Layout-test harness boundary — manager-selected provisional permission:** permit a disposable geometry-only harness limited to representative positions, bands, authored obstacles, and the shared fixed boundary. Keep it isolated from production scenes and combat simulation; it must not evaluate targeting, attacks, threat, balance, ECHO mapping, or numeric thresholds. The harness has not been created or run. Layout evidence may inform only the explicitly deferred thresholds, offsets, and boundary dimensions/coordinates; it cannot silently resolve other design gates.

## Implementation boundary

Until these choices are approved, keep `formation_preferences` as selector data/persistence only. Do not wire it into `CombatDirector`, retune placeholder offsets/depth/speeds, or change targeting. Current implementation behavior and source references are documented in `docs/I-03A_SPATIAL_FORMATION_EVIDENCE_AUDIT.md`.
