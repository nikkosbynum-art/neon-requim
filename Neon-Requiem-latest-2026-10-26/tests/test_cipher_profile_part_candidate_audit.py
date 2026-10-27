import unittest
import json
from pathlib import Path
from PIL import Image, ImageChops

from tools.art.audit_cipher_profile_part_candidate import ROOT, audit_candidate, audit_exit_code


class CipherProfilePartCandidateAuditTests(unittest.TestCase):
    def audit(self, name):
        return audit_candidate(ROOT / 'assets/characters/cipher/tier_01_drafts' / name)

    def test_candidate_01_mechanical_pass_does_not_approve_semantics(self):
        result = self.audit('reference_cutout_rig_candidate_01')
        self.assertEqual(result['status'], 'MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED')
        self.assertEqual(result['mechanical_status'], 'MECHANICAL_PASS')
        self.assertAlmostEqual(result['source_coverage_ratio'], 0.9940, places=3)
        self.assertFalse(result['production_approved'])
        self.assertEqual(result['semantic_visual_review'], 'NOT_AUTOMATED_OR_VERIFIED')

    def test_candidate_02_is_rejected_for_assembly_coverage(self):
        result = self.audit('reference_cutout_rig_candidate_02')
        self.assertEqual(result['status'], 'MECHANICAL_FAIL')
        self.assertLess(result['source_coverage_ratio'], 0.99)
        self.assertEqual(result['missing_source_core_pixels'], 5021)

    def test_candidate_03_is_mechanical_only_and_stays_quarantined(self):
        result = self.audit('reference_cutout_rig_candidate_03')
        self.assertEqual(result['status'], 'MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED')
        self.assertAlmostEqual(result['source_coverage_ratio'], 0.9963, places=3)
        self.assertEqual(result['missing_source_core_pixels'], 496)
        self.assertFalse(result['production_approved'])

    def test_candidate_04_is_mechanically_clean_but_semantic_screen_failed(self):
        result = self.audit('reference_cutout_rig_candidate_04')
        self.assertEqual(result['status'], 'MECHANICAL_PASS_SEMANTIC_SCREEN_FAIL')
        self.assertEqual(result['mechanical_status'], 'MECHANICAL_PASS')
        self.assertEqual(result['source_coverage_ratio'], 1.0)
        self.assertEqual(result['missing_source_core_pixels'], 0)
        self.assertEqual(result['extra_core_pixels'], 0)
        self.assertEqual(result['semantic_visual_review'], 'PREVIEW_SCREEN_FAIL')
        self.assertEqual(result['full_resolution_krita_review'], 'NOT_VERIFIED')
        self.assertFalse(result['production_approved'])
        self.assertEqual(audit_exit_code(result), 2)

    def test_candidate_05_preserves_coverage_after_head_backpack_boundary_change(self):
        result = self.audit('reference_cutout_rig_candidate_05')
        self.assertEqual(result['status'], 'MECHANICAL_PASS_SEMANTIC_SCREEN_FAIL')
        self.assertEqual(result['mechanical_status'], 'MECHANICAL_PASS')
        self.assertEqual(result['source_coverage_ratio'], 1.0)
        self.assertEqual(result['missing_source_core_pixels'], 0)
        self.assertEqual(result['extra_core_pixels'], 0)
        self.assertEqual(result['semantic_visual_review'], 'PREVIEW_SCREEN_FAIL')
        self.assertEqual(result['semantic_review_evidence'], 'docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_05_QUARANTINED.png')
        self.assertEqual(result['full_resolution_krita_review'], 'NOT_VERIFIED')
        self.assertFalse(result['production_approved'])
        self.assertEqual(audit_exit_code(result), 2)

    def test_candidate_06_leg_overlap_revision_remains_quarantined(self):
        result = self.audit('reference_cutout_rig_candidate_06')
        self.assertEqual(result['status'], 'MECHANICAL_PASS_VISUAL_REVIEW_REQUIRED')
        self.assertEqual(result['source_coverage_ratio'], 1.0)
        self.assertEqual(result['missing_source_core_pixels'], 0)
        self.assertEqual(result['extra_core_pixels'], 0)
        self.assertEqual(result['semantic_visual_review'], 'NOT_VERIFIED')
        self.assertEqual(result['semantic_review_evidence'], 'docs/visual_qa/CIPHER_T1_PARTS_CONTACT_SHEET_06_QUARANTINED.png')
        self.assertEqual(result['full_resolution_krita_review'], 'NOT_VERIFIED')
        self.assertFalse(result['production_approved'])
        self.assertTrue(all(part['status'] == 'PASS' for part in result['parts'].values()))
        candidate_dir = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06'
        manifest = json.loads((candidate_dir / 'parts_manifest.json').read_text(encoding='utf-8'))

        def source_aligned_core(semantic):
            info = manifest['parts'][semantic]
            x0, y0, x1, y1 = info['source_bbox_xyxy']
            pad = info['padding_px']
            with Image.open(candidate_dir / info['file']) as opened:
                alpha = opened.convert('RGBA').getchannel('A')
            core = alpha.crop((pad, pad, pad + x1 - x0, pad + y1 - y0))
            core = core.point(lambda value: 255 if value >= 32 else 0)
            aligned = Image.new('L', (330, 960), 0)
            aligned.paste(core, (x0, y0))
            return aligned

        for parent, child in (('near_thigh', 'near_shin'), ('near_shin', 'near_boot')):
            shared = ImageChops.multiply(source_aligned_core(parent), source_aligned_core(child))
            self.assertGreater(shared.histogram()[255], 0, f'{parent}/{child} must retain source overlap')


if __name__ == '__main__':
    unittest.main()
