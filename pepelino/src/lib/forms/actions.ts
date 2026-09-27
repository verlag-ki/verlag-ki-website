"use server";

import { birthdaySchema, contactSchema, formDataToObject, groupSchema, toFieldErrors } from "@/lib/validation/inquiries";
import { DEMO_SUCCESS_MESSAGE, getInquiryTransport } from "./transport";
import type { FormState } from "./state";
import { availabilityFor, calendarEnabled, CLOSED_REASON_TEXT } from "@/lib/booking";
import { todayInBerlin } from "@/lib/format";

/** Personenbezogene Felder werden bei Fehlern zurückgegeben, damit nichts neu getippt werden muss – aber nie gespeichert. */
function fail(error: import("zod").ZodError, values: Record<string, string>): FormState {
  const { privacy: _privacy, ...rest } = values;
  void _privacy;
  return {
    status: "error",
    message: "Bitte prüft die markierten Felder.",
    fieldErrors: toFieldErrors(error),
    values: rest,
  };
}

async function handle(kind: "birthday" | "group" | "contact", parsed: Record<string, unknown>): Promise<FormState> {
  const transport = getInquiryTransport();
  await transport.send(kind, parsed);
  return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE };
}

export async function submitBirthdayInquiry(_prev: FormState, formData: FormData): Promise<FormState> {
  const values = formDataToObject(formData);
  if (values.website) return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE }; // Honeypot
  const result = birthdaySchema().safeParse(values);
  if (!result.success) return fail(result.error, values);
  // Kalender aktiv: Zeitfenster serverseitig gegen die Regeln/Verfügbarkeit prüfen.
  if (calendarEnabled(result.data.location)) {
    const a = await availabilityFor(result.data.location, result.data.date, todayInBerlin());
    const slotError: Record<string, string> | null =
      a.status === "closed"
        ? { date: CLOSED_REASON_TEXT[a.reason] }
        : a.status === "open" && !a.slots.some((s) => s.start === result.data.startTime && s.available !== 0)
          ? { startTime: "Dieses Zeitfenster ist nicht verfügbar." }
          : null;
    if (slotError) {
      const { privacy: _p, ...rest } = values;
      void _p;
      return { status: "error", message: "Bitte prüft die markierten Felder.", fieldErrors: slotError, values: rest };
    }
  }
  return handle("birthday", result.data);
}

export async function submitGroupInquiry(_prev: FormState, formData: FormData): Promise<FormState> {
  const values = formDataToObject(formData);
  if (values.website) return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE };
  const result = groupSchema().safeParse(values);
  if (!result.success) return fail(result.error, values);
  return handle("group", result.data);
}

export async function submitContactInquiry(_prev: FormState, formData: FormData): Promise<FormState> {
  const values = formDataToObject(formData);
  if (values.website) return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE };
  const result = contactSchema.safeParse(values);
  if (!result.success) return fail(result.error, values);
  return handle("contact", result.data);
}
