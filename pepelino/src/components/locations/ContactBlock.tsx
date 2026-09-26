import type { Location } from "@/content/schema";
import { Icon } from "@/components/ui/Icon";
import { ReviewMarker } from "@/components/ui/ReviewMarker";

export function ContactBlock({ location: loc }: { location: Location }) {
  const tone = loc.accent === "blue" ? "text-blue-strong" : "text-green-strong";
  return (
    <div className="card p-6 sm:p-8">
      <h3 className="h-card">{loc.name}</h3>
      <address className="mt-4 space-y-3 not-italic">
        <p className="flex gap-3">
          <Icon name="pin" className={`mt-0.5 size-5 shrink-0 ${tone}`} />
          <span>
            {loc.address.street}
            <br />
            {loc.address.postalCode} {loc.address.city}
          </span>
        </p>
        {loc.phone && (
          <p className="flex items-center gap-3">
            <Icon name="phone" className={`size-5 shrink-0 ${tone}`} />
            <span>
              <a href={`tel:${loc.phone.tel}`} className="inline-flex min-h-11 items-center font-bold underline-offset-4 hover:underline">
                {loc.phone.display}
              </a>
              {loc.id === "kiel" && <span className="text-ink-soft"> (Zentrale, Mo – Fr 10 – 14 Uhr)</span>}
              <ReviewMarker status={loc.phone.provenance.verificationStatus} note={loc.phone.provenance.note} />
            </span>
          </p>
        )}
        {loc.email && (
          <p className="flex items-center gap-3">
            <Icon name="mail" className={`size-5 shrink-0 ${tone}`} />
            <span className="min-w-0 break-words">
              <a href={`mailto:${loc.email.address}`} className="inline-flex min-h-11 items-center font-bold underline-offset-4 hover:underline">
                {loc.email.address}
              </a>
              <ReviewMarker status={loc.email.provenance.verificationStatus} note={loc.email.provenance.note} />
            </span>
          </p>
        )}
      </address>
      <p className="mt-3 text-[0.95rem] text-ink-soft">Kostenlose Parkplätze sind vorhanden.</p>
      {loc.mapsUrl && (
        <a href={loc.mapsUrl.url} rel="noopener" className="btn btn-quiet mt-5">
          Route planen
          <Icon name="external" className="size-4" />
          <span className="sr-only">(öffnet Google Maps)</span>
        </a>
      )}
    </div>
  );
}
