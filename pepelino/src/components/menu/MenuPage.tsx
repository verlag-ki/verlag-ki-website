import Link from "next/link";
import type { LocationId } from "@/content/schema";
import { locations } from "@/content/locations";
import { menus } from "@/content/menus";
import { PageHeader } from "@/components/ui/PageHeader";
import { Icon } from "@/components/ui/Icon";
import { OpeningHours } from "@/components/locations/VisitInfo";
import { MenuView } from "./MenuView";

export function MenuPage({ locationId }: { locationId: LocationId }) {
  const loc = locations[locationId];
  const menu = menus[locationId];
  return (
    <>
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: loc.shortName, path: loc.pages.location },
          { name: "Speisekarte", path: loc.pages.menu },
        ]}
        eyebrow={`Bistro ${loc.name}`}
        eyebrowTone="text-green-strong"
        title={`Speisekarte ${loc.shortName}`}
        intro={<p>Snacks, warme Gerichte, kalte und heiße Getränke – das gibt es im Bistro von Pepelino {loc.shortName}.</p>}
      >
        <Link href={loc.pages.location} className="link-arrow text-ink">
          <Icon name="back" className="size-4" /> Zurück zu Pepelino {loc.shortName}
        </Link>
      </PageHeader>
      <div className="container-site mt-10 grid gap-10 lg:grid-cols-[1fr_300px]">
        <MenuView menu={menu} />
        <aside className="space-y-6 lg:sticky lg:top-6 lg:self-start">
          <div className="card p-6">
            <h2 className="h-card">Öffnungszeiten</h2>
            <div className="mt-4 text-[0.97rem]">
              <OpeningHours location={loc} compact />
            </div>
          </div>
          <div className="card p-6">
            <h2 className="h-card">Geburtstag feiern?</h2>
            <p className="mt-2 text-[0.97rem] text-ink-soft">Unsere Pakete enthalten Getränk, Eis oder Slush und – ab Pepe Medium – ein Geburtstags-Essen.</p>
            <Link href={loc.pages.birthday} className="link-arrow text-pink-strong">
              Zu den Paketen <Icon name="arrow" className="size-4" />
            </Link>
          </div>
        </aside>
      </div>
    </>
  );
}
