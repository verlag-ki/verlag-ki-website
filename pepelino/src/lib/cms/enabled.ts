/**
 * Der Pflegebereich ist aktiv
 *  – in der Entwicklung (lokales Speichern in src/content/data/), oder
 *  – in Produktion NUR mit GitHub-Speicher (Anmeldung über GitHub, jede Änderung ein Commit).
 * Ein Produktionsserver im lokalen Modus würde sonst ungeschützt Dateien schreiben.
 */
export const cmsEnabled =
  process.env.NODE_ENV !== "production" || process.env.NEXT_PUBLIC_KEYSTATIC_STORAGE === "github";
