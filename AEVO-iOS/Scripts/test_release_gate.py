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

    def test_shipped_pack_and_legal_information_are_complete(self):
        # The gate is open. Nothing here may report a missing prerequisite any more.
        self.assertEqual(release_issues(ROOT / "Core/Resources/SelectedPack"), [])

    def test_a_missing_public_address_still_blocks_the_release(self):
        for field in ["privacyURL", "supportURL"]:
            document = self.complete_fixture()
            document[field] = ""
            self.assertTrue(any(field in item for item in legal_issues(document)), field)

    def test_approval_flag_alone_cannot_release_incomplete_documents(self):
        # A release needs a recorded reviewer and date, not just the flag.
        for missing in ["reviewedBy", "reviewedOn"]:
            document = copy.deepcopy(self.legal)
            document.update(approved=True, privacyURL="https://example.org/privacy",
                            supportURL="https://example.org/support")
            document[missing] = ""
            self.assertTrue(any("geprüft" in item for item in legal_issues(document)), missing)
        # Clearing the flag itself blocks the release too.
        document = self.complete_fixture()
        document["approved"] = False
        self.assertTrue(any("geprüft" in item for item in legal_issues(document)))

    def test_private_workspace_address_is_not_accepted_as_a_public_page(self):
        value = self.complete_fixture()
        value["privacyURL"] = "https://app.notion.com/p/3e17bc57948381d9aaa2e1db1493346b"
        issues = legal_issues(value)
        self.assertTrue(any("private Arbeitsadresse" in item for item in issues))
        value["privacyURL"] = "https://aevo.notion.site/datenschutz"
        self.assertEqual(legal_issues(value), [])

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
            incomplete = self.complete_fixture()
            incomplete["privacyURL"] = ""
            (directory / "legal.json").write_text(json.dumps(incomplete))
            issues = release_issues(directory / "catalog.json")
            self.assertTrue(any("privacyURL" in item for item in issues))
            self.assertFalse(any("Inhalte haben" in item for item in issues))


if __name__ == "__main__":
    unittest.main()
