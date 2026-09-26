import type { Metadata } from "next";
import Link from "next/link";
import { PageHeader } from "@/components/ui/PageHeader";
import { locationList } from "@/content/locations";
import { pageMetadata } from "@/lib/seo";

// Historische Adresse (Pandemie-Konzept vom 03.04.2022). Bleibt erreichbar,
// wird aber nicht indexiert. Entscheidung 301/410 siehe docs/SEO_MIGRATION.md.
export const metadata: Metadata = pageMetadata({
  title: "Schutz- und Hygienekonzept (archiviert)",
  description: "Das frühere Schutz- und Hygienekonzept aus dem Jahr 2022 ist nicht mehr aktuell.",
  path: "/schutz-und-hygienekonzept/",
  noindex: true,
});

export default function Page() {
  return (
    <>
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: "Schutz- und Hygienekonzept", path: "/schutz-und-hygienekonzept/" },
        ]}
        title="Schutz- und Hygienekonzept"
        intro={
          <p>
            Das hier früher veröffentlichte Schutz- und Hygienekonzept stammte aus der Corona-Zeit (Stand April 2022) und gilt nicht mehr. Aktuelle Hausregeln – zum Beispiel zu Socken im Spielbereich oder zu mitgebrachten Speisen – findet ihr auf den Standortseiten.
          </p>
        }
      >
        <ul className="flex flex-col gap-3 sm:flex-row">
          {locationList.map((l) => (
            <li key={l.id}>
              <Link href={`${l.pages.location}#faq`} className={`btn ${l.accent === "blue" ? "btn-blue" : "btn-green"}`}>
                Hausregeln {l.shortName}
              </Link>
            </li>
          ))}
        </ul>
      </PageHeader>
    </>
  );
}
