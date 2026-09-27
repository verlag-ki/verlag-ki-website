import type { Metadata } from "next";
import { BirthdayPage } from "@/components/birthday/BirthdayPage";
import { locations } from "@/content/locations";
import { pageMetadata } from "@/lib/seo";
import { packagesFor } from "@/content/birthdays";
import { formatPrice } from "@/lib/format";

const from = formatPrice(Math.min(...packagesFor("westerroenfeld").map((p) => p.price.amount)));

export const metadata: Metadata = pageMetadata({
  title: "Kindergeburtstag Rendsburg – Pepelino Westerrönfeld",
  description:
    `Kindergeburtstag bei Rendsburg feiern: drei Pakete im Pepelino Westerrönfeld ab ${from} pro Kind inklusive Eintritt, eigener Geburtstagsbereich. Unverbindlich anfragen.`,
  path: "/kindergeburtstag-rendsburg/",
  image: "/images/media/rd-geburtstagsbereich.webp",
});

export default function Page() {
  return <BirthdayPage location={locations.westerroenfeld} />;
}
