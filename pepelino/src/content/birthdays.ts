import type { BirthdayAddon, BirthdayPackage, LocationId, VerificationStatus } from "./schema";
import { birthdayFor } from "./editable";

/**
 * Geburtstagspakete, Kabine/Nische und Hinweise – gepflegt im Pflegebereich
 * (src/content/data/geburtstag-*.json). Einzige Datenquelle für Paketübersicht
 * UND Anfrageformular. Kabine/Nische gibt es öffentlich belegt nur in Kiel.
 */
const kiel = birthdayFor("kiel");
const westerroenfeld = birthdayFor("westerroenfeld");

export const birthdayPackages: BirthdayPackage[] = [...kiel.packages, ...westerroenfeld.packages];
export const birthdayAddons: BirthdayAddon[] = [...kiel.addons, ...westerroenfeld.addons];

export const birthdayRules: Record<LocationId, { text: string; verificationStatus: VerificationStatus; note?: string }[]> = {
  kiel: kiel.rules,
  westerroenfeld: westerroenfeld.rules,
};

export function packagesFor(location: LocationId): BirthdayPackage[] {
  return birthdayPackages.filter((p) => p.location === location);
}

export function addonsFor(location: LocationId): BirthdayAddon[] {
  return birthdayAddons.filter((a) => a.location === location);
}
