# Open questions

## Netrunner Requiem Form concept review — visual direction approved — 2026-10-26

The official form names remain Origin Form → Adapted Form → Signature Form → Requiem Form. Older Street/Combat/Military/Apex board labels map to the four forms by order only. The netrunner-family digital visual direction is confirmed for CIPHER, ECHO, and GLITCH with distinct expressions. The revised CIPHER four-form board (precision-optic/data geometry, scan motif, HUD-to-eye progression, magenta/cyan Requiem breakup) is approved for visual direction only; it remains quarantined outside the project. No mechanics, targeting, production, rig, runtime, or integration approval is included; see `docs/NETRUNNER_APEX_VISUAL_DIRECTION_REVIEW_2026-10-26.md`.

## Owner-selected follow-up status — 2026-10-26 America/Chicago

- **I-03 overlap:** neighbor overlap may be used only while silhouettes remain legible, UI remains unobscured, and collision/pathing stays usable. Manager-selected provisional rules now allow temporary passing only for authored-obstacle routing or the approved attack-range override while preserving founding-roster destination order; define no-threat as no living enemy target and no unresolved committed enemy attack/effect against the recruit. A disposable geometry-only harness is provisionally permitted only for representative positions, bands, authored obstacles, and the shared fixed boundary, isolated from production/combat simulation and excluding targeting, attacks, threat evaluation, balance, ECHO mapping, and numeric thresholds. These manager selections are local and provisional; no harness exists or was run. Spatial implementation, numeric layout values, and ECHO/air-lane gates remain open.
- **I-06 scope:** functional level purchase/stat growth remains BREAKER-only until individualized combat/economy evidence supports expansion. All-twelve recruitment and evolution records remain. Final stats, costs, curves, and caps remain open.
- **I-09 scope:** wave 126 remains the design-approved endless start; runtime/save ceiling remains 125. Scaling, generator/pool/composition, boss cadence, endless rewards/milestones, and above-125 offline reward inputs are deferred pending a complete profile and compatible save policy. Keep the existing credit-only, saved-holding-wave, claim-save, no-wave-advance, eight-hour target; provisional Undercity data is not an extrapolation basis.
- **Character direction:** BULWARK evolution concept is medic-specific armor, medical-pack, and diagnostic-bracer progression, preserving connected hose logic and approved helmet-cross treatment. Concept-only; mechanics, production art, and rig readiness are not approved.

## Accessibility follow-ups — partial scope approved — 2026-10-26

The owner-approved scope remains keyboard/mouse for 1.0 (controller deferred), continuous text-only scaling, and master volume plus mute. A separate manager-selected provisional follow-up, made under the user's prior authorization and pending canonical reconciliation, sets text scaling to 100–150% (default 100%), master volume to 0–100% (default 100%) with separate mute, the keyboard/focus behavior below, redundant non-color cues for color-communicated interactive/gameplay-critical states, and captions for gameplay-critical non-speech SFX only. D-01 is provisionally scoped to gameplay-clarity SFX only; original soundtrack and in-engine outcome sequences are deferred. These are local-only recommendations, not a claim of canonical confirmation.

Implementation prerequisites remain: build a shared text-scaling helper and review layouts; add persisted mute state with load/default handling; verify Tab / Shift+Tab visual-order traversal, Enter / Space activation, Escape close/cancel behavior, arrow operation for options/sliders, dialog boundaries, and focus restoration; inventory color-communicated states and define their non-color indicators; inventory gameplay-critical SFX and define caption labels. No cue content, speech, soundtrack, or outcome sequence is selected. No UI/input/audio/save implementation or validation is implied by these provisional selections. See `docs/DESIGN_DECISIONS.md` and `docs/REMOTE_SYNC_QUEUE.md`.

The manager has selected a provisional missing-field default under the user's prior authorization: `muted = false` for new profiles and saves without a mute field, retaining `master_volume = 1.0`. This avoids silent muting but allows audio to play until muted. It remains local-only pending canonical reconciliation; no implementation or validation is claimed.

## Squad preferences — implementation scope approved; spatial rules remain open

Implement optional per-recruit band/role selectors and persistence through Reboot only. Preference values do not yet affect movement or targeting. See `docs/DESIGN_DECISIONS.md`.

The user has approved these spatial directions: fixed battlefield depth bands with one shared fixed boundary shape; enemy-relative distance; founding-roster order within bands; local avoidance; role/contact/ranged mapping; temporary departure from a preferred band to enter role attack range then regroup; finishing the current attack or ability before regrouping; authored-obstacle routing with waiting if no route exists; compressing ordered spacing before temporarily relaxing a band when positions do not fit; regrouping after target changes only when enemies pose no threat; defeated recruits stop moving; and a separate spatial height/air lane for SPARK drone attachments and ECHO decoy attachments. All recruit bodies remain grounded. This attachment lane changes spatial placement and is not presentation-only hover. **Working interpretation:** evaluate enemy-relative distance against the enemy's current position as it moves; preserve the character's existing attack range when no role is selected as a conservative fallback. **User-selected tuning sequence:** tune exact contact/ranged thresholds, same-band offsets, and boundary dimensions/coordinates after layout testing; no values are selected now. The manager provisionally permits a narrow disposable geometry-only harness, as scoped above; it has not been created or run. The provisional passing and no-threat rules are recorded above. Remaining choices are air-lane geometry/transitions/collision/pathing/band interaction/targeting and attack effects, attachment activation timing, and ECHO's drone-versus-decoy mapping. No other recruit/attachment has an approved air-lane exception. Walking speeds remain internal. No spatial runtime changes are authorized until the remaining contract gates are approved; the geometry-only harness permission does not approve combat behavior. See `docs/I-03B_SPATIAL_MOVEMENT_DECISION_BRIEF.md` and `docs/I-03A_SPATIAL_FORMATION_EVIDENCE_AUDIT.md`.

