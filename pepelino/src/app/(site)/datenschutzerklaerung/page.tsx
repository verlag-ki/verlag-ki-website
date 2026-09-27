import type { Metadata } from "next";
import { PageHeader } from "@/components/ui/PageHeader";
import { PreviewNotice } from "@/components/ui/ReviewMarker";
import { site } from "@/content/site";
import { SOURCES } from "@/content/sources";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Datenschutzerklärung",
  description: "Informationen zur Verarbeitung personenbezogener Daten auf der Website der Pepelino Spieleparadiese.",
  path: "/datenschutzerklaerung/",
});

export default function Page() {
  return (
    <>
      <PageHeader crumbs={[{ name: "Startseite", path: "/" }, { name: "Datenschutz", path: "/datenschutzerklaerung/" }]} title="Datenschutzerklärung" />
      <div className="container-site mt-8 max-w-3xl space-y-8">
        <PreviewNotice>
          Entwurf für die Relaunch-Vorschau – keine rechtsgültige Datenschutzerklärung. Beschrieben ist nur, was diese Vorschau technisch tut. Die{" "}
          <a href={SOURCES.privacy} className="underline" rel="noopener">
            bisherige Erklärung
          </a>{" "}
          nennt zahlreiche Dienste (u. a. Jetpack, Google Ads, AdSense, Google Web Fonts, Borlabs Cookie), deren Einsatz im Relaunch nicht vorgesehen bzw. ungeklärt ist. Vor dem Livegang juristisch erstellen und prüfen lassen.
        </PreviewNotice>
        <div className="prose-pepe">
          <h2>Verantwortliche Stelle</h2>
          <p>
            {site.legalName}, Göteborgring 83, 24109 Kiel, E-Mail: {site.central.email}
          </p>
          <h2>Was diese Website technisch verarbeitet</h2>
          <ul>
            <li>Beim Aufruf verarbeitet der Webserver technisch notwendige Daten (z. B. IP-Adresse, Zeitpunkt, aufgerufene Seite). Hosting-Anbieter und Speicherdauer werden vor dem Livegang ergänzt.</li>
            <li>Es werden keine Analyse-, Werbe- oder Tracking-Dienste eingesetzt und keine Cookies zu Marketingzwecken gesetzt.</li>
            <li>Schriftarten werden lokal von diesem Server geladen; es findet keine Verbindung zu Google Fonts statt.</li>
          </ul>
          <h2>Formulare</h2>
          <p>
            In der Vorschau werden Eingaben in Anfrage- und Kontaktformularen ausschließlich auf Vollständigkeit geprüft und danach verworfen – sie werden weder gespeichert noch versendet. Für den Livegang werden Empfänger, Zweck, Rechtsgrundlage (voraussichtlich Art. 6 Abs. 1 lit. b DSGVO) und Speicherdauer ergänzt.
          </p>
          <h2>Google Maps</h2>
          <p>
            Karten von Google Maps werden erst geladen, wenn ihr aktiv auf „Karte laden“ klickt. Erst dann werden Daten (u. a. eure IP-Adresse) an Google übertragen. Die Entscheidung wird nicht gespeichert.
          </p>
          <h2>Externe Links</h2>
          <p>Links zu sozialen Netzwerken, zum Gutscheinshop und zu Nachbarangeboten sind einfache Verweise; Daten werden erst beim Anklicken an den jeweiligen Anbieter übertragen.</p>
          <h2>Eure Rechte</h2>
          <p>Ihr habt das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung der Verarbeitung, Datenübertragbarkeit, Widerspruch sowie Beschwerde bei einer Aufsichtsbehörde.</p>
        </div>
      </div>
    </>
  );
}
