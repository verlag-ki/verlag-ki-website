import type { Attraction, LocationId } from "./schema";
import { SOURCES, src } from "./sources";

/**
 * Nur Attraktionen, die auf der jeweiligen Standortseite textlich genannt sind.
 * Superlative („einmalig in Schleswig-Holstein“) wurden bewusst nicht
 * übernommen, solange sie nicht vom Auftraggeber belegt sind.
 */
export const attractions: Attraction[] = [
  {
    id: "kiel-klettervulkan",
    name: "Klettervulkan",
    location: "kiel",
    description:
      "Vier Kletterrouten führen auf den Gipfel. Wer schnell wieder unten sein will, nimmt die High-Speed-Rutsche.",
    image: "kielKlettervulkan",
    facts: ["4 Kletterrouten", "130 Griffe", "5,50 m hoch"],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-trampolin",
    name: "Trampoline & Bungee",
    location: "kiel",
    description:
      "Zwölf Trampoline, davon vier mit Bungee-Funktion. Das Team klinkt die Kinder sicher ein und passt auf.",
    image: "kielTrampolin",
    facts: ["12 Trampoline", "4 mit Bungee"],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-rollrutsche",
    name: "Rollrutsche",
    location: "kiel",
    description: "Eine lange Rollenrutsche gehört zu den Lieblingen in der Kieler Halle.",
    image: null,
    facts: [],
    provenance: src(
      SOURCES.kiel,
      "verified_public",
      "Website nennt „über 45 Meter“ und „einmalig in ganz Schleswig-Holstein“ – beides vor Übernahme bestätigen lassen.",
    ),
  },
  {
    id: "kiel-kartbahn",
    name: "Kartbahn",
    location: "kiel",
    description: "Auf der Kartbahn kommen auch die Kleinsten groß heraus – wer fährt die schnellste Runde?",
    image: null,
    facts: ["Benutzungsgebühr 1 €"],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-bumper",
    name: "Bumper Cars",
    location: "kiel",
    description: "Elektrisch betriebene Bumper Cars sorgen für Fahrspaß bei Kindern und Eltern.",
    image: "kielBumper",
    facts: [],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-huepfburg",
    name: "Hüpfburgen",
    location: "kiel",
    description: "Verschiedene Hüpfburgen für alle, denen das Trampolin noch nicht genug ist.",
    image: null,
    facts: [],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-kletterpark",
    name: "Kletterpark",
    location: "kiel",
    description: "Im Kletterpark entscheidet jedes Kind selbst, was es ausprobieren möchte.",
    image: "kielHochseil",
    facts: [],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "kiel-fussball",
    name: "Indoor-Fußball",
    location: "kiel",
    description: "Größere Kinder und Jugendliche kicken auf weichem Kunstrasen.",
    image: null,
    facts: ["Spielfeld 32 × 15 m"],
    provenance: src(
      SOURCES.kiel,
      "verified_public",
      "Laut Website Teil des Angebots; Zuordnung zum Pepelino oder zur benachbarten Soccerhalle des SFC Mettenhof klären.",
    ),
  },
  {
    id: "kiel-kleinkind",
    name: "Kleinkinderbereich",
    location: "kiel",
    description:
      "Die Jüngsten spielen in einem abgetrennten Bereich mit Riesenlegos, Softbausteinen und Bällebad oder drehen Runden auf Dreirädern.",
    image: "kielKleinkind",
    facts: [],
    provenance: src(SOURCES.kiel),
  },
  {
    id: "rd-rutschen",
    name: "Riesenrutsche & Walrutsche",
    location: "westerroenfeld",
    description: "Die zweibahnige Riesenrutsche und die mächtige Walrutsche sind die großen Rutsch-Abenteuer in Westerrönfeld.",
    image: null,
    facts: [],
    provenance: src(SOURCES.rd),
  },
  {
    id: "rd-kletter",
    name: "Kletterlandschaft",
    location: "westerroenfeld",
    description: "Eine große, mehrstöckige Kletterlandschaft zum Klettern, Kriechen und Verstecken.",
    image: "rdKletter",
    facts: [],
    provenance: src(SOURCES.rd, "verified_public", "Nur über Galeriefotos der Standortseite belegt, nicht im Text beschrieben."),
  },
  {
    id: "rd-trampolin",
    name: "Trampoline",
    location: "westerroenfeld",
    description: "Ein eigenes Trampolinfeld zum Springen und Austoben.",
    image: "rdTrampolin",
    facts: [],
    provenance: src(SOURCES.rd, "verified_public", "Nur über Galeriefotos der Standortseite belegt, nicht im Text beschrieben."),
  },
  {
    id: "rd-fahrzeuge",
    name: "Dreirad & Go-Kart",
    location: "westerroenfeld",
    description: "Runden drehen auf dem Dreirad oder im Go-Kart – für kleine und größere Fahrerinnen und Fahrer.",
    image: "rdFahrzeuge",
    facts: [],
    provenance: src(SOURCES.rd),
  },
  {
    id: "rd-gastro",
    name: "Gastronomiebereich",
    location: "westerroenfeld",
    description: "Ein großzügiger Bereich zum Stärken und Durchatmen, mit Lieblingsgerichten für Kinder und Eltern.",
    image: null,
    facts: [],
    provenance: src(SOURCES.rd),
  },
];

export function attractionsFor(location: LocationId): Attraction[] {
  return attractions.filter((a) => a.location === location);
}

/** Drei Karten für die Startseite – Standortbezug wird in der Karte angezeigt. */
/** Startseite: gemischt aus beiden Hallen (Hero zeigt bereits Kiel). */
export const homeAttractionIds = ["rd-kletter", "kiel-trampolin", "rd-fahrzeuge"] as const;
