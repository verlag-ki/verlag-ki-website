import type { Metadata } from "next";
import { MenuPage } from "@/components/menu/MenuPage";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Speisekarte Kiel – Bistro im Pepelino",
  description: "Speisen und Getränke im Pepelino Kiel: Chicken Nuggets, Pizza, Burger, Pommes, Kaffeespezialitäten und mehr – mit Preisen.",
  path: "/kinderspieleparadies-kiel/",
});

export default function Page() {
  return <MenuPage locationId="kiel" />;
}
