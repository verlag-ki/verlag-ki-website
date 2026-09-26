import { describe, expect, it } from "vitest";
import { birthdaySchema, contactSchema, groupSchema, toFieldErrors } from "@/lib/validation/inquiries";
import { todayInBerlin } from "@/lib/format";

const today = () => "2026-09-26";

const validBirthday = {
  location: "kiel",
  packageId: "kiel-medium",
  addonId: "kiel-nische",
  childName: "Mia",
  childAge: "7",
  date: "2026-10-09",
  startTime: "14:00",
  children: "8",
  adults: "2",
  contactName: "Alex Beispiel",
  email: "alex@example.org",
  phone: "0431 123456",
  message: "",
  privacy: "on",
};

describe("Geburtstagsanfrage", () => {
  it("akzeptiert eine vollständige Anfrage", () => {
    expect(birthdaySchema(today).safeParse(validBirthday).success).toBe(true);
  });

  it("verlangt mindestens 5 Kinder", () => {
    const r = birthdaySchema(today).safeParse({ ...validBirthday, children: "4" });
    expect(r.success).toBe(false);
    expect(toFieldErrors(r.error!).children).toMatch(/Mindestens 5/);
  });

  it("lehnt Datum in der Vergangenheit ab", () => {
    const r = birthdaySchema(today).safeParse({ ...validBirthday, date: "2026-09-25" });
    expect(r.success).toBe(false);
    expect(toFieldErrors(r.error!).date).toBeDefined();
  });

  it("verhindert Kieler Pakete/Optionen für Westerrönfeld", () => {
    const r1 = birthdaySchema(today).safeParse({ ...validBirthday, location: "westerroenfeld", addonId: "none" });
    expect(toFieldErrors(r1.error!).packageId).toBeDefined();
    const r2 = birthdaySchema(today).safeParse({ ...validBirthday, location: "westerroenfeld", packageId: "rd-medium" });
    expect(toFieldErrors(r2.error!).addonId).toBeDefined();
  });

  it("verlangt Datenschutzbestätigung und gültige E-Mail", () => {
    const r = birthdaySchema(today).safeParse({ ...validBirthday, privacy: undefined, email: "kein-at" });
    const e = toFieldErrors(r.error!);
    expect(e.privacy).toBeDefined();
    expect(e.email).toBeDefined();
  });

  it("fragt kein Geschlecht ab", () => {
    const shape = Object.keys(birthdaySchema(today).shape);
    expect(shape).toContain("childName");
    expect(shape.join()).not.toMatch(/gender|geschlecht/i);
  });
});

describe("Gruppenanfrage", () => {
  const valid = {
    institution: "Grundschule Beispiel",
    ageGroup: "3. Klasse",
    location: "westerroenfeld",
    date: "2026-11-02",
    startTime: "09:00",
    endTime: "12:00",
    children: "24",
    adults: "3",
    contactName: "Kim Muster",
    email: "kim@example.org",
    phone: "04331 1234",
    privacy: "on",
  };
  it("akzeptiert gültige Daten", () => expect(groupSchema(today).safeParse(valid).success).toBe(true));
  it("Ende muss nach Beginn liegen", () => {
    const r = groupSchema(today).safeParse({ ...valid, endTime: "08:30" });
    expect(toFieldErrors(r.error!).endTime).toBeDefined();
  });
});

describe("Kontakt", () => {
  it("verlangt Standort", () => {
    const r = contactSchema.safeParse({ name: "A", email: "a@b.de", message: "Hallo", privacy: "on" });
    expect(toFieldErrors(r.error!).location).toBeDefined();
  });
});

describe("Zeitzone", () => {
  it("todayInBerlin nutzt Europe/Berlin", () => {
    // 23:30 UTC am 26.09. ist in Berlin bereits der 27.09.
    expect(todayInBerlin(new Date("2026-09-26T23:30:00Z"))).toBe("2026-09-27");
  });
});
