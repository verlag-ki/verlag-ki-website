import type { AdmissionPrice, LocationId } from "./schema";
import { SOURCES, src } from "./sources";

const eur = (amount: number) => ({ amount, currency: "EUR" as const });

export const admissionPrices: AdmissionPrice[] = [
  // Kiel – Standortseite und Getränkekarte (10/2025) stimmen überein
  { id: "kiel-u2", location: "kiel", category: "Kinder unter 2 Jahren", note: "mit Nachweis", price: eur(4), unit: "pro Kind", provenance: src(SOURCES.kiel) },
  { id: "kiel-kind", location: "kiel", category: "Kinder ab 2 Jahren", price: eur(14), unit: "pro Kind", provenance: src(SOURCES.kiel) },
  { id: "kiel-kind-beh", location: "kiel", category: "Kind mit Behinderung", note: "mit Nachweis; Begleitperson zahlt regulär", price: eur(8.5), unit: "pro Kind", provenance: src(SOURCES.kiel) },
  { id: "kiel-erw", location: "kiel", category: "Erwachsene", price: eur(7), unit: "pro Person", provenance: src(SOURCES.kiel) },
  { id: "kiel-ue65", location: "kiel", category: "Seniorinnen und Senioren ab 65", note: "mit Nachweis", price: eur(4), unit: "pro Person", provenance: src(SOURCES.kiel) },
  { id: "kiel-erw-beh", location: "kiel", category: "Erwachsene mit Behinderung", note: "mit Nachweis", price: eur(4), unit: "pro Person", provenance: src(SOURCES.kiel) },
  // Westerrönfeld
  { id: "rd-u2", location: "westerroenfeld", category: "Kinder bis 2 Jahre", note: "mit Nachweis", price: eur(4), unit: "pro Kind", provenance: src(SOURCES.rd) },
  { id: "rd-kind", location: "westerroenfeld", category: "Kinder ab 2 Jahren", price: eur(12), unit: "pro Kind", provenance: src(SOURCES.rd) },
  { id: "rd-kind-beh", location: "westerroenfeld", category: "Kind mit Behinderung", note: "mit Nachweis; Begleitperson zahlt regulär", price: eur(8.5), unit: "pro Kind", provenance: src(SOURCES.rd) },
  { id: "rd-erw", location: "westerroenfeld", category: "Erwachsene", price: eur(6), unit: "pro Person", provenance: src(SOURCES.rd) },
  { id: "rd-ue65", location: "westerroenfeld", category: "Seniorinnen und Senioren ab 65", note: "mit Nachweis", price: eur(4), unit: "pro Person", provenance: src(SOURCES.rd) },
  { id: "rd-erw-beh", location: "westerroenfeld", category: "Erwachsene mit Behinderung", note: "mit Nachweis", price: eur(4), unit: "pro Person", provenance: src(SOURCES.rd) },
];

export function pricesFor(location: LocationId): AdmissionPrice[] {
  return admissionPrices.filter((p) => p.location === location);
}

export const PAYMENT_NOTE = {
  text: "Kartenzahlung (EC) ist ab 10 € möglich.",
  provenance: src(SOURCES.kiel),
};
