import Link from "next/link";
import { Icon, type IconName } from "@/components/ui/Icon";

const items: { href: string; icon: IconName; title: string; text: string; tone: string }[] = [
  { href: "#attraktionen", icon: "slide", title: "Attraktionen", text: "Klettern, rutschen, hüpfen", tone: "text-blue" },
  { href: "/kindergeburtstag-kiel/", icon: "cake", title: "Kindergeburtstag", text: "Pakete & Anfrage", tone: "text-pink" },
  { href: "/gruppenanmeldung-schulklassen/", icon: "group", title: "Gruppen & Schulen", text: "Ausflüge planen", tone: "text-orange" },
  { href: "/kinderspieleparadies-kiel/", icon: "cutlery", title: "Essen & Trinken", text: "Unsere Speisekarten", tone: "text-green" },
  { href: "#besuch", icon: "clock", title: "Preise & Zeiten", text: "Alles zum Besuch", tone: "text-blue-strong" },
];

export function QuickLinks() {
  return (
    <nav aria-label="Schnelleinstieg" className="container-site mt-10 md:mt-14">
      <ul className="grid grid-cols-1 gap-1 sm:grid-cols-2 lg:grid-cols-5 lg:gap-4">
        {items.map((it) => (
          <li key={it.title}>
            <Link
              href={it.href}
              className="group flex min-h-16 items-center gap-4 rounded-2xl px-3 py-3 no-underline transition-colors hover:bg-white hover:shadow-[var(--shadow-soft)] lg:flex-col lg:gap-2 lg:px-2 lg:py-5 lg:text-center"
            >
              <Icon name={it.icon} className={`size-9 shrink-0 lg:size-11 ${it.tone}`} strokeWidth={1.8} />
              <span>
                <span className="block font-display text-[1.15rem] font-bold leading-tight group-hover:underline group-hover:underline-offset-4">{it.title}</span>
                <span className="block text-[0.95rem] text-ink-soft">{it.text}</span>
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
