import type { Faq, LocationId } from "./schema";
import { faqItems } from "./editable";

/**
 * FAQ – gepflegt im Pflegebereich (src/content/data/faq.json).
 * Ursprünglich aus den öffentlichen Standortseiten, sprachlich bereinigt.
 * Bewusst NICHT übernommen:
 *  – Link auf /kindergeburtstaganmeldung/ (404, E01)
 *  – info@sfc-mettenhof.de als Buchungsadresse für Westerrönfeld (E06)
 *  – Kabinen/Nischen-Frage für Westerrönfeld (E07)
 */
export const faqs: Faq[] = faqItems();

export function faqsFor(location: LocationId): Faq[] {
  return faqs.filter((f) => f.scope === "global" || f.scope === location);
}
