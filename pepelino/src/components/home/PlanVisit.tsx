import Link from "next/link";
import { locations } from "@/content/locations";
import { pricesFor } from "@/content/prices";
import { formatDays, formatPrice, formatTimeRange } from "@/lib/format";
import { Icon, type IconName } from "@/components/ui/Icon";
import { locationList } from "@/content/locations";
import { formatDateRange, upcoming } from "@/lib/format";

function childPrice(id: "kiel" | "westerroenfeld") {
  const p = pricesFor(id).find((x) => x.category === "Kinder ab 2 Jahren");
  return p ? formatPrice(p.price.amount) : "–";
}

export function PlanVisit() {
  const kiel = locations.kiel;
  const openSlots = kiel.opening.slots.filter((s) => s.opens);
  const sameHours =
    JSON.stringify(kiel.opening.slots) === JSON.stringify(locations.westerroenfeld.opening.slots);

  const cards: { icon: IconName; tone: string; title: string; body: React.ReactNode; links: { href: string; label: string }[] }[] = [
    {
      icon: "clock",
      tone: "bg-sun-wash text-[#8a6a00]",
      title: "Öffnungszeiten",
      body: (
        <>
          {openSlots.map((s) => (
            <span key={s.days.join()} className="block">
              {formatDays(s.days)}: {formatTimeRange(s.opens, s.closes)}
            </span>
          ))}
          {sameHours && <span className="mt-1 block text-ink-soft">in Kiel und Westerrönfeld</span>}
          {locationList.map((l) => {
            const next = upcoming(l.specialDates)[0];
            return next ? (
              <span key={l.id} className="mt-2 block rounded-lg bg-sun-wash px-2 py-1 text-[0.9rem]">
                <strong>{l.shortName}:</strong> {next.label} ({formatDateRange(next.from, next.to)})
              </span>
            ) : null;
          })}
        </>
      ),
      links: [{ href: "/indoorspielplatz-in-der-naehe/#preise", label: "Zeiten & Ausnahmen" }],
    },
    {
      icon: "ticket",
      tone: "bg-pink-wash text-pink-strong",
      title: "Eintrittspreise",
      body: (
        <>
          Kinder ab 2 Jahren: {childPrice("kiel")} in Kiel, {childPrice("westerroenfeld")} in Westerrönfeld.
        </>
      ),
      links: [{ href: "/indoorspielplatz-in-der-naehe/#preise", label: "Beide Preislisten" }],
    },
    {
      icon: "cutlery",
      tone: "bg-green-wash text-green-strong",
      title: "Speisen & Getränke",
      body: <>Snacks, Pizza, Burger und Kaffeespezialitäten im Bistro. Eigene Speisen bitte zu Hause lassen.</>,
      links: [
        { href: locations.kiel.pages.menu, label: "Speisekarte Kiel" },
        { href: locations.westerroenfeld.pages.menu, label: "Speisekarte Westerrönfeld" },
      ],
    },
    {
      icon: "pin",
      tone: "bg-blue-wash text-blue-strong",
      title: "Anfahrt & Kontakt",
      body: <>Kostenlose Parkplätze an beiden Standorten. Adressen, Telefon und Routenplaner auf einen Blick.</>,
      links: [{ href: "/indoorspielplatz-in-der-naehe/", label: "Jetzt ansehen" }],
    },
  ];

  return (
    <section id="besuch" aria-labelledby="plan-title" className="bg-blue-wash">
      <div className="container-site py-14 md:py-20">
        <p className="eyebrow text-blue-strong">Euren Besuch planen</p>
        <h2 id="plan-title" className="h-section mt-2">
          Alles Wichtige auf einen Blick
        </h2>
        <ul className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4 lg:gap-5">
          {cards.map((c) => (
            <li key={c.title} className="card flex flex-col p-6">
              <div className="flex items-center gap-3">
                <span className={`inline-flex size-11 shrink-0 items-center justify-center rounded-full ${c.tone}`}>
                  <Icon name={c.icon} className="size-[1.35rem]" />
                </span>
                <h3 className="h-card">{c.title}</h3>
              </div>
              <p className="mt-3 flex-1 text-[0.97rem] leading-relaxed">{c.body}</p>
              <ul className="mt-3">
                {c.links.map((l) => (
                  <li key={l.href}>
                    <Link href={l.href} className="link-arrow text-blue-strong">
                      {l.label}
                      <Icon name="arrow" className="size-4" />
                    </Link>
                  </li>
                ))}
              </ul>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
