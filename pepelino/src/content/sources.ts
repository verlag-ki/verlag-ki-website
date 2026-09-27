import type { Provenance, VerificationStatus } from "./schema";

/** Datum der letzten eigenen Prüfung der öffentlichen Originalseiten. */
export const CHECKED_AT = "2026-09-26";

const ORIGIN = "https://www.pepelino-fun.de";

/** Öffentliche Quellen, die für diese Vorschau erneut abgerufen wurden. */
export const SOURCES = {
  home: `${ORIGIN}/`,
  kiel: `${ORIGIN}/indoorspielplatz-kiel/`,
  rd: `${ORIGIN}/indoorspielplatz-rendsburg/`,
  birthdayKiel: `${ORIGIN}/kindergeburtstag-kiel/`,
  birthdayRd: `${ORIGIN}/kindergeburtstag-rendsburg/`,
  menuKiel: `${ORIGIN}/kinderspieleparadies-kiel/`,
  menuRd: `${ORIGIN}/kinderspieleparadies-rendsburg/`,
  menuImgKielFood: `${ORIGIN}/wp-content/uploads/2025/10/Kiel-Speisen.jpg`,
  menuImgKielDrinks: `${ORIGIN}/wp-content/uploads/2025/10/Kiel-Getraenke.jpg`,
  menuImgRdFood: `${ORIGIN}/wp-content/uploads/2025/10/Rendsburg-Speisen.jpg`,
  menuImgRdDrinks: `${ORIGIN}/wp-content/uploads/2025/10/Rendsburg-Getraenke.jpg`,
  qrKiel: `${ORIGIN}/speisekarte-fuer-qr-code/`,
  qrRd: `${ORIGIN}/speisekarte-qr-code-rd/`,
  groups: `${ORIGIN}/gruppenanmeldung-schulklassen/`,
  contact: `${ORIGIN}/indoorspielplatz-in-der-naehe/`,
  hygiene: `${ORIGIN}/schutz-und-hygienekonzept/`,
  imprint: `${ORIGIN}/impressum/`,
  privacy: `${ORIGIN}/datenschutzerklaerung/`,
  oldBirthdayForm: `${ORIGIN}/kindergeburtstaganmeldung/`,
  voucherShop: "https://gutschein.moinmoinkiel.de/pepelino-gutschein.html",
} as const;

export function src(
  sourceUrl: string,
  verificationStatus: VerificationStatus = "verified_public",
  note?: string,
): Provenance {
  return { sourceUrl, checkedAt: CHECKED_AT, verificationStatus, ...(note ? { note } : {}) };
}
