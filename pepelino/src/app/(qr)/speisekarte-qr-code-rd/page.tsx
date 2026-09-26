import type { Metadata } from "next";
import { QrMenuPage } from "@/components/menu/QrMenuPage";
import { pageMetadata } from "@/lib/seo";
import { locations } from "@/content/locations";

// QR-Ziel für gedruckte Codes: dauerhaft erreichbar halten.
// Inhalt entspricht der Speisekartenseite, daher Canonical dorthin (kein Duplicate Content).
export const metadata: Metadata = {
  ...pageMetadata({
    title: "Speisekarte Westerrönfeld (QR)",
    description: "Speisen und Getränke im Pepelino – für den schnellen Blick am Tisch.",
    path: locations.westerroenfeld.pages.menu,
  }),
};

export default function Page() {
  return <QrMenuPage locationId="westerroenfeld" />;
}
