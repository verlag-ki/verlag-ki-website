"use client";

import { useEffect, useState } from "react";
import type { LocationId } from "@/content/schema";
import type { Availability } from "@/lib/booking";
import { CLOSED_REASON_TEXT } from "@/lib/booking/texts";

type Props = {
  location: LocationId;
  date: string;
  error?: string;
  defaultValue?: string;
};

/**
 * Zeitfenster-Auswahl für den Geburtstags-Kalender (nur wenn aktiviert).
 * Lädt nach Datumswahl die buchbaren Zeitfenster von /api/geburtstag/verfuegbarkeit.
 */
export function SlotPicker({ location, date, error, defaultValue }: Props) {
  const [result, setResult] = useState<{ date: string; data: Availability | null; failed: boolean } | null>(null);

  useEffect(() => {
    if (!date) return;
    const ctrl = new AbortController();
    fetch(`/api/geburtstag/verfuegbarkeit?standort=${location}&datum=${date}`, { signal: ctrl.signal })
      .then((r) => (r.ok ? r.json() : Promise.reject(r.status)))
      .then((data: Availability) => setResult({ date, data, failed: false }))
      .catch((e) => {
        if (e?.name !== "AbortError") setResult({ date, data: null, failed: true });
      });
    return () => ctrl.abort();
  }, [location, date]);

  const current = result?.date === date ? result : null;
  const loading = Boolean(date) && !current;

  return (
    <fieldset aria-describedby={error ? "startTime-error" : "slot-status"} aria-busy={loading}>
      <legend className="font-bold">
        Zeitfenster <span className="text-pink-strong" aria-hidden="true">*</span>
      </legend>
      <div id="slot-status" aria-live="polite" className="mt-1 text-[0.9rem] text-ink-soft">
        {!date && "Bitte zuerst ein Datum wählen."}
        {loading && "Freie Zeitfenster werden geladen …"}
        {current?.failed && "Zeitfenster konnten nicht geladen werden – bitte nennt eure Wunschzeit in der Nachricht."}
        {current?.data?.status === "closed" && CLOSED_REASON_TEXT[current.data.reason]}
        {current?.data?.status === "open" && !current.data.live && "Unverbindlich – wir bestätigen den Termin nach Prüfung."}
      </div>
      {current?.data?.status === "open" && (
        <div className="mt-2 grid gap-2 sm:grid-cols-3">
          {current.data.slots.map((s, i) => {
            const full = s.available === 0;
            return (
              <label
                key={s.start}
                className={`flex min-h-12 cursor-pointer items-center gap-3 rounded-xl bg-white px-4 py-2 shadow-[inset_0_0_0_1.5px_var(--color-line-strong)] has-[:checked]:shadow-[inset_0_0_0_2.5px_var(--color-pink)] ${full ? "cursor-not-allowed opacity-50" : ""}`}
              >
                <input
                  type="radio"
                  name="startTime"
                  value={s.start}
                  required
                  disabled={full}
                  defaultChecked={defaultValue ? defaultValue === s.start : i === 0 && !full}
                  className="size-5 accent-[var(--color-pink)]"
                />
                <span>
                  <span className="block font-bold">
                    {s.start} – {s.end} Uhr
                  </span>
                  {s.available !== null && (
                    <span className="block text-[0.85rem] text-ink-soft">{full ? "ausgebucht" : `noch ${s.available} frei`}</span>
                  )}
                </span>
              </label>
            );
          })}
        </div>
      )}
      {error && (
        <p id="startTime-error" className="mt-1 text-[0.9rem] font-bold text-pink-strong">
          {error}
        </p>
      )}
    </fieldset>
  );
}
