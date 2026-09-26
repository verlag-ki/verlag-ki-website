"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useId, useRef, useState } from "react";
import { site } from "@/content/site";
import { media } from "@/content/media";
import { Icon } from "@/components/ui/Icon";

type NavItem = (typeof site.nav)[number];

function isActive(pathname: string, item: NavItem): boolean {
  if (item.href === "/") return pathname === "/";
  // Sprungmarken (#preise) in Untermenüs zählen nicht als eigene Seite.
  const all = [item.href, ...(item.children?.filter((c) => !c.href.includes("#")).map((c) => c.href) ?? [])];
  return all.some((h) => h !== "/" && pathname.startsWith(h));
}

function Dropdown({ item, active }: { item: NavItem; active: boolean }) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLLIElement>(null);
  const id = useId();

  useEffect(() => {
    if (!open) return;
    const onDoc = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setOpen(false);
        ref.current?.querySelector("button")?.focus();
      }
    };
    document.addEventListener("mousedown", onDoc);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDoc);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  return (
    <li
      ref={ref}
      className="relative"
      onBlur={(e) => {
        if (!ref.current?.contains(e.relatedTarget as Node)) setOpen(false);
      }}
    >
      <button
        type="button"
        aria-expanded={open}
        aria-controls={id}
        onClick={() => setOpen((v) => !v)}
        className={`nav-link inline-flex items-center gap-1 ${active ? "is-active" : ""}`}
      >
        {item.label}
        <Icon name="chevron" className={`size-4 transition-transform ${open ? "rotate-180" : ""}`} />
      </button>
      <ul
        id={id}
        hidden={!open}
        className="absolute left-1/2 top-full z-40 mt-2 w-64 -translate-x-1/2 rounded-2xl bg-white p-2 shadow-[var(--shadow-lift)] ring-1 ring-line"
      >
        {item.children!.map((c) => (
          <li key={c.href}>
            <Link
              href={c.href}
              onClick={() => setOpen(false)}
              className="block rounded-xl px-3 py-2.5 text-[0.95rem] font-semibold text-ink no-underline hover:bg-blue-wash"
            >
              {c.label}
            </Link>
          </li>
        ))}
      </ul>
    </li>
  );
}

export function SiteHeader({ voucherUrl }: { voucherUrl: string }) {
  const pathname = usePathname() ?? "/";
  const [mobileOpen, setMobileOpen] = useState(false);
  const panelId = useId();

  // Menü bei Seitenwechsel schließen (Zustandsanpassung während des Renderns statt Effekt).
  const [lastPath, setLastPath] = useState(pathname);
  if (pathname !== lastPath) {
    setLastPath(pathname);
    setMobileOpen(false);
  }

  useEffect(() => {
    if (!mobileOpen) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setMobileOpen(false);
    document.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
    };
  }, [mobileOpen]);

  const logo = media.logo;

  return (
    <header className="relative z-30 bg-paper/95 backdrop-blur supports-[backdrop-filter]:bg-paper/85">
      <div className="container-site flex h-[76px] items-center justify-between gap-4 lg:h-[88px]">
        <Link href="/" className="flex shrink-0 items-center rounded-lg" aria-label="Pepelino – zur Startseite">
          <Image
            src={logo.src}
            width={logo.width}
            height={logo.height}
            alt=""
            priority
            sizes="100px"
            className="h-[58px] w-auto lg:h-[70px]"
          />
        </Link>

        <nav aria-label="Hauptnavigation" className="hidden lg:block">
          <ul className="flex items-center gap-1 xl:gap-2">
            {site.nav.map((item) => {
              const active = isActive(pathname, item);
              return item.children ? (
                <Dropdown key={item.label} item={item} active={active} />
              ) : (
                <li key={item.href}>
                  <Link href={item.href} aria-current={pathname === item.href ? "page" : undefined} className={`nav-link ${active ? "is-active" : ""}`}>
                    {item.label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        <div className="flex items-center gap-2">
          <a href={voucherUrl} className="btn btn-pink hidden !min-h-11 !px-4 !py-2 text-[0.95rem] sm:inline-flex" rel="noopener">
            <Icon name="gift" className="size-[1.1rem]" />
            Gutscheine
            <span className="sr-only">(externer Gutscheinshop)</span>
          </a>
          <button
            type="button"
            className="inline-flex size-12 items-center justify-center rounded-full text-ink ring-1 ring-line-strong lg:hidden"
            aria-expanded={mobileOpen}
            aria-controls={panelId}
            onClick={() => setMobileOpen((v) => !v)}
          >
            <Icon name={mobileOpen ? "close" : "menu"} className="size-6" />
            <span className="sr-only">{mobileOpen ? "Menü schließen" : "Menü öffnen"}</span>
          </button>
        </div>
      </div>

      <div id={panelId} hidden={!mobileOpen} className="fixed inset-x-0 bottom-0 top-[76px] z-40 overflow-y-auto bg-paper lg:hidden">
        <nav
          aria-label="Mobile Navigation"
          className="container-site pb-10 pt-4"
          onClick={(e) => {
            if ((e.target as HTMLElement).closest("a")) setMobileOpen(false);
          }}
        >
          <ul className="divide-y divide-line">
            {site.nav.map((item) =>
              item.children ? (
                <li key={item.label} className="py-3">
                  <p className="eyebrow px-1 pb-1 text-ink-soft">{item.label}</p>
                  <ul>
                    {item.children.map((c) => (
                      <li key={c.href}>
                        <Link href={c.href} className="flex min-h-12 items-center px-1 text-lg font-bold no-underline">
                          {c.label}
                        </Link>
                      </li>
                    ))}
                  </ul>
                </li>
              ) : (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    aria-current={pathname === item.href ? "page" : undefined}
                    className="flex min-h-14 items-center px-1 text-lg font-bold no-underline"
                  >
                    {item.label}
                  </Link>
                </li>
              ),
            )}
          </ul>
          <a href={voucherUrl} className="btn btn-pink mt-6 w-full" rel="noopener">
            <Icon name="gift" className="size-5" />
            Gutscheine kaufen
            <span className="sr-only">(externer Gutscheinshop)</span>
          </a>
        </nav>
      </div>
    </header>
  );
}
