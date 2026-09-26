import { z } from "zod";

/**
 * Zentrale Inhaltsschemas. Alle Komponenten lesen ausschließlich Daten,
 * die diese Schemas erfüllen (siehe src/tests/unit/content.test.ts).
 */

export const verificationStatus = z.enum([
  "verified_public", // öffentlich auf pepelino-fun.de belegt (nicht vom Kunden bestätigt)
  "conflicting_public", // öffentlich widersprüchlich
  "unknown", // nicht belegt
  "client_approved", // vom Auftraggeber freigegeben
]);
export type VerificationStatus = z.infer<typeof verificationStatus>;

export const provenance = z.object({
  sourceUrl: z.string().url(),
  checkedAt: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  verificationStatus,
  note: z.string().optional(),
});
export type Provenance = z.infer<typeof provenance>;

export const locationId = z.enum(["kiel", "westerroenfeld"]);
export type LocationId = z.infer<typeof locationId>;

export const weekday = z.enum(["mo", "di", "mi", "do", "fr", "sa", "so"]);
export type Weekday = z.infer<typeof weekday>;

export const openingSlot = z.object({
  days: z.array(weekday).min(1),
  opens: z.string().regex(/^\d{2}:\d{2}$/).nullable(),
  closes: z.string().regex(/^\d{2}:\d{2}$/).nullable(),
});

export const openingException = z.object({
  label: z.string(),
  text: z.string(),
  provenance,
});

export const rightsStatus = z.enum([
  "client_provided", // vom Auftraggeber direkt geliefert
  "public_website_unverified", // von pepelino-fun.de, Nutzungsrecht für Relaunch ungeklärt
  "licensed", // Lizenz dokumentiert
  "placeholder",
]);

export const mediaAsset = z.object({
  id: z.string(),
  src: z.string().startsWith("/"),
  width: z.number().int().positive(),
  height: z.number().int().positive(),
  alt: z.string().min(1),
  motif: z.string(),
  location: locationId.nullable(),
  origin: z.string().url().or(z.literal("client")),
  rightsStatus,
  usageScope: z.string(),
  objectPosition: z.string().optional(),
});
export type MediaAsset = z.infer<typeof mediaAsset>;

export const location = z.object({
  id: locationId,
  name: z.string(),
  shortName: z.string(),
  slug: z.string(),
  accent: z.enum(["blue", "green"]),
  address: z.object({
    street: z.string(),
    postalCode: z.string(),
    city: z.string(),
    region: z.string(),
    country: z.literal("DE"),
    provenance,
  }),
  geo: z.object({ latitude: z.number(), longitude: z.number(), provenance }).nullable(),
  phone: z.object({ display: z.string(), tel: z.string(), provenance }).nullable(),
  email: z.object({ address: z.string().email(), provenance }).nullable(),
  opening: z.object({ slots: z.array(openingSlot), provenance }),
  openingExceptions: z.array(openingException),
  intro: z.array(z.string()),
  highlights: z.array(z.string()),
  heroImage: z.string(),
  cardImage: z.string(),
  mapsUrl: z.object({ url: z.string().url(), provenance }).nullable(),
  reviewUrl: z.string().url().nullable(),
  pages: z.object({
    location: z.string(),
    birthday: z.string(),
    menu: z.string(),
    menuQr: z.string(),
  }),
});
export type Location = z.infer<typeof location>;

export const attraction = z.object({
  id: z.string(),
  name: z.string(),
  location: locationId,
  description: z.string(),
  image: z.string().nullable(),
  facts: z.array(z.string()).default([]),
  provenance,
});
export type Attraction = z.infer<typeof attraction>;

export const money = z.object({ amount: z.number().nonnegative(), currency: z.literal("EUR") });

export const admissionPrice = z.object({
  id: z.string(),
  location: locationId,
  category: z.string(),
  note: z.string().optional(),
  price: money,
  unit: z.string(),
  provenance,
});
export type AdmissionPrice = z.infer<typeof admissionPrice>;

export const packageFeature = z.object({
  text: z.string(),
  verificationStatus,
  note: z.string().optional(),
});

export const birthdayPackage = z.object({
  id: z.string(),
  location: locationId,
  name: z.string(),
  tier: z.enum(["small", "medium", "large"]),
  price: money,
  unit: z.literal("pro Kind"),
  minChildren: z.number().int().positive(),
  features: z.array(packageFeature),
  provenance,
});
export type BirthdayPackage = z.infer<typeof birthdayPackage>;

export const birthdayAddon = z.object({
  id: z.string(),
  location: locationId,
  name: z.string(),
  price: money,
  description: z.string(),
  provenance,
});
export type BirthdayAddon = z.infer<typeof birthdayAddon>;

export const menuItem = z.object({
  name: z.string(),
  detail: z.string().optional(),
  variants: z.array(z.object({ size: z.string().optional(), price: money.nullable() })).min(1),
  note: z.string().optional(),
});
export type MenuItem = z.infer<typeof menuItem>;

export const menuSection = z.object({
  id: z.string(),
  title: z.string(),
  kind: z.enum(["food", "drinks"]),
  items: z.array(menuItem),
});
export type MenuSection = z.infer<typeof menuSection>;

export const menu = z.object({
  location: locationId,
  sections: z.array(menuSection),
  notices: z.array(z.string()),
  /** Stand der Vorlage, z. B. „Oktober 2025“. */
  asOf: z.string(),
  sourceImages: z.array(z.object({ label: z.string(), url: z.string().url() })),
  provenance,
});
export type Menu = z.infer<typeof menu>;

export const faq = z.object({
  id: z.string(),
  question: z.string(),
  answer: z.string(),
  scope: z.enum(["global", "kiel", "westerroenfeld"]),
  provenance,
});
export type Faq = z.infer<typeof faq>;

export const externalLink = z.object({
  id: z.string(),
  url: z.string().url(),
  service: z.string(),
  purpose: z.string(),
  embedding: z.enum(["link", "consent_embed", "none"]),
  requiresConsent: z.boolean(),
  provenance,
});
export type ExternalLink = z.infer<typeof externalLink>;

export const verificationItem = z.object({
  id: z.string(),
  topic: z.string(),
  location: z.enum(["kiel", "westerroenfeld", "global"]),
  priority: z.enum(["P0", "P1", "P2"]),
  finding: z.string(),
  values: z.array(z.object({ value: z.string(), sourceUrl: z.string().url() })),
  handlingInDemo: z.string(),
  clientQuestion: z.string(),
});
export type VerificationItem = z.infer<typeof verificationItem>;
