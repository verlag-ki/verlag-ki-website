# Integrationen, Dienste & Medienrechte

## Drittanbieter in der Vorschau

| Dienst | Einbindung | Wann Datenfluss? | Consent | Status |
|---|---|---|---|---|
| Google Maps | `iframe` nach Klick (`MapConsent`) | erst nach „Karte laden“ | Zwei-Klick, nicht gespeichert | für Livegang an Consent-Lösung anbinden |
| Google Maps (Routenlink) | normaler Link | nur beim Anklicken | nein | Ziel = Adresse aus Website |
| moinmoinKIEL Gutscheinshop | Link im Header | nur beim Anklicken | nein | Ziel identisch mit heutigem Startseiten-Button (geprüft 26.09.2026); Vertrag/Partnerschaft nicht geprüft |
| Instagram, Facebook, YouTube, TikTok | Links im Footer | nur beim Anklicken | nein | Facebook- und YouTube-Profil sind auf der Altseite doppelt/uneinheitlich verlinkt |
| SFC Mettenhof, 4D Minigolf Kiel | Links (Geburtstag Kiel) | nur beim Anklicken | nein | Nachbarangebote laut Altseite |
| Schriften | lokal (`@fontsource-variable`) | nie extern | – | SIL OFL 1.1 |
| YouTube-Video (Altseite RD-Geburtstag) | **nicht eingebunden** | – | – | Video-ID nicht verifiziert |
| Borlabs Cookie, Jetpack, Google Ads, AdSense, Web Fonts | **nicht eingebunden** | – | – | nur in alter Datenschutzerklärung genannt |

Kein Analytics, kein Tracking, keine Cookies.

## Formulare

| Formular | Seite | Transport | Speicherung |
|---|---|---|---|
| Geburtstagsanfrage Kiel/RD | `/kindergeburtstag-*/` | Server Action → `demoTransport` | keine |
| Gruppenanfrage | `/gruppenanmeldung-schulklassen/` | Server Action → `demoTransport` | keine |
| Kontakt | `/indoorspielplatz-in-der-naehe/` | Server Action → `demoTransport` | keine |

Die bisherigen zusätzlichen Kontaktformulare auf Standort- und Speisekartenseiten (F05–F07) wurden zu **einem** Kontaktweg zusammengeführt (E18).

**Schnittstellen** (`src/lib/forms/transport.ts`):
- `InquiryTransport.send(kind, payload)` – später z. B. SMTP oder ein Transaktionsmail-Dienst (EU-Hosting, AV-Vertrag). Empfänger je Standort und Anfrageart konfigurierbar machen (V05).
- `BookingProvider` (`getAvailability`, `reserve`) – nur Interface. Es gibt keine belegte Buchungs-/Kapazitätsschnittstelle. Bis dahin heißt alles „Anfrage“.
- Spam-Schutz: Honeypot-Feld aktiv. Für Livegang zusätzlich Rate-Limiting am Server/Edge und optional ein datenschutzfreundliches Captcha (z. B. Friendly Captcha) prüfen.

## Medien

| Slot | Datei | Herkunft | rightsStatus | Einsatz |
|---|---|---|---|---|
| Logo | `public/brand/pepelino-logo.png` | Auftraggeber (26.09.2026) | `client_provided` | Header, Footer, QR-Seiten, Favicon |
| heroKlettervulkan | `kiel-klettervulkan-hero.webp` | pepelino-fun.de/2021/02/Klettervulkan-Pepelino-1 | `public_website_unverified` | Hero Startseite, Kopf Kiel |
| kielKlettervulkan | `kiel-klettervulkan.webp` | …/Klettervulkan-Pepelino2-1 | ″ | Attraktion |
| kielTrampolin | `kiel-bungee-trampolin.webp` | …/Bungee-Trampolin | ″ | Attraktion, Gruppen |
| kielBumper | `kiel-bumper-cars.webp` | …/Bumper-1 | ″ | Attraktion |
| kielBaellebad | `kiel-baellebad.webp` | …/Standort-Titelbild-Pepelino | ″ | Standortkachel Kiel |
| kielHochseil | `kiel-hochseilgarten.webp` | …/hochseilgarten | ″ | Attraktion Kletterpark |
| kielKleinkind | `kiel-kleinkinderbereich.webp` | …/kleinkinder1 | ″ | Attraktion |
| kielKabinen | `kiel-geburtstagskabinen.webp` | …/Geburtstagskabinen-bei-pepelino-1 | ″ | Geburtstag Kiel |
| kielNische | `kiel-geburtstagsnische.webp` | …/Geburtstagsnische-1 | ″ | Geburtstag Startseite/Kiel |
| rdKletter | `rd-kletterlandschaft.webp` | pepelino-fun.de/2025/01/WhatsApp-Image-…-9 | ″ | Kopf RD, Standortkachel |
| rdFahrzeuge | `rd-kinderfahrzeuge.webp` | …-3 | ″ | Attraktion |
| rdHuepfburg | `rd-huepfburg.webp` | …-11 | ″ | Geburtstag RD |
| rdGeburtstag | `rd-geburtstagsbereich.webp` | …-5 | ″ | Geburtstag RD |
| rdGastro | `rd-gastronomie.webp` | …-04-2 | ″ | derzeit ungenutzt (Reserve) |
| rdTrampolin | `rd-trampolin.webp` | …-14 | ″ | Attraktion |

Vollständige Quell-URLs, Alt-Texte und Maße: `src/content/media.ts`. Alle Fotos wurden verkleinert und als WebP gespeichert.

**Wichtig:** Die Fotos stammen von der bestehenden Website. Laut Impressum wurden Bilder teils über Envato Elements lizenziert; welche Dateien das betrifft und ob die Lizenz einen Relaunch abdeckt, ist offen. Die WhatsApp-Fotos von 2025 sind vermutlich eigene Aufnahmen – Urheber und Einwilligung abgebildeter Personen klären. **Kein Foto ist für die Veröffentlichung freigegeben.** Empfehlung: ein professionelles Foto-Shooting in beiden Hallen (Hero mit Kind auf Rutsche, drei Attraktionen je Halle, Geburtstagsbereich, je ein Standortbild) mit Model-Releases.

Die freigegebene Designreferenz (PNG) ist ein KI-Konzeptbild und wird nicht als Bildquelle verwendet.
