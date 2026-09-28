# Freigabe der Rechtstexte und öffentliche Seiten

Stand: 28. September 2026. Dieser Abschnitt löst die entsprechenden Zeilen in `VEROEFFENTLICHUNG_0_3_2.md` ab.

## Was freigegeben ist

Julian Kürten hat die Rechtstexte als Anbieter freigegeben. Der Vermerk in `legal.json` sagt genau das: `approvalBasis` ist `owner_confirmation`, dazu Name und Datum. Es wird weder eine anwaltliche Prüfung noch eine Prüfung durch den Assistenten behauptet. Inhaltliche Änderungen an den Texten erfordern eine erneute Freigabe.

Die inhaltliche Sperre und die Sperre wegen fehlender rechtlicher Freigabe sind damit offen. `Scripts/validate_release.py` meldet nur noch die beiden öffentlichen Adressen.

## Was an den Texten geändert wurde

Ein freigegebener Text kann dem Leser nicht mitteilen, dass daran noch etwas zu prüfen sei. Vier solche Absätze sind durch konkrete Aussagen ersetzt:

- **Supportpostfach.** IONOS als Auftragsverarbeiter nach Art. 28 DSGVO, Löschung der Supportnachrichten spätestens zwölf Monate nach abschließender Bearbeitung, keine automatisierte Entscheidungsfindung.
- **Öffentliche Seiten.** Notion Labs, Inc. als Anbieter mit Anschrift, benannte Verbindungsdaten, Cookies und Aufrufstatistiken, Art. 6 Abs. 1 Buchst. f DSGVO als Grundlage, Auftragsverarbeitung nach Art. 28 DSGVO und Standardvertragsklauseln für die Übermittlung in die Vereinigten Staaten.
- **Speicherdauer.** Dieselbe Frist von zwölf Monaten, ohne den früheren Vorbehalt.
- **Inhaltsmeldungen.** Zweimal gestrichen, weil es die Funktion in der App nicht mehr gibt. Die verbliebene Liste gespeicherter Meldungen ist ebenfalls aus den Einstellungen entfernt; ältere Einträge bleiben in den Daten und in Sicherungen lesbar.

Drei Angaben darin verantwortet der Anbieter und niemand sonst: die Vereinbarung zur Auftragsverarbeitung mit IONOS, dieselbe mit Notion und die Löschfrist von zwölf Monaten. Stimmen sie mit der tatsächlichen Praxis nicht überein, werden sie an einer Stelle geändert, in `Scripts/release_legal_text.py`, danach das Skript erneut ausführen.

## Öffentliche Seiten in Notion

Die drei Seiten sind fertig und tragen nicht mehr den Zusatz Entwurf:

| Seite | Zweck |
|---|---|
| Impressum · aevo. | Anbieterangaben nach § 5 DDG |
| Datenschutzerklärung · aevo. | vollständiger Text, wortgleich mit der App |
| Kontakt & Support · aevo. | Supportweg und häufige Fragen |

Alle drei entstehen aus `Core/Resources/legal.json`. `Scripts/render_public_pages.py` gibt sie als Markdown aus, damit Web und App nicht auseinanderlaufen.

**Der letzte Schritt geht nicht über die Schnittstelle.** Die Freigabe zum Web lässt sich nur in Notion selbst umlegen. Der Konnektor kann Seiten anlegen und schreiben, aber nicht veröffentlichen. Ein Abruf der bisherigen Adresse ohne Anmeldung wurde geprüft: die Seite antwortet mit HTTP 200, liefert aber nur die Notion-Hülle mit Anmeldeverweis und kein Wort des Textes.

Vorgehen: die drei Unterseiten einzeln über Teilen im Web veröffentlichen, die Arbeitsübersicht dabei privat lassen, weil Notion Unterseiten mitveröffentlicht. Danach die ausgegebenen Adressen eintragen:

```bash
python3 Scripts/set_public_urls.py \
    --privacy https://<name>.notion.site/... \
    --support https://<name>.notion.site/...
```

Das Skript ruft jede Adresse ohne Zugangsdaten ab und lehnt sie ab, wenn die Seite keinen Inhalt liefert. Es schreibt danach in App-Konfiguration und Rechtstextquelle.

## Warum die Sperre jetzt mehr prüft

Eine private Arbeitsadresse ist syntaktisch eine gültige HTTPS-Adresse. Die Release-Sperre hätte sie durchgelassen, und die App wäre mit einem Datenschutzlink erschienen, den niemand ohne Notion-Konto öffnen kann. `Scripts/validate_release.py` weist Adressen auf `app.notion.com`, `notion.so`, `docs.google.com` und `drive.google.com` jetzt ausdrücklich zurück. Zwei Prüfungen in `Scripts/test_release_gate.py` sichern das ab.

## Geprüft

66 Swift-Kerntests, 17 Python-Tests, Syntax aller 22 App-Dateien, Projektintegrität. Die generierte Demo-App bleibt bei 66 Tests ohne Fehler. Kein nativer Build und kein iPhone-Test.
