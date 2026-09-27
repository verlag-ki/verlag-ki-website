"""Record the owner's confirmation without inventing an independent reviewer's identity."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REVIEW_FIELDS = {"approved", "reviewedOn", "reviewedBy", "reviewDate",
                 "approvalBasis", "approvalConfirmedOn", "approvalConfirmedBy"}


def fingerprint(item):
    content = {key: value for key, value in item.items() if key not in REVIEW_FIELDS}
    return hashlib.sha256(json.dumps(content, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def load_confirmation(pack=None):
    path = (Path(pack) if pack else ROOT / "ContentPacks/aevo-de") / "approval.json"
    return json.loads(path.read_text()) if path.exists() else {}


def confirmed(item, confirmation):
    return (confirmation.get("basis") == "owner_confirmation"
            and bool(confirmation.get("confirmedBy"))
            and bool(confirmation.get("confirmedOn"))
            and confirmation.get("contentHashes", {}).get(item["id"]) == fingerprint(item))


def apply_confirmation(item, confirmation):
    if item.get("approvalBasis") == "owner_confirmation":
        item["approved"] = False
        for key in ["approvalBasis", "approvalConfirmedOn", "approvalConfirmedBy"]:
            item.pop(key, None)
    if confirmed(item, confirmation):
        item.update(approved=True, approvalBasis="owner_confirmation",
                    approvalConfirmedOn=confirmation["confirmedOn"],
                    approvalConfirmedBy=confirmation["confirmedBy"])
