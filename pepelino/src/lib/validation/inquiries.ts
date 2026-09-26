import { z } from "zod";
import { addonsFor, packagesFor } from "@/content/birthdays";
import { locationId } from "@/content/schema";
import { todayInBerlin } from "@/lib/format";

/**
 * Gemeinsame Validierung für Client (Hinweise) und Server (verbindliche Prüfung).
 * Erfasst wird nur, was für die Bearbeitung einer Anfrage nötig ist –
 * z. B. kein Geschlecht des Geburtstagskindes (siehe docs/CONTENT_VERIFICATION.md).
 */

const trimmed = (max: number) => z.string().trim().max(max, `Bitte höchstens ${max} Zeichen.`);
const required = (label: string, max = 120) => trimmed(max).min(1, `Bitte ${label} angeben.`);

const phone = z
  .string()
  .trim()
  .min(1, "Bitte eine Telefonnummer angeben.")
  .regex(/^[+()\d\s/-]{6,25}$/, "Bitte eine gültige Telefonnummer angeben.");

const email = z.string().trim().min(1, "Bitte eine E-Mail-Adresse angeben.").email("Bitte eine gültige E-Mail-Adresse angeben.");

const count = (label: string, min: number, max: number) =>
  z.coerce
    .number({ error: `Bitte ${label} angeben.` })
    .int(`Bitte eine ganze Zahl für ${label} angeben.`)
    .min(min, `Mindestens ${min}.`)
    .max(max, `Bitte höchstens ${max} – für größere Gruppen schreibt uns gern eine Nachricht.`);

const futureDate = (today: () => string) =>
  z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Bitte ein Datum wählen.")
    .refine((d) => d >= today(), "Bitte ein Datum ab heute wählen.");

const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, "Bitte eine Uhrzeit wählen.");

const consent = z.literal("on", { error: "Bitte bestätigt den Datenschutzhinweis." });

export function birthdaySchema(today: () => string = () => todayInBerlin()) {
  return z
    .object({
      location: locationId,
      packageId: z.string().min(1, "Bitte ein Paket wählen."),
      addonId: z.string().optional().default("none"),
      childName: required("den Vornamen des Geburtstagskindes", 60),
      childAge: z.coerce.number().int().min(1, "Bitte ein Alter zwischen 1 und 17 angeben.").max(17, "Bitte ein Alter zwischen 1 und 17 angeben."),
      date: futureDate(today),
      startTime: time,
      children: count("die Anzahl der Kinder", 5, 40),
      adults: count("die Anzahl der Erwachsenen", 0, 40),
      contactName: required("euren Namen"),
      email,
      phone,
      message: trimmed(1500).optional().default(""),
      privacy: consent,
    })
    .superRefine((v, ctx) => {
      if (!packagesFor(v.location).some((p) => p.id === v.packageId)) {
        ctx.addIssue({ code: "custom", path: ["packageId"], message: "Dieses Paket gibt es an diesem Standort nicht." });
      }
      if (v.addonId && v.addonId !== "none" && !addonsFor(v.location).some((a) => a.id === v.addonId)) {
        ctx.addIssue({ code: "custom", path: ["addonId"], message: "Diese Option gibt es an diesem Standort nicht." });
      }
    });
}

export function groupSchema(today: () => string = () => todayInBerlin()) {
  return z
    .object({
      institution: required("die Einrichtung oder Schule"),
      ageGroup: required("Alter oder Jahrgangsstufe", 60),
      location: locationId,
      date: futureDate(today),
      startTime: time,
      endTime: time,
      children: count("die Anzahl der Kinder", 1, 200),
      adults: count("die Anzahl der Begleitpersonen", 1, 50),
      contactName: required("euren Namen"),
      email,
      phone,
      message: trimmed(1500).optional().default(""),
      privacy: consent,
    })
    .refine((v) => v.endTime > v.startTime, { path: ["endTime"], message: "Das Ende muss nach dem Beginn liegen." });
}

export const contactSchema = z.object({
  name: required("euren Namen"),
  location: z.enum(["kiel", "westerroenfeld", "allgemein"], { error: "Bitte einen Standort wählen." }),
  email,
  message: required("eine Nachricht", 2000),
  privacy: consent,
});

export type FieldErrors = Record<string, string>;

export function toFieldErrors(error: z.ZodError): FieldErrors {
  const out: FieldErrors = {};
  for (const issue of error.issues) {
    const key = String(issue.path[0] ?? "form");
    if (!out[key]) out[key] = issue.message;
  }
  return out;
}

export function formDataToObject(fd: FormData): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [k, v] of fd.entries()) if (typeof v === "string" && !k.startsWith("$")) out[k] = v;
  return out;
}
