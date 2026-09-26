import Link from "next/link";
import type { Location } from "@/content/schema";
import { Icon } from "@/components/ui/Icon";
import { Photo } from "@/components/ui/Photo";

const TEASER: Record<Location["id"], string> = {
  kiel: "Klettervulkan, Bungee-Trampoline und Kartbahn am Göteborgring.",
  westerroenfeld: "Riesenrutsche, Walrutsche und Go-Karts direkt am Busbahnhof.",
};

/** Große Bild-Text-Kachel mit Standortfarbe. */
export function LocationCard({ location: loc, headingLevel = "h3" }: { location: Location; headingLevel?: "h2" | "h3" }) {
  const H = headingLevel;
  const bg = loc.accent === "blue" ? "bg-blue-strong" : "bg-green-strong";
  return (
    <article className={`relative grid overflow-hidden text-white shadow-[var(--shadow-lift)] sm:grid-cols-[1fr_1.05fr] ${bg} rounded-[2rem_3.5rem_2.25rem_3rem]`}>
      <div className="order-2 flex flex-col justify-center gap-3 p-7 sm:order-1 sm:p-9">
        <p className="eyebrow text-white/85">Pepelino</p>
        <H className="-mt-1 text-[2.1rem] leading-none sm:text-[2.4rem]">{loc.shortName}</H>
        <p className="max-w-[28ch] text-white/95">{TEASER[loc.id]}</p>
        <p className="text-[0.95rem] text-white/85">
          {loc.address.street}, {loc.address.postalCode} {loc.address.city}
        </p>
        <Link href={loc.pages.location} className="btn btn-white mt-2 self-start">
          Standort <span className="sr-only">{loc.shortName}</span> entdecken
          <Icon name="arrow" className="size-4" />
        </Link>
      </div>
      <div className="relative order-1 aspect-[16/10] sm:order-2 sm:aspect-auto sm:min-h-[300px]">
        <Photo media={loc.cardImage} sizes="(min-width: 1024px) 30vw, (min-width: 640px) 50vw, 100vw" />
      </div>
    </article>
  );
}