## Active recruit roster — decisions approved; implementation validation pending

The user approved auto-fill into the first open slot, reserve when all six are full, vacant slots when fewer than six recruits are owned, between-encounter lineup swaps only, and lineup persistence through System Reboot. Only owned/deployed recruits fight; generic actors remain prototype fixtures. HP follows recruit identity through swaps; benching does not heal a recruit; Reboot heals all owned recruits, including reserves. The existing retreat recovery rule still heals the deployed squad on holding-wave re-entry. For v1 migration, map the source-defined BREAKER slot to BREAKER, preserve the five placeholder HP values as legacy data, and initialize other owned recruits at full HP. Use copy/validate/rollback. **Resolved:** the user superseded the earlier starter-priority default: new/migrated profiles without a saved lineup auto-fill up to six currently owned recruits in stable founding-roster order. Slots remain vacant only when fewer than six are owned; excess owned recruits stay in reserve. Purchases during combat take effect at the next encounter if a slot is open; otherwise the recruit remains in reserve. These rules are locally implemented, with Test Lane validation pending. See `docs/DESIGN_DECISIONS.md`.

## Historical save versions supported for migration — implementation scope open

**Status update, 2026-10-26:** version 1 is now explicitly supported through a copy/validate/rollback migration to version 2 for the known current v1 shape. Other historical/unknown schema versions remain unsupported and protected. Focused validation is pending; do not infer successful migration from the implementation alone.

The local save-protection policy is approved in `docs/DESIGN_DECISIONS.md`: newer or unknown schemas are read-only, and older saves may migrate only through explicitly supported copy-based migrations with validation and rollback. The current writer schema is version 2; version 1 is supported only for its known current shape and approved roster HP mapping. Other historical versions remain unsupported and may only be replaced through the explicitly confirmed Reset Save flow. The confirmed-reset path stages content-hash-verified quarantine copies for unsupported or invalid `.bak` and `.bak.prev` sidecars before committing a fresh primary. The focused Python and Godot 4.7.2 save-protection regression runs passed; this does not replace Test Lane's broader migration/release validation.

## Research node definitions — deferred until combat/economy playtests

**Approved and source-backed:** the branches are Combat Protocols, Underground Economy, Network Infrastructure, and Personnel Development. Purchases spend spendable Network Influence; purchased research and both Influence balances persist across System Reboot. Combat remains automatic, with no manual ability triggers, target overrides, or per-target commands. The user selected **defer node definitions until combat/economy playtests**; keep all four catalog node arrays empty and the Research UI read-only until complete entries receive explicit approval.

For each future entry, these fields remain undefined: node ID/name/order and organization; one-time versus repeatable rank model and cap; complete effect/target/trigger/value/timing contract; spendable Influence costs and cost structure; prerequisite links and graph policy; branch/node unlock criteria; and how the effect applies to automatic combat, including purchase/effect activation timing. Reboot persistence is not an open choice: purchased research and both balances remain permanent. Any proposed run-specific recalculation must preserve purchased research.

`docs/I-10B_RESEARCH_CATALOG_DECISION_PACKET.md` provides neutral structural options and a blank per-branch worksheet. It invents no node, effect, cost, or value and is not authorization to populate the catalog. Validator schema requirements and synthetic fixtures are implementation constraints, not design approval.

## Recruit run-level cap and final cost balance — open

- **Current test setup:** BREAKER uses the user-approved trial curve `round(20 × 1.12^(level - 1))`; final costs remain subject to economy playtest data.
- **Unresolved:** the canonical recruit-level design leaves level caps open. No cap is implemented in the prototype and no cap value should be inferred from the wave ceiling.
- **Decision needed for 1.0 balance:** after economy testing, decide whether recruit run-levels have a cap and, if so, the cap value (or progression rule beyond the cap). The current prototype can continue testing without a fabricated threshold.
- **Scope note:** only BREAKER currently has a run-level purchase path; the other eleven recruit level paths remain to be implemented.

## Attachment reference reconciliation — visual review completed, design details still open — 2026-10-25 UTC

- **DEADLOCK weapon count/carry state — RESOLVED 2026-10-26:** one rifle is shown held and back-mounted in different states. This resolves identity/count only; it does not approve weapon cutout boundaries, attachment coordinates/pivots, or transition behavior. Do not duplicate weapon art or infer new attachment points.
- **GLITCH weapon identity/count — resolved as one rifle:** the held and back-mounted item is one rifle in two carry states, replacing the roster's “sidearm” label. Do not duplicate it. Semantic cutout boundaries, authored grip/stow mounts, pivots, transition behavior, and artist provenance remain open.
- **IRONCLAD weapon stow — art direction approved:** include a back-stowed weapon state. Exact mount, overlap, anchors, pivots, and transition evidence remain open; do not infer their placement from omitted rear-view art.
- **SPARK tool behavior:** The approved reference shows a wrench-like tool; the roster does not assign it a combat action. It remains presentation-only unless a source-backed behavior is approved.

