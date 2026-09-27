import type { Metadata } from "next";
import { MenuPage } from "@/components/menu/MenuPage";
import { pageMetadata } from "@/lib/seo";


// Sonderzeiten laufen ab: Seite stündlich neu erzeugen.
export const revalidate = 3600;
export const metadata: Metadata = pageMetadata({
  title: "Speisekarte Westerrönfeld – Bistro im Pepelino",
  description: "Speisen und Getränke im Pepelino Westerrönfeld bei Rendsburg: Nuggets, Hot Dog, Burger, Kuchen, Kaffee und mehr – mit Preisen.",
  path: "/kinderspieleparadies-rendsburg/",
});

export default function Page() {
  return <MenuPage locationId="westerroenfeld" />;
}
