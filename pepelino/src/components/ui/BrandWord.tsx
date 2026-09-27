/**
 * „Pepelino“ in den Farben des Logos (Cyan, Grün, Rot, Gelb im Wechsel)
 * mit dunkler Kontur wie im Original-Schriftzug – dadurch auch Gelb und
 * Cyan auf hellem Grund gut lesbar. Nur für große Überschriften.
 * Screenreader lesen das Wort normal vor.
 */
export function BrandWord({ word = "Pepelino" }: { word?: string }) {
  return (
    <span className="whitespace-nowrap">
      <span className="sr-only">{word}</span>
      <span aria-hidden="true" className="brand-word">
        {word.split("").map((ch, i) => (
          <span key={i}>{ch}</span>
        ))}
      </span>
    </span>
  );
}