Paired concept/anatomy observations for all twelve are documented in `docs/ATTACHMENT_REFERENCE_REVIEW_12.md`. These unresolved details do not block preparation for other characters or non-weapon art.

## Remaining eleven approved concept/anatomy references — production parts pending — 2026-10-25 UTC

The user approved all eleven individual concepts and their anatomy turnarounds as visual/anatomy references, including the depicted prosthetic side for RECOIL. Ten recruits now have quarantined visible-profile mesh-rig candidates (BULWARK, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, GLITCH); CIPHER has a separate quarantined cutout candidate. Ten mesh candidates now render six generic pose transforms each in Godot and have reviewed contact boards, but these are feasibility artifacts, not modular production rigs or authored animations. The references do not establish concealed anatomy or semantic part structure. Hidden/far-side anatomy, exact part boundaries, pivots, semantic cutouts, character-specific pose design, and joint seam review remain open before production-ready art can be submitted. See the current validation notes in `docs/IMPLEMENTATION_STATUS.md`.

The CIPHER single-part head/neck experiment reduced atlas ambiguity to one semantic component, but its generated alpha still contains colored haze outside the physical silhouette and does not meet the planned vertical safety margin. The image edit did not remove the haze. A clean externally authored cutout or manual alpha cleanup is needed before this part can enter a rig; production work should pause on generated part packs until that succeeds.

## Historical concept board review — superseded 2026-10-25 UTC

The contact sheet remains a historical discussion artifact. The user later approved the individual Tier I concepts as the visual references. The sheet itself should not be split or used as rig source art.

Historical statement superseded by the user's 2026-10-25 approval of all eleven anatomy turnarounds as references. These reference images are still not production art.

## Current BREAKER Tier I status — 2026-10-25 UTC

The arm-boundary canon choice is **RESOLVED**: external shoulder shell over a biological upper arm; the mechanical prosthesis starts at the elbow. Historical arm-extent questions and review notes later in this file are superseded by this decision. The latest candidate01 slim/broad shell-off fit board was visually reviewed on 2026-10-25; **both fits are rejected** for texture/cutout seams and proportions/style that do not match the approved source. A contextual cutaway study was then generated; it communicates the correct boundary but exaggerates the upper-arm mass and changes armor details, so it also fails art acceptance. The user chose to keep v20 as a quarantined review candidate instead of continuing to revise its hidden-arm shape now. This does not approve v20 as acceptable anatomy or production art. Remaining production work includes authored hidden anatomy, independent shell art, authored pivots, expressive motion, and all-frame seam review. None passes the production-art gate.

## Punch contour interpretation — 2026-10-25 UTC

The quarantined candidate 09 v4 punch capture includes a dark trailing contour below the cyber arm. A one-time source partition traced a sparse 264-pixel component (bounds `(240,553)-(279,598)`) inside `pelvis.png`; exact RGBA reconstruction passes. Four-parent trials (pelvis, torso, cyber shoulder, cyber elbow) were captured for neutral, idle, walk, and punch, but the variants are visually too similar at gameplay scale to establish a best owner. The source shape is sparse and does not by itself prove an authored cable. Preserve the original layer; do not remove, repaint, or promote the component until its meaning and rig treatment are resolved.

## Approved 1.0 scope decision — 2026-10-24

Historical 2026-10-24 scope: all twelve founding recruits are playable in 1.0 with Tier I production art targeted for each; BREAKER receives the first complete four-tier art set; higher-tier visual art for the other eleven was then deferred until after 1.0. The later 2026-10-26 owner decision below supersedes that visual-art deferral.

## Evolution art scope — 1.0 — owner-approved 2026-10-26

All twelve recruits need distinct visible art changes at every evolution step in 1.0: Origin Form, Adapted Form, Signature Form, and Requiem Form. This supersedes the earlier C-05/post-1.0 deferral for the eleven recruits besides BREAKER. The approval sets the coverage requirement only; it does not select specific tier designs. Source, identity, semantic-part, provenance, pivot, deformation, rig/animation, and production-review gates remain in force. No quarantined candidate is promoted by this scope decision.

## Access required

1. **Notion direct pages:** all eight canonical child pages and Project HQ were fetched on 2026-10-24 and saved under `Notion/Live Readbacks/`. Compare against the offline reconstructed working copies in `migration_package/notion_reconstruction/`; linked asset files still require Drive verification.
2. Can Google Drive access be enabled later to verify the remote library and current file states? Local recovered references and the inventory IDs are documented, but the remote folders were not re-read in this session.
3. Can the exact nikkosbynum-art/neon-requim repository be confirmed as the project source? In the 2026-10-26 I-13 audit, no general repository-read connector was exposed; public web returned Cache miss for the exact URL, could not access its exact API endpoint, and exact-site search returned no match. Repository identity, visibility, metadata, and files remain unverified; this does not establish absence, privacy, or emptiness. The local checkout has no .git metadata. See docs/MIGRATION_REPORT.md.
4. Earlier live review observed a full-health-per-wave run reaching wave 25 without retreat; that health rule was later superseded. Current carryover-HP regression naturally clears through wave 5, then reaches full-squad defeat and retreats to holding wave 5 after 80.2 simulated seconds. `tests/capture_retreat_recovery_qa.gd` verifies and captures the defeat and full-health holding-wave re-entry at 1280×720. Test coverage also verifies per-slot HP carryover across victories, zero-HP allies remaining defeated, per-slot run-save restoration, and compatibility with older version-1 saves that omit squad HP. The available 800×450 placeholder capture has now been reviewed; repeat small-viewport review when production art or camera/layout changes.

