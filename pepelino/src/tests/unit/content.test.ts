import { describe, expect, it } from "vitest";
import { z } from "zod";
import * as S from "@/content/schema";
import { attractions, homeAttractionIds } from "@/content/attractions";
import { addonsFor, birthdayAddons, birthdayPackages, packagesFor } from "@/content/birthdays";
import { faqs } from "@/content/faq";
import { locationList, locations } from "@/content/locations";
import { media } from "@/content/media";
import { menus } from "@/content/menus";
import { admissionPrices } from "@/content/prices";
import { externalLinks } from "@/content/site";
import { verificationQueue } from "@/content/verification-queue";
import fs from "node:fs";
import path from "node:path";

describe("Inhaltsschemas", () => {
  it.each([
    ["locations", z.array(S.location), locationList],
    ["attractions", z.array(S.attraction), attractions],
    ["admissionPrices", z.array(S.admissionPrice), admissionPrices],
    ["birthdayPackages", z.array(S.birthdayPackage), birthdayPackages],
    ["birthdayAddons", z.array(S.birthdayAddon), birthdayAddons],
    ["menus", z.array(S.menu), Object.values(menus)],
    ["faqs", z.array(S.faq), faqs],
    ["externalLinks", z.array(S.externalLink), externalLinks],
    ["verificationQueue", z.array(S.verificationItem), verificationQueue],
    ["media", z.array(S.mediaAsset), Object.values(media)],
  ] as const)("%s erfüllt das Schema", (_n, schema, data) => {
    const r = (schema as z.ZodType).safeParse(data);
    expect(r.success, r.success ? "" : JSON.stringify(r.error.issues, null, 2)).toBe(true);
  });
});

describe("Datenkonsistenz", () => {
  it("jeder Standort hat genau drei Geburtstagspakete Small/Medium/Large", () => {
    for (const loc of locationList) {
      expect(packagesFor(loc.id).map((p) => p.tier)).toEqual(["small", "medium", "large"]);
    }
  });

  it("Kabine/Nische gibt es nur in Kiel (öffentlich nur dort belegt)", () => {
    expect(addonsFor("westerroenfeld")).toHaveLength(0);
    expect(addonsFor("kiel").length).toBeGreaterThan(0);
  });

  it("widersprüchliche Kieler Slush-Wertgrenze wird nicht als bestätigt ausgegeben", () => {
    for (const p of packagesFor("kiel")) {
      const slush = p.features.find((f) => f.text.includes("Slush"))!;
      expect(slush.verificationStatus).toBe("conflicting_public");
      expect(slush.text).not.toMatch(/\d,\d{2}\s?€/);
    }
  });

  it("IDs sind eindeutig", () => {
    const ids = [...attractions, ...admissionPrices, ...birthdayPackages, ...faqs, ...verificationQueue].map((x) => x.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it("alle referenzierten Medien existieren als Datei", () => {
    const refs = [
      ...attractions.map((a) => a.image).filter(Boolean),
      ...locationList.flatMap((l) => [l.heroImage, l.cardImage]),
    ] as string[];
    for (const key of refs) {
      const m = (media as Record<string, S.MediaAsset>)[key];
      expect(m, key).toBeDefined();
      expect(fs.existsSync(path.join(process.cwd(), "public", m.src)), m.src).toBe(true);
    }
  });

  it("keine Fotos sind als freigegeben markiert, solange Rechte offen sind", () => {
    for (const m of Object.values(media) as S.MediaAsset[]) {
      if (m.id === "logo") expect(m.rightsStatus).toBe("client_provided");
      else expect(m.rightsStatus).toBe("public_website_unverified");
    }
  });

  it("Startseiten-Attraktionen existieren", () => {
    for (const id of homeAttractionIds) expect(attractions.find((a) => a.id === id)).toBeDefined();
  });

  it("Standortseiten-Pfade sind die bestehenden URLs", () => {
    expect(locations.kiel.pages).toEqual({
      location: "/indoorspielplatz-kiel/",
      birthday: "/kindergeburtstag-kiel/",
      menu: "/kinderspieleparadies-kiel/",
      menuQr: "/speisekarte-fuer-qr-code/",
    });
    expect(locations.westerroenfeld.pages.menuQr).toBe("/speisekarte-qr-code-rd/");
  });
});
