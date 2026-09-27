import { NextResponse, type NextRequest } from "next/server";

/**
 * Einheitliche URLs mit abschließendem Schrägstrich (wie auf der bisherigen
 * WordPress-Seite) – außer für den Pflegebereich (/keystatic) und APIs,
 * deren Router keine Schrägstrich-URLs erwartet.
 * Ersetzt die eingebaute trailingSlash-Weiterleitung (siehe next.config.ts).
 */
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  if (pathname.endsWith("/") || pathname.startsWith("/keystatic") || pathname.startsWith("/api/")) {
    if (pathname.startsWith("/keystatic") && pathname.endsWith("/")) {
      return NextResponse.redirect(new URL(pathname.replace(/\/+$/, "") + request.nextUrl.search, request.url), 308);
    }
    return NextResponse.next();
  }
  // Dateien (robots.txt, sitemap.xml, Bilder …) nicht anfassen
  if (/\.[a-z0-9]+$/i.test(pathname)) return NextResponse.next();
  // Hinweis: nextUrl.clone() würde den Schrägstrich wieder entfernen, daher new URL().
  return NextResponse.redirect(new URL(`${pathname}/${request.nextUrl.search}`, request.url), 308);
}

export const config = {
  matcher: ["/((?!_next/).*)"],
};
