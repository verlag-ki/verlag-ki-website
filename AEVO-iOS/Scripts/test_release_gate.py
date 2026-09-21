"""Prevent accidental publication with draft or incomplete legal information."""
import copy
import json
import tempfile
import unittest
from pathlib import Path
from validate_release import legal_issues, release_issues

ROOT = Path(__file__).resolve().parents[1]


class ReleaseGateTests(unittest.TestCase):
    def setUp(self):
        self.legal = json.loads((ROOT / "Core/Resources/legal.json").read_text())

    def complete_fixture(self):
        value = copy.deepcopy(self.legal)
        value.update(approved=True, reviewedBy="Test fixture", reviewedOn="2026-09-20",
                     privacyURL="https://example.org/privacy", supportURL="https://example.org/support",
                     supportProcessing="Test fixture only", websiteProcessing="Test fixture only")
        value["operatorInfo"].update(name="Test fixture", address="Test fixture", email="test@example.org")
        return value

    def test_current_bundle_passes_content_review_but_still_needs_legal_information(self):
        issues = release_issues(ROOT / "Core/Resources/catalog.json")
        self.assertFalse(any("Inhalte haben" in item for item in issues))
        self.assertTrue(any("privacyURL" in item for item in issues))

    def test_a_single_unreviewed_item_still_blocks_the_release(self):
        with tempfile.TemporaryDirectory() as folder:
            directory = Path(folder)
            (directory / "catalog.json").write_text(json.dumps(
                {"questions": [{"id": "fixture-q", "approved": True}], "cards": [{"id": "fixture-c", "approved": False}]}))
            (directory / "practice.json").write_text(json.dumps({"cases": [], "oral": []}))
            (directory / "legal.json").write_text(json.dumps(self.complete_fixture()))
            issues = release_issues(directory / "catalog.json")
            self.assertEqual(issues, [issues[0]])
            self.assertIn("1 Inhalte haben", issues[0])

    def test_approval_flag_alone_cannot_release_incomplete_documents(self):
        self.legal["approved"] = True
        issues = legal_issues(self.legal)
        self.assertTrue(any("geprüft" in item for item in issues))
        self.assertTrue(any("privacyURL" in item for item in issues))

    def test_completed_fixture_and_rejected_unsafe_link(self):
        value = self.complete_fixture()
        self.assertEqual(legal_issues(value), [])
        value["privacyURL"] = "javascript:alert(1)"
        self.assertTrue(any("privacyURL" in item for item in legal_issues(value)))
        value["privacyURL"] = "https://person:secret@example.org/privacy"
        self.assertTrue(any("privacyURL" in item for item in legal_issues(value)))

    def test_approved_content_still_blocks_incomplete_legal_information(self):
        with tempfile.TemporaryDirectory() as folder:
            directory = Path(folder)
            (directory / "catalog.json").write_text(json.dumps({"questions": [{"id": "fixture-q", "approved": True}], "cards": []}))
            (directory / "practice.json").write_text(json.dumps({"cases": [], "oral": []}))
            (directory / "legal.json").write_text(json.dumps(self.legal))
            issues = release_issues(directory / "catalog.json")
            self.assertTrue(any("privacyURL" in item for item in issues))
            self.assertFalse(any("Inhalte haben" in item for item in issues))


if __name__ == "__main__":
    unittest.main()
