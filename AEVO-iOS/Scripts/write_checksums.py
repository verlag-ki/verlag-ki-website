#!/usr/bin/env python3
"""Rewrite Dateipruefsummen.json so the shipped manifest matches the files on disk.

Run this after every change to the project, right before handing the package over.
Build output, version control data and the manifest itself stay out of the list.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "Dateipruefsummen.json"
SKIPPED_DIRECTORIES = {".build", ".git", "DerivedData", "__pycache__", ".swiftpm"}


def tracked_files():
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file() or path == MANIFEST:
            continue
        relative = path.relative_to(ROOT)
        if SKIPPED_DIRECTORIES.intersection(relative.parts):
            continue
        yield relative, path


def main():
    checksums = {
        relative.as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
        for relative, path in tracked_files()
    }
    MANIFEST.write_text(json.dumps(checksums, ensure_ascii=False, indent=2) + "\n")
    print(f"{len(checksums)} Dateien in {MANIFEST.name} eingetragen.")


if __name__ == "__main__":
    main()
