# Geburtstags-Kalender – vorbereitet, noch ausgeschaltet

## Heute

Das Formular nimmt einen **Wunschtermin** (Datum + Startzeit) als unverbindliche Anfrage entgegen. Es gibt keine Kapazitätsprüfung.

## Stufe 1 – Regel-Kalender (fertig gebaut, per Schalter aktivierbar)

Pepelino legt im Pflegebereich unter **„Geburtstagstermine Kiel/Westerrönfeld“** fest:

- Wochentage mit Geburtstagen (Kiel öffentlich: Fr–So; Westerrönfeld: **ungeklärt**, V02)
- zusätzliche Tage (Ferien, Feiertage) und gesperrte Tage
- Zeitfenster (Beginn) und Dauer einer Feier
- Vorlauf (mind. Tage) und maximaler Vorausbuchungszeitraum
- optional: parallele Feiern je Zeitfenster (nur Anzeige)

Mit **„Kalender aktiv“** zeigt das Formular nach Datumswahl nur noch passende Zeitfenster. Das wird **zweimal** geprüft: im Browser über `GET /api/geburtstag/verfuegbarkeit?standort=kiel&datum=YYYY-MM-DD` und noch einmal serverseitig beim Absenden.

**Grenze von Stufe 1:** Die Website weiß nicht, welche Termine bereits vergeben sind. Es bleibt eine Anfrage, die Pepelino bestätigt.

Die aktuell eingetragenen Zeitfenster (11:00 / 13:30 / 16:00, 150 Minuten) sind **Platzhalter**.

Demo lokal: `BIRTHDAY_CALENDAR=demo npm run dev` (erzwingt den Kalender unabhängig vom Schalter).

## Stufe 2 – Live-Verfügbarkeit (Schnittstelle vorbereitet)

`src/lib/booking/index.ts` definiert `BookingProvider` mit `getAvailability()` und optional `reserve()`. Für Stufe 2 wird ein Adapter geschrieben und in `getBookingProvider()` zurückgegeben. Formular und API bleiben unverändert und zeigen dann „noch X frei“ bzw. „ausgebucht“.

Mögliche Anbindungen:

| Option | Aufwand | Hinweis |
|---|---|---|
| Externes Buchungssystem mit API (z. B. bookingkit, SimplyBook.me, Anny) | mittel | Pepelino pflegt Kapazitäten dort; Anzahlung/Online-Zahlung möglich |
| Eigene kleine Datenbank + Mitarbeiter-Ansicht | höher | volle Kontrolle, eigener Betrieb und Datenschutz nötig |
| Google-Kalender je Standort als Belegungsquelle | gering–mittel | pragmatisch, aber Fehleranfälligkeit bei manueller Pflege |

## Vor dem Einschalten zu klären

1. Buchbare Wochentage je Standort (insbesondere Westerrönfeld)
2. Echte Zeitfenster und Dauer
3. Wie viele Feiern gleichzeitig (Tische, Kabinen, Nischen)
4. Mindestvorlauf; Umgang mit Ferien und Feiertagen
5. Ob verbindliche Buchung mit Anzahlung gewünscht ist (dann Stufe 2 + Zahlungsanbieter + AGB)