## Character attachment decisions resolved — scope remains limited — 2026-10-26

- **BULWARK:** the white backing behind the helmet medical cross belongs to the helmet panel, and a side-facing cross is approved in addition to the front-view cross. Require an artist-authored side-view version; do not paste/reuse the front crop. Exact pixel boundary, side placement, backing split, pivot, and production readiness remain open.
- **CIPHER:** the held concept rifle and vertical side-view item are the same prop in different carry states. The existing isolated cutout remains unverified against the approved source; cutout boundaries, grip/stow attachment points, pivots, and transition behavior remain open.
- **DEADLOCK:** one rifle is depicted held and back-mounted in different states. Authored grip/stow anchors and transition behavior remain open.
- **GLITCH:** the held and back-mounted prop is one rifle in two carry states, replacing the roster's “sidearm” label. Semantic boundaries, grip/stow mounts, pivots, transitions, and provenance remain open.
- **ECHO:** Signal Cascade decoys are distinct from physical sensory devices. Do not map/count depicted spheres as decoys; count, view identity, and attachment mapping remain open.
- **IRONCLAD:** back-stowed weapon state is approved as art direction; mount, overlap, anchors, pivots, and transition evidence remain open.

These scoped approvals do not authorize unreviewed cutout boundaries, hidden geometry, attachment coordinates, pivots, or candidate promotion. All related art remains quarantined. Source: owner decisions recorded locally on 2026-10-26; canonical remote reconciliation is queued.

## Design questions preserved

- **BREAKER Tier I cyberware extent — RESOLVED by explicit user approval on 2026-10-25:** retain an external shoulder shell over a biological human upper arm; the mechanical right forearm/fist prosthesis begins at the elbow. This reconciles the approved profile silhouette with the written Tier I description. Production art, independent layers and hidden anatomy still require validation.

- No animation-ready source parts with authored pivots have been recovered. Candidate 09 v4/v5 now supports a quarantined feasibility rig and pose/contact tests; continue testing that draft without treating it as the production rig. Production promotion still requires clean alpha, proportion-matched separate parts, author-approved pivots, and continuous seam/deformation review. Existing generated atlases and fixed-cell crops remain unusable substitutes.

- Which Tier I character-stage name should accompany the approved global evolution tiers? The reconstructed BREAKER page and boards use alternate labels; they are not silently substituted for the global names.
- No original source supplies layered BREAKER anatomy beyond the concept references. The v4 split retains the visible source pixels; v5 adds a generated hidden-skin hypothesis beneath the original shell. These drafts use estimated pivots and a shared shoulder bone; neither is production art or a validated production rig. Clean authored layers, concealed anatomy approval, and full clip/seam validation remain outstanding.
- What are the approved numeric combat and economy curves, including upgrade/reward formulas and wave scaling?
- What are the canonical encounter-zone names, visual identities, and wave boundaries within each district? The user approved modular encounter zones with seamless-looking transitions on 2026-10-24; the current two Undercity palette modules and wave-13 QA boundary are temporary test fixtures only.
- Release details still open: what minimum hardware should be supported, which exact Windows 11 build is the floor, which display combinations beyond 16:9 at 1280×720 should be accepted, and what installer/build/update procedure will 1.0 use? The approved target is a direct-download Windows installer, x86_64, Windows 11, with scalable 16:9 presentation and a 1280×720 minimum viewport; mobile is outside 1.0. The hardware floor must follow tests across low-end, typical, and high-end Windows 11 x86_64 devices. Source: docs/LOCAL_SESSION_DECISIONS_2026-10-25.md.
- Is the provisional versioned permanent/run/settings save partition approved for production?
- Which research nodes, costs, prerequisites, ranks, and gameplay effects should ship? The four approved branches and a save-safe transaction framework/read-only branch UI exist; node entries remain empty and no purchase or gameplay effect is enabled.
- What offline-credit rate should ship? The user approved one ordinary reward at the saved highest-cleared holding wave per elapsed hour, capped at eight hours, as a configurable feasibility trial. It is implemented and tested with atomic save-before-apply; the trial rate is not final balance.
- Evolution unlock model is approved as permanent milestone plus earned materials. The user approved wave 25/75/125 and per-recruit costs of 1/2/3 shared generic Evolution Data for prototype feasibility testing; release balance remains open. Tier stat/trait effects, art integration, and final material naming remain undecided.
- What are the detailed named boss and guaranteed recruitment rules in the canonical design?
- Does the prototype trial of one Influence per completed 25-wave band and `min(0.5% × sqrt(lifetime Influence), 25%)` outgoing-damage bonus produce a good progression curve? The user approved these values for feasibility testing on 2026-10-24, not as final release balance. The live manual Reboot control and damage modifier are integrated for prototype testing; final balance remains open.
- Evolution milestones/costs are wired for prototype feasibility: Adapted Form 25/1, Signature Form 75/2, Requiem Form 125/3, per recruit. The live BREAKER transaction records the new tier and spends materials through a save-before-apply path. It does not yet change stats, traits, or appearance. Release tuning, effect values, final material naming, and visual production remain open.
- Broader evolution testing should verify the per-recruit path as recruit implementations are added. The permanent first-clear ledger and repeatable material rewards are connected to wave clears. The prototype combat/save horizon reaches 125, with waves 26–125 explicitly using placeholder content. The live Reboot caller captures unsaved run state, commits atomically, then updates the running scene. The save operation assumes one game process; concurrent instances are not coordinated.
- I-05 defines maximum-encounter and no-progress timers, action-before-timer ordering, qualifying progress categories, and defeat on either timer's expiry. Test Lane reports focused regressions, seeded CLI activation, scene smoke, and the full Godot suite passed. Numeric thresholds and formula values remain feasibility inputs. D-04 defines qualifying trial ability/status changes. I-04 provisional runtime exists and its focused residual runner passed; broader/release verification and final values remain open. The approved defeat flow retreats to the highest-cleared holding wave; the arrival cue remains a process-local placeholder, not a completed cinematic.
Until source review or explicit decisions resolve these points, prototype values remain configurable stand-ins and no unresolved system is treated as final.

