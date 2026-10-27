import tempfile
import unittest
import json
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET
import zipfile

from PIL import Image

from tools.art.build_krita_authoring_workspace import ROOT, build_workspace


class KritaAuthoringWorkspaceBuilderTests(unittest.TestCase):
    def build(self, candidate, temp_dir):
        source = ROOT / 'assets/characters/cipher/tier_01_drafts' / candidate
        return build_workspace(source, Path(temp_dir) / 'review.ora')

    def test_candidate_04_workspace_has_reference_and_hidden_semantic_layers(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = self.build('reference_cutout_rig_candidate_04', temp)
            with zipfile.ZipFile(output) as archive:
                self.assertEqual(archive.read('mimetype'), b'image/openraster')
                layers = ET.fromstring(archive.read('stack.xml')).findall('./stack/layer')
                self.assertEqual(len(layers), 12)
                self.assertEqual(sum(layer.attrib['visibility'] == 'hidden' for layer in layers), 10)
                self.assertEqual(sum(layer.attrib['visibility'] == 'visible' for layer in layers), 2)
                for layer in layers:
                    self.assertEqual(Image.open(archive.open(layer.attrib['src'])).size, (330, 960))
                self.assertEqual(Image.open(archive.open('mergedimage.png')).size, (330, 960))

    def test_candidate_05_workspace_preserves_the_review_candidate_layers(self):
        source = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_05'
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = build_workspace(source, Path(temp) / 'candidate05.ora')
            with zipfile.ZipFile(output) as archive:
                layers = ET.fromstring(archive.read('stack.xml')).findall('./stack/layer')
                self.assertEqual(len(layers), 12)
                self.assertEqual(sum(layer.attrib['visibility'] == 'hidden' for layer in layers), 10)
                with archive.open('mergedimage.png') as merged_file:
                    with Image.open(merged_file) as merged:
                        self.assertEqual(merged.size, (330, 960))

    def test_candidate_06_workspace_preserves_source_aligned_joint_overlap_layers(self):
        source = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_06'
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = build_workspace(source, Path(temp) / 'candidate06.ora')
            with zipfile.ZipFile(output) as archive:
                layers = ET.fromstring(archive.read('stack.xml')).findall('./stack/layer')
                self.assertEqual(len(layers), 12)
                self.assertEqual(sum(layer.attrib['visibility'] == 'hidden' for layer in layers), 10)
                self.assertEqual(sum(layer.attrib['visibility'] == 'visible' for layer in layers), 2)
                for layer in layers:
                    with archive.open(layer.attrib['src']) as layer_file:
                        with Image.open(layer_file) as layer_image:
                            self.assertEqual(layer_image.size, (330, 960))
                with archive.open('mergedimage.png') as merged_file:
                    with Image.open(merged_file) as merged:
                        self.assertEqual(merged.size, (330, 960))

    def test_candidate_01_negative_part_offsets_clip_without_shifting_reference(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = self.build('reference_cutout_rig_candidate_01', temp)
            with zipfile.ZipFile(output) as archive:
                layers = ET.fromstring(archive.read('stack.xml')).findall('./stack/layer')
                self.assertEqual(len(layers), 12)
                self.assertEqual(Image.open(archive.open('mergedimage.png')).size, (330, 960))

    def test_candidates_02_and_03_bbox_manifests_build_without_rescaling(self):
        for candidate in ('reference_cutout_rig_candidate_02', 'reference_cutout_rig_candidate_03'):
            with self.subTest(candidate=candidate):
                with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
                    output = self.build(candidate, temp)
                    with zipfile.ZipFile(output) as archive:
                        layers = ET.fromstring(archive.read('stack.xml')).findall('./stack/layer')
                        self.assertEqual(len(layers), 12)
                        for layer in layers:
                            self.assertEqual(Image.open(archive.open(layer.attrib['src'])).size, (330, 960))

    def test_existing_workspace_is_not_overwritten(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            output = Path(temp) / 'existing.ora'
            output.write_bytes(b'keep')
            candidate = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04'
            with self.assertRaises(FileExistsError):
                build_workspace(candidate, output)
            self.assertEqual(output.read_bytes(), b'keep')

    def copy_candidate_04(self, temp):
        source = ROOT / 'assets/characters/cipher/tier_01_drafts/reference_cutout_rig_candidate_04'
        candidate = Path(temp) / 'candidate'
        shutil.copytree(source, candidate)
        manifest_path = candidate / 'parts_manifest.json'
        manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
        return candidate, manifest_path, manifest

    def test_source_reference_cannot_escape_project_root(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            candidate, manifest_path, manifest = self.copy_candidate_04(temp)
            manifest['source'] = '../outside.png'
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'escapes its allowed directory'):
                build_workspace(candidate, Path(temp) / 'bad.ora')

    def test_part_file_cannot_escape_candidate_folder(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            candidate, manifest_path, manifest = self.copy_candidate_04(temp)
            first_part = next(iter(manifest['parts'].values()))
            first_part['file'] = '../outside.png'
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'escapes its allowed directory'):
                build_workspace(candidate, Path(temp) / 'bad.ora')

    def test_source_bbox_must_match_nontransparent_part_bounds(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            candidate, manifest_path, manifest = self.copy_candidate_04(temp)
            first_part = next(iter(manifest['parts'].values()))
            first_part['source_bbox_xyxy'][2] += 1
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'alpha bounds'):
                build_workspace(candidate, Path(temp) / 'bad.ora')

    def test_crop_cannot_extend_past_source_reference(self):
        with tempfile.TemporaryDirectory(dir=ROOT / 'tests') as temp:
            candidate, manifest_path, manifest = self.copy_candidate_04(temp)
            manifest['crop_xywh'] = [600, 10, 99999, 960]
            manifest_path.write_text(json.dumps(manifest), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'extends beyond'):
                build_workspace(candidate, Path(temp) / 'bad.ora')


if __name__ == '__main__':
    unittest.main()
