/** Schlankes Layout für QR-Code-Ziele am Tisch: keine große Navigation. */
export default function QrLayout({ children }: { children: React.ReactNode }) {
  return (
    <main id="inhalt" tabIndex={-1} className="outline-none">
      {children}
    </main>
  );
}
