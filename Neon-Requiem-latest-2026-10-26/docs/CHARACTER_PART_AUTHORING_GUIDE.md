# Character part authoring and intake guide

**Status:** Production workflow guidance based on the CIPHER Tier I pilot, 2026-10-25. This does not change approved character designs or gameplay canon.

## What the pilot taught us

- Transparent background and alpha-connected crops only prove that pixels can be segmented. They do not prove that an object is a complete body part or even belongs to the expected joint.
- A generated atlas can contain duplicated limbs, clipped parts, attached neighboring anatomy, and visually plausible but ambiguous pieces. A component count is not an acceptance metric.
- Crops can look acceptable at thumbnail size while showing cutoff edges, stray neighboring pixels, or unexplained skin/armor boundaries at full size.
- Do not label numbered alpha components as semantic body parts by inference. Record uncertain mapping as unresolved and keep the source quarantined.
- The approved concept and anatomy turnaround guide visible design. Neither supplies hidden pixels, pivots, or proof that a joint deforms cleanly.

## Required workflow for each recruit

1. Read the approved concept and approved anatomy turnaround together. Record identity anchors, visible equipment/cyberware, handedness, grounded/floating rationale, and any differences between views.
2. Make a part plan before generating or painting: name the parts, define which limb/joint each belongs to, note front/back overlap order, and identify which regions need hidden underpaint. Preserve the approved silhouette and costume details.
3. Prefer separate transparent files per semantic part. Require a fully transparent outer safety margin around the visible art; diffuse glows, vignettes, or shadows outside the character silhouette count as stray pixels. If an atlas is necessary, use a rigid labeled grid with generous gutters; keep every part completely inside its own cell, with no touch/crop at cell edges and no unrelated marks in the cell. A visual label key must map each file/cell to a body part and side.
4. Review the full source and each crop at 100% before rigging. Reject any clipped contour, duplicated or missing side/limb, fused neighboring part, stray component, ambiguous label, or inconsistent scale/orientation. Automated alpha segmentation is an aid for reviewing pixels only.
   - For a named `parts_manifest.json` candidate, generate an individual native-scale checkerboard sheet with `python tools/art/render_semantic_part_contact_sheet.py <candidate_dir> <new_output.png>`. The renderer supports both legacy named-part objects and traced-polygon part arrays. This supports per-part viewing but does not complete the human semantic gate.
   - Run `tools/art/audit_semantic_cutout.py <part.png>` for a mechanical alpha/margin report. Its 10% margin, alpha-32 silhouette threshold, 3-pixel edge tolerance, and 50-pixel low-alpha halo allowance are provisional intake thresholds; adjust per asset when justified. A PASS never approves anatomy or production art.
   - The same report includes a four-neighbor connected-component diagnostic for thresholded alpha islands. Use the component counts/areas to locate detached fragments during review, but do not make a disconnected component an automatic failure: gear, straps, layered armor, and other semantic assets may intentionally contain multiple pieces. Thin diagonal shapes can be split into single-pixel components by four-neighbor connectivity; inspect diagonal/8-neighbor connectivity and the source before calling them stray pixels or cleaning them.
   - **PolyRig 0.9.3 Auto Mesh constraint:** `addons/poly-rig/auto_mesh_button.gd` converts alpha to contours and uses only one contour for a texture (the selector compares vertex counts, not pixel area). Do not assume that UI operation retains every island. The shared `PolyRigContourMeshBuilder` instead creates a separate `Polygon2D` per detected contour under the semantic owner; validate every contour and rendered result before relying on it. Keep unrelated semantic items in their own named image/layer. A single semantic attachment can yield multiple contours, including thin diagonal details split by the contour detector; do not auto-delete those components without source review.
