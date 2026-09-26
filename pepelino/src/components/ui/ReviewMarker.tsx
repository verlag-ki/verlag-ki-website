import type { VerificationStatus } from "@/content/schema";

/**
 * Kennzeichnet in der Vorschau Angaben, die öffentlich widersprüchlich oder
 * unbelegt sind. Abschaltbar mit NEXT_PUBLIC_SHOW_REVIEW_MARKERS=false
 * (z. B. für Präsentations-Screenshots) – die Daten bleiben trotzdem markiert.
 */
export const SHOW_REVIEW_MARKERS = process.env.NEXT_PUBLIC_SHOW_REVIEW_MARKERS !== "false";

export function ReviewMarker({ status, note }: { status: VerificationStatus; note?: string }) {
  if (!SHOW_REVIEW_MARKERS) return null;
  if (status === "verified_public" || status === "client_approved") return null;
  const label = status === "conflicting_public" ? "in Prüfung" : "offen";
  return (
    <span className="review-marker" title={note}>
      {label}
      {note ? <span className="sr-only">: {note}</span> : null}
    </span>
  );
}

export function PreviewNotice({ children }: { children: React.ReactNode }) {
  return (
    <p className="flex gap-2 rounded-xl bg-sun-wash px-4 py-3 text-sm text-ink shadow-[inset_0_0_0_1px_#f1d58f]">
      <span aria-hidden="true" className="font-extrabold">
        !
      </span>
      <span>{children}</span>
    </p>
  );
}