## Arm-extent review aid — 2026-10-25 UTC — HISTORICAL, SUPERSEDED

A new matched-scale board, `docs/visual_qa/BREAKER_T1_arm_extent_decision_board.png`, documented the choice before the user selected the external-shell interpretation. The board remains a historical review artifact, not an art approval.

## Verification scope adjustment — 2026-10-25 UTC

Per the user's instruction to reduce the review loop, hidden anatomy verification is no longer a blocker to unrelated prototype implementation or visible concept review. It remains explicitly **NOT VERIFIED** and stays required before production-ready art/rig promotion. Candidate 09 is a provisional visual review direction, not final production art. The external-shell / biological-upper-arm / elbow-start-prosthesis boundary was approved on 2026-10-25; see `docs/DESIGN_DECISIONS.md`.

## Current BREAKER hidden-surface review — 2026-10-25 UTC

The v5 shell-off donor shows a continuous biological upper-arm volume, but its deltoid reads rounder than the original candidate 09 silhouette and residual source fragments remain around the cutaway. The neutral shell-on composition is pixel-identical to the source and passes the selected Godot registration tests. The donor stays quarantined pending owner visual review; decide whether to narrow its hidden volume toward the original silhouette before further component-fit work. This is a visual proportion question, not a change to the already-approved arm-boundary canon.


## BREAKER Tier I arm-boundary evidence update — 2026-10-25 UTC — HISTORICAL, SUPERSEDED

The v8 right `cyber_upper_arm` mask visibly owned a shoulder-shell/skin composite. The user later approved the external-shell interpretation; candidate 09 v2 provides a separate, more focused ROI ownership test. These historical exploratory notes do not replace the approved decision or establish finished art.

## BREAKER Tier I v5 continuity review — 2026-10-25 UTC

The arm-boundary canon is resolved. The v5 hidden-skin hypothesis now passes a 2D connected-mask check (27,550-pixel largest 8-connected region; both substantial visible-skin regions connect to it), but the shell-off donor still reads rounder than the reference. Keep that proportion review open and keep v5 quarantined. Biological correctness, independent part deformation, authored pivots, animation seams, and production alpha remain unverified.

## BREAKER hidden-arm fit result — 2026-10-25 UTC

The arm-boundary decision remains resolved, but shell-off proportions remain open. Reference-guided v6, narrowed v7, gap-filled v8, and continuous-underlayer v9 all preserve the visible candidate 09 composite and pass scoped connectivity checks; manual comparison still does not accept their shell-off anatomical fit. v7 is specifically rejected for fragmented edges. Do not promote any underpaint. Next art work needs a silhouette treatment based on the approved exposed bicep proportions, then owner visual review; keep the shell-on candidate 09 as the visible target.


## v13 hidden shoulder donor review — 2026-10-25 UTC

The shell-on composite is exact and the donor joins the visible upper-arm mask, but its shell-off proportions are generated and remain unapproved. Does the v13 arm/shoulder shape feel consistent with candidate 09's intended proportions? The full-mask variant prevents gaps across the original opaque shell footprint, and the separate 12-pixel/0.16-rad captures test reveal behavior, but neither establishes accepted deformation. The full-mask capture may reveal non-skin generated color when the shell moves. If the shape is not acceptable, use the approved shell-on art while hidden anatomy remains an authoring task; do not promote generated donor pixels by default.


### BREAKER v13 v5 follow-up — 2026-10-25 UTC

The user-approved arm boundary is settled. Hidden anatomy remains unresolved: v13 v5 passes shell-on preservation, connected rig registration, and independent-shell capture, but visual review still finds the exposed generated shoulder oversized and round relative to candidate 09. Continue with a proportion-matched hand-authored or carefully constrained underlay; keep v5 quarantined and do not promote it.


### BREAKER hidden upper-arm proportion — 2026-10-25 UTC

The external-shell / biological-upper-arm / elbow-start-prosthesis rule is resolved. The remaining visual choice is the revealed shoulder contour: v13 v4/v5 retains more bulk; v13 v6 is 82% width and slimmer but still has generated seams. None is production-ready. Review `docs/visual_qa/BREAKER_T1_v13_shoulder_shape_options.png` before adopting either proportion; preserve both as quarantined hypotheses meanwhile.


The v6 skin mask also measures 20,505 pixels in its largest connected component out of 20,723 total (58 components), below the previous 25,000-pixel screen. Resolve the detached flecks and visual shoulder shape before any production-art claim.


## BREAKER hidden anatomy source alignment — 2026-10-25 UTC