- **One editable attachment per layer:** a named attachment layer represents one independently moving semantic item. Split joint-owned armor plates, separate weapons/accessories, drones, cloth panels, and distinct physical cable routes. A fixed subpart may stay with a rigid assembly only when the approved source supports that relationship (for example, an optic mounted to a rifle). Multiple mount pivots do not require duplicate weapon art. Exact counts, ownership, and boundaries that are not visible in approved references stay unresolved until reviewed.
   - Component bounds are reported in cutout-image coordinates. When the part manifest includes source bounds and padding, map those coordinates back to the approved source before deciding whether an island is a stray fragment or part of a layered contour.
   - For source-derived cutouts, generate a native-resolution ownership overlay with `python tools/art/render_semantic_ownership_board.py <candidate_dir> <new_output.png>`. Red pixels identify multiply-owned source pixels, and the JSON report lists the part pairs and shared-pixel counts. The renderer accepts both legacy named-part objects and traced-polygon arrays. The overlay helps locate boundary collisions; it does not decide whether labels are anatomically correct, and it is not a replacement for 100% crop review.
5. Validate the static assembly against the approved front/side/back references for silhouette, proportions, overlap order, and grounding. Mark inferred hidden anatomy explicitly; do not describe extrapolated fill as source-backed.
6. Add semantic names, image dimensions, alpha bounds, authored pivot coordinates, layer order, provenance, and per-part status to a character-specific manifest. Never invent pivots from the center of a crop.
7. Only then build a provisional Godot rig. Validate neutral alignment, every joint seam through idle/walk/attack/hit poses, and foot/ground contact. Passing a few sampled contacts does not prove continuous deformation.
8. Promote art only after all visual, provenance, semantic mapping, pivot, and animation gates pass. User approval of a concept or turnaround is not production-art approval.

## Visual source-polygon authoring helper

`python tools/art/trace_part_authoring.py <approved_source_image>` opens a local tracing window for images inside the project. Left-click records integer source-image coordinates; right-click or **Finish part** closes the polygon and prompts for semantic owner, part ID, category, role, and boundary provenance. Mouse wheel zooms, middle-button drag pans, **Fit** resets the view, **Backspace** removes the last point, and **Escape** clears the in-progress polygon. **Remove last part** removes the latest in-memory trace. No files are written until **Export candidate** is used.

The exporter stores a timestamped polygon manifest under `tools/art/trace_manifests/` and calls `extract_traced_reference_parts.py` to create a new folder directly under that character's Tier I drafts. Existing folders are never overwritten. Exported cutouts preserve source RGB and keep all semantic, pivot, deformation, production, and runtime gates false. The tool cannot decide what a polygon means, resolve occlusion, invent hidden pixels, or author pivots; inspect each boundary at 100% and follow the bounded intake stop rule.

## Real-world occlusion and inferred underpaint

When a foreground object visibly covers another surface, assign the visible pixels to the real-world foreground owner (for example, a hand remains a hand even where it overlaps clothing). Keep the foreground object above the covered surface in draw order. Do not assign the foreground object's visible pixels to the garment or equipment behind it.

If the flattened reference hides the covered surface and the user has confirmed what continues behind the occluder, a review candidate may add a separate, conservative underpaint layer behind the foreground part. Label it `inferred`, record the source limitation and scope, avoid unsupported markings or texture, and preserve the original source-derived layers. If the owner or continuation is not clear from approved sources or user direction, stop and request art review rather than guessing.

Review underpaint both in the neutral assembly at the intended gameplay scale (1280×720 viewport and 800×450 downscale) and in any pose that could expose it. Near-invisibility at gameplay scale is useful presentation evidence, but it does not validate hidden anatomy, moving seams, pivots, or production readiness. Keep the candidate quarantined until those gates pass.

## Bounded intake and explicit stop rule

The early semantic gate is a go/no-go decision, not an invitation to keep segmenting until the image appears usable. After the first native-scale part sheet and source-ownership review, stop and keep the candidate quarantined if any required limb/gear piece is missing, clipped, duplicated, assigned to an uncertain owner, or unsupported by the approved visible reference. Record the exact unresolved part and the source evidence needed to resolve it. Do not continue to rigging, invent hidden anatomy, or run another extraction variant to disguise missing source information. Resume only when a human author supplies a corrected semantic part or the approved reference resolves the question.

## Rig reuse and character exceptions

