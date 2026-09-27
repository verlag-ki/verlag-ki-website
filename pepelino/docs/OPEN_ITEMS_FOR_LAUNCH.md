# Offene Punkte für den Livegang

Diese Liste blockiert die Demo nicht. Sie ist die minimale Kundenfreigabe vor einer Veröffentlichung. IDs verweisen auf `src/content/verification-queue.ts`.

## A. Fragen an Pepelino (Fakten)

| # | Frage | Prio |
|---|---|---|
| V01 | Kiel: Gilt für Eis/Slush im Geburtstagspaket 1,50 € oder 2,00 €? | P0 |
| V02 | Westerrönfeld: An welchen Wochentagen sind Geburtstage buchbar? | P0 |
| V04 | Welche Telefonnummer gilt für die Zentrale: 0431 533 330 oder 0431 533 33 30? Hat Kiel eine eigene Standortnummer? | P0 |
| V05 | Welche E-Mail gilt für Westerrönfeld, und wohin sollen Geburtstags-, Gruppen- und Kontaktanfragen je Standort gehen? | P0 |
| V03 | Welche Heißgetränke sind im Paket Pepe Large enthalten? | P1 |
| V06 | Öffnungszeiten in Ferien und an Feiertagen je Standort – und wer pflegt sie künftig? | P1 |
| V08 | Gibt es Gruppen-/Schulangebote und Sonderzeiten auch in Westerrönfeld? Preise für Gruppen? | P1 |
| V09 | Sind die Speisekarten 10/2025 aktuell? Bitte Transkription in `src/content/menus.ts` gegenlesen (inkl. Pizza-/fritz-Preise, Apfelschorle Kiel). Wo hängen gedruckte QR-Codes? | P1 |
| V07 | Dürfen Kennzahlen (Rollrutsche > 45 m, Hallenfläche) verwendet werden? | P2 |
| V10 | Gehört das Fußballfeld (32 × 15 m) zum Pepelino-Eintritt? | P2 |
| – | Soll das Hygienekonzept-URL mit 410 enden oder weiterleiten? | P2 |
| – | Welche Social-Media-Profile sind die offiziellen (je ein Facebook/YouTube-Link)? | P2 |
| – | Gutscheine: Ist der moinmoinKIEL-Shop weiterhin der gewünschte Online-Kanal? | P2 |

## B. Rechte & Recht

- [ ] **Bildrechte** für alle 15 Fotos klären oder neue Fotos produzieren (V11). Bis dahin nichts veröffentlichen.
- [ ] Logo: Freigabe für Web-Nutzung liegt durch Übergabe vor – ggf. Vektordatei (SVG) nachliefern.
- [ ] **Impressum** neu erstellen/prüfen: § 5 DDG, vertretungsberechtigte Person/Komplementärin, einheitliche E-Mail, OS-Plattform-Hinweis entfernen (V12).
- [ ] **Datenschutzerklärung** neu erstellen: Hosting, Formulare/Mail-Dienst, Google Maps, Speicherfristen.
- [ ] Consent-Lösung für Google Maps festlegen (aktuell Zwei-Klick ohne Speicherung).

## C. Technik

- [ ] Pflegebereich produktiv schalten: GitHub-Modus + Zugänge fürs Team (oder Keystatic Cloud), siehe `docs/PFLEGE.md`.
- [ ] Geburtstags-Kalender: Wochentage, Zeitfenster, Kapazität festlegen, dann einschalten – siehe `docs/GEBURTSTAGSKALENDER.md`.
- [ ] Hosting wählen (Node.js-fähig; Server Actions benötigen Laufzeit) und Domain/SSL einrichten.
- [ ] Mail-Transport implementieren (`InquiryTransport`), Empfänger konfigurieren, Testversand, Spam-Schutz ergänzen.
- [ ] Weiterleitungen laut `docs/SEO_MIGRATION.md` inkl. Search-Console-Abgleich.
- [ ] `SITE_INDEXABLE=true`, `NEXT_PUBLIC_SITE_URL` setzen; Vorschau-Balken verschwindet automatisch.
- [ ] Nach Klärung aller Punkte Status in `src/content/*` auf `client_approved` setzen → Prüfmarker verschwinden.
- [ ] Echter Test auf iOS Safari und Android Chrome; Messung der Core Web Vitals im Feld.
