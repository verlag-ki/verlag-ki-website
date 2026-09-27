/**
 * Pfad zu Dateien aus /public. Bei einer Vorschau im Unterordner
 * (NEXT_PUBLIC_BASE_PATH=/pepelino) wird das Präfix ergänzt – next/image
 * macht das bei `unoptimized` nicht automatisch.
 */
export function asset(src: string): string {
  const base = process.env.NEXT_PUBLIC_BASE_PATH ?? "";
  return base && src.startsWith("/") && !src.startsWith(base + "/") ? `${base}${src}` : src;
}
