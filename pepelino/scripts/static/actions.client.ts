// Wird NUR in der statischen Vorschau (npm run build:static) anstelle von
// src/lib/forms/actions.ts verwendet: gleiche Prüfung, aber im Browser.
// Es wird nichts gespeichert oder versendet.
import { birthdaySchema, contactSchema, formDataToObject, groupSchema, toFieldErrors } from "@/lib/validation/inquiries";
import { DEMO_SUCCESS_MESSAGE } from "@/lib/forms/transport";
import type { FormState } from "@/lib/forms/state";
import type { ZodType } from "zod";

function run(schema: ZodType, formData: FormData): FormState {
  const values = formDataToObject(formData);
  if (values.website) return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE };
  const r = schema.safeParse(values);
  if (!r.success) {
    const { privacy: _p, ...rest } = values;
    void _p;
    return { status: "error", message: "Bitte prüft die markierten Felder.", fieldErrors: toFieldErrors(r.error), values: rest };
  }
  return { status: "demo_success", message: DEMO_SUCCESS_MESSAGE };
}

export async function submitBirthdayInquiry(_prev: FormState, fd: FormData): Promise<FormState> {
  return run(birthdaySchema(), fd);
}
export async function submitGroupInquiry(_prev: FormState, fd: FormData): Promise<FormState> {
  return run(groupSchema(), fd);
}
export async function submitContactInquiry(_prev: FormState, fd: FormData): Promise<FormState> {
  return run(contactSchema, fd);
}
