import type { Metadata } from "next";
import { Hero } from "@/components/home/Hero";
import { QuickLinks } from "@/components/home/QuickLinks";
import { AttractionsTeaser } from "@/components/home/AttractionsTeaser";
import { BirthdayTeaser } from "@/components/home/BirthdayTeaser";
import { PlanVisit } from "@/components/home/PlanVisit";
import { LocationCard } from "@/components/locations/LocationCard";
import { JsonLd } from "@/components/ui/JsonLd";
import { locationList } from "@/content/locations";
import { site } from "@/content/site";
import { absoluteUrl, localBusinessJsonLd, pageMetadata } from "@/lib/seo";

export const metadata: Metadata = {
  ...pageMetadata({
    title: "Pepelino – Indoorspielplätze in Kiel und Westerrönfeld",
    description:
      "Wetterunabhängig spielen, toben und Kindergeburtstag feiern: Pepelino Spieleparadies in Kiel und in Westerrönfeld bei Rendsburg. Öffnungszeiten, Preise, Geburtstagspakete.",
    path: "/",
    image: "/images/media/kiel-klettervulkan-hero.webp",
  }),
  title: { absolute: "Pepelino – Indoorspielplätze in Kiel und Westerrönfeld" },
};

export default function HomePage() {
  return (
    <>
      <JsonLd
        data={[
          {
            "@context": "https://schema.org",
            "@type": "Organization",
            name: "Pepelino Spieleparadies",
            legalName: site.legalName,
            url: absoluteUrl("/"),
            logo: absoluteUrl("/brand/pepelino-logo.png"),
            email: site.central.email,
          },
          ...locationList.map(localBusinessJsonLd),
        ]}
      />
      <Hero />
      <QuickLinks />
      <AttractionsTeaser />
      <BirthdayTeaser />
      <PlanVisit />
      <section aria-labelledby="loc-title" className="container-site mt-20 md:mt-24">
        <h2 id="loc-title" className="sr-only">
          Unsere zwei Standorte
        </h2>
        <ul className="grid gap-6 lg:grid-cols-2">
          {locationList.map((loc) => (
            <li key={loc.id}>
              <LocationCard location={loc} />
            </li>
          ))}
        </ul>
      </section>
    </>
  );
}
