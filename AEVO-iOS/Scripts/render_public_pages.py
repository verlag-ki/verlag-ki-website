#!/usr/bin/env python3
"""Render the public Impressum, Datenschutz and Kontakt pages from the released legal text.

The app and the public pages must say the same thing, so both come from
Core/Resources/legal.json. Output is Markdown, ready to paste into the pages that
back the privacy and support addresses.
"""
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load():
    legal = json.loads((ROOT / "Core/Resources/legal.json").read_text())
    if not legal.get("approved"):
        raise SystemExit("Die Rechtstexte sind nicht freigegeben. Erst Scripts/release_legal_text.py ausführen.")
    return legal


def resolve(text, legal):
    operator = legal["operatorInfo"]
    values = {
        "operatorName": operator["name"],
        "address": operator["address"].replace("\n", ", "),
        "email": operator["email"],
        "supportProcessing": legal["supportProcessing"],
        "websiteProcessing": legal["websiteProcessing"],
    }
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def imprint(legal):
    operator = legal["operatorInfo"]
    lines = [
        f"Stand: {legal['updatedOn']}",
        "",
        "## Anbieter gemäß § 5 DDG",
        "",
        operator["name"],
        "",
        operator["address"].replace("\n", "  \n"),
        "",
        "## Kontakt",
        "",
        f"E-Mail: [{operator['email']}](mailto:{operator['email']})",
        "",
        "## Über das Angebot",
        "",
        "aevo. ist ein eigenständiges Lernangebot zur Vorbereitung auf die "
        "Ausbildereignungsprüfung. Es besteht keine Verbindung zur IHK oder DIHK. Die Aufgaben "
        "sind eigene Lernaufgaben und keine Originalprüfungsfragen. Verbindlich für deine "
        "Prüfung sind die Vorgaben deiner zuständigen Kammer.",
        "",
        "Alle veröffentlichten Lerninhalte und Funktionen bleiben kostenlos. Ein freiwilliges "
        "Trinkgeld schaltet keine Vorteile frei.",
        "",
        "## Verbraucherstreitbeilegung",
        "",
        "Wir sind nicht bereit und nicht verpflichtet, an Streitbeilegungsverfahren vor einer "
        "Verbraucherschlichtungsstelle teilzunehmen.",
    ]
    return "\n".join(lines)


def privacy(legal):
    lines = [f"Stand: {legal['updatedOn']}", ""]
    for section in legal["privacy"]:
        lines += [f"## {section['title']}", ""]
        for paragraph in section["paragraphs"]:
            lines += [resolve(paragraph, legal), ""]
        for link in section["links"]:
            lines += [f"[{link['title']}]({link['url']})", ""]
    return "\n".join(lines).rstrip() + "\n"


def contact(legal):
    operator = legal["operatorInfo"]
    lines = [
        f"Stand: {legal['updatedOn']}",
        "",
        "## So erreichst du uns",
        "",
        f"Schreib uns eine E-Mail an [{operator['email']}](mailto:{operator['email']}). Wir "
        "antworten, sobald es uns möglich ist. Ein Telefonsupport wird nicht angeboten.",
        "",
        "Bitte schreibe uns, was du in der App gemacht hast und was stattdessen passiert ist. "
        "Die Version findest du in der App unter Einstellungen.",
        "",
        "## Was die App von sich aus sendet",
        "",
        "Nichts. Lernstände, Notizen und Aufnahmen bleiben auf deinem iPhone. Wenn du in der App "
        "auf Kontakt tippst, öffnet sich nur ein vorbereiteter E-Mail-Entwurf, den du selbst "
        "prüfst und absendest. Angehängt wird dabei nichts.",
        "",
        "## Häufige Fragen",
        "",
        "**Ich habe mein iPhone gewechselt und meine Notizen sind weg.** Ohne vorher erstellten "
        "Export lässt sich ein Lernstand nicht wiederherstellen, weil er nur lokal liegt. "
        "Erstelle unter Einstellungen, Deine Daten, eine Sicherung, bevor du das Gerät wechselst.",
        "",
        "**Wie lösche ich meine Daten?** Lösche die App mit ihren Daten vom iPhone. Exportierte "
        "Dateien und Gerätesicherungen musst du gesondert löschen.",
        "",
        "**Kostet die App etwas?** Nein. Ein freiwilliges Trinkgeld ist möglich und schaltet "
        "nichts frei.",
        "",
        "## Rechtliches",
        "",
        "Anbieterangaben stehen im Impressum, die Datenverarbeitung in der Datenschutzerklärung. "
        "Beide Texte sind auch offline in der App lesbar.",
    ]
    return "\n".join(lines)


PAGES = {"impressum": imprint, "datenschutz": privacy, "kontakt": contact}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("page", choices=sorted(PAGES))
    legal = load()
    print(PAGES[parser.parse_args().page](legal))


if __name__ == "__main__":
    main()
