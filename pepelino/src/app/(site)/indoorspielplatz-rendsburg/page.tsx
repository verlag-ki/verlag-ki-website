import type { Metadata } from "next";
import { LocationPage } from "@/components/locations/LocationPage";
import { locations } from "@/content/locations";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Indoorspielplatz Rendsburg – Pepelino Westerrönfeld",
  description:
    "Pepelino in Westerrönfeld bei Rendsburg: Riesenrutsche, Walrutsche, Go-Karts und Geburtstagsbereich. Eintrittspreise, Öffnungszeiten, Anfahrt und FAQ.",
  path: "/indoorspielplatz-rendsburg/",
  image: "/images/media/rd-kletterlandschaft.webp",
});

export default function Page() {
  return <LocationPage location={locations.westerroenfeld} />;
}
