import type { SpecialDate } from "@/content/schema";
import { formatDateRange, formatTimeRange, upcoming } from "@/lib/format";

/**
 * Ferien-, Feiertags- und Sonderzeiten aus dem Pflegebereich.
 * Vergangene Einträge werden automatisch ausgeblendet (Seiten werden stündlich neu erzeugt).
 */
export function SpecialDates({ dates, limit, compact = false }: { dates: SpecialDate[]; limit?: number; compact?: boolean }) {
  const list = upcoming(dates).slice(0, limit);
  if (list.length === 0) return null;
  return (
    <div className={compact ? "" : "rounded-2xl bg-sun-wash p-4 shadow-[inset_0_0_0_1px_#f1d58f]"}>
      {!compact && <p className="font-bold">Sonderzeiten</p>}
      <ul className={`${compact ? "" : "mt-2"} space-y-1.5 text-[0.95rem]`}>
        {list.map((d) => (
          <li key={`${d.from}-${d.label}`}>
            <span className="font-semibold">{d.label}</span>{" "}
            <span className="text-ink-soft">({formatDateRange(d.from, d.to)})</span>:{" "}
            <span className="whitespace-nowrap font-bold">{d.closed ? "geschlossen" : formatTimeRange(d.opens, d.closes)}</span>
            {d.note && <span className="block text-ink-soft">{d.note}</span>}
          </li>
        ))}
      </ul>
    </div>
  );
}
