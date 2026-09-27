import type { LocationId, Menu } from "./schema";
import { menuFor } from "./editable";

/**
 * Speisen & Getränke – gepflegt im Pflegebereich (src/content/data/speisekarte-*.json).
 * Ursprünglich aus den öffentlichen Kartenbildern (10/2025) transkribiert.
 * Preise ohne Wert werden als „Preis vor Ort“ angezeigt.
 */
export const menus: Record<LocationId, Menu> = {
  kiel: menuFor("kiel"),
  westerroenfeld: menuFor("westerroenfeld"),
};
