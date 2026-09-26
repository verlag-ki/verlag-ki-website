import type { Metadata } from "next";
import { PageHeader } from "@/components/ui/PageHeader";
import { PreviewNotice } from "@/components/ui/ReviewMarker";
import { site } from "@/content/site";
import { SOURCES } from "@/content/sources";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Impressum",
  description: "Anbieterkennzeichnung der Pepelino Spieleparadiese in Kiel und Westerrönfeld.",
  path: "/impressum/",
});

export default function Page() {
  return (
    <>
      <PageHeader crumbs={[{ name: "Startseite", path: "/" }, { name: "Impressum", path: "/impressum/" }]} title="Impressum" />
      <div className="container-site mt-8 max-w-3xl space-y-8">
        <PreviewNotice>
          Staging-Fassung auf Basis des{" "}
          <a href={SOURCES.imprint} className="underline" rel="noopener">
            öffentlichen Impressums
          </a>{" "}
          (Stand 26.09.2026). Vor dem Livegang juristisch prüfen: Verweis auf § 5 DDG statt § 5 TMG, Angaben zur vertretungsberechtigten Person bzw. Komplementärin, Hinweis auf die eingestellte EU-OS-Plattform entfernen, Kontakt-E-Mail vereinheitlichen.
        </PreviewNotice>
        <div className="prose-pepe">
          <h2>Angaben gemäß § 5 DDG</h2>
          <p>
            {site.legalName}
            <br />
            Göteborgring 83
            <br />
            24109 Kiel
          </p>
          <p>
            Handelsregister: HRA 10389 KI
            <br />
            Registergericht: Amtsgericht Kiel
          </p>
          <p>Vertreten durch: <em>[Angabe fehlt im öffentlichen Impressum – bitte ergänzen]</em></p>
          <h2>Kontakt</h2>
          <p>
            Telefon: {site.central.phone.display}
            <br />
            E-Mail: {site.central.email}{" "}
            <span className="text-ink-soft">(öffentliches Impressum nennt info@sfc-mettenhof.de)</span>
          </p>
          <h2>Umsatzsteuer-ID</h2>
          <p>Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz: DE 296833322</p>
          <h2>Verbraucherstreitbeilegung</h2>
          <p>Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.</p>
          <h2>Bildnachweise</h2>
          <p>Bildrechte für den Relaunch werden derzeit geklärt. Das Pepelino-Logo wurde vom Betreiber bereitgestellt.</p>
        </div>
      </div>
    </>
  );
}
