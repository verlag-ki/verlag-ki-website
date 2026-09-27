import { z } from "zod";
import * as S from "./schema";
import type { LocationId } from "./schema";

/**
 * Brücke zwischen Pflegebereich (Keystatic, JSON-Dateien in src/content/data/)
 * und den typisierten Inhaltsmodellen.
 *
 * Jede Datei wird beim Build gegen das Schema geprüft. Ist eine Eingabe im
 * Pflegebereich ungültig (z. B. Uhrzeit „19 Uhr“ statt „19:00“), bricht der
 * Build mit einer verständlichen Meldung ab – fehlerhafte Daten gehen nie live.
 */

import oeffnungKiel from "./data/oeffnungszeiten-kiel.json";
import oeffnungRd from "./data/oeffnungszeiten-westerroenfeld.json";
import preiseKiel from "./data/preise-kiel.json";
import preiseRd from "./data/preise-westerroenfeld.json";
import geburtstagKiel from "./data/geburtstag-kiel.json";
import geburtstagRd from "./data/geburtstag-westerroenfeld.json";
import speisekarteKiel from "./data/speisekarte-kiel.json";
import speisekarteRd from "./data/speisekarte-westerroenfeld.json";
import faqFile from "./data/faq.json";

const RAW = {
  oeffnung: { kiel: oeffnungKiel, westerroenfeld: oeffnungRd },
  preise: { kiel: preiseKiel, westerroenfeld: preiseRd },
  geburtstag: { kiel: geburtstagKiel, westerroenfeld: geburtstagRd },
  speisekarte: { kiel: speisekarteKiel, westerroenfeld: speisekarteRd },
} as const;

const eur = (amount: number) => ({ amount, currency: "EUR" as const });
const time = (v: unknown) => (typeof v === "string" && v.trim() !== "" ? v.trim() : null);

function parse<T>(schema: z.ZodType<T>, data: unknown, file: string): T {
  const r = schema.safeParse(data);
  if (!r.success) {
    const details = r.error.issues.map((i) => `  – ${i.path.join(".")}: ${i.message}`).join("\n");
    throw new Error(`Ungültige Inhalte in src/content/data/${file}.json:\n${details}`);
  }
  return r.data;
}

/* ---------- Öffnungszeiten ---------- */

const openingFile = z.object({
  slots: z.array(z.object({ days: z.array(S.weekday), opens: z.unknown().optional(), closes: z.unknown().optional() })),
  provenance: S.provenance,
  exceptions: z.array(S.openingException),
  specialDates: z.array(z.record(z.string(), z.unknown().optional())).default([]),
});

export function openingFor(id: LocationId) {
  const file = `oeffnungszeiten-${id}`;
  const raw = parse(openingFile, RAW.oeffnung[id], file);
  const slots = parse(
    z.array(S.openingSlot),
    raw.slots.map((s) => ({ days: s.days, opens: time(s.opens), closes: time(s.closes) })),
    file,
  );
  const specialDates = parse(
    z.array(S.specialDate),
    raw.specialDates.map((d) => ({
      ...d,
      to: d.to || d.from,
      closed: Boolean(d.closed),
      opens: time(d.opens),
      closes: time(d.closes),
    })),
    file,
  ).sort((a, b) => a.from.localeCompare(b.from));
  return { opening: { slots, provenance: raw.provenance }, exceptions: raw.exceptions, specialDates };
}

/* ---------- Eintrittspreise ---------- */

const pricesFile = z.object({
  prices: z.array(z.object({ id: z.string(), category: z.string(), note: z.unknown().optional(), price: z.number(), unit: z.string(), provenance: S.provenance })),
});

export function admissionPricesFor(id: LocationId): S.AdmissionPrice[] {
  const file = `preise-${id}`;
  const raw = parse(pricesFile, RAW.preise[id], file);
  return parse(
    z.array(S.admissionPrice),
    raw.prices.map((p) => ({ ...p, location: id, price: eur(p.price) })),
    file,
  );
}

/* ---------- Geburtstag ---------- */

const birthdayFile = z.object({
  packages: z.array(z.record(z.string(), z.unknown().optional())),
  addons: z.array(z.record(z.string(), z.unknown().optional())).default([]),
  rules: z.array(z.object({ text: z.string(), verificationStatus: z.enum(["verified_public", "conflicting_public", "client_approved"]), note: z.unknown().optional() })),
});

export function birthdayFor(id: LocationId) {
  const file = `geburtstag-${id}`;
  const raw = parse(birthdayFile, RAW.geburtstag[id], file);
  const packages = parse(
    z.array(S.birthdayPackage),
    raw.packages.map((p) => ({ ...p, location: id, unit: "pro Kind", price: eur(p.price as number) })),
    file,
  );
  const addons = parse(
    z.array(S.birthdayAddon),
    raw.addons.map((a) => ({ ...a, location: id, price: eur(a.price as number) })),
    file,
  );
  const rules = raw.rules.map((r) => ({
    text: r.text,
    verificationStatus: r.verificationStatus,
    note: typeof r.note === "string" && r.note !== "" ? r.note : undefined,
  }));
  return { packages, addons, rules };
}

/* ---------- Speisekarte ---------- */

const menuFile = z.object({
  asOf: z.string(),
  notices: z.array(z.string()),
  sourceImages: z.array(z.object({ label: z.string(), url: z.string() })).default([]),
  provenance: S.provenance,
  sections: z.array(
    z.object({
      id: z.string(),
      title: z.string(),
      kind: z.enum(["food", "drinks"]),
      items: z.array(
        z.object({
          name: z.string(),
          detail: z.unknown().optional(),
          note: z.unknown().optional(),
          variants: z.array(z.object({ size: z.unknown().optional(), price: z.number().nullable() })),
        }),
      ),
    }),
  ),
});

export function menuFor(id: LocationId): S.Menu {
  const file = `speisekarte-${id}`;
  const raw = parse(menuFile, RAW.speisekarte[id], file);
  return parse(
    S.menu,
    {
      ...raw,
      location: id,
      sections: raw.sections.map((s) => ({
        ...s,
        items: s.items.map((i) => ({ ...i, variants: i.variants.map((v) => ({ size: v.size, price: v.price === null ? null : eur(v.price) })) })),
      })),
    },
    file,
  );
}

/* ---------- FAQ ---------- */

export function faqItems(): S.Faq[] {
  return parse(z.object({ items: z.array(S.faq) }), faqFile, "faq").items;
}
