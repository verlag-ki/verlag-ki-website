import Link from "next/link";
import { locations } from "@/content/locations";
import { Doodle, Icon } from "@/components/ui/Icon";
import { Photo } from "@/components/ui/Photo";
import { BrandWord } from "@/components/ui/BrandWord";

export function Hero() {
  const { kiel, westerroenfeld } = locations;
  return (
    <section aria-labelledby="hero-title" className="relative">
      {/* Bildfläche */}
      <div className="relative h-[clamp(260px,62vw,380px)] overflow-hidden md:h-[clamp(520px,52vw,640px)]">
        <Photo media="heroKlettervulkan" priority sizes="100vw" className="md:[object-position:70%_55%]" />
        {/* weiche Unterkante */}
        <svg className="absolute inset-x-0 -bottom-px h-10 w-full text-paper md:h-16" viewBox="0 0 1440 80" preserveAspectRatio="none" aria-hidden="true">
          <path fill="currentColor" d="M0 44C180 70 360 80 600 58S1020 8 1260 18c80 3 140 13 180 22v40H0Z" />
        </svg>
        <div className="absolute bottom-16 right-[6%] hidden size-40 rotate-[8deg] items-center justify-center rounded-full bg-pink p-5 text-center font-display text-[1.35rem] font-bold leading-tight text-white shadow-[var(--shadow-lift)] xl:flex">
          Hier werden Kinderträume wahr!
        </div>
      </div>

      {/* Textfläche */}
      <div className="container-site relative -mt-16 md:absolute md:inset-x-0 md:top-0 md:mt-0 md:flex md:h-[clamp(520px,52vw,640px)] md:items-start md:pt-[clamp(2.5rem,5vw,4.5rem)]">
        <div className="blob-card relative bg-paper px-6 pb-8 pt-8 shadow-[var(--shadow-lift)] sm:px-9 md:max-w-[560px] md:px-12 md:py-12">
          <Doodle kind="crown" className="absolute -top-6 right-8 h-12 w-16 rotate-12 text-sun md:-top-7 md:right-10 md:h-14 md:w-20" />
          <h1 id="hero-title" className="h-display">
            Spiel, Spaß und Abenteuer bei <BrandWord />
          </h1>
          <p className="mt-4 max-w-[34ch] text-lg text-ink-soft md:text-[1.15rem]">
            Unsere Indoorspielplätze in {kiel.shortName} und {westerroenfeld.shortName} bei Rendsburg – wetterunabhängig spielen, toben und feiern.
          </p>
          <div className="mt-7 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
            <Link href={kiel.pages.location} className="btn btn-blue">
              <Icon name="pin" className="size-5" />
              {kiel.shortName} entdecken
              <Icon name="arrow" className="size-4" />
            </Link>
            <Link href={westerroenfeld.pages.location} className="btn btn-green">
              <Icon name="pin" className="size-5" />
              {westerroenfeld.shortName} entdecken
              <Icon name="arrow" className="size-4" />
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
