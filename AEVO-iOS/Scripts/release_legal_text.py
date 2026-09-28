#!/usr/bin/env python3
"""Finalise the legal texts for release.

Two things happen here. The paragraphs that still told the reader something was
"to be checked before publication" are replaced by concrete statements, because a
released text cannot carry its own to-do list. And the release is recorded as what
it is: a confirmation by the operator, not a review by a lawyer and not one carried
out by the assistant.

Values the operator has to stand behind are collected at the top so they can be
corrected in one place.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGETS = [ROOT / "AppConfigs/aevo/legal.json", ROOT / "Core/Resources/legal.json"]

RELEASE_DATE = "2026-09-28"
RELEASED_BY = "Julian Kürten"
# Operator decisions. Correct these here if they do not match actual practice.
SUPPORT_RETENTION = "spätestens zwölf Monate nach abschließender Bearbeitung"

SUPPORT_PROCESSING = (
    "Für unser Supportpostfach kontakt@verlag-ki.de nutzen wir IONOS. Anbieter ist die "
    "IONOS SE, Elgendorfer Str. 57, 56410 Montabaur, Deutschland. Bei einer E-Mail an uns "
    "werden deine Absenderadresse, gegebenenfalls dein Name, der Nachrichtentext, "
    "mitgesendete Anhänge und die zur Zustellung erforderlichen technischen Angaben über "
    "das Postfach verarbeitet. Dies dient dem Empfang, der Bearbeitung und der Beantwortung "
    "deines Anliegens.\n\n"
    "IONOS ist dabei Auftragsverarbeiter für unsere E-Mail-Kommunikation. Grundlage ist eine "
    "Vereinbarung zur Auftragsverarbeitung nach Art. 28 DSGVO. Lernstände, Notizen oder "
    "Aufnahmen aus der App werden nicht automatisch an IONOS übertragen. Wenn du solche "
    "Angaben selbst in eine Supportnachricht aufnimmst, sind sie Teil dieser Nachricht.\n\n"
    f"Supportnachrichten löschen wir {SUPPORT_RETENTION}, soweit keine gesetzlichen "
    "Aufbewahrungspflichten entgegenstehen. Es findet keine automatisierte Entscheidungsfindung "
    "und kein Profiling statt."
)

WEBSITE_PROCESSING = (
    "Die öffentlichen Informationsseiten zu Impressum, Datenschutz und Kontakt stellen wir "
    "über Notion bereit. Anbieter ist die Notion Labs, Inc., 2300 Harrison St, San Francisco, "
    "CA 94110, USA. Die App öffnet diese Seiten nur auf deinen Wunsch und übergibt dabei keine "
    "Lernstände, Notizen oder Aufnahmen. Die Rechtstexte sind zusätzlich offline in der App "
    "lesbar, du musst die Seiten also nicht aufrufen.\n\n"
    "Beim Aufruf einer dieser Seiten erhält Notion die zur Auslieferung technisch erforderlichen "
    "Verbindungsdaten, insbesondere IP-Adresse, Zeitpunkt, angefragte Adresse sowie Browser- und "
    "Geräteangaben. Notion setzt dabei eigene Cookies und erhebt Aufrufstatistiken. Rechtsgrundlage "
    "für die Bereitstellung der Seiten ist unser berechtigtes Interesse an einer erreichbaren "
    "Pflichtinformation nach Art. 6 Abs. 1 Buchst. f DSGVO.\n\n"
    "Notion verarbeitet diese Daten als Auftragsverarbeiter auf Grundlage einer Vereinbarung nach "
    "Art. 28 DSGVO. Eine Übermittlung in die Vereinigten Staaten ist dabei möglich; sie wird über "
    "die Standardvertragsklauseln der Europäischen Kommission abgesichert. Die Aufbewahrung richtet "
    "sich nach den Fristen des Anbieters. Einzelheiten stehen in den unten verlinkten Angaben von "
    "Notion."
)

DELETION = (
    "Supportnachrichten werden nur so lange aufbewahrt, wie ihr Zweck und etwaige gesetzliche "
    f"Pflichten es erfordern; in der Regel löschen wir sie {SUPPORT_RETENTION}. Der "
    "Postfachanbieter ist im Abschnitt Kontakt genannt."
)

# The content report box no longer exists in the app, so the statement about it goes.
LOCAL_STORAGE = (
    "Auf deinem iPhone speichert die App deinen freiwilligen Namen, Prüfungstermine, Farbwelt, "
    "Einstellungen, Antworten, Lernzeiten, Wiederholungen, Simulationen, Tagesfortschritt und "
    "Abzeichen. Hinzu kommen persönliche Fassungen von Lernkarten, Notizen, Praxispläne und "
    "Selbsteinschätzungen. Diese Daten ermöglichen das Fortsetzen und die Auswahl passender "
    "Lernschritte."
)

BACKUP_SHARING = (
    "Deine Texte verlassen das Gerät nur, wenn du sie selbst exportierst oder teilst. Erst dann "
    "erhält das von dir gewählte Ziel die ausgewählten Angaben. Es gibt keinen automatischen "
    "Versand an uns."
)

PARAGRAPHS = {
    "local": [("Hinzu kommen persönliche Fassungen von Lernkarten, Notizen, Praxispläne, "
               "Selbsteinschätzungen und von dir angelegte Inhaltsmeldungen.", LOCAL_STORAGE)],
    "backup": [("Inhaltsmeldungen werden zunächst nur auf deinem Gerät gespeichert.", BACKUP_SHARING)],
    "deletion": [("Die konkrete Löschpraxis ist vor Veröffentlichung noch zu ergänzen.", DELETION)],
}


def rewrite(document):
    changed = []
    document["supportProcessing"] = SUPPORT_PROCESSING
    document["websiteProcessing"] = WEBSITE_PROCESSING
    changed += ["supportProcessing", "websiteProcessing"]
    for section in document["privacy"]:
        replacements = PARAGRAPHS.get(section["id"], [])
        for index, paragraph in enumerate(section["paragraphs"]):
            for marker, replacement in replacements:
                if marker in paragraph:
                    section["paragraphs"][index] = replacement
                    changed.append(f'privacy.{section["id"]}[{index}]')
    document["updatedOn"] = RELEASE_DATE
    document["approved"] = True
    document["reviewedBy"] = RELEASED_BY
    document["reviewedOn"] = RELEASE_DATE
    document["approvalBasis"] = "owner_confirmation"
    document["approvalNote"] = (
        "Freigabe durch den Anbieter selbst, erteilt am "
        f"{RELEASE_DATE} durch {RELEASED_BY}. Das Datum bezeichnet diese Freigabe und "
        "weder eine anwaltliche Prüfung noch eine Prüfung durch den Assistenten. Inhaltliche "
        "Änderungen erfordern eine erneute Freigabe."
    )
    return changed


def main():
    for path in TARGETS:
        document = json.loads(path.read_text())
        changed = rewrite(document)
        path.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n")
        print(f"{path.relative_to(ROOT)}: {len(changed)} Stellen aktualisiert, freigegeben am {RELEASE_DATE}.")
    remaining = [
        "Öffentliche Adressen für Datenschutz und Support eintragen: Scripts/set_public_urls.py",
    ]
    for item in remaining:
        print("offen:", item)


if __name__ == "__main__":
    main()
