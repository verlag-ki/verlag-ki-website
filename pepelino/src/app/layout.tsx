import type { Metadata, Viewport } from "next";
import "@/styles/globals.css";
import { SITE_URL } from "@/content/site";
import { isIndexable } from "@/lib/seo";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "Pepelino – Indoorspielplätze in Kiel und Westerrönfeld",
    template: "%s | Pepelino Spieleparadies",
  },
  description:
    "Pepelino Spieleparadies: wetterunabhängig spielen, toben und Kindergeburtstag feiern – in Kiel und in Westerrönfeld bei Rendsburg.",
  robots: isIndexable ? { index: true, follow: true } : { index: false, follow: false },
  formatDetection: { telephone: false },
};

export const viewport: Viewport = {
  themeColor: "#fffdfa",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="de">
      <body className="min-h-dvh overflow-x-clip">
        <a
          href="#inhalt"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-50 focus:rounded-full focus:bg-ink focus:px-5 focus:py-3 focus:font-bold focus:text-white"
        >
          Zum Inhalt springen
        </a>
        {!isIndexable && (
          <div className="bg-ink px-4 py-1.5 text-center text-[0.8rem] font-semibold text-white">
            Vorschau des Relaunchs – nicht die offizielle Pepelino-Website. Formulare versenden nichts.
          </div>
        )}
        {children}
      </body>
    </html>
  );
}
