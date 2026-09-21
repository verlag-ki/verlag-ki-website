#!/usr/bin/env python3
"""Portable integrity checks. They do not replace xcodebuild or a device test."""
import json
import plistlib
import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main():
    catalog = json.loads((ROOT / "Core/Resources/catalog.json").read_text())
    originals = json.loads((ROOT / "ContentInputs/AEVO_800_Aufgaben.json").read_text())["questions"]
    cards = json.loads((ROOT / "ContentInputs/AEVO_300_Lernkarten.json").read_text())["cards"]
    assert len(catalog["questions"]) == len(originals) == 800
    assert len(catalog["cards"]) == len(cards) == 300
    original_by_id = {x["id"]: x for x in originals}
    for question in catalog["questions"]:
        original = original_by_id[question["id"]]
        assert set(question["correctIDs"]) == set(original["correct_option_ids"])
        assert question["prompt"] == original["question"]
        assert question["explanation"] == original["explanation"]
        assert {o["id"] for o in question["options"]} == {o["id"] for o in original["options"]}
        assert question["approved"] == bool(original["review"]["release_ready"] and original["review"]["independent_reviewer"])
        assert question["correctIDs"] and set(question["correctIDs"]).issubset({o["id"] for o in question["options"]})
        for source in question["sources"]: assert source["url"].startswith("https://")
    for card, original in zip(catalog["cards"], cards):
        assert card["id"] == original["id"]
        assert card["title"] == original["front"]["title"]
        assert card["explanation"] == original["back"]["explanation"]
        assert card["remember"] == (original["back"].get("remember") or "")
        assert card["example"] == (original["back"].get("example") or "")
    for key in ["questions", "cards"]: assert len({x["id"] for x in catalog[key]}) == len(catalog[key])
    practice = json.loads((ROOT / "Core/Resources/practice.json").read_text())
    assert len(practice["cases"]) == 16 and len(practice["oral"]) == 24
    assert len({x["id"] for x in practice["cases"]}) == 16
    assert all(x["approved"] for x in practice["cases"] + practice["oral"])
    info = plistlib.loads((ROOT / "Configuration/Info.plist").read_bytes())
    assert info["NSMicrophoneUsageDescription"]
    project = (ROOT / "AEVO.xcodeproj/project.pbxproj").read_text()
    for swift in (ROOT / "App").glob("*.swift"): assert swift.relative_to(ROOT).as_posix() in project, swift
    for path in re.findall(r'"path" = "([^"$]+)";', project):
        if not path.endswith(".app"): assert (ROOT / path).exists(), path
    for name in ["Info.plist", "PrivacyInfo.xcprivacy"]:
        plistlib.loads((ROOT / "Configuration" / name).read_bytes())
    scheme = ET.parse(ROOT / "AEVO.xcodeproj/xcshareddata/xcschemes/AEVOLernen.xcscheme")
    assert scheme.find("LaunchAction").attrib["buildConfiguration"] == "Debug"
    for reference in scheme.findall(".//BuildableReference"): assert reference.attrib["BlueprintIdentifier"] in project
    storekit = json.loads((ROOT / "Configuration/Tips.storekit").read_text())
    assert [x["displayPrice"] for x in storekit["products"]] == ["2.99", "5.99", "9.99"]
    assert all(x["type"] == "Consumable" for x in storekit["products"])
    source = (ROOT / "App/TipStore.swift").read_text()
    assert all(x["productID"] in source for x in storekit["products"])
    icon = json.loads((ROOT / "App/Assets.xcassets/AppIcon.appiconset/Contents.json").read_text())
    for image in icon["images"]: assert (ROOT / "App/Assets.xcassets/AppIcon.appiconset" / image["filename"]).exists()
    print(json.dumps({"status": "passed", "questions": 800, "cards": 300, "branching_cases": 16, "oral_prompts": 24,
        "fields": dict(Counter(q["field"] for q in catalog["questions"])),
        "independently_approved": sum(x["approved"] for x in catalog["questions"] + catalog["cards"]),
        "app_swift_files": len(list((ROOT / "App").glob("*.swift"))), "native_build_verified": False}, ensure_ascii=False, indent=2))

if __name__ == "__main__": main()
