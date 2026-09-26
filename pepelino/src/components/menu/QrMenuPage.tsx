import Image from "next/image";
import Link from "next/link";
import type { LocationId } from "@/content/schema";
import { locations } from "@/content/locations";
import { media } from "@/content/media";
import { menus } from "@/content/menus";
import { Icon } from "@/components/ui/Icon";
import { MenuView } from "./MenuView";

/** Mobil optimierte Speisekarte für gedruckte QR-Codes – gleiche Datenquelle wie die Speisekartenseiten. */
export function QrMenuPage({ locationId }: { locationId: LocationId }) {
  const loc = locations[locationId];
  return (
    <div className="mx-auto max-w-xl px-5 pb-16">
      <header className="flex items-center justify-between gap-4 border-b border-line py-3">
        <Link href={loc.pages.location} aria-label={`Zu Pepelino ${loc.shortName}`}>
          <Image src={media.logo.src} width={media.logo.width} height={media.logo.height} alt="" className="h-12 w-auto" sizes="70px" priority />
        </Link>
        <p className="text-right text-sm font-bold">{loc.name}</p>
      </header>
      <h1 className="mt-6 text-[2rem]">Speisekarte</h1>
      <nav aria-label="Abschnitte" className="sticky top-0 z-10 -mx-5 mt-3 flex gap-2 bg-paper/95 px-5 py-2 backdrop-blur">
        <a href="#speisen" className="btn btn-green !min-h-11 flex-1 !px-3 text-[0.95rem]">Speisen</a>
        <a href="#getraenke" className="btn btn-quiet !min-h-11 flex-1 !px-3 text-[0.95rem]">Getränke</a>
      </nav>
      <div className="mt-6 text-[1.05rem]">
        <MenuView menu={menus[locationId]} compact />
      </div>
      <Link href={loc.pages.location} className="btn btn-quiet mt-10 w-full">
        <Icon name="back" className="size-4" /> Zu Pepelino {loc.shortName}
      </Link>
    </div>
  );
}
