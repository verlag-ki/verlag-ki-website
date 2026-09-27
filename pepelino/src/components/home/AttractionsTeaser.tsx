import { attractions, homeAttractionIds } from "@/content/attractions";
import { Doodle } from "@/components/ui/Icon";
import { LocationChoice } from "@/components/locations/LocationChoice";
import { AttractionCard } from "@/components/locations/AttractionCard";

export function AttractionsTeaser() {
  const cards = homeAttractionIds.map((id) => attractions.find((a) => a.id === id)!);
  return (
    <section id="attraktionen" aria-labelledby="attr-title" className="container-site mt-20 md:mt-28">
      <div className="grid gap-10 lg:grid-cols-[minmax(0,0.85fr)_minmax(0,2fr)] lg:items-center lg:gap-12">
        <div className="relative">
          <p className="eyebrow text-pink">Unsere Attraktionen</p>
          <h2 id="attr-title" className="h-section mt-2 max-w-[14ch]">
            Hier gibt es etwas zu erleben
          </h2>
          <Doodle kind="swoosh" className="mt-2 h-4 w-28 text-sun" />
          <p className="mt-4 max-w-[38ch] text-ink-soft">
            Klettern, rutschen, springen oder auf der Kartbahn Runden drehen – jede Halle hat ihre eigenen Lieblingsorte.
          </p>
          <div className="mt-6">
            <LocationChoice target="location" anchor="#attraktionen" label={(n) => `Attraktionen ${n}`} />
          </div>
        </div>
        <ul className="grid gap-6 sm:grid-cols-3">
          {cards.map((a) => (
            <li key={a.id}>
              <AttractionCard attraction={a} showLocation />
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
