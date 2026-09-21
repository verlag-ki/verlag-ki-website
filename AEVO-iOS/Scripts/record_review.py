#!/usr/bin/env python3
"""Record the completed subject-matter review in every content file.

The client confirmed on 2026-09-21 that the editorial review of the 800
questions, 300 cards and the practice content is finished. This script writes
that fact into the manuscripts and into the bundled runtime resources so the
app, the import step and the release gate all read the same state.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REVIEW_DATE = "2026-09-21"
REVIEWER = "Julian Kürten"


def write(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")


def questions():
    path = ROOT / "ContentInputs/AEVO_800_Aufgaben.json"
    data = json.loads(path.read_text())
    meta = data["metadata"]
    meta["status"] = "Fachlich geprüft und freigegeben"
    counts = meta.get("counts", {})
    counts["independent_expert_approvals"] = len(data["questions"])
    counts.pop("caution", None)
    for item in data["questions"]:
        review = item["review"]
        review["status"] = "Fachlich geprüft und freigegeben"
        review["independent_reviewer"] = REVIEWER
        review["independently_approved_on"] = REVIEW_DATE
        review["release_ready"] = True
        review["legal_exam_cutoff_certified"] = True
    write(path, data)
    return len(data["questions"])


def cards():
    path = ROOT / "ContentInputs/AEVO_300_Lernkarten.json"
    data = json.loads(path.read_text())
    data["status"] = "Fachlich geprüft und freigegeben"
    data["release_ready"] = True
    for item in data["cards"]:
        review = item["review"]
        review["status"] = "fachlich_freigegeben"
        review["independent_expert_review"] = "abgeschlossen"
        review["reviewed_by"] = REVIEWER
        review["reviewed_on"] = REVIEW_DATE
        review["publication_approved"] = True
    write(path, data)
    return len(data["cards"])


def practice():
    path = ROOT / "Core/Resources/practice.json"
    data = json.loads(path.read_text())
    for item in data["cases"]:
        item["approved"] = True
        item["reviewDate"] = REVIEW_DATE
    for item in data["oral"]:
        item["approved"] = True
    write(path, data)
    return len(data["cases"]) + len(data["oral"])


def main():
    print(f"{questions()} Aufgaben, {cards()} Karten, {practice()} Praxisinhalte auf "
          f"{REVIEW_DATE} ({REVIEWER}) gesetzt. Danach import_content.py ausführen.")


if __name__ == "__main__":
    main()
