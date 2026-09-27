import { Doodle } from "@/components/ui/Icon";
import { LocationChoice } from "@/components/locations/LocationChoice";
import { Photo } from "@/components/ui/Photo";

export function BirthdayTeaser() {
  return (
    <section id="geburtstag" aria-labelledby="bday-title" className="mt-20 bg-pink-wash md:mt-28">
      <div className="container-site grid items-center gap-10 py-14 md:grid-cols-2 md:gap-14 md:py-20">
        <div className="relative aspect-[4/3] overflow-hidden organic-image shadow-[var(--shadow-lift)]">
          <Photo media="kielNische" sizes="(min-width: 768px) 50vw, 100vw" />
        </div>
        <div className="relative">
          <Doodle kind="crown" className="absolute -top-4 right-0 hidden h-14 w-20 -rotate-6 text-sun md:block" />
          <p className="eyebrow text-pink-strong">Kindergeburtstag</p>
          <h2 id="bday-title" className="h-section mt-2 max-w-[16ch]">
            Ein Geburtstag voller Abenteuer
          </h2>
          <p className="mt-4 max-w-[46ch] text-ink-soft">
            Feiern, spielen, strahlen: Drei Geburtstagspakete – von Pepe Small bis Pepe Large – mit gedecktem Tisch, Namensschild fürs Geburtstagskind und viel Zeit zum Toben. Ab fünf Kindern seid ihr dabei.
          </p>
          <p className="mt-7 font-bold">Pakete & Anfrage für euren Standort:</p>
          <div className="mt-3">
            <LocationChoice target="birthday" label={(n) => `Geburtstag in ${n}`} />
          </div>
        </div>
      </div>
    </section>
  );
}
