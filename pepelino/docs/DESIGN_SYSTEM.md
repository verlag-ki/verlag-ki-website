# Designsystem Pepelino 2.0

Grundlage ist der **freigegebene, dritte und ruhigere Entwurf** (`Pepelino_Designreferenz_freigegeben.png`). Übernommen wurden Informationshierarchie, Großzügigkeit, Bildflächen und Farbdisziplin – nicht jede Dekoration.

## Leitregeln gegen Überladung

1. **Ein** emotionales Großbild pro Seite (Hero/Seitenkopf). Alle anderen Sektionen sind merklich ruhiger.
2. Pro Sektion **eine** starke Akzentfarbe plus höchstens eine kleine Nebenfarbe. Ausnahme: die zweifarbige Standortwahl (Blau/Grün).
3. Höchstens **ein** handgezeichneter Akzent (Krone, Strich, Stern) pro größerer Sektion – als `Doodle`-Komponente.
4. Organische Kanten nur an großen Bildflächen (`.organic-image`, `.blob-card`, Standortkacheln). Karten und Buttons bleiben reguläre, weich gerundete Formen.
5. Keine Verläufe, Glas-Effekte, Konfetti, Emoji, Dauer-Animationen, schwebende CTAs oder erfundenen Bewertungen.
6. Startseite zeigt nur Einstiege. Pakete, Speisekarten, FAQ und Attraktionslisten leben auf Unterseiten.

## Farben (Tokens in `src/styles/globals.css`)

| Token | Wert | Einsatz | Kontrast (gemessen) |
|---|---|---|---|
| `paper` | `#FFFDFA` | Hauptfläche | – |
| `ink` | `#163452` | Überschriften, Text | 12,6 : 1 auf `paper` |
| `ink-soft` | `#4F5B69` | Fließtext sekundär | 6,3 : 1 auf `blue-wash` |
| `pink` | `#DC165A` | Geburtstags-CTA, Gutscheine | 4,9 : 1 (weißer Text) |
| `pink-strong` | `#C8104F` | Hover, kleine Schrift auf `pink-wash` | 5,8 : 1 |
| `blue` / `blue-strong` | `#1478BE` / `#0F67A6` | Kiel, Links, Fokus | 4,7 / 6,0 : 1 |
| `green` / `green-strong` | `#16824A` / `#13733F` | Westerrönfeld, Speisen | 4,9 / 5,9 : 1 |
| `sun` | `#FFD46C` | nur Deko-Akzente (Krone, Strich) – nie Textfarbe | – |
| `orange` | `#E8590C` | nur große Schrift/Icons (3,6 : 1) | – |
| `blue-wash` | `#EAF6FD` | „Besuch planen“ | – |
| `pink-wash` | `#FFF1F5` | Geburtstagssektionen | – |

Kleiner Akzenttext auf getönten Flächen nutzt immer die `-strong`-Variante (z. B. Eyebrow auf `pink-wash`: 4,45 : 1 mit `pink` wäre zu wenig).

## Typografie

- **Bricolage Grotesque** (variabel, `opsz`/`wght`) für Überschriften – warm, leicht unregelmäßig, nah an der Referenz. Gewicht 750.
- **Nunito Sans** (variabel) für Text, Navigation, Preise und Formulare. Grundgröße 17 px, Zeilenhöhe 1,6.
- Beide lokal über `@fontsource-variable` eingebunden (SIL Open Font License 1.1), keine Verbindung zu Google Fonts.
- Skala: `.h-display` clamp(36 → 64 px), `.h-section` clamp(28 → 42 px), `.h-card` 21 px. `text-wrap: balance` gegen unkontrollierte Umbrüche.
- „Pepelino“ in Überschriften erscheint in den Logofarben (`BrandWord`) – nur für große Schrift.

## Komponenten

| Komponente | Ort | Hinweis |
|---|---|---|
| `SiteHeader` | navigation/ | eine Zeile Desktop, Dropdowns als Disclosure-Buttons, mobiles Vollbild-Menü, Escape schließt |
| `SiteFooter` | navigation/ | beide Standorte, Zentrale, Service, Rechtliches |
| `Hero`, `QuickLinks`, `AttractionsTeaser`, `BirthdayTeaser`, `PlanVisit` | home/ | die acht Startseitenabschnitte (inkl. Header/Footer) |
| `LocationCard`, `AttractionCard`, `LocationPage`, `ContactBlock` | locations/ | |
| `OpeningHours`, `PriceTable`, `FaqAccordion` | locations/VisitInfo | `<details>`-Akkordeon, FAQ-JSON-LD |
| `BirthdayPackageCard`, `BirthdayPage` | birthday/ | drei Pakete, ein Haupt-CTA |
| `BirthdayInquiryForm`, `GroupInquiryForm`, `ContactForm`, `Fields` | forms/ | Server Actions, Fehler je Feld, Fokus auf erstes fehlerhaftes Feld |
| `MapConsent` | consent/ | Zwei-Klick-Karte |
| `MenuView`, `MenuSection`, `QrMenuPage` | menu/ | eine Datenquelle für Speisekarte und QR |
| `PageHeader`, `Section`, `Breadcrumbs`, `Photo`, `Icon`, `Doodle`, `ReviewMarker` | ui/ | |

`LocationSelector` aus dem Briefing ist als zweifarbige Standortwahl im Hero, in den Standortkacheln und im Header-Menü umgesetzt; ein eigener Zustands-Umschalter wurde bewusst nicht gebaut, weil jede Standortinformation eine eigene, indexierbare URL hat.

## Logo

Das vom Auftraggeber gelieferte Pepelino-Logo (Figur + Schriftzug) ersetzt den typografischen Platzhalter. Datei: `public/brand/pepelino-logo.png` (1020 × 796, transparent). Favicon/Apple-Icon sind daraus abgeleitet (Kopf der Figur). Das im Referenzbild generierte Logo wird **nicht** verwendet.

## Responsives Verhalten

- Container max. 1280 px, Seitenränder 20 px (mobil) / 32 px.
- Hero: Desktop Textkarte über dem Foto (Bildhöhe clamp 520–640 px); mobil Foto oben, Karte überlappend darunter, beide Standort-Buttons volle Breite.
- Navigation kollabiert unter 1024 px.
- Touch-Ziele ≥ 44 px (Buttons 48 px, Menüeinträge 48–56 px).
- `prefers-reduced-motion` deaktiviert Übergänge.
