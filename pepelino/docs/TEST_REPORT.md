# Testbericht

**Datum:** 26.09.2026 · **Umgebung:** Linux-Container, Node 22.22.2, Chromium 141 (Playwright 1.56.1), Produktionsbuild (`next build` + `next start`).
Alle Angaben unten stammen aus tatsächlich ausgeführten Läufen.

## Ergebnisse

| Prüfung | Befehl | Ergebnis |
|---|---|---|
| TypeScript | `npm run typecheck` | ✅ keine Fehler |
| ESLint (next/core-web-vitals + TS) | `npm run lint` | ✅ 0 Fehler, 0 Warnungen |
| Unit-Tests (Vitest) | `npm test` | ✅ 28 / 28 |
| Build | `npm run build` | ✅ 18 Seiten + robots/sitemap/icons statisch vorgerendert |
| E2E + Barrierefreiheit (Playwright + axe) | `npm run test:e2e` | ✅ 75 bestanden, 1 übersprungen (Mobilmenü-Test läuft nur im Mobil-Profil) |

### Unit-Tests (28)
- Alle Inhaltsdateien erfüllen ihre Zod-Schemas (10 Datensätze).
- Konsistenz: drei Pakete je Standort; Kabine/Nische nur Kiel; Kieler Slush-Wert nie als bestätigt/mit Betrag; eindeutige IDs; alle Medien-Dateien vorhanden; Fotos nicht als freigegeben markiert; bestehende URL-Pfade unverändert.
- Validierung: gültige Geburtstagsanfrage; min. 5 Kinder; kein Datum in der Vergangenheit; keine Kieler Pakete/Optionen für Westerrönfeld; Datenschutz + E-Mail Pflicht; kein Geschlechtsfeld; Gruppen-Endzeit nach Beginn; Kontakt verlangt Standort; „heute“ in Europe/Berlin.

### E2E (je Desktop 1440×900 und Mobil 390×844)
- Alle 14 Routen: HTTP 200, genau eine H1, Title/Description vorhanden, Canonical auf pepelino-fun.de, `noindex` in der Vorschau, **kein horizontales Scrollen**, alle Bilder mit `alt`.
- **axe-core WCAG 2.0/2.1/2.2 A+AA: 0 Verstöße auf allen 14 Routen**, beide Viewports.
- Alle internen Links liefern 200.
- `/kindergeburtstaganmeldung/` leitet auf `/kindergeburtstag-kiel/` weiter; unbekannte URL → 404-Seite.
- robots.txt sperrt Vorschau; Sitemap enthält Kernseiten, keine QR-Seiten.
- JSON-LD: LocalBusiness mit Adresse + 2 Öffnungszeiten-Blöcken, keine Bewertungen, strittige Telefonnummer nicht ausgezeichnet, BreadcrumbList vorhanden.
- Geburtstagsformular: leeres Absenden → Fehlermeldung + Fokus auf erstes Fehlerfeld; vollständige Eingabe → „Demo: Diese Anfrage wurde nicht an Pepelino gesendet.“
- Westerrönfeld-Formular ohne Kabine/Nische; Paketkarte wählt Paket im Formular vor.
- Google Maps: vor Klick keine Anfrage an google.*; nach Klick iframe.
- Mobilmenü per Tastatur öffnen, Escape schließt.

## Lighthouse 13 (Labor, lokal)

Simulierte Drosselung (mobil: langsames 4G + 4× CPU). SEO-Wert 69 ausschließlich wegen des **gewollten** `noindex` der Vorschau (Audit „is-crawlable“); alle anderen SEO-Audits bestanden.

| Seite | Profil | Perf. | A11y | Best Pr. | SEO | LCP | CLS | TBT |
|---|---|---|---|---|---|---|---|---|
| / | mobil | 94 | 100 | 100 | 69 | 2,8 s | 0,017 | 40 ms |
| / | desktop | 99 | 100 | 100 | 69 | 0,7 s | 0,06 | 0 ms |
| /indoorspielplatz-kiel/ | mobil | 98 | 100 | 100 | 69 | 2,1 s | 0,053 | 70 ms |
| /indoorspielplatz-kiel/ | desktop | 100 | 100 | 100 | 69 | 0,7 s | 0,015 | 0 ms |
| /kindergeburtstag-kiel/ | mobil | 94 | 100 | 100 | 69 | 2,9 s | 0,022 | 40 ms |
| /kindergeburtstag-kiel/ | desktop | 100 | 100 | 100 | 69 | 0,7 s | 0,007 | 0 ms |
| /speisekarte-fuer-qr-code/ | mobil | 94 | 100 | 100 | 69 | 2,9 s | 0,009 | 40 ms |
| /speisekarte-fuer-qr-code/ | desktop | 100 | 100 | 100 | 69 | 0,6 s | 0,003 | 0 ms |

Das sind **Labordaten auf localhost**, keine Felddaten. Das LCP-Ziel ≤ 2,5 s wird mobil im Labor teils knapp verfehlt (2,8–2,9 s); INP ist im Labor nicht messbar. Erreichung der Core-Web-Vitals-Ziele ist damit **nicht belegt** – echte Messung nach Deployment (Hosting mit CDN) erforderlich.

## Behobene Befunde während der Tests
- Layout-Shift der Hero-Textkarte (CLS 0,098 → 0,06) durch obere statt mittige Ausrichtung.
- „Preise & Infos“ fälschlich als aktiv markiert auf Standortseiten.
- Doppelt verwendetes Foto (Rollrutsche/Kletterpark) und ein Foto, das nicht zur Bildunterschrift passte (Westerrönfeld „Riesenrutsche“ zeigte Klettergerüst).
- Lint-Regel `react-hooks/set-state-in-effect` im Header (Menü-Schließen auf Seitenwechsel neu gelöst).

## Nicht getestet / bekannte Grenzen
- Keine echten Mobilgeräte (iOS Safari, Android Chrome) – nur emuliertes Chromium.
- Kein Firefox/WebKit-Lauf (nur Chromium im Container verfügbar).
- Kein Screenreader-Test (NVDA/VoiceOver) – axe deckt nur automatisch prüfbare Kriterien ab.
- Kein Test des nach Klick geladenen Google-Maps-iframes gegen den echten Dienst (in E2E gemockt).
- Kein Lasttest, kein Security-Scan, keine Prüfung der Altseite über öffentliche Abrufe hinaus.
- Screenshots in `docs/screenshots/` (Startseite, Geburtstag Kiel, Standort Westerrönfeld, QR-Karte – jeweils Desktop und Mobil).
