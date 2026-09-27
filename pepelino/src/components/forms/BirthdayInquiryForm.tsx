"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import type { BirthdayAddon, BirthdayPackage, LocationId } from "@/content/schema";
import { submitBirthdayInquiry } from "@/lib/forms/actions";
import { initialFormState } from "@/lib/forms/state";
import { formatPrice } from "@/lib/format";
import { SlotPicker } from "./SlotPicker";
import { DateField, FormStatus, Honeypot, PrivacyCheckbox, SelectField, SubmitButton, TextArea, TextField } from "./Fields";

type Props = {
  location: LocationId;
  locationName: string;
  packages: BirthdayPackage[];
  addons: BirthdayAddon[];
  dateHint: string;
  /** Geburtstags-Kalender aktiv? Dann Zeitfenster statt freier Startzeit (siehe src/lib/booking). */
  calendar?: boolean;
};

const START_TIMES = ["11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30"];

/**
 * Anfrageformular Kindergeburtstag. Pakete/Optionen kommen aus denselben
 * Datensätzen wie die Paketübersicht (src/content/birthdays.ts).
 */
export function BirthdayInquiryForm({ location, locationName, packages, addons, dateHint, calendar = false }: Props) {
  const [state, action, pending] = useActionState(submitBirthdayInquiry, initialFormState);
  const formRef = useRef<HTMLFormElement>(null);
  const statusRef = useRef<HTMLDivElement>(null);
  const [date, setDate] = useState("");

  // Paketkarten verlinken auf #paket-<id>: passendes Paket vorauswählen.
  useEffect(() => {
    const select = () => {
      const id = decodeURIComponent(window.location.hash.replace(/^#paket-/, ""));
      const input = formRef.current?.querySelector<HTMLInputElement>(`input[name="packageId"][value="${CSS.escape(id)}"]`);
      if (input) {
        input.checked = true;
        input.focus({ preventScroll: true });
      }
    };
    select();
    window.addEventListener("hashchange", select);
    return () => window.removeEventListener("hashchange", select);
  }, []);

  useEffect(() => {
    if (state.status === "idle") return;
    if (state.status === "error") {
      const first = formRef.current?.querySelector<HTMLElement>("[aria-invalid=true]");
      first?.focus();
    } else statusRef.current?.scrollIntoView({ block: "center" });
  }, [state]);

  const pkgError = state.fieldErrors?.packageId;
  const selectedPkg = state.values?.packageId;

  return (
    <form ref={formRef} action={action} noValidate className="relative space-y-7" aria-describedby="form-demo-note">
      <p id="form-demo-note" className="text-[0.95rem] text-ink-soft">
        Unverbindliche Anfrage – wir bestätigen den Termin per E-Mail oder Telefon. Pflichtfelder sind mit <span className="text-pink-strong">*</span> markiert.
      </p>
      <input type="hidden" name="location" value={location} />
      <Honeypot />

      <fieldset aria-describedby={pkgError ? "packageId-error" : undefined}>
        <legend className="font-bold">
          Paket <span className="text-pink-strong" aria-hidden="true">*</span>
        </legend>
        <div className="mt-2 grid gap-3 sm:grid-cols-3">
          {packages.map((p, i) => (
            <label
              key={p.id}
              className="flex min-h-14 cursor-pointer items-center gap-3 rounded-xl bg-white px-4 py-3 shadow-[inset_0_0_0_1.5px_var(--color-line-strong)] has-[:checked]:shadow-[inset_0_0_0_2.5px_var(--color-pink)] has-[:focus-visible]:outline has-[:focus-visible]:outline-3 has-[:focus-visible]:outline-blue"
            >
              <input
                type="radio"
                name="packageId"
                value={p.id}
                required
                defaultChecked={selectedPkg ? selectedPkg === p.id : i === 1}
                className="size-5 accent-[var(--color-pink)]"
              />
              <span>
                <span className="block font-bold">{p.name}</span>
                <span className="block text-[0.9rem] text-ink-soft">{formatPrice(p.price.amount)} pro Kind</span>
              </span>
            </label>
          ))}
        </div>
        {pkgError && (
          <p id="packageId-error" className="mt-1 text-[0.9rem] font-bold text-pink-strong">
            {pkgError}
          </p>
        )}
      </fieldset>

      {addons.length > 0 && (
        <SelectField
          name="addonId"
          label="Kabine oder Nische"
          state={state}
          defaultValue="none"
          options={[
            { value: "none", label: "Kein Bedarf" },
            ...addons.map((a) => ({ value: a.id, label: `${a.name} (${formatPrice(a.price.amount)})` })),
          ]}
          hint={`Nur in ${locationName} buchbar.`}
        />
      )}

      <div className="grid gap-5 sm:grid-cols-2">
        <TextField name="childName" label="Vorname des Geburtstagskindes" state={state} required autoComplete="off" hint="Für das persönliche Namensschild." />
        <TextField name="childAge" label="Alter, das gefeiert wird" type="number" inputMode="numeric" min={1} max={17} state={state} required />
        <DateField name="date" label="Wunschdatum" state={state} required hint={dateHint} onValueChange={calendar ? setDate : undefined} />
        {calendar ? (
          <div className="sm:col-span-2">
            <SlotPicker location={location} date={date || state.values?.date || ""} error={state.fieldErrors?.startTime} defaultValue={state.values?.startTime} />
          </div>
        ) : (
          <SelectField
            name="startTime"
            label="Gewünschte Startzeit"
            state={state}
            required
            options={START_TIMES.map((t) => ({ value: t, label: `${t} Uhr` }))}
            hint="Wir stimmen die genaue Zeit mit euch ab."
          />
        )}
        <TextField name="children" label="Anzahl Kinder (inkl. Geburtstagskind)" type="number" inputMode="numeric" min={5} max={40} state={state} required hint="Mindestens 5 Kinder." />
        <TextField name="adults" label="Anzahl Erwachsene" type="number" inputMode="numeric" min={0} max={40} state={state} required />
      </div>

      <fieldset className="space-y-5">
        <legend className="font-display text-xl font-bold">Eure Kontaktdaten</legend>
        <div className="grid gap-5 sm:grid-cols-2">
          <TextField name="contactName" label="Vor- und Nachname" state={state} required autoComplete="name" className="sm:col-span-2" />
          <TextField name="email" label="E-Mail" type="email" inputMode="email" state={state} required autoComplete="email" />
          <TextField name="phone" label="Telefon" type="tel" inputMode="tel" state={state} required autoComplete="tel" hint="Für Rückfragen zum Termin." />
        </div>
        <TextArea name="message" label="Nachricht" state={state} />
      </fieldset>

      <PrivacyCheckbox state={state} />

      <div ref={statusRef} aria-live="polite">
        <FormStatus state={state} />
      </div>

      <SubmitButton pending={pending} label="Anfrage prüfen & senden (Demo)" />
    </form>
  );
}
