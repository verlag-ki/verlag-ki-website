# Pepelino 2.0 – Relaunch-Vorschau

Lokal lauffähige Relaunch-Version von www.pepelino-fun.de auf Basis des freigegebenen, ruhigen Designentwurfs.
**Status: interne Vorschau.** Nichts hiervon ist veröffentlicht; Formulare versenden nichts, Suchmaschinen werden ausgesperrt.

## Technik

| Baustein | Version |
|---|---|
| Node.js | 22 LTS (getestet mit 22.22.2; mindestens 20.9) |
| Next.js (App Router, Turbopack) | 16.3.x |
| React | 19.3 |
| TypeScript | 5.9 |
| Tailwind CSS | 4.3 (Tokens in `src/styles/globals.css`) |
| Zod | 4.x (Inhalts- und Formularvalidierung) |
| Keystatic | 0.6 (Pflegebereich, Git-basiert, ohne Datenbank) |
| Schriften | Bricolage Grotesque + Nunito Sans, lokal via `@fontsource-variable` (SIL OFL 1.1) |
| Tests | Vitest 5, Playwright 1.56.1, axe-core |

## Start

```bash
cd pepelino
npm install
npm run dev          # http://localhost:3000
```

Produktionsbuild lokal:

```bash
npm run build
npm run start        # http://localhost:3000
```

## Prüfen

```bash
npm run typecheck    # TypeScript
npm run lint         # ESLint (next/core-web-vitals)
npm test             # Unit-Tests: Inhaltsschemas, Datenkonsistenz, Formularvalidierung
npm run build
npm run test:e2e     # Playwright gegen `next start` auf Port 3100 (Desktop 1440×900 + Mobil 390×844, inkl. axe)
node scripts/screenshots.mjs http://localhost:3100 docs/screenshots / /kindergeburtstag-kiel/
```

`npm run check` führt Typecheck, Lint, Unit-Tests und Build nacheinander aus.
Ergebnisse des letzten Laufs: [`docs/TEST_REPORT.md`](docs/TEST_REPORT.md).

## Statische Vorschau in einem Unterordner (z. B. verlag-ki.de/pepelino)

```bash
npm run build:static     # → dist-static/pepelino/ und dist-static/pepelino.zip
```

Den Ordner `pepelino/` in das Web-Verzeichnis des Servers kopieren (bei Caddy: in das `root` des `file_server`, sodass `…/pepelino/index.html` entsteht). Keine Server-Konfiguration nötig.

Unterschiede zur vollen Fassung: Formulare prüfen im Browser (weiterhin Demo, kein Versand), kein Pflegebereich, keine Kalender-API, keine Weiterleitungen/HTTP-Header (Suchmaschinen-Sperre über `noindex` in jeder Seite). Das Skript legt Server-Dateien während des Baus kurz beiseite und stellt sie danach immer wieder her.

## Umgebungsvariablen

| Variable | Standard | Zweck |
|---|---|---|
| `NEXT_PUBLIC_SITE_URL` | `https://www.pepelino-fun.de` | Basis für Canonicals, Sitemap, Open Graph |
| `SITE_INDEXABLE` | *(nicht gesetzt)* | Erst `true` erlaubt Indexierung (robots.txt, Meta-Robots, `X-Robots-Tag`) und blendet den Vorschau-Balken aus. **Nur für den freigegebenen Livegang setzen.** |
| `NEXT_PUBLIC_KEYSTATIC_STORAGE` | lokal | `github` für den Pflegebereich in Produktion (sonst ist `/keystatic` dort gesperrt). Details: `docs/PFLEGE.md` |
| `BIRTHDAY_CALENDAR` | *(nicht gesetzt)* | `demo` erzwingt den Geburtstags-Kalender (zum Vorführen) |
| `NEXT_PUBLIC_SHOW_REVIEW_MARKERS` | an | `false` blendet die gelben „in Prüfung“-Hinweise aus (z. B. für Präsentationen). Die Daten bleiben markiert. |

## Projektstruktur

```
src/
  app/(site)/…          Alle Seiten mit Header/Footer (bestehende URL-Pfade)
  app/(qr)/…            QR-Speisekarten ohne große Navigation
  app/sitemap.ts, robots.ts, not-found.tsx, layout.tsx
  components/           home/, locations/, birthday/, menu/, forms/, consent/, navigation/, ui/
  content/              EINZIGE Quelle für Geschäftsdaten (typisiert + Zod-Schemas)
  lib/                  format/, seo/, validation/, forms/ (Server Actions + Transport)
  tests/unit, tests/e2e
public/brand/           Logo (vom Auftraggeber geliefert)
public/images/media/    Foto-Slots (Rechte ungeklärt, siehe docs/INTEGRATIONS_AND_RIGHTS.md)
docs/                   Projektdokumentation
```

