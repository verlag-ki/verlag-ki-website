import Link from "next/link";
import type { BirthdayPackage, Location } from "@/content/schema";
import { addonsFor, birthdayRules, packagesFor } from "@/content/birthdays";
import { locations } from "@/content/locations";
import { getExternal } from "@/content/site";
import { formatPrice } from "@/lib/format";
import { PageHeader, Section } from "@/components/ui/PageHeader";
import { Icon } from "@/components/ui/Icon";
import { Photo } from "@/components/ui/Photo";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { BirthdayInquiryForm } from "@/components/forms/BirthdayInquiryForm";
import { calendarEnabled } from "@/lib/booking";

export function BirthdayPackageCard({ pkg, featured }: { pkg: BirthdayPackage; featured?: boolean }) {
  return (
    <article className={`card relative flex h-full flex-col p-6 sm:p-7 ${featured ? "ring-2 ring-pink" : ""}`}>
      {featured && (
        <p className="absolute -top-3 left-6 rounded-full bg-pink px-3 py-0.5 text-[0.8rem] font-extrabold text-white">Mit Geburtstags-Essen</p>
      )}
      <h3 className="h-card">{pkg.name}</h3>
      <p className="mt-2">
        <span className="font-display text-[2rem] font-bold leading-none">{formatPrice(pkg.price.amount)}</span>{" "}
        <span className="text-ink-soft">{pkg.unit}</span>
      </p>
      <ul className="mt-5 flex-1 space-y-2.5 text-[0.97rem]">
        {pkg.features.map((f) => (
          <li key={f.text} className="flex gap-2.5">
            <Icon name="check" className="mt-0.5 size-5 shrink-0 text-pink" />
            <span>
              {f.text}
              <ReviewMarker status={f.verificationStatus} note={f.note} />
            </span>
          </li>
        ))}
      </ul>
      <a href={`#paket-${pkg.id}`} className="btn btn-quiet mt-6">
        {pkg.name} anfragen
      </a>
    </article>
  );
}

