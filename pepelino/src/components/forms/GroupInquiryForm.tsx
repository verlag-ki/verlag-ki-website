"use client";

import { useActionState, useEffect, useRef } from "react";
import { submitGroupInquiry } from "@/lib/forms/actions";
import { initialFormState } from "@/lib/forms/state";
import { DateField, FormStatus, Honeypot, PrivacyCheckbox, SelectField, SubmitButton, TextArea, TextField } from "./Fields";

const TIMES = ["08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00"];

export function GroupInquiryForm() {
  const [state, action, pending] = useActionState(submitGroupInquiry, initialFormState);
  const formRef = useRef<HTMLFormElement>(null);
  useEffect(() => {
    if (state.status === "error") formRef.current?.querySelector<HTMLElement>("[aria-invalid=true]")?.focus();
  }, [state]);
  const timeOptions = TIMES.map((t) => ({ value: t, label: `${t} Uhr` }));

  return (
    <form ref={formRef} action={action} noValidate className="relative space-y-7">
      <p className="text-[0.95rem] text-ink-soft">
        Unverbindliche Anfrage. Pflichtfelder sind mit <span className="text-pink-strong">*</span> markiert.
      </p>
      <Honeypot />
      <div className="grid gap-5 sm:grid-cols-2">
        <TextField name="institution" label="Einrichtung / Schule" state={state} required autoComplete="organization" className="sm:col-span-2" />
        <TextField name="ageGroup" label="Alter oder Jahrgangsstufe" state={state} required hint="z. B. „3. Klasse“ oder „4–6 Jahre“" />
        <SelectField
          name="location"
          label="Standort"
          state={state}
          required
          options={[
            { value: "kiel", label: "Kiel" },
            { value: "westerroenfeld", label: "Westerrönfeld (Konditionen auf Anfrage)" },
          ]}
        />
        <DateField name="date" label="Wunschdatum" state={state} required />
        <div className="grid grid-cols-2 gap-3">
          <SelectField name="startTime" label="Von" state={state} required options={timeOptions} />
          <SelectField name="endTime" label="Bis" state={state} required options={timeOptions} />
        </div>
        <TextField name="children" label="Anzahl Kinder" type="number" inputMode="numeric" min={1} max={200} state={state} required />
        <TextField name="adults" label="Anzahl Begleitpersonen" type="number" inputMode="numeric" min={1} max={50} state={state} required />
      </div>
      <fieldset className="space-y-5">
        <legend className="font-display text-xl font-bold">Ansprechperson</legend>
        <div className="grid gap-5 sm:grid-cols-2">
          <TextField name="contactName" label="Vor- und Nachname" state={state} required autoComplete="name" className="sm:col-span-2" />
          <TextField name="email" label="E-Mail" type="email" inputMode="email" state={state} required autoComplete="email" />
          <TextField name="phone" label="Telefon" type="tel" inputMode="tel" state={state} required autoComplete="tel" />
        </div>
        <TextArea name="message" label="Nachricht" state={state} hint="z. B. Essenswünsche oder Besonderheiten der Gruppe" />
      </fieldset>
      <PrivacyCheckbox state={state} />
      <div aria-live="polite">
        <FormStatus state={state} />
      </div>
      <SubmitButton pending={pending} label="Gruppenanfrage prüfen (Demo)" />
    </form>
  );
}
