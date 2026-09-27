import type { Metadata } from "next";
import { BirthdayPage } from "@/components/birthday/BirthdayPage";
import { locations } from "@/content/locations";
import { pageMetadata } from "@/lib/seo";
import { packagesFor } from "@/content/birthdays";
import { formatPrice } from "@/lib/format";

const from = formatPrice(Math.min(...packagesFor("kiel").map((p) => p.price.amount)));

export const metadata: Metadata = pageMetadata({
  title: "Kindergeburtstag Kiel – Pakete & Anfrage",
  description:
    `Kindergeburtstag im Pepelino Kiel: drei Pakete ab ${from} pro Kind inklusive Eintritt, optional mit eigener Nische oder Kabine. Jetzt unverbindlich anfragen.`,
  path: "/kindergeburtstag-kiel/",
  image: "/images/media/kiel-geburtstagsnische.webp",
});

export default function Page() {
  return <BirthdayPage location={locations.kiel} />;
}
