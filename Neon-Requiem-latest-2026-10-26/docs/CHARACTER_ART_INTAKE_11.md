# Tier I art intake briefs — remaining founding recruits

**Status:** Source-backed intake briefs. The user has since approved the individual concept images as Tier I visual references; the briefs remain source facts, not sprite parts, rigs, or production assets.
**Roster source:** [Founding Recruit Roster](https://app.notion.com/p/40394c5658c8812d849be3d32629920e), retrieved 2026-10-25. Live fetch metadata: 2026-10-24T03:56:33.654Z.
**Local asset audit:** 2026-10-25. At the time of the audit, the folders contained four broad concept boards and BREAKER-only character trials. No layered art or Tier I part sets were found for these eleven recruits. Individual concept references and anatomy-turnaround review drafts were added later; those later images are recorded in `docs/ASSET_MANIFEST.md`.

## What the sources establish

The roster gives each recruit a faction, combat archetype, rarity, short backstory, and signature ability. The local `01_world_roster_concept_sheet.png` and `02_character_faction_design_sheet.png` are broad reference boards. The former is BREAKER-focused; the latter shows generic class and faction variants, without reliably identifying a specific founding recruit in each image. They are inspiration/reference only and must not be cut up or imported as character sprites.

The live roster does **not** define these recruits' precise body proportions, faces, clothing construction, individual palette mapping, anatomy, limb/cyberware side, weapon silhouette (except where explicit in the role/ability), sprite parts, or rig pivots. The user-approved individual concepts now establish the visible Tier I direction where the roster is silent. Hidden anatomy, transparent parts, and rig pivots remain unresolved production inputs.

## Briefs

| Recruit | Verified roster identity | Character-specific visual facts established | Tier I art status |
|---|---|---|---|
| BULWARK | Vanguard Zero; Tactical Soldier / Combat Medic; Rare. Abandoned elite threat responder; converted tactical gear to life support. Last Protocol: emergency squad heal. | Life-support conversion and emergency medic role are stated; exact equipment and anatomy are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| CIPHER | Ghost Circuit; Netrunner / Sharpshooter; Rare. Corporate analyst who leaked secrets and hacked rifle optics. Ghost Round: cyberware-disrupting precision shot. | Hacked rifle optics are stated; exact rifle, body design, and cyberware are not. | **QUARANTINED reference-cutout candidate**; modular production art **NOT SUBMITTED** |
| SPARK | Redline Syndicate; Combat Engineer / Drone Operator; Common. Scrapyard mechanic after a gang war. Scrap Swarm: three attack drones. | Three attack drones and mechanic background are stated; drone shapes and carried equipment are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| SPECTER | Helix Dominion; Infiltrator / Blade Specialist; Epic. Assassin fled after discovering their own termination order. Null Trace: cloaked priority strike. | Blade-specialist role and cloaked strike are stated; blade design and cloak presentation are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| IRONCLAD | Helix Dominion; Heavy Gunner / Tank; Rare. Female convoy guard who saved civilians and escaped in powered armor. Lockdown: anchor and suppress. | Female identity and powered armor are explicit; armor construction and weapon are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| STITCH | Chrome Saints; Rippertech / Chem Specialist; Common. Back-alley implant surgeon. Black Market Cocktail: heal and attack boost with instability. | Implant-surgeon and chem-specialist roles are stated; medical/chemical equipment and anatomy are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| RECOIL | Redline Syndicate; Shotgunner / Brawler; Common. Debt collector with a hydraulic prosthetic arm. Breach Charge: frontline penetration. | Hydraulic prosthetic arm is explicit; which side, boundaries, and exact construction are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| ECHO | Ghost Circuit; Netrunner / Drone Operator; Rare. Neural injury; remote drones act as sensory extensions. Signal Cascade: decoys. | Neural injury and remote drones as sensory extensions are explicit; visible injury treatment and drone design are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| VECTOR | Independent Mercenary; Blade Specialist / Skirmisher; Common. Courier in dangerous territory with reflex implants. Slipstream: multi-target dash. | Courier, blade-specialist role, and reflex implants are stated; exact blade, implants, and anatomy are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| DEADLOCK | Vanguard Zero; Tactical Marksman / Anti-Cyberware; Rare. Suppression specialist who refused to kill an innocent witness. System Break: disables the strongest enemy implant. | Tactical marksman and anti-cyberware roles are stated; weapon and implant-disabling visual effects are not specified. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |
| GLITCH | The Fractured; Cyberpsycho / Infiltrator; Epic. Female former corporate movement specialist with neural acceleration damage. Frame Skip: accelerated target-switching burst. | Female identity and neural acceleration damage are explicit; visible effects/anatomy and movement form are not. | **QUARANTINED visible-profile mesh-rig candidate**; modular production art **NOT SUBMITTED** |

All facts in this table are paraphrases of the linked roster page. They are not additional canon. Singular pronouns are used only where the source explicitly specifies female identity; otherwise the briefs avoid inventing pronouns.

## Per-character production intake

Before creating a character's Tier I manifest or rig, record and review:

1. A character-specific approved full-body reference, including the side-view facing and visual scale.
2. Anatomy and equipment map: biological/cybernetic parts, side, attachment boundaries, and what must stay continuous through motion.
3. Intended reusable rig archetype and any justified character-specific bones/poses; this is a proposed implementation detail until matched to source anatomy.
4. Independently separable transparent parts, canvas dimensions, source provenance, pivots, draw order, and supported attachment transforms.
5. Neutral, idle, walk, attack, hit, and defeat captures plus a written visual review. The shared validator can check file and manifest integrity; it cannot approve anatomy or style.

The shared intake contract remains [`CHARACTER_ART_PIPELINE.md`](CHARACTER_ART_PIPELINE.md). Do not create empty manifests. Record genuine individual reference sources in this brief before proceeding. For each recruit, promote only after its own anatomy, seams, animation, and user-review gates pass.

## Local source locations audited

- `migration_package/drive_assets/concept_art/01_world_roster_concept_sheet.png` — 1536×1024 RGBA; BREAKER-focused reference.
- `migration_package/drive_assets/concept_art/02_character_faction_design_sheet.png` — 1536×1024 RGB; generic class/faction references, not per-recruit production art.
- `Google Drive/02 - Character Sprites/` — reviewed local staging copy; character-specific production trials found in this folder are BREAKER-labelled. No files for the eleven IDs.
- `assets/characters/` — contains only `breaker/`; no runtime or review asset directories for the other eleven.

No source binary was copied, modified, or promoted by this audit.
