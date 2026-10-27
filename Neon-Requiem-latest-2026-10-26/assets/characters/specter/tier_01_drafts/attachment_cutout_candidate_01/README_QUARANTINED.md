# SPECTER Tier I traced source-pixel cutouts

Status: QUARANTINED REVIEW CANDIDATE; not rig input or runtime art.

The polygons were explicitly supplied in the source manifest. This tool only masks the selected source pixels; it does not infer semantic ownership, fill hidden anatomy, create pivots, or validate deformation. Godot 4.7.2 confirmed the exposed hilt's 1 contour and exposed blade body's 16 contours all triangulate through PolyRig, with static native-scale texture/render differences under 0.24% and zero fully opaque interior changes. The blade's multiple contours remain separate meshes under the one candidate semantic owner. This is only mesh-input and raster-preservation evidence: the hidden grip, weapon pivot, hand attachment, stow relationship, and deformation are unresolved. Review every part at 100% and in a neutral assembly before any rig work.
