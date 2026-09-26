import type { SVGProps } from "react";

/**
 * Sparsames, einheitliches Icon-Set (2px Strich, runde Enden).
 * Dekorative Icons sind aria-hidden; Bedeutung trägt immer der Text daneben.
 */
const paths = {
  arrow: <path d="M5 12h14M13 6l6 6-6 6" />,
  pin: (
    <>
      <path d="M12 21s-7-6.2-7-11.5A7 7 0 0 1 19 9.5C19 14.8 12 21 12 21Z" />
      <circle cx="12" cy="9.5" r="2.5" />
    </>
  ),
  clock: (
    <>
      <circle cx="12" cy="12" r="8.5" />
      <path d="M12 7.5V12l3 2" />
    </>
  ),
  ticket: (
    <>
      <path d="M4 8a2 2 0 0 0 2-2h12a2 2 0 0 0 2 2v2a2 2 0 0 0 0 4v2a2 2 0 0 0-2 2H6a2 2 0 0 0-2-2v-2a2 2 0 0 0 0-4Z" />
      <path d="M10 9.5v5M14 9.5v5" />
    </>
  ),
  cutlery: (
    <>
      <path d="M7 3v8M4.5 3v5a2.5 2.5 0 0 0 5 0V3M7 11v10" />
      <path d="M17 21V3c-2 1.5-3 4-3 7v3h3" />
    </>
  ),
  cake: (
    <>
      <path d="M4 20h16M5 20v-6a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v6" />
      <path d="M5 16c1.2 1 2.3 1 3.5 0s2.3-1 3.5 0 2.3 1 3.5 0 2.3-1 3.5 0" />
      <path d="M12 12V8M12 5.5c.8-.8.8-1.7 0-2.5-.8.8-.8 1.7 0 2.5Z" />
    </>
  ),
  group: (
    <>
      <circle cx="12" cy="8" r="3" />
      <circle cx="5.5" cy="10" r="2.2" />
      <circle cx="18.5" cy="10" r="2.2" />
      <path d="M6.5 20a5.5 5.5 0 0 1 11 0M2 19a3.8 3.8 0 0 1 4.2-4.2M22 19a3.8 3.8 0 0 0-4.2-4.2" />
    </>
  ),
  slide: (
    <>
      <path d="M4 20V6h4" />
      <path d="M8 6c3 0 4 3 6 7s4 7 7 7" />
      <path d="M4 12h3" />
    </>
  ),
  phone: (
    <path d="M6.5 3.5h3l1.5 4-2 1.3a11 11 0 0 0 6.2 6.2l1.3-2 4 1.5v3a2 2 0 0 1-2.2 2A17 17 0 0 1 4.5 5.7a2 2 0 0 1 2-2.2Z" />
  ),
  mail: (
    <>
      <rect x="3.5" y="5.5" width="17" height="13" rx="2" />
      <path d="m4 7 8 6 8-6" />
    </>
  ),
  gift: (
    <>
      <rect x="4" y="9" width="16" height="11" rx="1.5" />
      <path d="M3 9h18M12 9v11M12 9c-1.5-3-5-4-5-1.5S12 9 12 9Zm0 0c1.5-3 5-4 5-1.5S12 9 12 9Z" />
    </>
  ),
  menu: <path d="M4 7h16M4 12h16M4 17h16" />,
  close: <path d="M6 6l12 12M18 6 6 18" />,
  chevron: <path d="m6 9 6 6 6-6" />,
  check: <path d="m5 12.5 4.5 4.5L19 7.5" />,
  info: (
    <>
      <circle cx="12" cy="12" r="8.5" />
      <path d="M12 11v5M12 8h.01" />
    </>
  ),
  external: <path d="M14 4h6v6M20 4l-9 9M18 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5" />,
  back: <path d="M19 12H5M11 6l-6 6 6 6" />,
} as const;

export type IconName = keyof typeof paths;

export function Icon({ name, className = "size-5", ...rest }: { name: IconName } & SVGProps<SVGSVGElement>) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      className={className}
      {...rest}
    >
      {paths[name]}
    </svg>
  );
}

/** Kleiner handgezeichnet wirkender Akzent – höchstens einer pro Sektion. */
export function Doodle({ kind, className }: { kind: "crown" | "spark" | "swoosh"; className?: string }) {
  if (kind === "crown")
    return (
      <svg viewBox="0 0 64 48" className={className} aria-hidden="true" fill="none" stroke="currentColor" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round">
        <path d="M8 38 5 12l15 13 12-19 11 19 16-12-4 25c-17 3-30 3-47 0Z" />
        <path d="M11 44c14 2 28 2 42-1" />
      </svg>
    );
  if (kind === "spark")
    return (
      <svg viewBox="0 0 48 48" className={className} aria-hidden="true" fill="none" stroke="currentColor" strokeWidth={3} strokeLinecap="round">
        <path d="M24 6v9M24 33v9M6 24h9M33 24h9M11 11l6 6M31 31l6 6M37 11l-6 6M17 31l-6 6" />
      </svg>
    );
  return (
    <svg viewBox="0 0 120 24" className={className} aria-hidden="true" fill="none" stroke="currentColor" strokeWidth={4} strokeLinecap="round">
      <path d="M4 16c20-9 44-12 70-8 14 2 28 5 42 2" />
    </svg>
  );
}
