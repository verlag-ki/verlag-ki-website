import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader, Section } from "@/components/ui/PageHeader";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { Icon } from "@/components/ui/Icon";
import { ContactBlock } from "@/components/locations/ContactBlock";
import { OpeningHours, PriceTable } from "@/components/locations/VisitInfo";
import { MapConsent } from "@/components/consent/ConsentGate";
import { ContactForm } from "@/components/forms/ContactForm";
import { locationList } from "@/content/locations";
import { pricesFor } from "@/content/prices";
import { site } from "@/content/site";
import { pageMetadata } from "@/lib/seo";


// Sonderzeiten laufen ab: Seite stündlich neu erzeugen.
export const revalidate = 3600;
export const metadata: Metadata = pageMetadata({
  title: "Indoorspielplatz in der Nähe – Kontakt, Preise & Anfahrt",
  description:
    "Pepelino in Kiel und Westerrönfeld bei Rendsburg: Adressen, Öffnungszeiten, Eintrittspreise, Kontakt zur Zentrale und Routenplanung.",
  path: "/indoorspielplatz-in-der-naehe/",
});

export default function Page() {
  return (
    <>
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: "Kontakt & Anfahrt", path: "/indoorspielplatz-in-der-naehe/" },
        ]}
        eyebrow="Preise & Infos"
        eyebrowTone="text-blue-strong"
        title="Indoorspielplatz in eurer Nähe"
        intro={<p>Zweimal in Schleswig-Holstein: in Kiel-Mettenhof und in Westerrönfeld bei Rendsburg. Hier findet ihr Adressen, Zeiten, Preise und alle Kontaktwege.</p>}
      />

      <Section id="standorte" eyebrow="Unsere Standorte" eyebrowTone="text-blue-strong" title="Adressen & Anfahrt">
        <div className="grid gap-10 lg:grid-cols-2">
          {locationList.map((loc) => (
            <div key={loc.id} className="space-y-5">
              <ContactBlock location={loc} />
              <MapConsent query={`${loc.address.street}, ${loc.address.postalCode} ${loc.address.city}`} title={`Karte: ${loc.name}`} />
            </div>
          ))}
        </div>
      </Section>

      <Section id="preise" tone="blue" eyebrow="Eintritt & Zeiten" eyebrowTone="text-blue-strong" title="Preise und Öffnungszeiten">
        <div className="grid gap-6 lg:grid-cols-2">
          {locationList.map((loc) => (
            <div key={loc.id} className="card p-6 sm:p-8">
              <h3 className={`h-card ${loc.accent === "blue" ? "text-blue-strong" : "text-green-strong"}`}>{loc.name}</h3>
              <div className="mt-4">
                <OpeningHours location={loc} compact />
              </div>
              <div className="mt-5">
                <PriceTable prices={pricesFor(loc.id)} caption={`Eintrittspreise ${loc.name}`} />
              </div>
              <Link href={loc.pages.location} className="link-arrow mt-2 text-blue-strong">
                Mehr zu {loc.shortName} <Icon name="arrow" className="size-4" />
              </Link>
            </div>
          ))}
        </div>
      </Section>

      <Section id="kontakt" eyebrow="Kontakt" eyebrowTone="text-blue-strong" title="Schreibt uns">
        <div className="grid gap-10 lg:grid-cols-[1.5fr_1fr]">
          <div className="card p-6 sm:p-9">
            <ContactForm />
          </div>
          <aside className="card h-fit p-6">
            <h3 className="h-card">{site.central.label}</h3>
            <p className="mt-2 text-ink-soft">Telefonisch erreichbar {site.central.phoneHours}</p>
            <p className="mt-2">
              <a href={`tel:${site.central.phone.tel}`} className="inline-flex min-h-11 items-center font-bold underline underline-offset-4">
                {site.central.phone.display}
              </a>
              <ReviewMarker status={site.central.provenance.verificationStatus} note={site.central.provenance.note} />
            </p>
            <p>
              <a href={`mailto:${site.central.email}`} className="inline-flex min-h-11 items-center font-bold underline underline-offset-4">
                {site.central.email}
              </a>
            </p>
            <p className="mt-2 text-ink-soft">{site.central.address}</p>
          </aside>
        </div>
      </Section>
    </>
  );
}
