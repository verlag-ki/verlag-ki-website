import type { Location, LocationId } from "./schema";
import { SOURCES, src } from "./sources";

/** Reguläre Öffnungszeiten – an beiden Standorten öffentlich identisch angegeben. */
const regularSlots = (): Location["opening"]["slots"] => [
  { days: ["mo", "di", "mi", "do"], opens: null, closes: null },
  { days: ["fr"], opens: "14:00", closes: "19:00" },
  { days: ["sa", "so"], opens: "11:00", closes: "19:00" },
];

export const locations: Record<LocationId, Location> = {
  kiel: {
    id: "kiel",
    name: "Pepelino Kiel",
    shortName: "Kiel",
    slug: "indoorspielplatz-kiel",
    accent: "blue",
    address: {
      street: "Göteborgring 83",
      postalCode: "24109",
      city: "Kiel",
      region: "Schleswig-Holstein",
      country: "DE",
      provenance: src(SOURCES.kiel),
    },
    geo: {
      latitude: 54.3262482,
      longitude: 10.0618428,
      provenance: src(
        SOURCES.kiel,
        "verified_public",
        "Koordinaten aus dem auf der Website verlinkten Google-Maps-Eintrag (Sport- und Freizeitcenter Mettenhof, gleiche Adresse).",
      ),
    },
    phone: {
      display: "0431 533 330",
      tel: "+49431533330",
      provenance: src(
        SOURCES.contact,
        "conflicting_public",
        "Zentrale. Überwiegend 0431 533 330; auf der Kiel-Seite zusätzlich 0431 533 33 30 (tel:04315333330).",
      ),
    },
    email: { address: "info@pepelino-fun.de", provenance: src(SOURCES.contact, "verified_public", "Zentrale E-Mail") },
    opening: { slots: regularSlots(), provenance: src(SOURCES.menuKiel) },
    openingExceptions: [
      {
        label: "Ferien & Feiertage",
        text: "12:00 – 19:00 Uhr",
        provenance: src(
          SOURCES.menuImgKielDrinks,
          "conflicting_public",
          "Nur auf der Kieler Getränkekarte (Bild, Stand 10/2025) genannt; HTML-Seite verweist auf „siehe Hauptseite“.",
        ),
      },
    ],
    intro: [
      "Rutschen, hüpfen, klettern – oder ganz entspannt durchs Bällebad krabbeln: In unserer Halle am Göteborgring in Kiel-Mettenhof findet jedes Kind seine Lieblingsecke, ganz egal, wie das Wetter draußen ist.",
      "Während die Kinder toben, können Eltern im Bistro bei Milchkaffee oder Tee zusehen.",
    ],
    highlights: [
      "Klettervulkan mit High-Speed-Rutsche",
      "Zwölf Trampoline, vier davon mit Bungee",
      "Kartbahn, Bumper Cars und Kletterpark",
      "Abgetrennter Kleinkinderbereich",
    ],
    heroImage: "heroKlettervulkan",
    cardImage: "kielBaellebad",
    mapsUrl: {
      url: "https://www.google.com/maps/search/?api=1&query=G%C3%B6teborgring+83%2C+24109+Kiel",
      provenance: src(SOURCES.kiel, "verified_public", "Adresse aus der Website; Routenlink selbst erzeugt."),
    },
    reviewUrl: null,
    pages: {
      location: "/indoorspielplatz-kiel/",
      birthday: "/kindergeburtstag-kiel/",
      menu: "/kinderspieleparadies-kiel/",
      menuQr: "/speisekarte-fuer-qr-code/",
    },
  },
  westerroenfeld: {
    id: "westerroenfeld",
    name: "Pepelino Westerrönfeld",
    shortName: "Westerrönfeld",
    slug: "indoorspielplatz-rendsburg",
    accent: "green",
    address: {
      street: "Am Busbahnhof 16",
      postalCode: "24784",
      city: "Westerrönfeld",
      region: "Schleswig-Holstein",
      country: "DE",
      provenance: src(SOURCES.rd),
    },
    geo: {
      latitude: 54.2749107,
      longitude: 9.6543781,
      provenance: src(SOURCES.rd, "verified_public", "Koordinaten aus dem auf der Website verlinkten Google-Maps-Eintrag „Pepelino Spieleparadies“."),
    },
    phone: {
      display: "04331 437 090 9",
      tel: "+4943314370909",
      provenance: src(SOURCES.rd),
    },
    email: {
      address: "rendsburg@pepelino-fun.de",
      provenance: src(
        SOURCES.rd,
        "conflicting_public",
        "Angezeigt wird rendsburg@pepelino-fun.de, verlinkt ist teilweise mailto:pepelino-rendsburg@gmx.de.",
      ),
    },
    opening: { slots: regularSlots(), provenance: src(SOURCES.menuRd) },
    openingExceptions: [
      {
        label: "Ferien & Feiertage",
        text: "Gesonderte Zeiten – aktuelle Angaben bitte beim Standort erfragen.",
        provenance: src(SOURCES.menuImgRdDrinks, "unknown", "Getränkekarte nennt nur „Siehe Webseite“."),
      },
    ],
    intro: [
      "Direkt am Busbahnhof in Westerrönfeld, gleich bei Rendsburg, wartet eine bunte Auswahl an Spielgeräten: Runden drehen mit Dreirad oder Go-Kart, die zweibahnige Riesenrutsche oder die mächtige Walrutsche ausprobieren.",
      "Im großzügigen Gastronomiebereich stärkt sich die ganze Familie, und für Geburtstage gibt es einen eigenen Bereich, in dem ihr ungestört feiern könnt.",
    ],
    highlights: [
      "Zweibahnige Riesenrutsche und Walrutsche",
      "Dreiräder und Go-Karts",
      "Großzügiger Gastronomiebereich",
      "Eigener Geburtstagsbereich",
    ],
    heroImage: "rdKletter",
    cardImage: "rdKletter",
    mapsUrl: {
      url: "https://www.google.com/maps/search/?api=1&query=Am+Busbahnhof+16%2C+24784+Westerr%C3%B6nfeld",
      provenance: src(SOURCES.rd, "verified_public", "Adresse aus der Website; Routenlink selbst erzeugt."),
    },
    reviewUrl: null,
    pages: {
      location: "/indoorspielplatz-rendsburg/",
      birthday: "/kindergeburtstag-rendsburg/",
      menu: "/kinderspieleparadies-rendsburg/",
      menuQr: "/speisekarte-qr-code-rd/",
    },
  },
};

export const locationList: Location[] = [locations.kiel, locations.westerroenfeld];

export function getLocation(id: LocationId): Location {
  return locations[id];
}
