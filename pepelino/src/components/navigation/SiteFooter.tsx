import Image from "next/image";
import Link from "next/link";
import { locationList } from "@/content/locations";
import { media } from "@/content/media";
import { externalLinks, site } from "@/content/site";
import { formatDays, formatTimeRange } from "@/lib/format";
import { Icon } from "@/components/ui/Icon";
import { ReviewMarker } from "@/components/ui/ReviewMarker";
import { asset } from "@/lib/assets";

const social = externalLinks.filter((l) => ["instagram", "facebook", "youtube", "tiktok"].includes(l.id));

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-line bg-white">
      <div className="container-site grid gap-12 py-14 md:grid-cols-2 lg:grid-cols-[1.1fr_1fr_1fr_0.9fr]">
        <div>
          <Image src={asset(media.logo.src)} width={media.logo.width} height={media.logo.height} alt="Pepelino Spieleparadies" className="h-20 w-auto" sizes="110px" />
          <p className="mt-4 max-w-xs text-[0.95rem] text-ink-soft">{site.tagline}. Wetterunabhängig spielen, toben und feiern.</p>
          <div className="mt-5 text-[0.95rem]">
            <p className="font-extrabold">{site.central.label}</p>
            <p className="text-ink-soft">{site.central.phoneHours}</p>
            <p className="mt-1">
              <a href={`tel:${site.central.phone.tel}`} className="font-semibold underline-offset-4 hover:underline">
                {site.central.phone.display}
              </a>
              <ReviewMarker status={site.central.provenance.verificationStatus} note={site.central.provenance.note} />
            </p>
            <p>
              <a href={`mailto:${site.central.email}`} className="font-semibold underline-offset-4 hover:underline">
                {site.central.email}
              </a>
            </p>
          </div>
        </div>

        {locationList.map((loc) => (
          <div key={loc.id}>
            <h2 className={`text-lg ${loc.accent === "blue" ? "text-blue-strong" : "text-green-strong"}`}>{loc.name}</h2>
            <address className="mt-3 text-[0.95rem] not-italic leading-relaxed">
              {loc.address.street}
              <br />
              {loc.address.postalCode} {loc.address.city}
            </address>
            <dl className="mt-3 grid grid-cols-[auto_1fr] gap-x-3 gap-y-0.5 text-[0.95rem]">
              {loc.opening.slots
                .filter((s) => s.opens)
                .map((s) => (
                  <div key={s.days.join()} className="contents">
                    <dt className="text-ink-soft">{formatDays(s.days)}</dt>
                    <dd className="whitespace-nowrap">{formatTimeRange(s.opens, s.closes)}</dd>
                  </div>
                ))}
            </dl>
            <ul className="mt-3 space-y-0.5 text-[0.95rem]">
              <li>
                <Link href={loc.pages.location} className="link-arrow !min-h-9 text-ink">
                  Standortseite <Icon name="arrow" className="size-4" />
                </Link>
              </li>
              <li>
                <Link href={loc.pages.birthday} className="link-arrow !min-h-9 text-ink">
                  Kindergeburtstag <Icon name="arrow" className="size-4" />
                </Link>
              </li>
            </ul>
          </div>
        ))}

        <div>
          <h2 className="text-lg">Service</h2>
          <ul className="mt-3 space-y-0.5 text-[0.95rem]">
            {site.footerLinks.map((l) => (
              <li key={l.href}>
                <Link href={l.href} className="inline-flex min-h-9 items-center underline-offset-4 hover:underline">
                  {l.label}
                </Link>
              </li>
            ))}
          </ul>
          <h2 className="mt-6 text-lg">Folgt uns</h2>
          <ul className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-[0.95rem]">
            {social.map((l) => (
              <li key={l.id}>
                <a href={l.url} rel="noopener" className="inline-flex min-h-9 items-center underline-offset-4 hover:underline">
                  {l.service}
                </a>
              </li>
            ))}
          </ul>
        </div>
      </div>
      <div className="border-t border-line">
        <div className="container-site flex flex-col gap-3 py-6 text-sm text-ink-soft sm:flex-row sm:items-center sm:justify-between">
          <p>© {site.legalName}</p>
          <ul className="flex gap-5">
            {site.legalLinks.map((l) => (
              <li key={l.href}>
                <Link href={l.href} className="inline-flex min-h-9 items-center font-semibold text-ink underline-offset-4 hover:underline">
                  {l.label}
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </footer>
  );
}
