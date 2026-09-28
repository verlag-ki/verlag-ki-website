#!/usr/bin/env python3
"""Enter the public privacy, imprint and support addresses into the app.

Apple requires a privacy address that anyone can open without signing in, and a
reader has to be able to reach it too. A private Notion address answers with the
Notion shell and none of the text, so this script fetches each address without
credentials and refuses one whose page cannot be read.

    python3 Scripts/set_public_urls.py \\
        --privacy https://<name>.notion.site/... \\
        --support https://<name>.notion.site/... \\
        [--imprint https://<name>.notion.site/...]

Use --skip-check only when there is no network from here; then open each address
in a private browser window yourself before relying on it.
"""
import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
CONFIGS = [ROOT / "AppConfigs/aevo.json", ROOT / "Core/Resources/app-config.json"]
LEGAL = [ROOT / "AppConfigs/aevo/legal.json", ROOT / "Core/Resources/legal.json"]
# Addresses that are private work links rather than published pages.
PRIVATE_HOSTS = {"app.notion.com", "www.notion.so", "notion.so"}
UNKNOWN_PATH = "/diese-seite-gibt-es-nicht-" + "9f3a7c21"


def get(url):
    """Fetch without credentials. Returns (body, error)."""
    request = urllib.request.Request(url, headers={"User-Agent": "aevo-release-check"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            if response.status != 200:
                return None, f"antwortet mit HTTP {response.status}"
            return response.read(400_000), None
    except (urllib.error.URLError, urllib.error.HTTPError, OSError) as error:
        return None, f"nicht abrufbar: {error}"


def check_public(url):
    """Report why an address is not usable as a public page, or None if it is.

    Notion and similar hosts render their pages in the browser, so the fetched HTML
    of a published page contains no readable text. Searching for words in it would
    reject correct addresses. What does distinguish them: an unknown path on the same
    host returns the host's generic page, and a published page does not.
    """
    parsed = urlparse(url)
    if parsed.scheme != "https" or not parsed.hostname:
        return "keine gültige HTTPS-Adresse"
    if parsed.username or parsed.password:
        return "enthält Zugangsdaten"
    if parsed.hostname in PRIVATE_HOSTS:
        return f"{parsed.hostname} ist eine private Arbeitsadresse, keine veröffentlichte Seite"
    page, error = get(url)
    if error:
        return error
    baseline, error = get(f"{parsed.scheme}://{parsed.netloc}{UNKNOWN_PATH}")
    if error is None and page == baseline:
        return "liefert dasselbe wie eine unbekannte Adresse, ist also nicht veröffentlicht"
    return None


def write(paths, values):
    for path in paths:
        document = json.loads(path.read_text())
        document.update({key: value for key, value in values.items() if value is not None})
        path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n")
        print(f"  eingetragen in {path.relative_to(ROOT)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--privacy", required=True)
    parser.add_argument("--support", required=True)
    parser.add_argument("--imprint")
    parser.add_argument("--skip-check", action="store_true")
    options = parser.parse_args()

    supplied = {"privacyURL": options.privacy, "supportURL": options.support}
    if options.imprint:
        supplied["imprintURL"] = options.imprint

    problems = []
    for name, url in supplied.items():
        if options.skip_check:
            print(f"{name}: ungeprüft übernommen")
            continue
        reason = check_public(url)
        print(f"{name}: {'öffentlich lesbar' if reason is None else 'ABGELEHNT, ' + reason}")
        if reason:
            problems.append(f"{name}: {reason}")
    if problems:
        sys.exit("Nichts geändert. " + " | ".join(problems))

    write(CONFIGS, supplied)
    # The legal document carries the two addresses it names in its own text.
    write(LEGAL, {key: value for key, value in supplied.items() if key != "imprintURL"})
    print("\nJetzt die Release-Sperre prüfen:")
    print("  python3 Scripts/validate_release.py Core/Resources/SelectedPack")


if __name__ == "__main__":
    main()
