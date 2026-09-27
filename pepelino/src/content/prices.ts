import type { AdmissionPrice, LocationId } from "./schema";
import { SOURCES, src } from "./sources";
import { admissionPricesFor } from "./editable";

/** Eintrittspreise – gepflegt im Pflegebereich (src/content/data/preise-*.json). */
export const admissionPrices: AdmissionPrice[] = [...admissionPricesFor("kiel"), ...admissionPricesFor("westerroenfeld")];

export function pricesFor(location: LocationId): AdmissionPrice[] {
  return admissionPrices.filter((p) => p.location === location);
}

export const PAYMENT_NOTE = {
  text: "Kartenzahlung (EC) ist ab 10 € möglich.",
  provenance: src(SOURCES.kiel),
};
