# Pflegebereich – Anleitung für das Pepelino-Team

Unter **`/keystatic`** (z. B. `https://www.pepelino-fun.de/keystatic`) pflegt ihr Inhalte selbst – ohne Programmierkenntnisse.

## Was ihr ändern könnt

| Bereich | je Standort | Wirkt auf |
|---|---|---|
| **Öffnungszeiten** – reguläre Zeiten, dauerhafte Zusatzzeilen | Kiel / Westerrönfeld | Standortseite, Kontaktseite, Speisekarte, Footer, Startseite, Google-Daten (JSON-LD) |
| **Ferien, Feiertage & Sonderzeiten** – mit Von/Bis-Datum, Uhrzeit oder „geschlossen“ | Kiel / Westerrönfeld | erscheinen automatisch, verschwinden nach Ablauf von selbst |
| **Eintrittspreise** | Kiel / Westerrönfeld | Standortseite, Kontaktseite, Startseite |
| **Kindergeburtstag** – Pakete, Leistungen, Preise, Kabine/Nische, „Gut zu wissen“ | Kiel / Westerrönfeld | Paketübersicht **und** Anfrageformular (immer identisch) |
| **Geburtstagstermine (Kalender)** – Wochentage, Zeitfenster, Sperrtage | Kiel / Westerrönfeld | Kalender im Anfrageformular (derzeit ausgeschaltet) |
| **Speisekarte** – Abschnitte, Gerichte, Größen, Preise | Kiel / Westerrönfeld | Speisekartenseite **und** QR-Speisekarte |
| **Häufige Fragen** | beide / je Standort | Standortseiten |

Nicht im Pflegebereich (bewusst, ändert sich selten): Adressen, Texte der Seiten, Fotos, Rechtstexte.

## So geht's

1. `/keystatic` öffnen und mit GitHub anmelden (Zugang richtet die Agentur ein).
2. Links den Bereich wählen, z. B. **Kiel → Öffnungszeiten Kiel**.
3. Ändern → oben rechts **Speichern**.
4. Nach ca. 1–3 Minuten ist die Änderung live (die Seite wird automatisch neu gebaut).

**Prüfstatus:** Jede Angabe hat einen Block „Prüfung“. Wenn ihr etwas kontrolliert oder geändert habt, stellt ihn auf **„Vom Betreiber freigegeben“** und setzt das Datum. Dann verschwindet der gelbe Hinweis „in Prüfung“ auf der Website.

**Uhrzeiten** immer als `HH:MM` eingeben (`14:00`, nicht `14 Uhr`). Leer = geschlossen.

**„Technischer Schlüssel“** bei Paketen, Preisen usw. bestehender Einträge nicht ändern. Bei neuen Einträgen einen eindeutigen Namen in Kleinbuchstaben mit Bindestrichen wählen (z. B. `kiel-xl`).

## Sicherheitsnetz

- Jede Speicherung ist eine Version im Git-Verlauf – alles lässt sich zurückholen.
- Ungültige Eingaben (z. B. Enddatum vor Startdatum, fehlende Uhrzeit) stoppen den Neubau; die bisherige Seite bleibt online, bis der Fehler behoben ist. Die Fehlermeldung nennt Datei und Feld.

## Technik (für die Agentur)

- Werkzeug: [Keystatic](https://keystatic.com) (`keystatic.config.ts`), Daten als JSON in `src/content/data/`, geprüft über `src/content/editable.ts` (Zod).
- **Lokal/Vorschau:** Speicherung direkt in die Dateien, kein Login.
- **Produktion:** Umgebungsvariablen `NEXT_PUBLIC_KEYSTATIC_STORAGE=github`, `NEXT_PUBLIC_KEYSTATIC_GITHUB_REPO=<owner>/<repo>` sowie die von Keystatic erzeugten `KEYSTATIC_GITHUB_CLIENT_ID`, `KEYSTATIC_GITHUB_CLIENT_SECRET`, `KEYSTATIC_SECRET` (GitHub-App-Einrichtung beim ersten Aufruf von `/keystatic`). Ohne GitHub-Modus ist `/keystatic` in Produktion gesperrt (404).
- Der Hoster muss bei jedem Commit neu bauen (z. B. Vercel/Netlify mit Git-Anbindung). Seiten mit Sonderzeiten werden zusätzlich stündlich neu erzeugt, damit abgelaufene Einträge verschwinden.
- Alternative ohne GitHub-Konten fürs Team: Keystatic Cloud (Login per E-Mail) – `cloud: { project: "…" }` in der Konfiguration.
