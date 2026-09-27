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

const dayFmt = new Intl.DateTimeFormat("de-DE", { weekday: "short", day: "2-digit", month: "2-digit", timeZone: "UTC" });

/** "Mo., 12.10." bzw. "Mo., 12.10. – Fr., 23.10." (ISO-Datumsangaben YYYY-MM-DD) */
export function formatDateRange(from: string, to: string): string {
  const f = dayFmt.format(new Date(`${from}T00:00:00Z`));
  if (to === from) return f;
  return `${f} – ${dayFmt.format(new Date(`${to}T00:00:00Z`))}`;
}

/** Nur Einträge, die heute noch gelten oder in der Zukunft liegen. */
export function upcoming<T extends { to: string }>(items: T[], today: string = todayInBerlin()): T[] {
  return items.filter((i) => i.to >= today);
}
