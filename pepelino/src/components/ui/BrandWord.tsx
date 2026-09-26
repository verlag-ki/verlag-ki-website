/**
 * „Pepelino“ in den Logofarben. Für große Überschriften (≥ 24 px, fett) –
 * alle Farben erfüllen dort mindestens 3:1 auf Off-White.
 * Screenreader lesen das Wort normal vor.
 */
const COLORS = ["text-blue", "text-green", "text-pink", "text-blue", "text-green", "text-pink", "text-orange", "text-blue"];

export function BrandWord({ word = "Pepelino" }: { word?: string }) {
  return (
    <span className="whitespace-nowrap">
      <span className="sr-only">{word}</span>
      <span aria-hidden="true">
        {word.split("").map((ch, i) => (
          <span key={i} className={COLORS[i % COLORS.length]}>
            {ch}
          </span>
        ))}
      </span>
    </span>
  );
}
