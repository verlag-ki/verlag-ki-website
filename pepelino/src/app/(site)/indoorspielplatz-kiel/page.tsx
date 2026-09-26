import type { Metadata } from "next";
import { LocationPage } from "@/components/locations/LocationPage";
import { locations } from "@/content/locations";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Indoorspielplatz Kiel – Klettervulkan, Trampoline & Kartbahn",
  description:
    "Pepelino Kiel am Göteborgring: Klettervulkan, Bungee-Trampoline, Kartbahn, Bumper Cars und Kleinkinderbereich. Eintrittspreise, Öffnungszeiten, Anfahrt und FAQ.",
  path: "/indoorspielplatz-kiel/",
  image: "/images/media/kiel-klettervulkan-hero.webp",
});

export default function Page() {
  return <LocationPage location={locations.kiel} />;
}
