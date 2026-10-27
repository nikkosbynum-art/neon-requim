# Assets

No production artwork or audio has been imported. See docs/ASSET_MANIFEST.md. The code-generated placeholder actor is explicitly temporary and is not stored as a production asset.

All per-character tier_01_drafts folders are excluded from Godot's automatic imports by a .gdignore marker. They hold quarantined art and test candidates; tests that need pixels read the source image files directly. This prevents draft images and workspaces from being mistaken for runtime art while keeping them available for local review.

The BREAKER and other character candidates remain non-production until their required visual, semantic-part, hidden-anatomy, pivot, and animation gates pass. See each candidate's quarantine README and the shared character-part authoring guide.
