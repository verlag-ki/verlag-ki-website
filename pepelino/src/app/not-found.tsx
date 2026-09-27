import Link from "next/link";
import { SiteHeader } from "@/components/navigation/SiteHeader";
import { SiteFooter } from "@/components/navigation/SiteFooter";
import { Doodle } from "@/components/ui/Icon";
import { getExternal } from "@/content/site";
import { locationList } from "@/content/locations";

export default function NotFound() {
  return (
    <>
      <SiteHeader voucherUrl={getExternal("voucher").url} />
      <main id="inhalt" tabIndex={-1} className="container-site py-16 outline-none md:py-24">
        <Doodle kind="spark" className="h-12 w-12 text-sun" />
        <p className="eyebrow mt-4 text-pink-strong">Fehler 404</p>
        <h1 className="h-display mt-2 max-w-[16ch]">Hier ist leider niemand zum Spielen.</h1>
        <p className="mt-4 max-w-[48ch] text-lg text-ink-soft">
          Die Seite gibt es nicht (mehr). Vielleicht hilft einer dieser Wege weiter:
        </p>
        <ul className="mt-8 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
          <li>
            <Link href="/" className="btn btn-pink">Zur Startseite</Link>
          </li>
          {locationList.map((l) => (
            <li key={l.id}>
              <Link href={l.pages.location} className="btn btn-quiet">
                Pepelino {l.shortName}
              </Link>
            </li>
          ))}
        </ul>
      </main>
      <SiteFooter />
    </>
  );
}
