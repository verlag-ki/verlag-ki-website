import type { Faq, LocationId } from "./schema";
import { SOURCES, src } from "./sources";

/**
 * FAQ aus den öffentlichen Standortseiten, sprachlich bereinigt.
 * Bewusst NICHT übernommen:
 *  – Link auf /kindergeburtstaganmeldung/ (404, E01)
 *  – info@sfc-mettenhof.de als Buchungsadresse für Westerrönfeld (E06)
 *  – Kabinen/Nischen-Frage für Westerrönfeld (E07)
 */
export const faqs: Faq[] = [
  {
    id: "food",
    question: "Dürfen wir eigenes Essen und Trinken mitbringen?",
    answer:
      "Bitte bringt keine eigenen Speisen und Getränke mit – in unserem Bistro findet ihr Snacks, warme Gerichte und Getränke. Für Geburtstagsfeiern gelten eigene Regeln, die ihr auf der Geburtstagsseite findet.",
    scope: "global",
    provenance: src(SOURCES.kiel),
  },
  {
    id: "shoes",
    question: "Welche Schuhe brauchen die Kinder?",
    answer:
      "Straßenschuhe sind im Spielbereich nicht erlaubt. Aus Sicherheits- und Hygienegründen wird in den Spielgeräten mit Socken gespielt – nicht barfuß und nicht mit Hallenschuhen. Dicke Socken sind ideal.",
    scope: "global",
    provenance: src(SOURCES.kiel),
  },
  {
    id: "parking",
    question: "Gibt es Parkplätze?",
    answer: "Ja, es gibt ausreichend kostenlose Parkplätze.",
    scope: "global",
    provenance: src(SOURCES.kiel),
  },
  {
    id: "card",
    question: "Kann ich mit Karte bezahlen?",
    answer: "Ja, EC-Kartenzahlung ist ab einem Betrag von 10 € möglich.",
    scope: "global",
    provenance: src(SOURCES.kiel),
  },
  {
    id: "vouchers",
    question: "Gibt es Geschenkgutscheine?",
    answer:
      "Ja. Gutscheine bekommt ihr direkt an unserer Kasse – ein schönes Geschenk zum Geburtstag, zu Weihnachten, Ostern oder zur Einschulung.",
    scope: "global",
    provenance: src(SOURCES.kiel),
  },
  {
    id: "birthday-kiel",
    question: "Wie melde ich einen Kindergeburtstag in Kiel an?",
    answer:
      "Wählt auf unserer Geburtstagsseite Kiel ein Paket und sendet uns eure Anfrage mit Wunschtermin. Wir melden uns per E-Mail oder Telefon zur Bestätigung.",
    scope: "kiel",
    provenance: src(SOURCES.kiel, "verified_public", "Alter Link auf /kindergeburtstaganmeldung/ ersetzt."),
  },
  {
    id: "birthday-rd",
    question: "Wie melde ich einen Kindergeburtstag in Westerrönfeld an?",
    answer:
      "Über das Anfrageformular auf unserer Geburtstagsseite Westerrönfeld. Wir melden uns mit einer Bestätigung oder einem Alternativtermin.",
    scope: "westerroenfeld",
    provenance: src(SOURCES.rd, "conflicting_public", "Alt-FAQ verweist auf Kieler Adresse info@sfc-mettenhof.de (E06); Zielroute klären."),
  },
];

export function faqsFor(location: LocationId): Faq[] {
  return faqs.filter((f) => f.scope === "global" || f.scope === location);
}