The approved visual target is candidate01; candidate09 is a later pose/reconciliation study and should not set the final proportions. The v2 and 72%-width v3 generated underlays preserve the candidate01 shell-on image and connect in 2D to the elbow-start mechanical forearm. The v3 is slimmer and currently the better proportion hypothesis, but the skin texture is generated and the shell remains fused in the approved reference layer. Review the local comparison board before deciding the visual contour. Production art, independent shell layer, and animation deformation remain open.

### BREAKER candidate01 shell-off review — 2026-10-25 UTC

Resolved by the user: external shoulder shell over biological upper arm; prosthesis begins at the elbow. This is no longer a design question. The exact candidate01 layer split verifies shell-on image preservation only. The shell-off assembly and generated edits have been rejected for visible mismatch/artifacts. Remaining work is an accurately aligned underarm and clean independently deformable shell/skin art, followed by full pose/seam review. Production-art gate remains **NOT PASSED**. Evidence: `docs/visual_qa/BREAKER_T1_candidate01_shell_elbow_rebuild_v4.png`.

### BREAKER candidate01 fitted underarm and elbow split — 2026-10-25 UTC — SUPERSEDED VISUAL OPTIONS

The canon choice is resolved. At the time, two corrected, quarantined underarm widths were offered for review. Neither was selected; subsequent visual QA rejected both, so this is no longer a pending choice. The y=495 cut is a provisional rig pivot, not canon. The prior incorrectly transformed preview boards are superseded. Production art, independent deformation and all-frame seam quality remain open.

A new pose-sampled mask-contact check covers the elbow seam for both width hypotheses: 206 frames each, with positive 8-neighbor contact throughout. This structural result did not establish visual fit; both were later rejected on the approved-reference comparison. Production art remains **NOT PASSED**.

#### 2026-10-25 visual review outcome

The corrected full-body and crop boards show that both generated underarms have visible texture/cutout seams and a bulky, stylistically mismatched contour. Reject both. Keep the approved candidate01 shell-on reference unchanged and out of these shell-off experiments. Next art attempt must create a style-matched biological upper-arm underlay and split the shoulder shell as independently authored artwork; it must not reuse either rejected donor as production content.

### Contextual cutaway study — 2026-10-25 UTC

`candidate01_upper_arm_cutaway_study_v1.png` shows the selected shell-over-biology / elbow-start prosthesis rule, but its exposed upper arm is overbuilt and its shoulder armor differs from the approved profile. It is useful only as a boundary illustration; it is not accepted anatomy, a production component, or a tested rig. Keep the question open for artist-authored, proportion-matched hidden anatomy and a separately deformable shell.

`docs/BREAKER_T1_HIDDEN_ANATOMY_ART_BRIEF.md` now defines evidence needed to close the art gate without treating hidden proportions as preapproved. No current image passes the visual and rig gates together.

The first contextual cutaway refinement also failed: its shell-off inset remains overbuilt and the shell changes. Further whole-image generation is not a suitable way to create this source-aligned layer; the next attempt needs localized source editing or artist-authored transparent parts, followed by the existing reference and rig gates.
## BREAKER source-art route — 2026-10-25 10:07 UTC

Google Drive read-only access is now verified, but the inspected canonical folders and reconstruction archive contain no editable layered art source. The existing PNGs are reference concepts/spec support. Decide the concealed upper-arm proportions and obtain/author clean, independently deformable skin and shoulder-shell layers before claiming the BREAKER art gate passes. Until then, use candidate01 only as the shell-on appearance reference and keep all fitted/generated donors quarantined. No new design decision is needed for the approved boundary itself: external shell over biological upper arm; prosthesis starts at elbow.

The latest localized donor concept was also rejected for overbuilt anatomy and a style mismatch. Avoid treating another isolated generated anatomy image as accepted content without checking it against candidate01 at native crop and gameplay scale.

The follow-up full-body-context generation also failed the same art gate. Remaining path: source-controlled hand authoring using candidate01 as a strict pixel authority, or recovery of editable artist layers. The Drive/archive audit found no such source in the inspected material.

The first hand-authored SVG underlay is now available for shell-off review at `docs/visual_qa/BREAKER_T1_candidate01_vector_underlay_neutral_shell_off.png` and `..._walk_shell_off.png`. Does its narrower arm contour feel proportionate to candidate01, and does the more graphic SVG surface fit the reference style at gameplay scale? It stays provisional until reviewed.

- **Hidden anatomy acceptance remains open:** the 18%-opacity source-texture SVG underlay fails shell-off visual review (swollen/detached contour, stray/doubled texture). Shell-on source fidelity and Godot sampled contact tests pass, but this does not pass the art gate. Canonical boundary is settled; hidden proportions, clean separately authored parts, and production rig deformation are not.

- **Concealed upper-arm contour needs an art direction choice:** the canon boundary is settled, but visual trials show that a compact vector does not match the painted reference, while generated/full-size underlays distort the proportions. The opposite-arm same-source cutout is too narrow when simply fitted. Choose whether the hidden arm should follow the visible opposite arm's natural proportions or be shaped to fill more of the original shoulder-shell envelope; any selected contour remains a provisional art choice pending review.

- **Latest v4 result:** the narrower source-texture v4 passes scoped Godot registration/contact and preserves the shell-on source, but still fails the shell-off art gate because its finish is vector-like and texture streaks remain. The hidden contour/style remains awaiting user direction; the previous suggested visible-arm proportion reference has not yet been answered. No trial is promoted.

