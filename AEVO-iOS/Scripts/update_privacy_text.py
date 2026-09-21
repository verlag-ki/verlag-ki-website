#!/usr/bin/env python3
"""Bring the bundled privacy statement in line with the 0.3.4 interface.

Two features it described are gone: the local content reports and the permanent
"never ask again" switches for review and tip hints. The statement must not keep
promising either of them.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEGAL = ROOT / "Core/Resources/legal.json"

REPLACEMENTS = [
    ("Hinzu kommen persönliche Fassungen von Lernkarten, Notizen, Praxispläne, "
     "Selbsteinschätzungen und von dir angelegte Inhaltsmeldungen.",
     "Hinzu kommen persönliche Fassungen von Lernkarten, Notizen, Praxispläne und "
     "Selbsteinschätzungen."),
    ("Aktive Lernzeit und bisherige Anfragen werden nur lokal ausgewertet, damit "
     "Bewertungs- und Trinkgeldhinweise selten bleiben. Du kannst beide Hinweise in "
     "den Einstellungen dauerhaft abschalten.",
     "Aktive Lernzeit und bisherige Anfragen werden nur lokal ausgewertet, damit "
     "Bewertungs- und Trinkgeldhinweise selten bleiben. Sie erscheinen höchstens nach "
     "einer abgeschlossenen Lernrunde und nicht in der Woche vor einem eingetragenen "
     "Prüfungstermin."),
    ("Inhaltsmeldungen werden zunächst nur auf deinem Gerät gespeichert. Erst wenn du "
     "einen Bericht selbst teilst oder versendest, erhält das von dir gewählte Ziel die "
     "ausgewählten Angaben. Es gibt keinen automatischen Versand an uns.",
     "Deine Texte verlassen das Gerät nur, wenn du sie selbst teilst oder exportierst. "
     "Erst dann erhält das von dir gewählte Ziel die ausgewählten Angaben. Es gibt "
     "keinen automatischen Versand an uns."),
]


def main():
    document = json.loads(LEGAL.read_text())
    applied = 0
    for section in document["privacy"]:
        updated = []
        for paragraph in section["paragraphs"]:
            for old, new in REPLACEMENTS:
                if old in paragraph:
                    paragraph = paragraph.replace(old, new)
                    applied += 1
            updated.append(paragraph)
        section["paragraphs"] = updated
    missing = len(REPLACEMENTS) - applied
    if missing:
        raise SystemExit(f"{missing} Textstellen nicht gefunden. Datenschutztext bitte prüfen.")
    LEGAL.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n")
    print(f"{applied} Absätze im Datenschutztext aktualisiert.")


if __name__ == "__main__":
    main()
