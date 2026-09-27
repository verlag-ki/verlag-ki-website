import Link from "next/link";
import type { Location } from "@/content/schema";
import { locationList } from "@/content/locations";
import { Icon } from "@/components/ui/Icon";

type Target = keyof Location["pages"];

/**
 * Gleichwertige Standortwahl: beide Hallen nebeneinander, gleiche Größe,
 * jeweils in ihrer Standortfarbe. Überall dort verwenden, wo ein Ziel
 * pro Standort existiert – nie einen Standort als „Hauptziel“ bevorzugen.
 */
export function LocationChoice({
  target,
  label,
  anchor = "",
  size = "default",
}: {
  target: Target;
  /** z. B. (name) => `Geburtstag in ${name}` */
  label: (shortName: string) => string;
  anchor?: string;
  size?: "default" | "small";
}) {
  return (
    <ul className={`flex flex-col gap-3 sm:flex-row sm:flex-wrap ${size === "small" ? "gap-2" : ""}`}>
      {locationList.map((loc) => (
        <li key={loc.id}>
          <Link
            href={`${loc.pages[target]}${anchor}`}
            className={`btn ${loc.accent === "blue" ? "btn-blue" : "btn-green"} w-full sm:w-auto ${size === "small" ? "!min-h-11 !px-4 !py-2 text-[0.95rem]" : ""}`}
          >
            <Icon name="pin" className="size-[1.1rem]" />
            {label(loc.shortName)}
            <Icon name="arrow" className="size-4" />
          </Link>
        </li>
      ))}
    </ul>
  );
}
