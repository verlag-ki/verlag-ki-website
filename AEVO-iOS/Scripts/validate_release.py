#!/usr/bin/env python3
"""Check recorded release prerequisites, not substantive legal/professional correctness."""
import json
import re
import sys
from pathlib import Path
from urllib.parse import urlparse
from content_approval import load_confirmation, confirmed
from validate_content_pack import validate


# Workspace addresses that require a sign-in instead of serving the page to everyone.
PRIVATE_PAGE_HOSTS = {"app.notion.com", "www.notion.so", "notion.so",
                      "docs.google.com", "drive.google.com"}


def present(value):
    return isinstance(value, str) and bool(value.strip())


def legal_issues(document):
    issues = []
    if document.get("version") != 1:
        issues.append("Unbekanntes Format der rechtlichen Informationen.")
    if document.get("approved") is not True or not present(document.get("reviewedBy")) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", document.get("reviewedOn", "")):
        issues.append("Impressum und Datenschutz sind noch nicht vollständig geprüft und freigegeben.")
    operator = document.get("operatorInfo", {})
    for field, label in [("name", "Anbietername"), ("address", "Anschrift"), ("email", "Kontakt-E-Mail")]:
        if not present(operator.get(field)):
            issues.append(f"{label} fehlt.")
    email = operator.get("email", "")
    if email and not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email):
        issues.append("Kontakt-E-Mail hat kein gültiges Format.")
    for field in ["privacyURL", "supportURL"]:
        value = urlparse(document.get(field, ""))
        if value.scheme != "https" or not value.hostname or value.username or value.password:
            issues.append(f"Öffentliche HTTPS-Adresse fehlt oder ist ungültig: {field}.")
        elif value.hostname in PRIVATE_PAGE_HOSTS:
            issues.append(f"{field} verweist auf eine private Arbeitsadresse ({value.hostname}), "
                          "die ohne Anmeldung keinen Inhalt zeigt. Die veröffentlichte Adresse eintragen.")
    for field in ["supportProcessing", "websiteProcessing"]:
        if not present(document.get(field)):
            issues.append(f"Verarbeitung und Löschfristen noch zu beschreiben: {field}.")
    sections = document.get("privacy", [])
    required = {"controller", "local", "permissions", "backup", "apple", "external", "deletion", "rights"}
    if not required.issubset({x.get("id") for x in sections}):
        issues.append("Datenschutzerklärung ist unvollständig.")
    return issues


def release_issues(pack_path):
    pack_path = Path(pack_path)
    # Keep the old fixture/import entry point readable for release-gate regression tests.
    if pack_path.is_file():
        catalog = json.loads(pack_path.read_text())
        practice = json.loads(pack_path.with_name("practice.json").read_text())
        legal = json.loads(pack_path.with_name("legal.json").read_text())
        items = catalog["questions"] + catalog["cards"] + practice["cases"] + practice["oral"]
        confirmation = load_confirmation()
    else:
        data = validate(pack_path, pack_path.parent / "app-config.json")
        legal = json.loads((pack_path.parent / "legal.json").read_text())
        items = data["questions"] + data["cards"] + data["practice"]["cases"] + data["practice"]["oral"]
        confirmation = load_confirmation(pack_path)
    drafts = [x["id"] for x in items if x.get("approved") is not True
              or (x.get("approvalBasis") == "owner_confirmation" and not confirmed(x, confirmation))]
    issues = []
    if drafts:
        issues.append(f"{len(drafts)} Inhalte haben keine dokumentierte Freigabe für die aktuelle Fassung.")
    issues.extend(legal_issues(legal))
    return issues


def main():
    try:
        issues = release_issues(Path(sys.argv[1]))
    except (OSError, ValueError, KeyError, IndexError, TypeError) as error:
        print(f"error: Veröffentlichungsvoraussetzungen nicht prüfbar: {error}")
        return 1
    for issue in issues:
        print(f"error: {issue}")
    if issues:
        return 1
    print("Dokumentierte Inhaltsfreigaben und Anbieterangaben vorhanden. Geräte-, Store- und Rechtsprüfung bleiben erforderlich.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
