import Link from "next/link";
import type { Location } from "@/content/schema";
import { attractionsFor } from "@/content/attractions";
import { packagesFor } from "@/content/birthdays";
import { faqsFor } from "@/content/faq";
import { locations } from "@/content/locations";
import { PAYMENT_NOTE, pricesFor } from "@/content/prices";
import { formatPrice } from "@/lib/format";
import { localBusinessJsonLd } from "@/lib/seo";
import { PageHeader, Section } from "@/components/ui/PageHeader";
import { Icon } from "@/components/ui/Icon";
import { JsonLd } from "@/components/ui/JsonLd";
import { Photo } from "@/components/ui/Photo";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { AttractionCard } from "./AttractionCard";
import { FaqAccordion, OpeningHours, PriceTable } from "./VisitInfo";
import { ContactBlock } from "./ContactBlock";
import { MapConsent } from "@/components/consent/ConsentGate";

const COPY: Record<Location["id"], { title: React.ReactNode; region: string }> = {
  kiel: { title: "Indoorspielplatz in Kiel", region: "Kiel-Mettenhof" },
  westerroenfeld: { title: "Indoorspielplatz bei Rendsburg in Westerrönfeld", region: "Westerrönfeld bei Rendsburg" },
};

export function LocationPage({ location: loc }: { location: Location }) {
  const blue = loc.accent === "blue";
  const btn = blue ? "btn-blue" : "btn-green";
  const tone = blue ? "text-blue-strong" : "text-green-strong";
  const other = loc.id === "kiel" ? locations.westerroenfeld : locations.kiel;
  const attrs = attractionsFor(loc.id);
  const withImage = attrs.filter((a) => a.image);
  const withoutImage = attrs.filter((a) => !a.image);
  const packages = packagesFor(loc.id);
  const minPrice = Math.min(...packages.map((p) => p.price.amount));

  return (
    <>
      <JsonLd data={localBusinessJsonLd(loc)} />
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: loc.shortName, path: loc.pages.location },
        ]}
        eyebrow={`Pepelino ${loc.shortName}`}
        eyebrowTone={tone}
        title={COPY[loc.id].title}
        intro={loc.intro.map((p) => (
          <p key={p}>{p}</p>
        ))}
        image={loc.heroImage}
      >
        <div className="flex flex-col gap-3 sm:flex-row sm:flex-wrap">
          <a href="#preise" className={`btn ${btn}`}>
            Preise & Öffnungszeiten
          </a>
          <Link href={loc.pages.birthday} className="btn btn-quiet">
            Kindergeburtstag feiern
          </Link>
        </div>
      </PageHeader>

      <section aria-label="Das Wichtigste in Kürze" className="container-site mt-12">
        <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          {loc.highlights.map((h) => (
            <li key={h} className="flex items-start gap-3 rounded-2xl bg-white p-4 shadow-[inset_0_0_0_1px_var(--color-line)]">
              <Icon name="check" className={`mt-0.5 size-5 shrink-0 ${tone}`} />
              <span className="font-semibold">{h}</span>
            </li>
          ))}
        </ul>
      </section>

      <Section id="attraktionen" eyebrow="Attraktionen" eyebrowTone={tone} title={`Das erwartet euch in ${loc.shortName}`}>
        <ul className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
          {withImage.map((a) => (
            <li key={a.id}>
              <AttractionCard attraction={a} />
            </li>
          ))}
        </ul>
        {withoutImage.length > 0 && (
          <div className="mt-10 rounded-[var(--radius-card)] bg-white p-6 shadow-[inset_0_0_0_1px_var(--color-line)] sm:p-8">
            <h3 className="h-card">Außerdem</h3>
            <ul className="mt-4 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
              {withoutImage.map((a) => (
                <li key={a.id}>
                  <p className="font-display text-lg font-bold">
                    {a.name}
                    <ReviewMarker status={a.provenance.verificationStatus} note={a.provenance.note} />
                  </p>
                  <p className="mt-1 text-[0.97rem] text-ink-soft">{a.description}</p>
                  {a.facts.length > 0 && <p className="mt-1 text-[0.9rem] font-bold">{a.facts.join(" · ")}</p>}
                </li>
              ))}
            </ul>
          </div>
        )}
      </Section>

      <Section id="preise" tone="blue" eyebrow="Besuch planen" eyebrowTone="text-blue-strong" title="Eintritt & Öffnungszeiten">
        <div className="grid gap-6 lg:grid-cols-[1.2fr_1fr]">
          <div className="card p-6 sm:p-8">
            <h3 className="h-card flex items-center gap-2">
              <Icon name="ticket" className="size-5 text-pink-strong" /> Eintrittspreise
            </h3>
            <div className="mt-3">
              <PriceTable prices={pricesFor(loc.id)} caption={`Eintrittspreise Pepelino ${loc.shortName}`} />
            </div>
            <p className="mt-4 text-[0.95rem] text-ink-soft">{PAYMENT_NOTE.text}</p>
          </div>
          <div className="card p-6 sm:p-8">
            <h3 className="h-card flex items-center gap-2">
              <Icon name="clock" className="size-5 text-[#8a6a00]" /> Öffnungszeiten
            </h3>
            <div className="mt-4">
              <OpeningHours location={loc} />
            </div>
            <p className="mt-5 text-[0.95rem] text-ink-soft">
              Sonderöffnungen in Ferien und an Feiertagen können abweichen – im Zweifel kurz anrufen.
            </p>
          </div>
        </div>
      </Section>

      <section aria-labelledby="geburtstag-titel" className="container-site mt-16 md:mt-24">
        <div className="grid items-center gap-8 overflow-hidden rounded-[2rem_3rem_2rem_2.5rem] bg-pink-wash md:grid-cols-2">
          <div className="relative aspect-[4/3] md:aspect-auto md:h-full md:min-h-[340px]">
            <Photo media={loc.id === "kiel" ? "kielKabinen" : "rdGeburtstag"} sizes="(min-width: 768px) 45vw, 100vw" />
          </div>
          <div className="p-7 pt-0 md:p-10 md:pl-2">
            <p className="eyebrow text-pink-strong">Kindergeburtstag</p>
            <h2 id="geburtstag-titel" className="h-section mt-2">
              Feiern in {loc.shortName}
            </h2>
            <p className="mt-3 text-ink-soft">
              Drei Pakete von {packages.map((p) => p.name).join(", ").replace(/, ([^,]*)$/, " bis $1")} – ab {formatPrice(minPrice)} pro Kind, Eintritt inklusive, ab 5 Kindern.
            </p>
            <Link href={loc.pages.birthday} className="btn btn-pink mt-6">
              Pakete & Anfrage
              <Icon name="arrow" className="size-4" />
            </Link>
          </div>
        </div>
      </section>

      <Section id="essen" eyebrow="Essen & Trinken" eyebrowTone="text-green-strong" title="Bistro & Speisekarte">
        <div className="flex flex-col gap-5 sm:flex-row sm:items-center sm:justify-between">
          <p className="max-w-[55ch] text-ink-soft">
            Von Chicken Nuggets bis Milchkaffee: Im Bistro gibt es Snacks, warme Gerichte und Getränke. Eigene Speisen und Getränke dürfen nicht mitgebracht werden.
          </p>
          <Link href={loc.pages.menu} className="btn btn-green shrink-0 self-start sm:self-auto">
            Zur Speisekarte {loc.shortName}
            <Icon name="arrow" className="size-4" />
          </Link>
        </div>
      </Section>

      <Section id="faq" eyebrow="Gut zu wissen" eyebrowTone={tone} title="Häufige Fragen">
        <FaqAccordion items={faqsFor(loc.id)} />
      </Section>

      <Section id="anfahrt" eyebrow="Anfahrt & Kontakt" eyebrowTone={tone} title={`So findet ihr uns in ${COPY[loc.id].region}`}>
        <div className="grid gap-8 lg:grid-cols-[1fr_1.4fr]">
          <ContactBlock location={loc} />
          <MapConsent
            query={`${loc.address.street}, ${loc.address.postalCode} ${loc.address.city}`}
            title={`Karte: Pepelino ${loc.shortName}`}
          />
        </div>
        <p className="mt-8 text-ink-soft">
          Lust auf die andere Halle?{" "}
          <Link href={other.pages.location} className="font-bold text-ink underline underline-offset-4">
            Pepelino {other.shortName} entdecken
          </Link>
        </p>
      </Section>
    </>
  );
}
