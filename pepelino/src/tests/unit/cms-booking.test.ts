import { describe, expect, it } from "vitest";
import { rulesProvider, bookingConfig, bookingConfigSchema } from "@/lib/booking";
import * as S from "@/content/schema";
import { formatDateRange, upcoming } from "@/lib/format";
import fs from "node:fs";
import path from "node:path";

describe("Pflegebereich-Dateien (src/content/data)", () => {
  it("alle JSON-Dateien sind gültiges JSON", () => {
    const dir = path.join(process.cwd(), "src/content/data");
    for (const f of fs.readdirSync(dir)) expect(() => JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")), f).not.toThrow();
  });

  it("Sonderzeiten: Keystatic lässt leere Felder weg – wird trotzdem akzeptiert", () => {
    const r = S.specialDate.safeParse({ from: "2026-12-24", to: "2026-12-24", label: "Heiligabend", closed: true, opens: null, closes: null });
    expect(r.success).toBe(true);
  });

  it("Sonderzeiten: ohne Uhrzeit und nicht geschlossen ist ungültig", () => {
    const r = S.specialDate.safeParse({ from: "2026-10-12", to: "2026-10-23", label: "Ferien", closed: false, opens: null, closes: null });
    expect(r.success).toBe(false);
  });

  it("vergangene Sonderzeiten werden ausgeblendet", () => {
    const items = [
      { to: "2026-09-01", label: "alt" },
      { to: "2026-10-01", label: "neu" },
    ];
    expect(upcoming(items, "2026-09-27").map((i) => i.label)).toEqual(["neu"]);
    expect(formatDateRange("2026-10-12", "2026-10-23")).toBe("Mo., 12.10. – Fr., 23.10.");
  });
});

describe("Geburtstags-Kalender (Stufe 1, Regeln)", () => {
  const today = "2026-09-27";
  it("Konfigurationen sind gültig und standardmäßig AUS", () => {
    for (const id of ["kiel", "westerroenfeld"] as const) {
      expect(bookingConfigSchema.safeParse(bookingConfig(id)).success).toBe(true);
      expect(bookingConfig(id).enabled).toBe(false);
    }
  });
  it("Dienstag in Kiel geschlossen, Samstag mit Zeitfenstern", async () => {
    expect(await rulesProvider.getAvailability("kiel", "2026-10-06", today)).toEqual({ status: "closed", reason: "weekday" });
    const sat = await rulesProvider.getAvailability("kiel", "2026-10-10", today);
    expect(sat.status).toBe("open");
    if (sat.status === "open") {
      expect(sat.slots[0]).toEqual({ start: "11:00", end: "13:30", available: null });
      expect(sat.live).toBe(false);
    }
  });
  it("Vorlauf, Vergangenheit und Höchstabstand", async () => {
    expect(await rulesProvider.getAvailability("kiel", "2026-09-26", today)).toEqual({ status: "closed", reason: "past" });
    expect(await rulesProvider.getAvailability("kiel", "2026-09-28", today)).toEqual({ status: "closed", reason: "too_soon" });
    expect(await rulesProvider.getAvailability("kiel", "2027-06-05", today)).toEqual({ status: "closed", reason: "too_far" });
  });
});
