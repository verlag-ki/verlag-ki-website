/**
 * Formular-Transport. In der Vorschau ist ausschließlich der Demo-Adapter aktiv:
 * Er verwirft die Daten sofort (keine Speicherung, kein Logging, kein Versand).
 *
 * Für den Livegang wird ein echter Adapter (z. B. SMTP/Transaktionsmail-Dienst)
 * implementiert, sobald Empfänger, Dienstleister (AV-Vertrag) und Datenschutztext
 * freigegeben sind. Siehe docs/INTEGRATIONS_AND_RIGHTS.md.
 */
export type InquiryKind = "birthday" | "group" | "contact";

export interface InquiryTransport {
  readonly isDemo: boolean;
  send(kind: InquiryKind, payload: Record<string, unknown>): Promise<{ delivered: boolean }>;
}

export const demoTransport: InquiryTransport = {
  isDemo: true,
  async send() {
    return { delivered: false };
  },
};

/**
 * Platzhalter für eine spätere echte Reservierungs-/Kapazitätsanbindung.
 * Bewusst NICHT implementiert – es gibt keine belegte Buchungsschnittstelle.
 */
export interface BookingProvider {
  getAvailability(locationId: string, date: string): Promise<{ slots: string[] }>;
  reserve(input: Record<string, unknown>): Promise<{ reservationId: string }>;
}

export function getInquiryTransport(): InquiryTransport {
  // Hier später per Umgebungsvariable einen echten Adapter wählen.
  return demoTransport;
}

export const DEMO_SUCCESS_MESSAGE = "Demo: Diese Anfrage wurde nicht an Pepelino gesendet.";