- **Mapped texture v5–v6:** the 14% blend remains too smooth; the 38% blend adds crosswise shading. Both pass sampled contact and shell-on fidelity but fail visual acceptance. The approved shell-on reference is unchanged; all test-only source and outputs remain quarantined.

- **BREAKER hidden upper-arm art remains unresolved.** The user-approved boundary is fixed: external shoulder shell overlays a biological upper arm, and the prosthesis starts at the elbow. V7 passes shell-on coverage and sampled rig contact but fails native-scale shell-off review due to a jagged shoulder-wrap edge and ambiguous connection. Hidden proportions, clean source-aligned shell/skin parts, and all-pose deformation remain open. Do not promote v7 or another isolated generated arm without visual and rig acceptance.

- **Candidate01 shoulder-to-torso connection:** v10 closes the measured 60–80 px source gap at gameplay scale and passes sampled contact plus shell-on occlusion. The close-up still shows stretched texture. It remains a review candidate pending the owner's visual acceptance and later artist-authored production layer/pivots.

- **V10 disposition:** its stretched geometry is rejected at native scale for an unnatural inward kink, edge specks, and an elbow seam. The user may review earlier v7 shell-off preview as a shape reference, but it remains too narrow to connect naturally with the torso. Hidden anatomy remains unresolved; keep all candidate layers out of runtime.

- **V11 disposition:** the narrow under-vest socket closes coverage structurally but repeats edge pixels into visible horizontal streaks; reject it. This confirms that simple edge cloning does not provide acceptable paint. Keep the arm art gate open and all v7/v10/v11 underlays out of runtime.

## CIPHER candidate 07 torso ownership — unresolved — 2026-10-25 UTC

The quarantined candidate-07 contact sheet shows a narrow detached contour in `torso_jacket`, previously measured at 882 alpha pixels and provisionally mapped to a rear jacket outline. The neutral assembly matches the visible side-profile silhouette, but the fragment's semantic owner and the 9,869 shared source pixels in the ownership map have not been reviewed as rig boundaries. Keep the candidate out of rig input. Resolve by human source-backed part labeling and explicit overlap owner rules; do not delete, merge, or remap pixels by inference.

## CIPHER candidate 07 multi-contour ownership — unresolved — 2026-10-25 UTC

The reusable Godot intake helper now builds one `Polygon2D` per detected alpha contour and keeps those nodes under the same semantic owner. Candidate 07's eight backpack contours and every contour in the other nine parts triangulate independently through PolyRig. Four images remain multi-contour (`backpack_mount`, `pelvis_belt_gear`, `torso_jacket`, and `head_hood_hair_face`), so visual/semantic ownership and any needed separate owners still require review against approved references. The former six backpack triangulation failures are no longer a current blocker; no source pixels were edited or discarded. The candidate remains quarantined; pivots, weights, hidden anatomy, deformation, and production approval remain open.

The normal-renderer static assembly comparison differs from the current source-aligned assembly at 531/79,200 sampled pixels (0.67%) using a provisional 1% bound. The comparison establishes approximate compositing at 0.5× only; residual differences have not been localized as texture-edge filtering, contour coverage, or layer-overlap effects. Native-scale visual/semantic review and movement/deformation checks remain required.

The per-part follow-up now compares all ten raw cutouts and contour meshes at native scale. Every part is below the provisional 1% color-difference bound, with zero differences in fully opaque interior pixels; all observed deviations are semitransparent or alpha-edge-adjacent. The full-body composite measurement remains a 0.5× render comparison. Confirm edge appearance in the character's actual target import/filter settings and full Krita pose review; no pivots, weights, hidden anatomy, or deformation have been validated.

## CIPHER hand/jacket ownership — interpretation resolved, pixels still open — 2026-10-25 UTC

The user-approved interpretation is encoded and regression-tested: visible hand pixels belong to foreground `near_hand`; the jacket continues behind; hand pixels must not be assigned to `pelvis_belt_gear`. Candidate 07 currently has zero shared core pixels between hand and pelvis/torso, 1,706 at the forearm seam, and no hidden jacket underpaint. Any later underpaint is inferred and must be labeled. This resolves intended ownership only; the candidate remains quarantined and unverified. Remaining open blocks include semantic review of multi-contour ownership, pivots, hidden anatomy, weights, and deformation. The former backpack triangulation failure has been cleared by the per-contour mesh builder.

## Automatic abilities and squad preferences — source reconciliation — 2026-10-26 UTC

