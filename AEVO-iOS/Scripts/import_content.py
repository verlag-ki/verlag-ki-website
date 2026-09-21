#!/usr/bin/env python3
"""Convert the authored source files. Review state is carried over unchanged."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def sources(items):
    return [{"title": s["title"], "url": s["url"]} for s in items]

def main():
    q = json.loads((ROOT / "ContentInputs/AEVO_800_Aufgaben.json").read_text())
    c = json.loads((ROOT / "ContentInputs/AEVO_300_Lernkarten.json").read_text())
    questions = []
    for item in q["questions"]:
        assert set(item["correct_option_ids"]) == {o["id"] for o in item["options"] if o["correct"]}
        review = item["review"]
        approved = bool(review.get("release_ready") and review.get("independent_reviewer") and review.get("independently_approved_on"))
        questions.append(dict(id=item["id"], version=item["version"], field=item["handlungsfeld"],
            competency=item["competency"], family=item["family_id"], topic=item["family_title"],
            objective=item["learning_objective"], context=item["context"], prompt=item["question"],
            options=[{k: o[k] for k in ("id", "text", "explanation")} for o in item["options"]],
            correctIDs=item["correct_option_ids"], explanation=item["explanation"],
            sources=sources(item["sources"]), approved=approved, reviewedOn=review.get("independently_approved_on"), reviewedBy=review.get("independent_reviewer")))
    cards = []
    for item in c["cards"]:
        review = item["review"]
        approved = bool(review.get("publication_approved") and review.get("reviewed_by") and review.get("reviewed_on"))
        cards.append(dict(id=item["id"], version=item["content_version"], field=item.get("handlungsfeld"),
            competency=item.get("aevo_competency"), title=item["front"]["title"],
            explanation=item["back"]["explanation"], remember=item["back"].get("remember") or "",
            example=item["back"].get("example") or "", sources=sources(item["sources"]), approved=approved, reviewedOn=review.get("reviewed_on"), reviewedBy=review.get("reviewed_by")))
    revision_path = ROOT / "ContentInputs/revisions.json"
    revisions = json.loads(revision_path.read_text()) if revision_path.exists() else []
    output = dict(version=1, generatedOn="2026-09-21", questions=questions, cards=cards, revisions=revisions)
    (ROOT / "Core/Resources/catalog.json").write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print(f"{len(questions)} Aufgaben, {len(cards)} Karten. Freigegeben: {sum(x['approved'] for x in questions + cards)}.")

if __name__ == "__main__":
    main()
