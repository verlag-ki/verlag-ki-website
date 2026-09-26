/** Rendert strukturierte Daten serverseitig als application/ld+json. */
export function JsonLd({ data }: { data: object | object[] }) {
  return (
    <script
      type="application/ld+json"
      // JSON.stringify + Escaping von "<" verhindert das Schließen des Script-Tags.
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data).replace(/</g, "\\u003c") }}
    />
  );
}
