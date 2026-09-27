import { z } from "zod";
import { weekday, type LocationId, type Weekday } from "@/content/schema";
import termineKiel from "@/content/data/geburtstag-termine-kiel.json";
import termineRd from "@/content/data/geburtstag-termine-westerroenfeld.json";
import { CLOSED_REASON_TEXT } from "./texts";

/**
 * Vorbereitung Geburtstags-Kalender.
 *
 * Stand: AUSGESCHALTET. Solange Pepelino Zeitfenster und Kapazitäten nicht
 * festgelegt hat, nimmt das Formular nur Wunschtermine als Anfrage entgegen.
 *
 * Einschalten (Stufe 1 – „Regel-Kalender“): im Pflegebereich unter
 * „Geburtstagstermine“ Wochentage, Zeitfenster und Kapazität pflegen und
 * „Kalender aktiv“ setzen. Das Formular zeigt dann nur noch buchbare Tage und
 * Zeitfenster. Belegte Plätze kennt die Website in Stufe 1 NICHT.
 *
 * Stufe 2 („Live-Verfügbarkeit“): einen `BookingProvider` für ein Buchungs-
 * system oder eine eigene Datenbank implementieren und in `getBookingProvider()`
 * zurückgeben. Die Oberfläche bleibt gleich. Siehe docs/GEBURTSTAGSKALENDER.md.
 */

export const bookingConfigSchema = z.object({
  enabled: z.boolean(),
  weekdays: z.array(weekday),
  /** Zusätzliche buchbare Tage (z. B. Feiertage, Ferientage), YYYY-MM-DD */
  extraDates: z.array(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).default([]),
  /** Gesperrte Tage (z. B. Betriebsferien), YYYY-MM-DD */
  blockedDates: z.array(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).default([]),
  slotStarts: z.array(z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/)).min(1),
  durationMinutes: z.number().int().positive(),
  /** Parallele Feiern je Zeitfenster; 0 = unbekannt */
  capacityPerSlot: z.number().int().min(0),
  leadTimeDays: z.number().int().min(0),
  maxDaysAhead: z.number().int().positive(),
  note: z.string().optional(),
});
export type BookingConfig = z.infer<typeof bookingConfigSchema>;

const CONFIGS: Record<LocationId, BookingConfig> = {
  kiel: bookingConfigSchema.parse(termineKiel),
  westerroenfeld: bookingConfigSchema.parse(termineRd),
};

export function bookingConfig(location: LocationId): BookingConfig {
  return CONFIGS[location];
}

/** Kalender ist nur aktiv, wenn im Pflegebereich eingeschaltet ODER per Umgebungsvariable für Demos erzwungen. */
export function calendarEnabled(location: LocationId): boolean {
  return process.env.BIRTHDAY_CALENDAR === "demo" || CONFIGS[location].enabled;
}

export type Slot = {
  start: string;
  end: string;
  /** null = Kapazität unbekannt (Stufe 1); Zahl = freie Plätze (Stufe 2) */
  available: number | null;
};

export type Availability =
  | { status: "disabled" }
  | { status: "closed"; reason: keyof typeof CLOSED_REASON_TEXT }
  | { status: "open"; slots: Slot[]; live: boolean };

export interface BookingProvider {
  readonly name: string;
  getAvailability(location: LocationId, date: string, today: string): Promise<Availability>;
  /** Stufe 2: verbindliche Reservierung. In Stufe 1 bewusst nicht implementiert. */
  reserve?(input: { location: LocationId; date: string; start: string; packageId: string; children: number }): Promise<{ reservationId: string }>;
}

const WEEKDAYS: Weekday[] = ["so", "mo", "di", "mi", "do", "fr", "sa"];

function addMinutes(time: string, minutes: number): string {
  const [h, m] = time.split(":").map(Number);
  const t = h * 60 + m + minutes;
  return `${String(Math.floor(t / 60) % 24).padStart(2, "0")}:${String(t % 60).padStart(2, "0")}`;
}

function daysBetween(a: string, b: string): number {
  return Math.round((Date.parse(`${b}T00:00:00Z`) - Date.parse(`${a}T00:00:00Z`)) / 864e5);
}

/** Stufe 1: berechnet buchbare Tage und Zeitfenster nur aus den gepflegten Regeln. */
export const rulesProvider: BookingProvider = {
  name: "rules",
  async getAvailability(location, date, today) {
    const cfg = CONFIGS[location];
    const diff = daysBetween(today, date);
    if (diff < 0) return { status: "closed", reason: "past" };
    if (diff < cfg.leadTimeDays) return { status: "closed", reason: "too_soon" };
    if (diff > cfg.maxDaysAhead) return { status: "closed", reason: "too_far" };
    if (cfg.blockedDates.includes(date)) return { status: "closed", reason: "blocked" };
    const wd = WEEKDAYS[new Date(`${date}T00:00:00Z`).getUTCDay()];
    if (!cfg.weekdays.includes(wd) && !cfg.extraDates.includes(date)) return { status: "closed", reason: "weekday" };
    return {
      status: "open",
      live: false,
      slots: cfg.slotStarts.map((start) => ({
        start,
        end: addMinutes(start, cfg.durationMinutes),
        available: cfg.capacityPerSlot > 0 ? cfg.capacityPerSlot : null,
      })),
    };
  },
};

export function getBookingProvider(): BookingProvider {
  // Stufe 2: hier z. B. einen Adapter für ein externes Buchungssystem zurückgeben.
  return rulesProvider;
}

export async function availabilityFor(location: LocationId, date: string, today: string): Promise<Availability> {
  if (!calendarEnabled(location)) return { status: "disabled" };
  return getBookingProvider().getAvailability(location, date, today);
}

export { CLOSED_REASON_TEXT } from "./texts";
