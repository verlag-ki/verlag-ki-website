"use client";

import { useState } from "react";

/**
 * Zwei-Klick-Lösung für Drittinhalte. Vor dem Klick wird KEINE Verbindung zu
 * Google aufgebaut. Die Entscheidung gilt nur für diese Seitenansicht und wird
 * nicht gespeichert (kein Cookie, kein localStorage).
 * Für den Livegang an die gewählte Consent-Lösung anbinden (docs/INTEGRATIONS_AND_RIGHTS.md).
 */
export function MapConsent({ query, title }: { query: string; title: string }) {
  const [allowed, setAllowed] = useState(false);
  const src = `https://www.google.com/maps?q=${encodeURIComponent(query)}&output=embed`;

  if (allowed) {
    return (
      <iframe
        title={title}
        src={src}
        className="aspect-[4/3] w-full rounded-[var(--radius-card)] border-0 sm:aspect-[16/10]"
        loading="lazy"
        referrerPolicy="no-referrer-when-downgrade"
      />
    );
  }

  return (
    <div className="flex aspect-[4/3] w-full flex-col items-center justify-center gap-4 rounded-[var(--radius-card)] bg-blue-wash p-6 text-center sm:aspect-[16/10]">
      <p className="max-w-[40ch] text-[0.95rem]">
        Hier kann eine Karte von <strong>Google Maps</strong> angezeigt werden. Dabei werden Daten wie eure IP-Adresse an Google übertragen.
      </p>
      <button type="button" className="btn btn-blue" onClick={() => setAllowed(true)}>
        Karte laden
      </button>
      <p className="text-sm text-ink-soft">Die Einwilligung gilt nur für diese Seitenansicht.</p>
    </div>
  );
}