export function BirthdayPage({ location: loc }: { location: Location }) {
  const packages = packagesFor(loc.id);
  const addons = addonsFor(loc.id);
  const rules = birthdayRules[loc.id];
  const other = loc.id === "kiel" ? locations.westerroenfeld : locations.kiel;
  const dateHint =
    loc.id === "kiel"
      ? "Geburtstage finden freitags bis sonntags sowie an Feiertagen und in den Ferien statt."
      : "Nennt uns euren Wunschtermin – wir prüfen, ob er möglich ist.";

  return (
    <>
      <PageHeader
        crumbs={[
          { name: "Startseite", path: "/" },
          { name: loc.shortName, path: loc.pages.location },
          { name: "Kindergeburtstag", path: loc.pages.birthday },
        ]}
        eyebrow={`Kindergeburtstag in ${loc.shortName}`}
        title={loc.id === "kiel" ? "Kindergeburtstag in Kiel feiern" : "Kindergeburtstag bei Rendsburg feiern"}
        intro={
          <>
            <p>
              Toben, rutschen, gemeinsam am festlich gedeckten Tisch sitzen: Bei Pepelino {loc.shortName} wählt ihr eines von drei Paketen – der Eintritt ist immer inklusive, das Geburtstagskind bekommt ein Namensschild zum Mitnehmen.
            </p>
            {loc.id === "kiel" && <p>Wer ganz unter sich sein möchte, feiert in einer eigenen Geburtstagsnische oder -kabine.</p>}
          </>
        }
        image={loc.id === "kiel" ? "kielNische" : "rdGeburtstag"}
      >
        <a href="#anfrage" className="btn btn-pink">
          Zur Anfrage
          <Icon name="arrow" className="size-4" />
        </a>
      </PageHeader>

      <Section id="pakete" eyebrow="Unsere Pakete" title={`Geburtstagspakete in ${loc.shortName}`}>
        <ul className="grid gap-6 md:grid-cols-3">
          {packages.map((p) => (
            <li key={p.id}>
              <BirthdayPackageCard pkg={p} featured={p.tier === "medium"} />
            </li>
          ))}
        </ul>

        <div className="mt-10 grid gap-6 lg:grid-cols-2">
          <div className="rounded-[var(--radius-card)] bg-pink-wash p-6 sm:p-8">
            <h3 className="h-card">Gut zu wissen</h3>
            <ul className="mt-4 space-y-3">
              {rules.map((r) => (
                <li key={r.text} className="flex gap-2.5">
                  <Icon name="info" className="mt-0.5 size-5 shrink-0 text-pink-strong" />
                  <span>
                    {r.text}
                    <ReviewMarker status={r.verificationStatus} note={r.note} />
                  </span>
                </li>
              ))}
            </ul>
          </div>
          {addons.length > 0 ? (
            <div className="rounded-[var(--radius-card)] bg-white p-6 shadow-[inset_0_0_0_1px_var(--color-line)] sm:p-8">
              <h3 className="h-card">Eigene Nische oder Kabine</h3>
              <ul className="mt-4 divide-y divide-line">
                {addons.map((a) => (
                  <li key={a.id} className="flex items-baseline justify-between gap-4 py-3">
                    <span>
                      <span className="block font-bold">{a.name}</span>
                      <span className="text-[0.95rem] text-ink-soft">{a.description}</span>
                    </span>
                    <span className="whitespace-nowrap font-display text-lg font-bold">{formatPrice(a.price.amount)}</span>
                  </li>
                ))}
              </ul>
              <p className="mt-2 text-[0.9rem] text-ink-soft">Pauschal pro Feier, zusätzlich zum Paket.</p>
            </div>
          ) : (
            <div className="relative min-h-[240px] overflow-hidden rounded-[var(--radius-card)]">
              <Photo media="rdHuepfburg" sizes="(min-width: 1024px) 45vw, 100vw" />
            </div>
          )}
        </div>
      </Section>

      <Section id="anfrage" tone="pink" eyebrow="Anfrage" title="Geburtstag anfragen" intro={<p>Schickt uns euren Wunschtermin – das ist noch keine verbindliche Buchung.</p>}>
        <div className="grid gap-10 lg:grid-cols-[1.6fr_1fr]">
          <div className="card p-6 sm:p-9">
            <BirthdayInquiryForm
              location={loc.id}
              locationName={loc.shortName}
              packages={packages}
              addons={addons}
              dateHint={dateHint}
              calendar={calendarEnabled(loc.id)}
            />
          </div>
          <aside className="space-y-5 text-[0.97rem]">
            <div className="card p-6">
              <h3 className="h-card">Lieber anrufen?</h3>
              {loc.phone && (
                <p className="mt-2">
                  <a href={`tel:${loc.phone.tel}`} className="inline-flex min-h-11 items-center font-bold underline underline-offset-4">
                    {loc.phone.display}
                  </a>
                  <ReviewMarker status={loc.phone.provenance.verificationStatus} note={loc.phone.provenance.note} />
                </p>
              )}
              {loc.id === "kiel" && <p className="text-ink-soft">Zentrale, Mo – Fr 10 – 14 Uhr</p>}
            </div>
            <p className="text-ink-soft">
              Ihr möchtet in {other.shortName} feiern?{" "}
              <Link href={other.pages.birthday} className="font-bold text-ink underline underline-offset-4">
                Zu den Paketen in {other.shortName}
              </Link>
            </p>
          </aside>
        </div>
      </Section>

      {loc.id === "kiel" && (
        <Section id="mehr" eyebrow="Nebenan" title="Noch mehr Geburtstagsideen am Göteborgring">
          <ul className="grid gap-4 sm:grid-cols-2">
            {["sfc", "minigolf"].map((id) => {
              const l = getExternal(id);
              return (
                <li key={id} className="card flex items-center justify-between gap-4 p-6">
                  <span>
                    <span className="block font-display text-lg font-bold">{l.service}</span>
                    <span className="text-[0.95rem] text-ink-soft">{l.purpose}</span>
                  </span>
                  <a href={l.url} rel="noopener" className="link-arrow shrink-0 text-blue-strong">
                    Website <Icon name="external" className="size-4" />
                    <span className="sr-only">von {l.service} (extern)</span>
                  </a>
                </li>
              );
            })}
          </ul>
        </Section>
      )}
    </>
  );
}