Reuse the project's standard semantic names and parent anchors when they fit the character's actual anatomy. Do not force a shared skeleton or part split across a prosthetic, unusual limb, floating character, or distinctive silhouette when that would misrepresent the approved reference. Record each justified exception in that character's manifest and part plan, and provide a character-specific pose/clip review for the changed joints. A shared rig is a work-saving starting contract; it is not an art or gameplay rule.

## Gameplay-scale and action readability gate

The 256 px foot-to-hair target is a normalized authoring/reference scale, not proof that a character reads in combat. Before `animation_reviewed` can pass, inspect the assembled character in an isolated Godot QA composition using the project's 1280×720 gameplay viewport, then review a 800×450 downscale. Compare against the approved front/profile/back views and record whether the silhouette, role/gear read, key action pose, and ground contact remain clear at the actual on-screen size. Keep this QA scene outside the runtime main scene until art gates pass.

Review neutral/grounded idle, automatic movement, attack, hit, and defeat as authored or otherwise supported by that character's approved rig plan. For each reviewed action, capture the actual combined pose or clip at both resolutions. The fixed-angle joint sweep in the generic workbench is only a seam diagnostic; it does not define or certify an action range. Use per-character joint ranges derived from authored action clips or explicitly reviewed pose specifications, and label the source of those ranges. If standard-manifest preview has only neutral pose, animation review remains open.

## Pilot-specific disposition

The later Krita cleanup export for CIPHER candidate 01 passes the mechanical alpha/margin audit and preserves source RGB. It remains quarantined because alpha cleanliness does not establish semantic part boundaries. A Godot test now confirms the provisional head-composite transform around one proposed neck socket across five small rotations. It does not test torso contact or full-body movement. The candidate includes hood, hair, face, optic, and collar in one image; the torso/collar overlap and final pivot still require a complete character assembly review.

CIPHER atlas candidates 01 and 02 remain quarantined. Candidate 02 yielded 18 alpha-connected review crops, but its diagnostic shows clipped/duplicated or ambiguous limb forms. It has no reliable semantic map or authored pivots and is not rig input. The original individually prompted `head_hood_hair_neck` export failed its alpha/margin audit; the later Krita cleanup export passes that mechanical audit and has more vertical breathing room. Both remain quarantined because the collar boundary, torso overlap, final pivot, and full-body semantic map are still unresolved. Do not treat clean alpha or a transform smoke test as production readiness.

The static cutout audit reports edge margins and low-alpha pixels outside a 3 px dilation of the silhouette. It makes these mechanical checks repeatable but cannot identify whether each pixel belongs to the intended part.

## CIPHER side-profile cutout rig pilot — 2026-10-25 UTC

A first complete set of separately named visible-profile cutouts was derived from the approved side turnaround, with a 60 px alpha safety border and a source-bounds manifest. This avoids generated atlas ambiguity and preserves the approved visible silhouette. However, the flattened view has no concealed pixels to support joint flex: matching a static assembly does not prove seam quality after rotation. The Godot candidate keeps the limbs mostly rigid in the tested poses. Far-side anatomy, authored pivots, overlap paint, and continuous deformation still require review. The candidate remains quarantined and must not be treated as production art.

## Ten-recruit visible-profile mesh preflight — 2026-10-25 UTC

For BULWARK, SPARK, SPECTER, IRONCLAD, STITCH, RECOIL, ECHO, VECTOR, DEADLOCK, and GLITCH, a source-preserving right-profile extraction plus triangulated Godot mesh is a useful **deformation preflight** when a flattened turnaround is the available input. Exterior neutral-board pixels are made transparent; the character RGB is preserved. PolyRig triangulation/geodesic weights (with bounded engine fallbacks) are used to exercise a shared 19-bone skeleton candidate. This creates a testable starting point without pretending the source image contains separable limbs.

The result is still one flattened texture per recruit. It does not contain semantic parts, occluded anatomy, far-side limbs, authored pivots, accessory/weapon/drone attachments, or proven character-specific deformation. Generic pose-state calls and structural tests are not authored animation clips. Before reuse beyond a quarantined test, review actual deformed captures, then author and validate independent parts and hidden underpaint per the workflow above.

