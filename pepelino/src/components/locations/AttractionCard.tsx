import type { Attraction } from "@/content/schema";
import { locations } from "@/content/locations";
import { Photo } from "@/components/ui/Photo";

export function AttractionCard({ attraction: a, showLocation = false }: { attraction: Attraction; showLocation?: boolean }) {
  const loc = locations[a.location];
  return (
    <article className="h-full">
      {a.image ? (
        <div className="relative aspect-[4/3] overflow-hidden rounded-[var(--radius-card)] bg-blue-wash">
          <Photo media={a.image} sizes="(min-width: 1024px) 26vw, (min-width: 640px) 33vw, 100vw" />
          {showLocation && (
            <span
              className={`absolute left-3 top-3 rounded-full px-3 py-1 text-[0.8rem] font-extrabold text-white shadow ${
                loc.accent === "blue" ? "bg-blue-strong" : "bg-green-strong"
              }`}
            >
              {loc.shortName}
            </span>
          )}
        </div>
      ) : null}
      <h3 className="h-card mt-4">{a.name}</h3>
      <p className="mt-1.5 text-[0.98rem] text-ink-soft">{a.description}</p>
      {a.facts.length > 0 && (
        <ul className="mt-3 flex flex-wrap gap-2" aria-label={`Fakten zu ${a.name}`}>
          {a.facts.map((f) => (
            <li key={f} className="rounded-full bg-white px-3 py-1 text-[0.85rem] font-bold shadow-[inset_0_0_0_1px_var(--color-line)]">
              {f}
            </li>
          ))}
        </ul>
      )}
    </article>
  );
}
