import type { AdmissionPrice, Faq, Location } from "@/content/schema";
import { formatDays, formatPrice, formatTimeRange } from "@/lib/format";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { Icon } from "@/components/ui/Icon";
import { JsonLd } from "@/components/ui/JsonLd";
import { faqJsonLd } from "@/lib/seo";

export function OpeningHours({ location: loc, compact = false }: { location: Location; compact?: boolean }) {
  return (
    <div>
      <dl className={`grid grid-cols-[auto_1fr] gap-x-6 ${compact ? "gap-y-1" : "gap-y-2.5"}`}>
        {loc.opening.slots.map((s) => (
          <div key={s.days.join()} className="contents">
            <dt className="text-ink-soft">{formatDays(s.days)}</dt>
            <dd className={s.opens ? "font-bold" : "text-ink-soft"}>{formatTimeRange(s.opens, s.closes)}</dd>
          </div>
        ))}
        {loc.openingExceptions.map((ex) => (
          <div key={ex.label} className="contents">
            <dt className="text-ink-soft">{ex.label}</dt>
            <dd className="font-bold">
              {ex.text}
              <ReviewMarker status={ex.provenance.verificationStatus} note={ex.provenance.note} />
            </dd>
          </div>
        ))}
      </dl>
    </div>
  );
}

export function PriceTable({ prices, caption }: { prices: AdmissionPrice[]; caption: string }) {
  return (
    <table className="w-full border-collapse text-left">
      <caption className="sr-only">{caption}</caption>
      <thead className="sr-only">
        <tr>
          <th scope="col">Kategorie</th>
          <th scope="col">Preis</th>
        </tr>
      </thead>
      <tbody>
        {prices.map((p) => (
          <tr key={p.id} className="border-b border-line last:border-0">
            <th scope="row" className="py-3 pr-4 align-top font-semibold">
              {p.category}
              {p.note && <span className="block text-[0.9rem] font-normal text-ink-soft">{p.note}</span>}
            </th>
            <td className="whitespace-nowrap py-3 text-right align-top font-display text-lg font-bold">
              {formatPrice(p.price.amount)}
              <ReviewMarker status={p.provenance.verificationStatus} note={p.provenance.note} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

export function FaqAccordion({ items, withJsonLd = true }: { items: Faq[]; withJsonLd?: boolean }) {
  return (
    <>
      {withJsonLd && <JsonLd data={faqJsonLd(items)} />}
      <div className="divide-y divide-line rounded-[var(--radius-card)] bg-white shadow-[var(--shadow-soft)]">
        {items.map((f) => (
          <details key={f.id} className="group px-5 sm:px-7">
            <summary className="flex min-h-16 cursor-pointer list-none items-center justify-between gap-4 py-4 font-display text-[1.15rem] font-bold [&::-webkit-details-marker]:hidden">
              <span>
                {f.question}
                <ReviewMarker status={f.provenance.verificationStatus} note={f.provenance.note} />
              </span>
              <Icon name="chevron" className="size-5 shrink-0 transition-transform group-open:rotate-180" />
            </summary>
            <p className="max-w-[65ch] pb-5 text-ink-soft">{f.answer}</p>
          </details>
        ))}
      </div>
    </>
  );
}
