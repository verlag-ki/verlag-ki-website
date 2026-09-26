# Inhaltsprüfung

Status je Angabe steht maschinenlesbar in `src/content/*` (`provenance.verificationStatus`). Offene Punkte: `src/content/verification-queue.ts`. In der Vorschau zeigen gelbe Marker „in Prüfung“ (widersprüchlich) bzw. „offen“ (unbelegt) die betroffenen Stellen.

**Hinweis:** „verified_public“ heißt *öffentlich belegt*, nicht *vom Kunden bestätigt*. Noch ist keine Angabe `client_approved`.

## Öffentlich belegt (verified_public)

| Bereich | Angabe |
|---|---|
| Adressen | Göteborgring 83, 24109 Kiel · Am Busbahnhof 16, 24784 Westerrönfeld |
| Öffnungszeiten (beide) | Mo–Do geschlossen, Fr 14–19 Uhr, Sa & So 11–19 Uhr |
| Eintritt Kiel | Kinder < 2 J. 4 €, ab 2 J. 14 €, Kind mit Behinderung 8,50 €, Erwachsene 7 €, Ü65 4 €, Erwachsene mit Behinderung 4 € |
| Eintritt Westerrönfeld | Kinder ≤ 2 J. 4 €, ab 2 J. 12 €, Kind mit Behinderung 8,50 €, Erwachsene 6 €, Ü65 4 €, Erwachsene mit Behinderung 4 € |
| Pakete Kiel | Small 16,90 €, Medium 21,90 €, Large 24,90 € pro Kind, ab 5 Kindern |
| Pakete Westerrönfeld | Small 16,90 €, Medium 19,90 €, Large 22,90 € pro Kind, ab 5 Kindern, Slush bis 1,50 € |
| Kiel Kabine/Nische | Nische 20 €, Kabine 35 € |
| Kiel Buchungstage | Fr–So, Feiertage und Ferien |
| Kiel Mitbringregel | Torte/Kuchen/Muffins, kleiner Obst-/Gemüseteller erlaubt; sonst keine eigenen Speisen/Getränke |
| FAQ | Socken-Pflicht, keine Straßenschuhe, kostenlose Parkplätze, EC ab 10 €, Gutscheine an der Kasse |
| Attraktionen Kiel | Klettervulkan (4 Routen, 130 Griffe, 5,50 m), 12 Trampoline/4 Bungee, Kartbahn (1 €), Hüpfburgen, Kletterpark, Fußball 32 × 15 m, Kleinkinderbereich, Bumper Cars, Rollrutsche |
| Attraktionen RD | Dreirad, Go-Kart, zweibahnige Riesenrutsche, Walrutsche, Gastronomie, Geburtstagsbereich; Kletterlandschaft + Trampoline nur per Galeriefoto |
| Speisekarten | Alle Positionen der Kartenbilder 10/2025 (transkribiert) |
| Zentrale | Mo–Fr 10–14 Uhr, info@pepelino-fun.de |
| RD-Telefon | 04331 437 090 9 |
| Firma | Kids World Kiel GmbH & Co. KG, HRA 10389 KI, AG Kiel, USt-ID DE 296833322 |

## Widersprüchlich (conflicting_public)

| ID | Thema | Werte | Umgang in der Demo |
|---|---|---|---|
| V01 | Slush-Wert Kiel | 1,50 € (Standortseite) vs. 2,00 € (Geburtstagsseite, Karte 10/2025) | ohne Wertgrenze, markiert |
| V02 | Buchungstage RD | Mo–So vs. Fr–So + Ferien/Feiertage | keine Tage behauptet, markiert |
| V03 | Kaffee im Paket Large | Spezialität vs. Filterkaffee/Tee vs. Becher | neutral „Kaffee oder Tee“, markiert |
| V04 | Telefon Zentrale | 0431 533 330 vs. 0431 533 33 30 | Mehrheitswert, markiert; nicht im JSON-LD |
| V05 | E-Mail RD | rendsburg@pepelino-fun.de vs. pepelino-rendsburg@gmx.de vs. info@sfc-mettenhof.de | sichtbarer Wert, markiert; nicht im JSON-LD |
| V06 | Ferien/Feiertage | Kiel 12–19 Uhr (nur Kartenbild) vs. „siehe Hauptseite“ | Kiel angezeigt + markiert, RD „bitte erfragen“ |
| V09 | QR-Kartenstand | 2023 vs. 10/2025 | QR-Seiten nutzen die 10/2025-Daten |
| – | Menü-Zuordnungen | Pizza-Preis für alle drei Sorten? Fritz-Preis für alle Sorten? Cola-Größen | markiert |

## Unbelegt (unknown)

| ID | Thema | Umgang |
|---|---|---|
| V08 | Gruppenangebot Westerrönfeld | wählbar, Konditionen „auf Anfrage“, markiert |
| – | Apfelschorle Kiel, „weitere Backwaren“ | „Preis vor Ort“ |
| – | Ferien/Feiertage RD | Hinweis auf Nachfrage |
| – | Vertretungsberechtigte Person im Impressum | als fehlend gekennzeichnet |

## Bewusst nicht übernommen

- Superlative/Kennzahlen: „einmalig in Schleswig-Holstein“, „über 45 Meter“, „über 2.000 m²“, „2000 m²“ (V07).
- Englischer Vorlagenrest „Arden McClain – Katy's Dad“ (E03/E04).
- Link auf `/kindergeburtstaganmeldung/` (404, E01) – jetzt 308-Weiterleitung auf `/kindergeburtstag-kiel/`.
- Kieler Buchungsadresse `info@sfc-mettenhof.de` in der RD-FAQ (E06) und Kabinen/Nischen-Frage für RD (E07).
- Pandemie-Hygienekonzept (E09).
- Google-Bewertungs-Aufforderung und jegliche Bewertungs-/Testimonial-Inhalte.
- Tippfehler („Pepeplino“, „Goggle“, „Bumber“) – korrigiert (E16).

## Formularfelder – bewusste Reduktion

| Bisher | Neu | Begründung |
|---|---|---|
| Geschlecht des Geburtstagskindes | entfällt | nicht notwendig |
| Name Geburtstagskind | nur Vorname | für das Namensschild |
| Uhrzeit „von – bis“ (Freitext) | Wunsch-Startzeit (Auswahl) | Endzeit ergibt sich aus Absprache |
| Kabine/Nische (Kiel) | bleibt, nur Kiel | in RD nicht angeboten |
| Einwilligungstext | Datenschutzhinweis-Bestätigung | Verarbeitung zur Vertragsanbahnung; juristisch finalisieren |
