import type { Menu, MenuSection as MenuSectionType } from "@/content/schema";
import { formatPrice } from "@/lib/format";
import { ReviewMarker } from "@/components/ui/ReviewMarker";

export function MenuSection({ section, compact = false }: { section: MenuSectionType; compact?: boolean }) {
  const headingId = `menu-${section.kind}-${section.id}`;
  return (
    <section aria-labelledby={headingId} className={compact ? "" : "card p-6 sm:p-7"}>
      <h3 id={headingId} className={`${compact ? "text-xl" : "h-card"} border-b-2 border-line pb-2`}>
        {section.title}
      </h3>
      <ul className="divide-y divide-line">
        {section.items.map((item) => (
          <li key={item.name} className="py-3">
            <div className="flex items-baseline justify-between gap-4">
              <p className="font-bold">
                {item.name}
                {item.note && <ReviewMarker status="conflicting_public" note={item.note} />}
              </p>
              {item.variants.length === 1 && (
                <p className="whitespace-nowrap font-bold tabular-nums">
                  {item.variants[0].size && <span className="mr-2 font-normal text-ink-soft">{item.variants[0].size}</span>}
                  {item.variants[0].price ? formatPrice(item.variants[0].price.amount) : <span className="font-normal text-ink-soft">Preis vor Ort</span>}
                </p>
              )}
            </div>
            {item.detail && <p className="text-[0.93rem] text-ink-soft">{item.detail}</p>}
            {item.variants.length > 1 && (
              <ul className="mt-1 flex flex-wrap gap-x-5 gap-y-1 text-[0.95rem]">
                {item.variants.map((v) => (
                  <li key={v.size} className="tabular-nums">
                    <span className="text-ink-soft">{v.size}</span> <strong>{v.price ? formatPrice(v.price.amount) : "Preis vor Ort"}</strong>
                  </li>
                ))}
              </ul>
            )}
          </li>
        ))}
      </ul>
    </section>
  );
}

export function MenuView({ menu, compact = false }: { menu: Menu; compact?: boolean }) {
  const food = menu.sections.filter((s) => s.kind === "food");
  const drinks = menu.sections.filter((s) => s.kind === "drinks");
  const grid = compact ? "space-y-8" : "grid gap-6 md:grid-cols-2";
  return (
    <div className="space-y-12">
      <section aria-labelledby="speisen">
        <h2 id="speisen" className={compact ? "font-display text-2xl" : "h-section"}>
          Speisen
        </h2>
        <div className={`mt-5 ${grid}`}>
          {food.map((s) => (
            <MenuSection key={s.id} section={s} compact={compact} />
          ))}
        </div>
      </section>
      <section aria-labelledby="getraenke">
        <h2 id="getraenke" className={compact ? "font-display text-2xl" : "h-section"}>
          Getränke
        </h2>
        <div className={`mt-5 ${grid}`}>
          {drinks.map((s) => (
            <MenuSection key={s.id} section={s} compact={compact} />
          ))}
        </div>
      </section>
      <ul className="space-y-2 rounded-[var(--radius-card)] bg-green-wash p-5 text-[0.95rem]">
        {menu.notices.map((n) => (
          <li key={n}>{n}</li>
        ))}
      </ul>
      <p className="text-sm text-ink-soft">
        Stand der Preise: {menu.asOf}. Änderungen vorbehalten.
        {menu.provenance.verificationStatus !== "client_approved" && <ReviewMarker status="unknown" note={menu.provenance.note} />}
      </p>
    </div>
  );
}
