"use client";

import { useActionState, useEffect, useRef } from "react";
import { submitContactInquiry } from "@/lib/forms/actions";
import { initialFormState } from "@/lib/forms/state";
import { FormStatus, Honeypot, PrivacyCheckbox, SelectField, SubmitButton, TextArea, TextField } from "./Fields";

export function ContactForm() {
  const [state, action, pending] = useActionState(submitContactInquiry, initialFormState);
  const formRef = useRef<HTMLFormElement>(null);
  useEffect(() => {
    if (state.status === "error") formRef.current?.querySelector<HTMLElement>("[aria-invalid=true]")?.focus();
  }, [state]);
  return (
    <form ref={formRef} action={action} noValidate className="relative space-y-6">
      <Honeypot />
      <div className="grid gap-5 sm:grid-cols-2">
        <TextField name="name" label="Name" state={state} required autoComplete="name" />
        <SelectField
          name="location"
          label="Worum geht es?"
          state={state}
          required
          options={[
            { value: "kiel", label: "Standort Kiel" },
            { value: "westerroenfeld", label: "Standort Westerrönfeld" },
            { value: "allgemein", label: "Allgemeine Frage" },
          ]}
        />
        <TextField name="email" label="E-Mail" type="email" inputMode="email" state={state} required autoComplete="email" className="sm:col-span-2" />
      </div>
      <TextArea name="message" label="Nachricht" state={state} required />
      <PrivacyCheckbox state={state} />
      <div aria-live="polite">
        <FormStatus state={state} />
      </div>
      <SubmitButton pending={pending} label="Nachricht prüfen (Demo)" />
    </form>
  );
}
