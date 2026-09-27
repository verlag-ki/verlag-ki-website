import copy
import json
import unittest
from content_approval import ROOT, load_confirmation, confirmed, apply_confirmation


class ContentApprovalTests(unittest.TestCase):
    def test_confirmation_covers_current_bundle_but_not_a_changed_answer(self):
        catalog = {k: json.loads((ROOT / ("ContentPacks/aevo-de/" + k + ".json")).read_text()) for k in ["questions", "cards"]}
        practice = json.loads((ROOT / "ContentPacks/aevo-de/practice.json").read_text())
        confirmation = load_confirmation()
        items = catalog["questions"] + catalog["cards"] + practice["cases"] + practice["oral"]
        self.assertEqual(len(items), 1140)
        self.assertTrue(all(confirmed(item, confirmation) for item in items))
        changed = copy.deepcopy(catalog["questions"][0])
        changed["explanation"] = "Changed after approval"
        self.assertFalse(confirmed(changed, confirmation))
        apply_confirmation(changed, confirmation)
        self.assertFalse(changed["approved"])


if __name__ == "__main__":
    unittest.main()
