import { NextResponse, type NextRequest } from "next/server";
import { locationId } from "@/content/schema";
import { availabilityFor } from "@/lib/booking";
import { todayInBerlin } from "@/lib/format";

/**
 * GET /api/geburtstag/verfuegbarkeit?standort=kiel&datum=2026-10-10
 * Liefert buchbare Zeitfenster für den Geburtstags-Kalender.
 * Solange der Kalender ausgeschaltet ist: { status: "disabled" }.
 */
export async function GET(request: NextRequest) {
  const loc = locationId.safeParse(request.nextUrl.searchParams.get("standort"));
  const date = request.nextUrl.searchParams.get("datum") ?? "";
  if (!loc.success || !/^\d{4}-\d{2}-\d{2}$/.test(date) || Number.isNaN(Date.parse(date))) {
    return NextResponse.json({ error: "Ungültiger Standort oder Datum" }, { status: 400 });
  }
  const result = await availabilityFor(loc.data, date, todayInBerlin());
  return NextResponse.json(result, { headers: { "Cache-Control": "no-store" } });
}
