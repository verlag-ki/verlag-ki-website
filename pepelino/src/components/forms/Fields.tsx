"use client";

import { useEffect, useState } from "react";
import type { FormState } from "@/lib/forms/state";
import { todayInBerlin } from "@/lib/format";
import { Icon } from "@/components/ui/Icon";

const inputBase =
  "mt-1.5 block w-full min-h-12 rounded-xl bg-white px-4 py-2.5 text-base text-ink shadow-[inset_0_0_0_1.5px_var(--color-line-strong)] placeholder:text-ink-soft/70 focus:outline-none focus:shadow-[inset_0_0_0_2.5px_var(--color-blue)] aria-[invalid=true]:shadow-[inset_0_0_0_2px_var(--color-pink)]";

type BaseProps = {
  name: string;
  label: string;
  state: FormState;
  hint?: string;
  required?: boolean;
  className?: string;
};

function describedBy(name: string, hint?: string, error?: string) {
  return [hint ? `${name}-hint` : null, error ? `${name}-error` : null].filter(Boolean).join(" ") || undefined;
}

function Meta({ name, hint, error }: { name: string; hint?: string; error?: string }) {
  return (
    <>
      {hint && (
        <p id={`${name}-hint`} className="mt-1 text-[0.9rem] text-ink-soft">
          {hint}
        </p>
      )}
      {error && (
        <p id={`${name}-error`} className="mt-1 text-[0.9rem] font-bold text-pink-strong">
          {error}
        </p>
      )}
    </>
  );
}

function LabelText({ label, required }: { label: string; required?: boolean }) {
  return (
    <span className="font-bold">
      {label}
      {required ? (
        <span className="text-pink-strong" aria-hidden="true">
          {" "}
          *
        </span>
      ) : (
        <span className="font-normal text-ink-soft"> (optional)</span>
      )}
    </span>
  );
}

export function TextField({
  name,
  label,
  state,
  hint,
  required,
  className,
  type = "text",
  autoComplete,
  inputMode,
  min,
  max,
  defaultValue,
}: BaseProps & {
  type?: "text" | "email" | "tel" | "number" | "time";
  autoComplete?: string;
  inputMode?: "numeric" | "tel" | "email" | "text";
  min?: number | string;
  max?: number | string;
  defaultValue?: string;
}) {
  const error = state.fieldErrors?.[name];
  return (
    <div className={className}>
      <label htmlFor={`f-${name}`}>
        <LabelText label={label} required={required} />
      </label>
      <input
        id={`f-${name}`}
        name={name}
        type={type}
        required={required}
        autoComplete={autoComplete}
        inputMode={inputMode}
        min={min}
        max={max}
        defaultValue={state.values?.[name] ?? defaultValue}
        aria-invalid={error ? true : undefined}
        aria-describedby={describedBy(name, hint, error)}
        className={inputBase}
      />
      <Meta name={name} hint={hint} error={error} />
    </div>
  );
}

/** Datumsfeld mit clientseitig gesetztem Minimum „heute“ (Europe/Berlin). */
export function DateField(props: BaseProps) {
  const { name, label, state, hint, required, className } = props;
  const [min, setMin] = useState<string | undefined>(undefined);
  useEffect(() => {
    // Erst im Browser setzen, damit statisch gerenderte Seiten kein veraltetes Datum enthalten.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMin(todayInBerlin());
  }, []);
  const error = state.fieldErrors?.[name];
  return (
    <div className={className}>
      <label htmlFor={`f-${name}`}>
        <LabelText label={label} required={required} />
      </label>
      <input
        id={`f-${name}`}
        name={name}
        type="date"
        required={required}
        min={min}
        defaultValue={state.values?.[name]}
        aria-invalid={error ? true : undefined}
        aria-describedby={describedBy(name, hint, error)}
        className={inputBase}
      />
      <Meta name={name} hint={hint} error={error} />
    </div>
  );
}

