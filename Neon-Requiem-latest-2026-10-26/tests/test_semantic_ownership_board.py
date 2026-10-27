import tempfile
import unittest
from pathlib import Path
import json

from PIL import Image

from tools.art.render_semantic_ownership_board import ROOT, render_ownership_board


class SemanticOwnershipBoardTests(unittest.TestCase):
    def candidate_04(self):
        return ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04'

    def test_board_preserves_native_source_scale_and_never_approves_semantics(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = Path(temp) / 'ownership.png'
            report = render_ownership_board(self.candidate_04(), output)
            self.assertEqual(report['source_crop_px'], [330, 960])
            self.assertEqual(report['part_count'], 10)
            self.assertEqual(report['scope'], 'manifest_pixel_ownership_visualization_only')
            self.assertEqual(report['semantic_correctness'], 'NOT_VERIFIED')
            self.assertFalse(report['production_approved'])
            with Image.open(output) as board:
                self.assertEqual(board.size, (990, 1060))

    def test_board_refuses_to_overwrite_existing_review(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = Path(temp) / 'ownership.png'
            output.write_bytes(b'keep')
            with self.assertRaises(FileExistsError):
                render_ownership_board(self.candidate_04(), output)
            self.assertEqual(output.read_bytes(), b'keep')

    def test_candidate_05_reduces_declared_layer_overlap_without_approving_labels(self):
        candidate_05 = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05'
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            report_04 = render_ownership_board(self.candidate_04(), Path(temp) / '04.png')
            report_05 = render_ownership_board(candidate_05, Path(temp) / '05.png')
            self.assertEqual(report_04['overlap_pixels'], 9205)
            self.assertEqual(report_05['overlap_pixels'], 4549)
            self.assertLess(report_05['overlap_pixels'], report_04['overlap_pixels'])
            pair_04 = next(pair for pair in report_04['overlap_pairs'] if {pair['part_a'], pair['part_b']} == {'backpack_mount', 'head_hood_hair_face'})
            self.assertEqual(pair_04['shared_pixels'], 4525)
            self.assertFalse(any({pair['part_a'], pair['part_b']} == {'backpack_mount', 'head_hood_hair_face'} for pair in report_05['overlap_pairs']))
            self.assertEqual(report_05['semantic_correctness'], 'NOT_VERIFIED')
            self.assertFalse(report_05['production_approved'])

    def test_board_reads_source_traced_array_manifest(self):
        candidate = ROOT / 'assets/characters/specter/tier_01_drafts/attachment_cutout_candidate_01'
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = Path(temp) / 'traced_ownership.png'
            report = render_ownership_board(candidate, output)
            self.assertEqual(report['source_crop_px'], [1536, 1024])
            self.assertEqual(report['part_count'], 2)
            self.assertEqual(report['overlap_pixels'], 0)
            self.assertEqual(report['source_reference'], 'docs/visual_qa/SPECTER_T1_CONCEPT_TURNAROUND_01_2026-10-25.png')
            self.assertEqual(report['semantic_correctness'], 'NOT_VERIFIED')
            self.assertFalse(report['production_approved'])
            self.assertTrue(output.is_file())

    def test_traced_array_rejects_duplicate_semantic_ids(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            candidate = Path(temp) / 'candidate'
            candidate.mkdir()
            Image.new('RGBA', (12, 8), (20, 30, 40, 255)).save(candidate / 'source.png')
            polygon = [[1, 1], [5, 1], [5, 5]]
            manifest = {
                'source_image': candidate.relative_to(ROOT).as_posix() + '/source.png',
                'parts': [
                    {'part_id': 'same', 'polygons_xy': [polygon]},
                    {'part_id': 'same', 'polygons_xy': [polygon]},
                ],
            }
            (candidate / 'parts_manifest.json').write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'semantic IDs must be unique'):
                render_ownership_board(candidate, Path(temp) / 'bad.png')


if __name__ == '__main__':
    unittest.main()