## Inhalte ändern

**Ohne Programmierung:** Pflegebereich unter `/keystatic` (lokal: http://localhost:3000/keystatic). Öffnungszeiten, Ferien-/Sonderzeiten, Eintrittspreise, Geburtstagspakete, Geburtstagstermine, Speisekarten und FAQ. Anleitung fürs Team: [`docs/PFLEGE.md`](docs/PFLEGE.md). Die Daten liegen als JSON in `src/content/data/` und werden beim Build geprüft.

Alle Preise, Zeiten, Pakete, Speisen, FAQ und Kontaktdaten liegen in `src/content/`. Komponenten enthalten keine Geschäftsdaten.

- **Öffnungszeiten & Sonderzeiten:** `src/content/data/oeffnungszeiten-*.json` (Pflegebereich)
- **Eintrittspreise:** `src/content/data/preise-*.json` (Pflegebereich)
- **Geburtstagspakete & Kabine/Nische:** `src/content/data/geburtstag-*.json` (Pflegebereich) – speist Paketübersicht *und* Formular.
- **Geburtstags-Kalender:** `src/content/data/geburtstag-termine-*.json` (Pflegebereich, derzeit aus) – siehe [`docs/GEBURTSTAGSKALENDER.md`](docs/GEBURTSTAGSKALENDER.md)
- **Speisekarten (inkl. QR-Seiten):** `src/content/data/speisekarte-*.json` (Pflegebereich)
- **FAQ:** `src/content/data/faq.json` (Pflegebereich)
- **Adresse / Kontakt / Attraktionen / Fotos:** `src/content/locations.ts`, `attractions.ts`, `media.ts` (Code)
- **Offene Punkte:** `src/content/verification-queue.ts`

Jeder Eintrag trägt `provenance` (`sourceUrl`, `checkedAt`, `verificationStatus`, `note`). Nach Kundenfreigabe den Status auf `client_approved` setzen – dann verschwindet der Prüfhinweis. `npm test` prüft alle Daten gegen die Schemas.

## Bilder tauschen

1. Neue Datei nach `public/images/media/` legen (WebP/JPEG, ca. 1600 px breit).
2. In `src/content/media.ts` den Slot anpassen: `src`, `width`, `height`, `alt`, `origin`, `rightsStatus`, `usageScope`, optional `objectPosition` (Fokuspunkt für mobile Zuschnitte).
3. `npm test` prüft, dass die Datei existiert.

## Echte Formularübermittlung (später)

Formulare laufen über Server Actions (`src/lib/forms/actions.ts`) mit serverseitiger Zod-Validierung. Der Versand passiert ausschließlich über `InquiryTransport` (`src/lib/forms/transport.ts`); aktiv ist nur der Demo-Adapter, der nichts speichert oder sendet und „Demo: Diese Anfrage wurde nicht an Pepelino gesendet.“ meldet.
Für den Livegang: Empfängeradressen je Standort klären, Mail-Dienst mit AV-Vertrag wählen, Adapter implementieren, `getInquiryTransport()` umstellen, Datenschutzerklärung ergänzen, Spam-Schutz (Honeypot ist vorhanden; ggf. Rate-Limit/Captcha) konfigurieren. Details: `docs/INTEGRATIONS_AND_RIGHTS.md`.

## Weg zur Veröffentlichung

Siehe [`docs/OPEN_ITEMS_FOR_LAUNCH.md`](docs/OPEN_ITEMS_FOR_LAUNCH.md). Kurz: offene Fakten bestätigen → Bildrechte klären → Rechtstexte erstellen → Formular-Transport anbinden → Hosting wählen (Node-fähig, z. B. Vercel oder eigener Node-Server) → Weiterleitungen laut `docs/SEO_MIGRATION.md` → `SITE_INDEXABLE=true` → Search Console & echte Core-Web-Vitals-Messung.

## Dokumentation

- [`docs/PFLEGE.md`](docs/PFLEGE.md) – Anleitung Pflegebereich
- [`docs/GEBURTSTAGSKALENDER.md`](docs/GEBURTSTAGSKALENDER.md)
- [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md)
- [`docs/SOURCES.md`](docs/SOURCES.md)
- [`docs/CONTENT_VERIFICATION.md`](docs/CONTENT_VERIFICATION.md)
- [`docs/SEO_MIGRATION.md`](docs/SEO_MIGRATION.md)
- [`docs/INTEGRATIONS_AND_RIGHTS.md`](docs/INTEGRATIONS_AND_RIGHTS.md)
- [`docs/TEST_REPORT.md`](docs/TEST_REPORT.md)
- [`docs/OPEN_ITEMS_FOR_LAUNCH.md`](docs/OPEN_ITEMS_FOR_LAUNCH.md)