export function SelectField({
  name,
  label,
  state,
  hint,
  required,
  className,
  options,
  defaultValue,
}: BaseProps & { options: { value: string; label: string }[]; defaultValue?: string }) {
  const error = state.fieldErrors?.[name];
  return (
    <div className={className}>
      <label htmlFor={`f-${name}`}>
        <LabelText label={label} required={required} />
      </label>
      <select
        id={`f-${name}`}
        name={name}
        required={required}
        defaultValue={state.values?.[name] ?? defaultValue ?? ""}
        aria-invalid={error ? true : undefined}
        aria-describedby={describedBy(name, hint, error)}
        className={`${inputBase} appearance-none bg-[url('data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22 fill=%22none%22 stroke=%22%23163452%22 stroke-width=%222%22><path d=%22m6 9 6 6 6-6%22/></svg>')] bg-[length:1.1rem] bg-[right_1rem_center] bg-no-repeat pr-10`}
      >
        <option value="" disabled>
          Bitte wählen
        </option>
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
      <Meta name={name} hint={hint} error={error} />
    </div>
  );
}

export function TextArea({ name, label, state, hint, required, className }: BaseProps) {
  const error = state.fieldErrors?.[name];
  return (
    <div className={className}>
      <label htmlFor={`f-${name}`}>
        <LabelText label={label} required={required} />
      </label>
      <textarea
        id={`f-${name}`}
        name={name}
        rows={4}
        required={required}
        defaultValue={state.values?.[name]}
        aria-invalid={error ? true : undefined}
        aria-describedby={describedBy(name, hint, error)}
        className={`${inputBase} min-h-28`}
      />
      <Meta name={name} hint={hint} error={error} />
    </div>
  );
}

export function PrivacyCheckbox({ state }: { state: FormState }) {
  const error = state.fieldErrors?.privacy;
  return (
    <div>
      <div className="flex items-start gap-3">
        <input
          id="f-privacy"
          name="privacy"
          type="checkbox"
          required
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? "privacy-error" : undefined}
          className="mt-1 size-6 shrink-0 accent-[var(--color-blue)]"
        />
        <label htmlFor="f-privacy" className="text-[0.95rem]">
          Ich habe die{" "}
          <a href="/datenschutzerklaerung/" className="font-bold underline underline-offset-4">
            Datenschutzhinweise
          </a>{" "}
          gelesen. Meine Angaben werden nur zur Bearbeitung dieser Anfrage verwendet. <span className="text-pink-strong">*</span>
        </label>
      </div>
      {error && (
        <p id="privacy-error" className="mt-1 text-[0.9rem] font-bold text-pink-strong">
          {error}
        </p>
      )}
    </div>
  );
}

/** Unsichtbares Honeypot-Feld gegen einfache Spam-Bots. */
export function Honeypot() {
  return (
    <div aria-hidden="true" className="absolute left-[-9999px] top-auto size-px overflow-hidden">
      <label htmlFor="f-website">Website (bitte leer lassen)</label>
      <input id="f-website" name="website" type="text" tabIndex={-1} autoComplete="off" />
    </div>
  );
}

export function FormStatus({ state }: { state: FormState }) {
  if (state.status === "idle") return null;
  if (state.status === "demo_success") {
    return (
      <div role="status" className="flex gap-3 rounded-2xl bg-sun-wash p-5 shadow-[inset_0_0_0_1.5px_#f1d58f]">
        <Icon name="info" className="mt-0.5 size-6 shrink-0" />
        <div>
          <p className="font-display text-lg font-bold">{state.message}</p>
          <p className="mt-1 text-[0.95rem]">
            Eure Eingaben waren vollständig und wurden geprüft – in dieser Vorschau aber weder gespeichert noch verschickt. Für eine echte Anfrage meldet euch bitte direkt beim Standort.
          </p>
        </div>
      </div>
    );
  }
  return (
    <div role="alert" className="rounded-2xl bg-pink-wash p-4 font-bold text-pink-strong">
      {state.message}
    </div>
  );
}

export function SubmitButton({ pending, label }: { pending: boolean; label: string }) {
  return (
    <button type="submit" className="btn btn-pink w-full sm:w-auto" disabled={pending} aria-disabled={pending}>
      {pending ? "Wird geprüft …" : label}
      {!pending && <Icon name="arrow" className="size-4" />}
    </button>
  );
}
