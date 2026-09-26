import type { Metadata } from "next";
import { PageHeader, Section } from "@/components/ui/PageHeader";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { Photo } from "@/components/ui/Photo";
import { GroupInquiryForm } from "@/components/forms/GroupInquiryForm";
import { groupOffer } from "@/content/site";
import { pageMetadata } from "@/lib/seo";

export const metadata: Metadata = pageMetadata({
  title: "Klassenausflug & Gruppen – Indoorspielplatz Kiel",
  description:
    "Schulklassen, Kitas und Horte bei Pepelino: wetterunabhängiger Ausflug in Kiel, nach Absprache auch außerhalb der Öffnungszeiten. Gruppenanfrage für Kiel und Westerrönfeld.",
  path: "/gruppenanmeldung-schulklassen/",
  image: "/images/media/kiel-bungee-trampolin.webp",
});

export default function Page() {
  return (
    <>
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: "Gruppen & Schulen", path: "/gruppenanmeldung-schulklassen/" },
        ]}
        eyebrow="Gruppen & Schulen"
        eyebrowTone="text-blue-strong"
        title="Klassenausflug und Gruppenbesuch bei Pepelino"
        intro={groupOffer.kiel.text.map((t) => (
          <p key={t}>{t}</p>
        ))}
        image="kielTrampolin"
      >
        <a href="#anfrage" className="btn btn-blue">
          Gruppe anfragen
        </a>
      </PageHeader>

      <Section id="standorte" eyebrow="Standorte" eyebrowTone="text-blue-strong" title="Kiel und Westerrönfeld im Vergleich">
        <div className="grid gap-6 md:grid-cols-2">
          <div className="card overflow-hidden">
            <div className="relative aspect-[16/9]">
              <Photo media="kielKlettervulkan" sizes="(min-width: 768px) 45vw, 100vw" />
            </div>
            <div className="p-6">
              <h3 className="h-card text-blue-strong">Kiel</h3>
              <p className="mt-2 text-ink-soft">
                Rutschen, Klettergerüste, Trampoline und viele weitere Attraktionen. Gruppenbesuche nach Absprache auch vormittags – für Projekttage, Wandertage oder den Schuljahresabschluss.
              </p>
            </div>
          </div>
          <div className="card overflow-hidden">
            <div className="relative aspect-[16/9]">
              <Photo media="rdKletter" sizes="(min-width: 768px) 45vw, 100vw" />
            </div>
            <div className="p-6">
              <h3 className="h-card text-green-strong">
                Westerrönfeld
                <ReviewMarker status={groupOffer.westerroenfeld.provenance.verificationStatus} note={groupOffer.westerroenfeld.provenance.note} />
              </h3>
              {groupOffer.westerroenfeld.text.map((t) => (
                <p key={t} className="mt-2 text-ink-soft">
                  {t}
                </p>
              ))}
            </div>
          </div>
        </div>
      </Section>

      <Section id="anfrage" tone="blue" eyebrow="Gruppenanfrage" eyebrowTone="text-blue-strong" title="Gruppenbesuch anfragen" intro={<p>Wir melden uns mit einem Angebot und einem passenden Termin.</p>}>
        <div className="card max-w-3xl p-6 sm:p-9">
          <GroupInquiryForm />
        </div>
      </Section>
    </>
  );
}
