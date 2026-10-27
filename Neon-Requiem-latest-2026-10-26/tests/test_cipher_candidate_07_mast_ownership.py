import json
from pathlib import Path
import unittest

from PIL import Image, ImageChops, ImageDraw

from tools.art.audit_cipher_profile_part_candidate import ROOT, audit_candidate
from tools.art.extract_cipher_profile_parts_candidate_02 import remove_exterior_board


class CipherCandidate07MastOwnershipTests(unittest.TestCase):
    def test_signal_mast_is_owned_by_backpack_not_head(self):
        candidate = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07'
        manifest = json.loads((candidate / 'parts_manifest.json').read_text(encoding='utf-8'))
        adjustment = manifest['ownership_adjustment']
        self.assertEqual(adjustment['from'], 'head_hood_hair_face')
        self.assertEqual(adjustment['to'], 'backpack_mount')
        source = remove_exterior_board(Image.open(ROOT / manifest['source']).crop(
            tuple(manifest['crop_xywh'][i] for i in (0, 1)) +
            (manifest['crop_xywh'][0] + manifest['crop_xywh'][2],
             manifest['crop_xywh'][1] + manifest['crop_xywh'][3])
        ))
        expected = Image.new('L', source.size, 0)
        ImageDraw.Draw(expected).polygon(adjustment['source_crop_polygon_xy'], fill=255)
        expected = ImageChops.multiply(
            expected,
            source.getchannel('A').point(lambda alpha: 255 if alpha >= 32 else 0),
        )
        expected_count = expected.histogram()[255]
        self.assertGreater(expected_count, 100)

        def aligned_part(name):
            info = manifest['parts'][name]
            x0, y0, x1, y1 = info['source_bbox_xyxy']
            pad = info['padding_px']
            with Image.open(candidate / info['file']) as opened:
                alpha = opened.convert('RGBA').getchannel('A')
            core = alpha.crop((pad, pad, pad + x1 - x0, pad + y1 - y0))
            core = core.point(lambda value: 255 if value >= 32 else 0)
            aligned = Image.new('L', source.size, 0)
            aligned.paste(core, (x0, y0))
            return aligned

        backpack = aligned_part('backpack_mount')
        head = aligned_part('head_hood_hair_face')
        self.assertEqual(ImageChops.multiply(expected, head).histogram()[255], 0)
        self.assertEqual(ImageChops.multiply(expected, backpack).histogram()[255], expected_count)

    def test_mast_remap_keeps_source_silhouette_and_quarantine(self):
        result = audit_candidate(
            ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07'
        )
        self.assertEqual(result['mechanical_status'], 'MECHANICAL_PASS')
        self.assertEqual(result['source_coverage_ratio'], 1.0)
        self.assertEqual(result['missing_source_core_pixels'], 0)
        self.assertEqual(result['extra_core_pixels'], 0)
        self.assertEqual(result['semantic_visual_review'], 'NOT_VERIFIED')
        self.assertFalse(result['production_approved'])
        self.assertTrue(all(part['status'] == 'PASS' for part in result['parts'].values()))

    def test_user_approved_hand_jacket_occlusion_stays_explicit(self):
        candidate = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_07'
        manifest = json.loads((candidate / 'parts_manifest.json').read_text(encoding='utf-8'))
        interpretation = manifest['approved_semantic_interpretations']['hand_jacket_occlusion']
        self.assertEqual(interpretation['status'], 'USER_APPROVED_INTERPRETATION_2026-10-25')
        self.assertEqual(interpretation['visible_hand_owner'], 'near_hand')
        self.assertEqual(interpretation['jacket_owner'], 'torso_jacket')
        self.assertTrue(interpretation['jacket_continues_behind_hand'])
        self.assertEqual(interpretation['visible_hand_pixels_must_not_be_owned_by'], 'pelvis_belt_gear')
        self.assertEqual(interpretation['required_draw_order_back_to_front'], ['torso_jacket', 'near_hand'])
        self.assertEqual(interpretation['underpaint_status'], 'NOT_AUTHORED')
        self.assertEqual(
            interpretation['underpaint_provenance_if_added'],
            'INFERRED_NOT_VISIBLE_IN_FLATTENED_SOURCE',
        )
        self.assertEqual(manifest['semantic_review_status'], 'NOT_VERIFIED')
        self.assertFalse(manifest['production_approved'])

        order = manifest['layer_order_back_to_front']
        self.assertLess(order.index('torso_jacket'), order.index('near_hand'))
        self.assertLess(order.index('pelvis_belt_gear'), order.index('near_hand'))

        def aligned_part(name):
            info = manifest['parts'][name]
            x0, y0, x1, y1 = info['source_bbox_xyxy']
            pad = info['padding_px']
            with Image.open(candidate / info['file']) as opened:
                alpha = opened.convert('RGBA').getchannel('A')
            core = alpha.crop((pad, pad, pad + x1 - x0, pad + y1 - y0))
            core = core.point(lambda value: 255 if value >= 32 else 0)
            aligned = Image.new('L', (330, 960), 0)
            aligned.paste(core, (x0, y0))
            return aligned

        hand = aligned_part('near_hand')
        pelvis = aligned_part('pelvis_belt_gear')
        torso = aligned_part('torso_jacket')
        forearm = aligned_part('near_forearm')
        self.assertEqual(ImageChops.multiply(hand, pelvis).histogram()[255], 0)
        self.assertEqual(ImageChops.multiply(hand, torso).histogram()[255], 0)
        self.assertGreater(ImageChops.multiply(hand, forearm).histogram()[255], 0)


if __name__ == '__main__':
    unittest.main()
