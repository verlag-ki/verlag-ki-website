import type { MetadataRoute } from "next";
import { absoluteUrl } from "@/lib/seo";

/** Nur indexierbare, kanonische Seiten. QR-Ziele und Archivseite sind bewusst nicht enthalten. */
export const INDEXABLE_ROUTES = [
  "/",
  "/indoorspielplatz-kiel/",
  "/indoorspielplatz-rendsburg/",
  "/kindergeburtstag-kiel/",
  "/kindergeburtstag-rendsburg/",
  "/kinderspieleparadies-kiel/",
  "/kinderspieleparadies-rendsburg/",
  "/gruppenanmeldung-schulklassen/",
  "/indoorspielplatz-in-der-naehe/",
  "/impressum/",
  "/datenschutzerklaerung/",
] as const;

export default function sitemap(): MetadataRoute.Sitemap {
  return INDEXABLE_ROUTES.map((path) => ({
    url: absoluteUrl(path),
    changeFrequency: path === "/" ? "weekly" : "monthly",
    priority: path === "/" ? 1 : path.includes("kiel") || path.includes("rendsburg") ? 0.8 : 0.5,
  }));
}
