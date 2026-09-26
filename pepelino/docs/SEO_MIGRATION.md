# SEO & Migration

## URL-Matrix

Alle bestehenden Pfade bleiben erhalten. Next.js arbeitet mit `trailingSlash: true` – wie die bisherige WordPress-Seite.

| Alte URL | Neue Route | Aktion | Indexierung | Hinweis |
|---|---|---|---|---|
| `/` | `/` | beibehalten | ja | |
| `/indoorspielplatz-kiel/` | gleich | beibehalten | ja | LocalBusiness-JSON-LD |
| `/indoorspielplatz-rendsburg/` | gleich | beibehalten | ja | LocalBusiness-JSON-LD |
| `/kindergeburtstag-kiel/` | gleich | beibehalten | ja | |
| `/kindergeburtstag-rendsburg/` | gleich | beibehalten | ja | |
| `/kinderspieleparadies-kiel/` | gleich | beibehalten (Speisekarte) | ja | |
| `/kinderspieleparadies-rendsburg/` | gleich | beibehalten (Speisekarte) | ja | |
| `/gruppenanmeldung-schulklassen/` | gleich | beibehalten | ja | |
| `/indoorspielplatz-in-der-naehe/` | gleich | beibehalten (Kontakt, Preise, Anfahrt) | ja | |
| `/speisekarte-fuer-qr-code/` | gleich | **erhalten** (gedruckte QR-Codes) | Canonical → `/kinderspieleparadies-kiel/` | nicht in Sitemap |
| `/speisekarte-qr-code-rd/` | gleich | **erhalten** (gedruckte QR-Codes) | Canonical → `/kinderspieleparadies-rendsburg/` | nicht in Sitemap |
| `/impressum/` | gleich | beibehalten | ja | Rechtstext neu erstellen |
| `/datenschutzerklaerung/` | gleich | beibehalten | ja | Rechtstext neu erstellen |
| `/schutz-und-hygienekonzept/` | gleich | Archivhinweis, `noindex` | nein | Nach Kundenentscheidung: 410 oder 301 auf `/indoorspielplatz-kiel/#faq` |
| `/kindergeburtstaganmeldung/` (404) | → `/kindergeburtstag-kiel/` | Weiterleitung (Next.js `permanent: true` = 308) | – | Ziel Kiel, da der Link aus der Kiel-FAQ stammt |

**Noch zu prüfen vor Livegang:** Server-Sitemap/WordPress-Sitemap der Altseite (war nicht auslesbar), Search-Console-Daten (Top-Landingpages, Backlinks), weitere Alt-URLs wie `/wp-content/uploads/…`-Bilder mit Backlinks, Feed- und Kategorie-URLs von WordPress. Jede zusätzlich gefundene URL erhält ein thematisch passendes 301-Ziel – keine Sammelweiterleitung auf die Startseite.

Falls der Hoster echte 301 statt 308 verlangt: Weiterleitungen dort (bzw. in `next.config.ts` mit `statusCode: 301`) konfigurieren.

## Technische SEO – umgesetzt

- Statisch vorgerendertes HTML für alle Seiten; Inhalte nicht in Bildern (Speisekarten jetzt als Text).
- Je Seite genau eine H1, logische H2/H3 (per Test geprüft).
- Individuelle `title`/`description`, Open Graph, Canonical auf `NEXT_PUBLIC_SITE_URL`.
- `sitemap.xml` mit 11 kanonischen Seiten; `robots.txt` sperrt die Vorschau vollständig.
- Staging-Schutz dreifach: `robots.txt Disallow: /`, `<meta name="robots" content="noindex">`, Header `X-Robots-Tag: noindex, nofollow`. Freigabe nur über `SITE_INDEXABLE=true`.
- JSON-LD: `Organization` (Startseite), `AmusementPark`/`LocalBusiness` je Standort (nur Adresse, Geo, Öffnungszeiten; strittige Telefon/E-Mail werden nicht ausgezeichnet), `BreadcrumbList` auf allen Unterseiten mit sichtbarer Brotkrümelnavigation, `FAQPage` auf den Standortseiten. Kein `aggregateRating`.
- Bilder über `next/image` (AVIF/WebP, `srcset`, feste Maße), Hero mit `priority`, übrige lazy.
- Echte `<a>`-Links überall; Sprunglinks zeigen auf existierende IDs.

## Lokale Keyword-Zuordnung

| Seite | Hauptthema | Titel |
|---|---|---|
| `/indoorspielplatz-kiel/` | Indoorspielplatz Kiel | Indoorspielplatz Kiel – Klettervulkan, Trampoline & Kartbahn |
| `/indoorspielplatz-rendsburg/` | Indoorspielplatz Rendsburg/Westerrönfeld | Indoorspielplatz Rendsburg – Pepelino Westerrönfeld |
| `/kindergeburtstag-kiel/` | Kindergeburtstag Kiel | Kindergeburtstag Kiel – Pakete & Anfrage |
| `/kindergeburtstag-rendsburg/` | Kindergeburtstag Rendsburg | Kindergeburtstag Rendsburg – Pepelino Westerrönfeld |
| `/gruppenanmeldung-schulklassen/` | Klassenausflug Kiel | Klassenausflug & Gruppen – Indoorspielplatz Kiel |
| `/indoorspielplatz-in-der-naehe/` | Indoorspielplatz in der Nähe | … – Kontakt, Preise & Anfahrt |

Standortseiten unterscheiden sich in Attraktionen, Fotos, Preisen, Paketen, FAQ und Anfahrt – keine Textdubletten.

## SEO-Abnahmepunkte vor Livegang

- [ ] `SITE_INDEXABLE=true` und `NEXT_PUBLIC_SITE_URL` auf Produktionsdomain gesetzt
- [ ] Alle Alt-URLs aus Search Console/Server-Log geprüft, Weiterleitungen ergänzt
- [ ] QR-Code-Standorte geklärt (V09)
- [ ] Sitemap in Search Console eingereicht
- [ ] Rich-Results-Test für LocalBusiness/FAQ/Breadcrumb
- [ ] Offene Fakten (Telefon, E-Mail) geklärt und Status auf `client_approved` gesetzt → `telephone`/`email` erscheinen dann automatisch im JSON-LD
- [ ] Core Web Vitals mit echten Nutzerdaten (CrUX) nach 28 Tagen prüfen