The first display-rendered pass exposed two rigging pitfalls: `Polygon2D` bone binding paths are relative to its `Skeleton2D` (as PolyRig's own `sync_bone()` implementation does), and weighted vertices, mesh-node offset, skeleton origin, and source ground landmark must share one coordinate frame. A headless pass alone did not detect the resulting invisible mesh. Keep both a path-resolution assertion and a real-render capture with a visible-pixel assertion in the batch harness. The resulting six-pose captures are useful for catching gross deformation, but do not replace semantic seam and animation review.


## CIPHER pilot follow-up - semantic pass is distinct from alpha and rig tests

The candidate-01 cutouts passed mechanical alpha checks and a structural Godot pose test, but a labeled 100% contact sheet revealed neighboring anatomy in some named parts and doubtful lower-limb mapping. Those tests were insufficient to establish semantic correctness. Candidate 02 then exposed a visible hole from mutually exclusive masks (96.25% source-core coverage) and was rejected. Candidate 03 removes that particular gap (99.63% coverage), but remains a review candidate until every individual part is checked at 100%, the neutral assembly is compared to the reference, pivots are authored, and deformed poses are inspected. For future recruits, maintain these separate gates: alpha geometry, source-silhouette coverage, semantic-part isolation/completeness, and rendered animation quality.


## Automated report wording and thresholds

Mechanical alpha/margin and source-silhouette coverage tools must report only mechanical results. A tool pass must leave semantic visual review, anatomy, pivots, and deformation explicitly unverified. The CIPHER pilot now has a regression audit that encodes this distinction. Its 99% coverage cutoff is a provisional intake threshold, not approval. Use labeled contact sheets and 100% crop inspection for the semantic gate.


## Candidate 04 follow-up - coverage is a separate gate

CIPHER candidate 04 achieves 100% thresholded source-silhouette coverage and clean margins for all ten candidate cutouts, but this does not establish that each layer contains only its named anatomy or has safe overlap for movement. The same candidate remains quarantined until 100% layer-by-layer inspection and rendered seam review. Keep source coverage, alpha geometry, semantic isolation, completeness, authored pivots, and deformation as separate checks.


## Candidate 05 follow-up - source ownership map found a boundary collision

A source-aligned ownership map showed candidate 04 assigning the rear hood region to both `backpack_mount` and `head_hood_hair_face`. Candidate 05 excludes the head/hood mask from the backpack mask. The diagnostic overlap count fell from 9,205 to 4,549 pixels while thresholded source-silhouette coverage remained 100%. This corrects one measured duplication only; candidate 05's semantic labels remain unreviewed and its torso/limb overlap, hidden anatomy, pivots, and deformation remain open. Keep it quarantined until the complete review gate passes.

## Candidate 05 checkerboard screen - 2026-10-25

Use an explicit checkerboard when presenting alpha cutouts; a viewer's gray/white transparency background can look like a pale art patch. The CIPHER candidate-05 native-resolution board clarified that the backpack's gray-looking area was transparent. The same screen flags `near_thigh` as an incomplete waistband/shorts fragment and a detached neighboring strip in `torso_jacket`; `pelvis_belt_gear` needs closer review. Candidate 05 is `PREVIEW_SCREEN_FAIL`, not rig input. This is preliminary file-based screening only; the complete 100% Krita review and the pivots/deformation gates remain open.


## Equipment and ability presentation

Follow [`ATTACHMENT_FUNCTION_CONTRACT.md`](ATTACHMENT_FUNCTION_CONTRACT.md) when preparing weapons, drones, accessories, cyberware, cables, and cloth. The combat director emits generic resolved-attack events through the main-scene router; this hook does not mean a weapon, drone, or signature ability has been implemented. Keep source-backed ability links distinct from open behavior details.

## Exporting edited OpenRaster layers to a review candidate

Use `tools/art/export_reviewed_openraster_parts.py` only after an artist has authored and named semantic part layers in one of the quarantined Tier I edit workspaces. It exports only layers explicitly selected by a JSON manifest; it does not segment reference images or infer names, anatomy, pivots, sockets, or behavior. It preserves the full source canvas and layer offsets. Reference, guide, diagnostic, underpaint, and pivot layers are not exportable. Selected layers must be leaves at full opacity using normal source-over compositing and must contain visible alpha pixels.

Example equipment entry (review metadata only; event names remain unresolved until the combat simulation defines them):

```json
{
  "schema_version": 1,
  "character_id": "SPARK",
  "tier_id": 1,
  "parts": [
    {
      "part_id": "attack_drone_01",
      "layer_name": "ATTACHMENT - attack drone 01 as an independent articulated attachment",
      "category": "drone",
      "attachment_role_id": "spark.attack_drone_01",
      "owner_character_id": "SPARK",
      "known_behavior": "One of exactly three roster-backed attack-drone identities; combat effects are simulation-owned.",
      "function_status": "source_backed",
      "presentation_triggers": ["UNRESOLVED"],
      "gameplay_authority": "combat_simulation"
    }
  ]
}
```

Run it with an output folder that does not already exist and remains under that character's `tier_01_drafts/` directory:

```powershell
python tools/art/export_reviewed_openraster_parts.py <workspace.ora> <selection.json> assets/characters/spark/tier_01_drafts/review_candidate_01_QUARANTINED
```

The exporter rejects blank layers, duplicate part IDs, missing attachment role IDs, mismatched owners, non-normal opacity/compositing, unsafe paths, non-quarantined source workspaces, and any output outside the draft quarantine. Multiple visual parts may share one `attachment_role_id`; runtime `attachment_id` values remain null in the art export and are assigned per owner instance later. The output includes canvas-aligned PNG layers, hashes, alpha bounds, and a review-only manifest. It never writes runtime art or marks pivots, animation, gameplay behavior, or production gates complete. The current twelve workspaces still contain blank layers; regressions confirm that blank equipment layers are refused in all twelve. Krita edits and visual/semantic review remain prerequisites.

## Extracting a clearly isolated prop from a flattened turnaround

`tools/art/extract_reference_prop_candidate.py` can make a quarantined static cutout when an approved reference shows one complete, visually isolated prop (for example, SPARK's three separate drones). The manifest must provide a crop, an explicit background seed, an object seed, and a safety margin for each item. The tool floods near-background pixels from the crop edge and keeps only the foreground component connected to the object seed; it does not infer semantic ownership or repair hidden surfaces. It preserves source RGB and records the source hash, crop coordinates, seed, alpha bounds, and a null pivot. Output is restricted to the matching recruit's `tier_01_drafts/` directory and refuses overwrite.

Example:

```powershell
python tools/art/extract_reference_prop_candidate.py tools/art/spark_drone_cutout_candidate_01.json assets/characters/spark/tier_01_drafts/attachment_cutout_candidate_01
```

Run `tools/art/audit_semantic_cutout.py` on each output and inspect the full-size PNGs over a checkerboard. These checks only screen alpha geometry; they do not establish complete surfaces, mechanical construction, attachment transforms, semantic boundaries, animation readiness, or gameplay behavior. Keep every output quarantined until it passes the separate visual, pivot, deformation, and event-integration gates.

After the pixels are reviewed, run `tools/art/audit_reference_prop_candidate.py <candidate_dir>`. This verifies the source file and item hashes, exact RGB preservation for every opaque pixel, zero pixel overlap between extracted items, the transparent safety margin, and the same mechanical alpha screen. A PASS still leaves semantic completeness, pivots, articulation, animation, and production gates false. The tool writes `source_fidelity_report.json` beside the review candidate and refuses to overwrite an existing report.
## Manually traced source-pixel cutouts

For a visible item embedded in a flattened approved turnaround, `tools/art/extract_traced_reference_parts.py <manifest.json> <new_candidate_dir>` accepts manually traced integer source-pixel polygons and produces canvas-aligned PNGs in a new quarantined directory. It supports disjoint polygons within one semantic attachment, records source/upstream hashes, rejects overlapping visible ownership, and keeps pivots, semantic review, deformation, and runtime flags false. It does not infer anatomy or fill hidden surfaces. Review every cutout at 100% on a checkerboard and in its registered neutral assembly before rigging. `tools/art/ironclad_back_cable_candidate_01.json` is an example manifest, not a production template.

