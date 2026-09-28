"""Prevent accidental publication with draft or incomplete legal information."""
import copy
import json
import os
import re
import subprocess
import sys
import textwrap
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


    def test_every_file_the_gate_opens_is_declared_as_a_build_input(self):
        """Xcode sandboxes the run script: it may read only its declared input files.

        A declared folder does not cover the files inside it, which once made the archive
        fail on Scripts/validate_release.py. This runs the gate, records every project file
        it opens, and compares that with the inputs in the generated project.
        """
        tracer = textwrap.dedent(f"""
            import json, runpy, sys
            from pathlib import Path
            root = Path({str(ROOT)!r}).resolve()
            seen = set()
            def hook(event, args):
                if event != "open":
                    return
                try:
                    path = Path(str(args[0])).resolve()
                except Exception:
                    return
                if path.is_file() and path.is_relative_to(root):
                    seen.add(path.relative_to(root).as_posix())
            sys.addaudithook(hook)
            sys.path.insert(0, str(root / "Scripts"))
            sys.argv = ["validate_release.py", str(root / "Core/Resources/SelectedPack")]
            try:
                runpy.run_path(str(root / "Scripts/validate_release.py"), run_name="__main__")
            except SystemExit:
                pass
            print("FILES", json.dumps(sorted(seen)))
        """)
        # Same environment as the build phase, so the run is comparable.
        environment = {**os.environ, "PYTHONDONTWRITEBYTECODE": "1",
                       "PYTHONPYCACHEPREFIX": tempfile.mkdtemp(prefix="gate-pycache-")}
        result = subprocess.run([sys.executable, "-c", tracer], capture_output=True,
                                text=True, env=environment)
        self.assertEqual(result.returncode, 0, result.stderr)
        opened = json.loads(result.stdout.rsplit("FILES", 1)[1])
        project = (ROOT / "LearningApp.xcodeproj/project.pbxproj").read_text()
        block = re.search(r'"inputPaths" = \((.*?)\);', project, re.S)
        declared = set(re.findall(r'\$\(SRCROOT\)/([^"]+)"', block.group(1)))
        undeclared = sorted(f for f in opened if f not in declared)
        self.assertEqual(undeclared, [], "nicht als Build-Eingabe deklariert")
        self.assertIn("Scripts/validate_release.py", declared)


if __name__ == "__main__":
    unittest.main()
