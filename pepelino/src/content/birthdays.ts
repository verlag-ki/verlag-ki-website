import type { BirthdayAddon, BirthdayPackage, LocationId } from "./schema";
import { SOURCES, src } from "./sources";

const eur = (amount: number) => ({ amount, currency: "EUR" as const });
const ok = (text: string) => ({ text, verificationStatus: "verified_public" as const });
const conflict = (text: string, note: string) => ({ text, verificationStatus: "conflicting_public" as const, note });

const MEAL = "1× Geburtstags-Essen: Nuggets (4 Stk.), Wiener oder Falafel – jeweils mit Pommes";

const SLUSH_KIEL_NOTE =
  "Wertgrenze öffentlich widersprüchlich: Standortseite Kiel 1,50 €, Geburtstagsseite Kiel und Speisekarte (10/2025) 2,00 €.";
const COFFEE_KIEL_NOTE =
  "Standortseite: „2× Kaffee-/Teespezialität“; Geburtstagsseite: „2× Filterkaffee oder Tee“; Speisekarte: „2× Becher Kaffee oder Tee“.";
const COFFEE_RD_NOTE = "Standortseite: „2× Kaffee-/Teespezialität“; Speisekarte (10/2025): „2× Kaffee/Tee“.";

/**
 * Einzige Datenquelle für Paketübersicht UND Anfrageformular.
 * Preise sind öffentlich belegt; widersprüchliche Leistungen sind je Merkmal markiert.
 */
export const birthdayPackages: BirthdayPackage[] = [
  {
    id: "kiel-small",
    location: "kiel",
    name: "Pepe Small",
    tier: "small",
    price: eur(16.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      conflict("1× Eis oder Slush", SLUSH_KIEL_NOTE),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "kiel-medium",
    location: "kiel",
    name: "Pepe Medium",
    tier: "medium",
    price: eur(21.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      conflict("1× Eis oder Slush", SLUSH_KIEL_NOTE),
      ok(MEAL),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "kiel-large",
    location: "kiel",
    name: "Pepe Large",
    tier: "large",
    price: eur(24.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      conflict("1× Eis oder Slush", SLUSH_KIEL_NOTE),
      ok(MEAL),
      ok("Überraschung für das Geburtstagskind"),
      ok("Freier Eintritt für insgesamt 2 Begleitpersonen je Gruppe"),
      conflict("2× Kaffee oder Tee für die Begleitpersonen", COFFEE_KIEL_NOTE),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "rd-small",
    location: "westerroenfeld",
    name: "Pepe Small",
    tier: "small",
    price: eur(16.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      ok("1× Eis oder Slush bis 1,50 €"),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayRd),
  },
  {
    id: "rd-medium",
    location: "westerroenfeld",
    name: "Pepe Medium",
    tier: "medium",
    price: eur(19.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      ok("1× Eis oder Slush bis 1,50 €"),
      ok(MEAL),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayRd),
  },
  {
    id: "rd-large",
    location: "westerroenfeld",
    name: "Pepe Large",
    tier: "large",
    price: eur(22.9),
    unit: "pro Kind",
    minChildren: 5,
    features: [
      ok("Eintritt inklusive"),
      ok("Gedeckter Geburtstagstisch"),
      ok("Persönliches Namensschild zum Mitnehmen"),
      ok("1× Getränk (0,3 l)"),
      ok("1× Eis oder Slush bis 1,50 €"),
      ok(MEAL),
      ok("Freier Eintritt für insgesamt 2 Begleitpersonen je Gruppe"),
      conflict("2× Kaffee oder Tee für die Begleitpersonen", COFFEE_RD_NOTE),
      ok("Reinigung & Entsorgung inklusive"),
    ],
    provenance: src(SOURCES.birthdayRd),
  },
];

/** Nur in Kiel öffentlich belegt. Für Westerrönfeld gibt es KEINE Kabinen-/Nischen-Option. */
export const birthdayAddons: BirthdayAddon[] = [
  {
    id: "kiel-nische",
    location: "kiel",
    name: "Geburtstagsnische",
    price: eur(20),
    description: "Eine eigene Nische für eure Gruppe.",
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "kiel-kabine",
    location: "kiel",
    name: "Geburtstagskabine",
    price: eur(35),
    description: "Eine eigene Kabine mit Thron – ganz unter euch.",
    provenance: src(SOURCES.birthdayKiel),
  },
];

export const birthdayRules: Record<LocationId, { text: string; verificationStatus: "verified_public" | "conflicting_public"; note?: string }[]> = {
  kiel: [
    { text: "Geburtstage sind ab 5 Kindern (inklusive Geburtstagskind) möglich.", verificationStatus: "verified_public" },
    {
      text: "Termine: Freitag bis Sonntag sowie an Feiertagen und in den Ferien.",
      verificationStatus: "verified_public",
    },
    {
      text: "Torte, Kuchen oder Muffins sowie ein kleiner Obst- und Gemüseteller dürfen mitgebracht werden. Andere Speisen und Getränke bitte nicht.",
      verificationStatus: "verified_public",
      note: "Auf der Altseite widersprüchlich formuliert (E08); hier als eindeutige Ausnahme formuliert – Freigabe nötig.",
    },
  ],
  westerroenfeld: [
    { text: "Geburtstage sind ab 5 Kindern (inklusive Geburtstagskind) möglich.", verificationStatus: "verified_public" },
    {
      text: "Mögliche Wochentage werden noch bestätigt – bitte im Anfrageformular euren Wunschtermin nennen.",
      verificationStatus: "conflicting_public",
      note: "Standortseite: Montag–Sonntag; Formular: nur Freitag–Sonntag sowie Ferien/Feiertage (E05).",
    },
  ],
};

export function packagesFor(location: LocationId): BirthdayPackage[] {
  return birthdayPackages.filter((p) => p.location === location);
}

export function addonsFor(location: LocationId): BirthdayAddon[] {
  return birthdayAddons.filter((a) => a.location === location);
}