The roster summaries remain non-verbatim/unverified evidence and do not establish canon behavior. Under owner-delegated playtest selection, all twelve abilities now have provisional simulation contracts in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md`; those rules are non-canon, values remain configurable, and runtime implementation/testing is still pending. ECHO's abstract decoy behavior is specified for simulation; source-specific device count/mapping and art/air-lane integration remain unresolved. The approved automatic policy still excludes manual triggers, target overrides, and per-target commands. See `docs/AUTOMATIC_ABILITIES_AND_FORMATION_SOURCE_AUDIT_2026-10-26.md` for provenance.

Formation preferences have an implementation-ready data contract: optional soft Front/Middle/Rear band and Vanguard/Assault/Support/Control role; unlimited membership per band; role guides movement inside a band or alone; preferences persist per recruit across Reboots; configuration is outside combat. All recruit bodies remain grounded; SPARK drone attachments and ECHO decoy attachments use the separate spatial height/air lane. The user approved fixed battlefield boundaries, the role attack-range exception, finish-current-action regrouping, authored-obstacle route/wait behavior, and this attachment-only lane. Exact contact/ranged thresholds, same-band offsets, and boundary dimensions/coordinates are deferred until after layout testing; the manager has provisionally permitted a bounded disposable geometry-only harness as recorded above; none has been created or run. The manager-selected provisional passing and no-threat rules are recorded above. Remaining decisions are air-lane geometry/transitions/collision/pathing/band relation/targeting and attack interactions, attachment activation timing, and ECHO device mapping. Do not infer missing targeting or flight mechanics or implement spatial behavior before the remaining contract gates are approved; the geometry-only harness permission does not approve combat behavior.

Historical next choices:
- Formation: (A) implement preference data/settings/persistence only; (B) decide spatial behavior first; (C) defer.
- Abilities: scope B was selected, then superseded by the owner-delegated provisional playtest contracts in `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md`.

## District, zone, and boss scope — source reconciliation — 2026-10-26 UTC

**Resolved for 1.0 scope metadata:** the five district bands are Undercity 1–25, Neon Row 26–50, Black Grid 51–75, Enforcement Zone 76–100, and The Spire 101–125; procedural endless progression starts at 126. The approved presentation plan uses two visual modules per district, transitioning at district-local wave 13 (global 13, 38, 63, 88, 113). Module descriptions are visual direction only; canonical location names and production art remain unspecified. The current Undercity palette modules and their wave-13 fixture remain provisional and separate.

**Boss scope:** one named boss per district is approved; endpoint placement is the pacing-test baseline, not a locked final spawn rule. Approved concept names are Patchwork, Ghostlight, Chainbreak, Civic Warden, and Sable Venn, with Patchwork replacing Nacre. No district-to-boss assignment or full boss definition is specified. The owner selected immediate permanent ownership on first defeat, immediate unique-identity enemy-generation exclusion, and application of existing roster rules (first open active slot, reserve when all six are occupied, next-encounter deployment if acquired during combat). This closes the separate claim-action and pending-claim replay questions. Boss stats, faction, ability/target rules, encounter scripting, complete reward profile, district mapping, spawn/cadence, and identity-specific art remain open. See `docs/I-07B_NAMED_BOSS_DECISION_PACKET.md`; do not infer missing content or wire encounters from this decision alone.

Data-only scope metadata is in data/world/district_scope.json. It is not consumed by runtime wave/zone systems. Source audit details and fetch state are recorded in docs/MIGRATION_REPORT.md.

## Endless progression rules after wave 125 — start is approved; mechanics remain open

The source-approved boundary is that procedural endless progression begins at wave 126. The live design and handoff do not define a complete generator or scaling contract. See `docs/ENDLESS_PROGRESSION_AUDIT_2026-10-25.md` for sources, current runtime/save behavior, and the exact contract required before implementation.

The following fields need explicit rules before the 125 prototype cap can be lifted: (1) enemy attributes, scaling model, stages, rounding and numeric bounds; (2) generated enemy/archetype pool, faction/composition policy, variety constraints and deterministic seed/replay; (3) whether endless waves contain bosses, cadence and eligible identities; (4) ordinary credit rewards, milestone policy and treatment of permanent materials after the districts; (5) the high-wave offline payout input, using the already approved credit-only/saved-holding-wave/claim-save/no-wave-advance structure; (6) supported wave ceiling, overflow behavior and save representation/compatibility; and (7) endless first-clear, retreat and Reboot semantics. See `docs/I-09B_ENDLESS_PROGRESSION_DECISION_PACKET.md` for neutral selectable options and consequences. The existing runtime/save cap remains 125 pending a complete profile; no numeric values or mechanics are inferred.

**Decision needed:** use `docs/I-09B_ENDLESS_PROGRESSION_DECISION_PACKET.md` to select or defer each rule family. Its predecessor, `docs/ENDLESS_PROGRESSION_OPTIONS_2026-10-25.md`, remains qualitative background. Option selection alone does not approve formulas, numeric values, content pools, rewards, or migrations. The general endless direction and wave-126 start do not authorize extrapolating provisional Undercity stats/rewards or inventing a boss/reward schedule.

## Ability behavior scope — all twelve contracts — trial defaults selected; implementation ready

The user selected all-twelve sequencing, then delegated selection of supported recommendations as provisional playtest defaults. `docs/I-04C_ABILITY_CONTRACT_DEFINITION_PACKET.md` contains all twelve operational simulation contracts and the shared automatic-activation baseline. The rules are owner-delegated trial defaults, not canon or final balance. I-04 provisional runtime exists and its focused residual runner passed; broader/release verification and final values remain open. ECHO's abstract decoy is included; its device/art mapping, air-lane presentation, and count-dependent attachment tests remain blocked on Character/source evidence. Roster labels remain from a non-verbatim offline reconstruction/prior fetch marked `unverified`; remote canonical reconciliation remains queued.

## I-05 hybrid combat/outcome — trial verified; tuning remains open

See `docs/I-05B_HYBRID_COMBAT_DECISION_BRIEF.md` and the I-05 verification record at the top of `docs/IMPLEMENTATION_STATUS.md`. Test Lane verified focused I-05 regressions, CLI seed activation, a main-scene smoke, and the full Godot suite. Squad power influences outcome likelihood without guaranteeing a win; direct damage remains the default control. Formula weights, coefficients, thresholds, profile values, cross-version RNG guarantees, and final balance remain provisional. D-04 defines qualifying ability/status changes for the trial hook; I-04 provisional runtime is available, with broader/release verification still pending.
