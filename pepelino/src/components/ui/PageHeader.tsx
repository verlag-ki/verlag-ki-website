import Link from "next/link";
import { JsonLd } from "./JsonLd";
import { Photo } from "./Photo";
import { breadcrumbJsonLd } from "@/lib/seo";

type Crumb = { name: string; path: string };

export function Breadcrumbs({ items }: { items: Crumb[] }) {
  return (
    <>
      <JsonLd data={breadcrumbJsonLd(items)} />
      <nav aria-label="Brotkrümelnavigation" className="text-sm text-ink-soft">
        <ol className="flex flex-wrap items-center gap-1.5">
          {items.map((c, i) => (
            <li key={c.path} className="flex items-center gap-1.5">
              {i > 0 && <span aria-hidden="true">/</span>}
              {i === items.length - 1 ? (
                <span aria-current="page" className="font-semibold text-ink">
                  {c.name}
                </span>
              ) : (
                <Link href={c.path} className="inline-flex min-h-8 items-center underline-offset-4 hover:underline">
                  {c.name}
                </Link>
              )}
            </li>
          ))}
        </ol>
      </nav>
    </>
  );
}

type Props = {
  crumbs: Crumb[];
  eyebrow?: string;
  eyebrowTone?: string;
  title: React.ReactNode;
  intro?: React.ReactNode;
  image?: string;
  children?: React.ReactNode;
};

/** Ruhiger Seitenkopf für Unterseiten: Text links, optional ein großes Bild mit organischer Kante. */
export function PageHeader({ crumbs, eyebrow, eyebrowTone = "text-pink-strong", title, intro, image, children }: Props) {
  return (
    <header className="container-site pt-6 md:pt-8">
      <Breadcrumbs items={crumbs} />
      <div className={`mt-6 grid items-center gap-8 md:mt-8 ${image ? "md:grid-cols-[1.05fr_1fr] md:gap-12" : ""}`}>
        <div>
          {eyebrow && <p className={`eyebrow ${eyebrowTone}`}>{eyebrow}</p>}
          <h1 className="h-display mt-2 max-w-[18ch] !text-[clamp(2.1rem,1.5rem+2.4vw,3.4rem)]">{title}</h1>
          {intro && <div className="mt-4 max-w-[52ch] space-y-3 text-lg text-ink-soft">{intro}</div>}
          {children && <div className="mt-6">{children}</div>}
        </div>
        {image && (
          <div className="relative aspect-[4/3] overflow-hidden organic-image shadow-[var(--shadow-lift)]">
            <Photo media={image} priority sizes="(min-width: 768px) 45vw, 100vw" />
          </div>
        )}
      </div>
    </header>
  );
}

export function Section({
  id,
  title,
  eyebrow,
  eyebrowTone = "text-pink-strong",
  tone,
  children,
  intro,
}: {
  id?: string;
  title: string;
  eyebrow?: string;
  eyebrowTone?: string;
  tone?: "pink" | "blue" | "green";
  intro?: React.ReactNode;
  children: React.ReactNode;
}) {
  const bg = tone === "pink" ? "bg-pink-wash" : tone === "blue" ? "bg-blue-wash" : tone === "green" ? "bg-green-wash" : "";
  const headingId = id ? `${id}-titel` : undefined;
  return (
    <section id={id} aria-labelledby={headingId} className={`mt-16 md:mt-24 ${bg}`}>
      <div className={`container-site ${bg ? "py-14 md:py-20" : ""}`}>
        {eyebrow && <p className={`eyebrow ${eyebrowTone}`}>{eyebrow}</p>}
        <h2 id={headingId} className="h-section mt-2">
          {title}
        </h2>
        {intro && <div className="mt-3 max-w-[60ch] text-ink-soft">{intro}</div>}
        <div className="mt-8">{children}</div>
      </div>
    </section>
  );
}
