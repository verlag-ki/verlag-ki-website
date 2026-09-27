import type { NextConfig } from "next";

/**
 * Staging-/Vorschau-Konfiguration.
 * Solange SITE_INDEXABLE nicht explizit "true" ist, wird jede Antwort mit
 * X-Robots-Tag: noindex ausgeliefert (siehe auch src/app/robots.ts).
 */
const indexable = process.env.SITE_INDEXABLE === "true";

/**
 * Statische Vorschau (z. B. verlag-ki.de/pepelino): `npm run build:static`.
 * Ohne Server-Funktionen – Formulare prüfen im Browser, Pflegebereich entfällt.
 */
const staticExport = process.env.STATIC_EXPORT === "1";
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? "";

const staticConfig: NextConfig = {
  output: "export",
  distDir: ".next-static",
  basePath,
  trailingSlash: true,
  poweredByHeader: false,
  images: { unoptimized: true },
  // Typen werden im regulären Build/`npm run typecheck` geprüft; hier würden nur
  // Verweise auf die für den statischen Bau beiseitegelegten Server-Dateien stören.
  typescript: { ignoreBuildErrors: true },
};

const serverConfig: NextConfig = {
  trailingSlash: true,
  // Schrägstrich-Weiterleitung übernimmt src/proxy.ts (Ausnahme: Pflegebereich /keystatic).
  skipTrailingSlashRedirect: true,
  poweredByHeader: false,
  images: {
    formats: ["image/avif", "image/webp"],
  },
  async headers() {
    const base = [
      { key: "X-Content-Type-Options", value: "nosniff" },
      { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
      { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
    ];
    if (!indexable) base.push({ key: "X-Robots-Tag", value: "noindex, nofollow" });
    return [{ source: "/:path*", headers: base }];
  },
  async redirects() {
    return [
      // Alte, öffentlich verlinkte Anmeldeadresse (liefert heute 404) → passende Geburtstagsseite Kiel.
      // Siehe docs/SEO_MIGRATION.md
      { source: "/kindergeburtstaganmeldung", destination: "/kindergeburtstag-kiel/", permanent: true },
    ];
  },
};

export default staticExport ? staticConfig : serverConfig;
