import type { Metadata } from "next";
import { SITE_URL, site } from "@/content/site";
import type { Location, Provenance } from "@/content/schema";
import { WEEKDAY_SCHEMA } from "@/lib/format";

const confirmed = (p: Provenance) => p.verificationStatus === "verified_public" || p.verificationStatus === "client_approved";

export const isIndexable = process.env.SITE_INDEXABLE === "true";

export function absoluteUrl(path: string): string {
  return `${SITE_URL}${path.startsWith("/") ? path : `/${path}`}`;
}

type PageMetaInput = {
  title: string;
  description: string;
  path: string;
  image?: string;
  noindex?: boolean;
};

export function pageMetadata({ title, description, path, image, noindex }: PageMetaInput): Metadata {
  const url = absoluteUrl(path);
  const robots = !isIndexable || noindex ? { index: false, follow: !noindex && isIndexable } : { index: true, follow: true };
  return {
    title,
    description,
    alternates: { canonical: url },
    robots,
    openGraph: {
      type: "website",
      locale: "de_DE",
      siteName: "Pepelino Spieleparadies",
      url,
      title,
      description,
      images: image ? [{ url: image }] : undefined,
    },
  };
}

/** LocalBusiness-JSON-LD ausschließlich aus Standortdaten; keine Bewertungen. */
export function localBusinessJsonLd(loc: Location) {
  return {
    "@context": "https://schema.org",
    "@type": ["AmusementPark", "LocalBusiness"],
    "@id": absoluteUrl(`${loc.pages.location}#business`),
    name: `${loc.name} – Indoorspielplatz`,
    url: absoluteUrl(loc.pages.location),
    image: absoluteUrl("/brand/pepelino-logo.png"),
    address: {
      "@type": "PostalAddress",
      streetAddress: loc.address.street,
      postalCode: loc.address.postalCode,
      addressLocality: loc.address.city,
      addressRegion: loc.address.region,
      addressCountry: loc.address.country,
    },
    ...(loc.geo ? { geo: { "@type": "GeoCoordinates", latitude: loc.geo.latitude, longitude: loc.geo.longitude } } : {}),
    ...(loc.phone && confirmed(loc.phone.provenance) ? { telephone: loc.phone.tel } : {}),
    ...(loc.email && confirmed(loc.email.provenance) ? { email: loc.email.address } : {}),
    openingHoursSpecification: loc.opening.slots
      .filter((s) => s.opens && s.closes)
      .map((s) => ({
        "@type": "OpeningHoursSpecification",
        dayOfWeek: s.days.map((d) => `https://schema.org/${WEEKDAY_SCHEMA[d]}`),
        opens: s.opens,
        closes: s.closes,
      })),
    parentOrganization: { "@type": "Organization", name: site.legalName },
  };
}

export function breadcrumbJsonLd(items: { name: string; path: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((it, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: it.name,
      item: absoluteUrl(it.path),
    })),
  };
}

export function faqJsonLd(items: { question: string; answer: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map((f) => ({
      "@type": "Question",
      name: f.question,
      acceptedAnswer: { "@type": "Answer", text: f.answer },
    })),
  };
}
