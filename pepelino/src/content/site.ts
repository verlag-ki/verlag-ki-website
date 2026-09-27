import type { ExternalLink } from "./schema";
import { SOURCES, src } from "./sources";

export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL ?? "https://www.pepelino-fun.de").replace(/\/$/, "");

export const site = {
  brand: "Pepelino",
  legalName: "Kids World Kiel GmbH & Co. KG",
  tagline: "Indoorspielplätze in Kiel und Westerrönfeld",
  locale: "de-DE",
  timeZone: "Europe/Berlin",
  central: {
    label: "Pepelino Zentrale",
    phone: { display: "0431 533 330", tel: "+49431533330" },
    phoneHours: "Mo – Fr, 10 – 14 Uhr",
    email: "info@pepelino-fun.de",
    address: "Göteborgring 83, 24109 Kiel",
    provenance: src(SOURCES.contact, "conflicting_public", "Telefonnummer teils abweichend (0431 533 33 30)."),
  },
  nav: [
    { href: "/", label: "Startseite" },
    { href: "/indoorspielplatz-kiel/", label: "Kiel" },
    { href: "/indoorspielplatz-rendsburg/", label: "Westerrönfeld" },
    {
      href: "/kindergeburtstag-kiel/",
      label: "Kindergeburtstag",
      children: [
        { href: "/kindergeburtstag-kiel/", label: "Geburtstag in Kiel" },
        { href: "/kindergeburtstag-rendsburg/", label: "Geburtstag in Westerrönfeld" },
      ],
    },
    { href: "/gruppenanmeldung-schulklassen/", label: "Gruppen & Schulen" },
    {
      href: "/indoorspielplatz-in-der-naehe/",
      label: "Preise & Infos",
      children: [
        { href: "/indoorspielplatz-kiel/#preise", label: "Preise & Zeiten Kiel" },
        { href: "/indoorspielplatz-rendsburg/#preise", label: "Preise & Zeiten Westerrönfeld" },
        { href: "/kinderspieleparadies-kiel/", label: "Speisekarte Kiel" },
        { href: "/kinderspieleparadies-rendsburg/", label: "Speisekarte Westerrönfeld" },
        { href: "/indoorspielplatz-in-der-naehe/", label: "Kontakt & Anfahrt" },
      ],
    },
  ] as { href: string; label: string; children?: { href: string; label: string }[] }[],
  footerLinks: [
    { href: "/kinderspieleparadies-kiel/", label: "Speisekarte Kiel" },
    { href: "/kinderspieleparadies-rendsburg/", label: "Speisekarte Westerrönfeld" },
    { href: "/gruppenanmeldung-schulklassen/", label: "Gruppen & Schulen" },
    { href: "/indoorspielplatz-in-der-naehe/", label: "Kontakt & Anfahrt" },
  ],
  legalLinks: [
    { href: "/impressum/", label: "Impressum" },
    { href: "/datenschutzerklaerung/", label: "Datenschutz" },
  ],
} as const;

export const externalLinks: ExternalLink[] = [
  {
    id: "voucher",
    url: SOURCES.voucherShop,
    service: "moinmoinKIEL Gutscheinshop",
    purpose: "Online-Gutscheine",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.home, "verified_public", "Button „Hier Gutschein kaufen“ auf der Startseite verlinkt am 26.09.2026 auf diese Adresse."),
  },
  {
    id: "instagram",
    url: "https://www.instagram.com/pepelinokiel/",
    service: "Instagram",
    purpose: "Social-Media-Profil",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.home),
  },
  {
    id: "facebook",
    url: "https://www.facebook.com/Pepelino-Spieleparadies-Kiel-100378357983555/",
    service: "Facebook",
    purpose: "Social-Media-Profil",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.home, "conflicting_public", "Daneben ist auch facebook.com/pepelinospieleparadieskiel verlinkt."),
  },
  {
    id: "youtube",
    url: "https://youtube.com/@PepelinoSpieleparadies",
    service: "YouTube",
    purpose: "Kanal",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.home, "conflicting_public", "Daneben auch Kanal-ID UCtQioxNc9Se9rNrUMt_n5aQ verlinkt."),
  },
  {
    id: "tiktok",
    url: "https://www.tiktok.com/@pepelinospieleparadies",
    service: "TikTok",
    purpose: "Social-Media-Profil",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.home),
  },
  {
    id: "sfc",
    url: "https://www.sfc-mettenhof.de/",
    service: "Sport- und Freizeitcenter Mettenhof",
    purpose: "Nachbarangebot (Soccerhalle) am Standort Kiel",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "minigolf",
    url: "https://www.4dminigolf-kiel.de/",
    service: "4D Minigolf Kiel",
    purpose: "Nachbarangebot am Standort Kiel",
    embedding: "link",
    requiresConsent: false,
    provenance: src(SOURCES.birthdayKiel),
  },
  {
    id: "maps",
    url: "https://www.google.com/maps",
    service: "Google Maps",
    purpose: "Karte auf der Kontaktseite (nur nach Einwilligung)",
    embedding: "consent_embed",
    requiresConsent: true,
    provenance: src(SOURCES.contact),
  },
];

export function getExternal(id: string): ExternalLink {
  const link = externalLinks.find((l) => l.id === id);
  if (!link) throw new Error(`Unbekannter externer Link: ${id}`);
  return link;
}

/** Gruppenangebot: öffentlich nur für Kiel beschrieben. */
export const groupOffer = {
  kiel: {
    text: [
      "Pepelino in Kiel ist ein wetterunabhängiges Ausflugsziel für Schulklassen, Kindergartengruppen und Horte – mit Rutschen, Klettergerüsten, Trampolinen und vielen weiteren Attraktionen.",
      "Gruppenbesuche sind nach Absprache auch außerhalb der regulären Öffnungszeiten möglich, zum Beispiel vormittags für Projekttage, Wandertage oder zum Schuljahresabschluss. Dann habt ihr die Halle für euch.",
    ],
    provenance: src(SOURCES.groups),
  },
  westerroenfeld: {
    text: [
      "Auch für Westerrönfeld könnt ihr eine Gruppenanfrage stellen. Konditionen und mögliche Zeiten außerhalb der Öffnungszeiten stimmen wir individuell mit euch ab.",
    ],
    provenance: src(SOURCES.groups, "unknown", "Öffentliche Seite beschreibt nur Kiel; Formular bietet Westerrönfeld als Ort an."),
  },
};
