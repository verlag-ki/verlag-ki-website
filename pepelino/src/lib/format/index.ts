import type { Weekday } from "@/content/schema";

const priceFormatter = new Intl.NumberFormat("de-DE", { style: "currency", currency: "EUR" });

export function formatPrice(amount: number): string {
  return priceFormatter.format(amount);
}

export const WEEKDAY_LABEL: Record<Weekday, string> = {
  mo: "Montag",
  di: "Dienstag",
  mi: "Mittwoch",
  do: "Donnerstag",
  fr: "Freitag",
  sa: "Samstag",
  so: "Sonntag",
};

export const WEEKDAY_SCHEMA: Record<Weekday, string> = {
  mo: "Monday",
  di: "Tuesday",
  mi: "Wednesday",
  do: "Thursday",
  fr: "Friday",
  sa: "Saturday",
  so: "Sunday",
};

/** "Montag – Donnerstag", "Samstag & Sonntag", "Freitag" */
export function formatDays(days: readonly Weekday[]): string {
  if (days.length === 1) return WEEKDAY_LABEL[days[0]];
  if (days.length === 2) return `${WEEKDAY_LABEL[days[0]]} & ${WEEKDAY_LABEL[days[1]]}`;
  return `${WEEKDAY_LABEL[days[0]]} – ${WEEKDAY_LABEL[days[days.length - 1]]}`;
}

export function formatTimeRange(opens: string | null, closes: string | null): string {
  if (!opens || !closes) return "geschlossen";
  return `${opens} – ${closes} Uhr`;
}

/** Heutiges Datum (YYYY-MM-DD) in Europe/Berlin. */
export function todayInBerlin(now: Date = new Date()): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Europe/Berlin", year: "numeric", month: "2-digit", day: "2-digit" }).format(now);
}
