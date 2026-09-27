import { config, fields, singleton } from "@keystatic/core";

/**
 * Pflegebereich für Pepelino-Mitarbeitende: /keystatic
 *
 * Speicherort:
 *  – Entwicklung/Vorschau: lokal (Dateien in src/content/data/)
 *  – Produktion: GitHub (KEYSTATIC_STORAGE=github) – jede Änderung wird ein
 *    Commit, der Hoster baut die Seite danach automatisch neu.
 * Siehe docs/PFLEGE.md.
 */

const storage =
  process.env.NEXT_PUBLIC_KEYSTATIC_STORAGE === "github"
    ? ({
        kind: "github",
        repo: (process.env.NEXT_PUBLIC_KEYSTATIC_GITHUB_REPO ?? "verlag-ki/verlag-ki-website") as `${string}/${string}`,
        pathPrefix: "pepelino",
      } as const)
    : ({ kind: "local" } as const);

const LOCATIONS = [
  { id: "kiel", label: "Kiel" },
  { id: "westerroenfeld", label: "Westerrönfeld" },
] as const;

/* ---------- wiederverwendbare Feldgruppen ---------- */

const statusOptions = [
  { label: "Vom Betreiber freigegeben", value: "client_approved" },
  { label: "Öffentlich belegt (alte Website)", value: "verified_public" },
  { label: "Widersprüchlich – in Prüfung", value: "conflicting_public" },
  { label: "Unbelegt / offen", value: "unknown" },
] as const;

const pruefung = () =>
  fields.object(
    {
      verificationStatus: fields.select({
        label: "Prüfstatus",
        description: "Nach eurer Kontrolle auf „Vom Betreiber freigegeben“ stellen – dann verschwindet der gelbe Prüfhinweis.",
        options: statusOptions,
        defaultValue: "client_approved",
      }),
      checkedAt: fields.date({ label: "Geprüft am", validation: { isRequired: true } }),
      sourceUrl: fields.text({ label: "Quelle (optional)", description: "Link, falls die Angabe aus einem Dokument stammt." }),
      note: fields.text({ label: "Interne Notiz (optional)", multiline: true }),
    },
    { label: "Prüfung" },
  );

const uhrzeit = (label: string) =>
  fields.text({
    label,
    description: "Format HH:MM, z. B. 14:00. Leer lassen = geschlossen.",
    validation: { pattern: { regex: /^(|([01]\d|2[0-3]):[0-5]\d)$/, message: "Bitte im Format HH:MM eingeben, z. B. 14:00" } },
  });

const preis = (label = "Preis in €") => fields.number({ label, step: 0.01, validation: { isRequired: true, min: 0 } });

/* ---------- Singletons je Standort ---------- */

function oeffnungszeiten(loc: (typeof LOCATIONS)[number]) {
  return singleton({
    label: `Öffnungszeiten ${loc.label}`,
    path: `src/content/data/oeffnungszeiten-${loc.id}`,
    format: { data: "json" },
    schema: {
      slots: fields.array(
        fields.object({
          days: fields.multiselect({
            label: "Tage",
            options: [
              { label: "Montag", value: "mo" },
              { label: "Dienstag", value: "di" },
              { label: "Mittwoch", value: "mi" },
              { label: "Donnerstag", value: "do" },
              { label: "Freitag", value: "fr" },
              { label: "Samstag", value: "sa" },
              { label: "Sonntag", value: "so" },
            ],
          }),
          opens: uhrzeit("Öffnet um"),
          closes: uhrzeit("Schließt um"),
        }),
        {
          label: "Reguläre Öffnungszeiten",
          itemLabel: (p) => `${p.fields.days.value.join(", ")}: ${p.fields.opens.value || "geschlossen"}${p.fields.closes.value ? ` – ${p.fields.closes.value}` : ""}`,
        },
      ),
      provenance: pruefung(),
      specialDates: fields.array(
        fields.object({
          label: fields.text({ label: "Bezeichnung", description: "z. B. „Herbstferien“, „Heiligabend“, „Betriebsferien“", validation: { length: { min: 1 } } }),
          from: fields.date({ label: "Von", validation: { isRequired: true } }),
          to: fields.date({ label: "Bis (bei einem Tag leer lassen)" }),
          closed: fields.checkbox({ label: "Geschlossen" }),
          opens: uhrzeit("Öffnet um"),
          closes: uhrzeit("Schließt um"),
          note: fields.text({ label: "Hinweis für Besucher (optional)" }),
        }),
        {
          label: "Ferien, Feiertage & Sonderzeiten",
          description: "Wird automatisch angezeigt, solange das Datum nicht vorbei ist.",
          itemLabel: (p) => `${p.fields.from.value ?? "?"} · ${p.fields.label.value}`,
        },
      ),
      exceptions: fields.array(
        fields.object({
          label: fields.text({ label: "Bezeichnung", description: "z. B. „Ferien & Feiertage“" }),
          text: fields.text({ label: "Zeiten / Text", description: "z. B. „12:00 – 19:00 Uhr“" }),
          provenance: pruefung(),
        }),
        { label: "Dauerhafte Zusatzzeilen", itemLabel: (p) => p.fields.label.value },
      ),
    },
  });
}

function preise(loc: (typeof LOCATIONS)[number]) {
  return singleton({
    label: `Eintrittspreise ${loc.label}`,
    path: `src/content/data/preise-${loc.id}`,
    format: { data: "json" },
    schema: {
      prices: fields.array(
        fields.object({
          id: fields.text({ label: "Technischer Schlüssel", description: "Eindeutig, nur Kleinbuchstaben und Bindestriche. Bestehende nicht ändern." }),
          category: fields.text({ label: "Kategorie", description: "z. B. „Kinder ab 2 Jahren“" }),
          note: fields.text({ label: "Zusatz (optional)", description: "z. B. „mit Nachweis“" }),
          price: preis(),
          unit: fields.select({
            label: "Einheit",
            options: [
              { label: "pro Kind", value: "pro Kind" },
              { label: "pro Person", value: "pro Person" },
            ],
            defaultValue: "pro Person",
          }),
          provenance: pruefung(),
        }),
        { label: "Preise", itemLabel: (p) => `${p.fields.category.value}: ${p.fields.price.value ?? "?"} €` },
      ),
    },
  });
}

function geburtstag(loc: (typeof LOCATIONS)[number]) {
  return singleton({
    label: `Kindergeburtstag ${loc.label}`,
    path: `src/content/data/geburtstag-${loc.id}`,
    format: { data: "json" },
    schema: {
      packages: fields.array(
        fields.object({
          id: fields.text({ label: "Technischer Schlüssel", description: `Eindeutig, z. B. „${loc.id === "kiel" ? "kiel" : "rd"}-medium“. Bestehende nicht ändern.` }),
          name: fields.text({ label: "Paketname" }),
          tier: fields.select({
            label: "Stufe",
            options: [
              { label: "Small", value: "small" },
              { label: "Medium", value: "medium" },
              { label: "Large", value: "large" },
            ],
            defaultValue: "medium",
          }),
          price: preis("Preis pro Kind in €"),
          minChildren: fields.integer({ label: "Mindestanzahl Kinder", defaultValue: 5, validation: { isRequired: true, min: 1 } }),
          features: fields.array(
            fields.object({
              text: fields.text({ label: "Leistung" }),
              verificationStatus: fields.select({ label: "Prüfstatus", options: statusOptions, defaultValue: "client_approved" }),
              note: fields.text({ label: "Interne Notiz (optional)" }),
            }),
            { label: "Leistungen", itemLabel: (p) => p.fields.text.value },
          ),
          provenance: pruefung(),
        }),
        { label: "Pakete", itemLabel: (p) => `${p.fields.name.value} – ${p.fields.price.value ?? "?"} €` },
      ),
      addons: fields.array(
        fields.object({
          id: fields.text({ label: "Technischer Schlüssel" }),
          name: fields.text({ label: "Name", description: "z. B. „Geburtstagskabine“" }),
          price: preis("Preis pro Feier in €"),
          description: fields.text({ label: "Beschreibung" }),
          provenance: pruefung(),
        }),
        { label: "Zusatzoptionen (z. B. Kabine/Nische)", itemLabel: (p) => p.fields.name.value },
      ),
      rules: fields.array(
        fields.object({
          text: fields.text({ label: "Hinweis", multiline: true }),
          verificationStatus: fields.select({
            label: "Prüfstatus",
            options: statusOptions.filter((o) => o.value !== "unknown"),
            defaultValue: "client_approved",
          }),
          note: fields.text({ label: "Interne Notiz (optional)" }),
        }),
        { label: "„Gut zu wissen“", itemLabel: (p) => p.fields.text.value.slice(0, 60) },
      ),
    },
  });
}

function speisekarte(loc: (typeof LOCATIONS)[number]) {
  return singleton({
    label: `Speisekarte ${loc.label}`,
    path: `src/content/data/speisekarte-${loc.id}`,
    format: { data: "json" },
    schema: {
      asOf: fields.text({ label: "Stand", description: "z. B. „Oktober 2025“" }),
      sections: fields.array(
        fields.object({
          id: fields.text({ label: "Technischer Schlüssel", description: "z. B. „burger“" }),
          title: fields.text({ label: "Überschrift" }),
          kind: fields.select({
            label: "Bereich",
            options: [
              { label: "Speisen", value: "food" },
              { label: "Getränke", value: "drinks" },
            ],
            defaultValue: "food",
          }),
          items: fields.array(
            fields.object({
              name: fields.text({ label: "Name" }),
              detail: fields.text({ label: "Beschreibung (optional)" }),
              variants: fields.array(
                fields.object({
                  size: fields.text({ label: "Größe/Menge (optional)", description: "z. B. „0,3 l“ oder „5 Stück“" }),
                  price: fields.number({ label: "Preis in € (leer = „Preis vor Ort“)", step: 0.01 }),
                }),
                { label: "Größen & Preise", itemLabel: (p) => `${p.fields.size.value || "Standard"}: ${p.fields.price.value ?? "–"} €` },
              ),
              note: fields.text({ label: "Interne Notiz (optional)", description: "Wenn gefüllt, erscheint ein Prüfhinweis." }),
            }),
            { label: "Gerichte / Getränke", itemLabel: (p) => p.fields.name.value },
          ),
        }),
        { label: "Abschnitte", itemLabel: (p) => p.fields.title.value },
      ),
      notices: fields.array(fields.text({ label: "Hinweis" }), { label: "Hinweise unter der Karte", itemLabel: (p) => p.value }),
      sourceImages: fields.array(
        fields.object({ label: fields.text({ label: "Bezeichnung" }), url: fields.text({ label: "URL" }) }),
        { label: "Ursprüngliche Kartenbilder (Archiv)", itemLabel: (p) => p.fields.label.value },
      ),
      provenance: pruefung(),
    },
  });
}

function geburtstagstermine(loc: (typeof LOCATIONS)[number]) {
  return singleton({
    label: `Geburtstagstermine ${loc.label} (Kalender)`,
    path: `src/content/data/geburtstag-termine-${loc.id}`,
    format: { data: "json" },
    schema: {
      enabled: fields.checkbox({
        label: "Kalender aktiv",
        description: "Aus = Formular nimmt Wunschtermine frei entgegen. An = nur die hier festgelegten Tage und Zeitfenster sind wählbar.",
      }),
      weekdays: fields.multiselect({
        label: "Wochentage mit Geburtstagen",
        options: [
          { label: "Montag", value: "mo" },
          { label: "Dienstag", value: "di" },
          { label: "Mittwoch", value: "mi" },
          { label: "Donnerstag", value: "do" },
          { label: "Freitag", value: "fr" },
          { label: "Samstag", value: "sa" },
          { label: "Sonntag", value: "so" },
        ],
      }),
      extraDates: fields.array(fields.date({ label: "Datum", validation: { isRequired: true } }), {
        label: "Zusätzliche Tage (Ferien, Feiertage)",
        itemLabel: (p) => p.value ?? "",
      }),
      blockedDates: fields.array(fields.date({ label: "Datum", validation: { isRequired: true } }), {
        label: "Gesperrte Tage (z. B. Betriebsferien, ausgebucht)",
        itemLabel: (p) => p.value ?? "",
      }),
      slotStarts: fields.array(
        fields.text({
          label: "Beginn",
          validation: { pattern: { regex: /^([01]\d|2[0-3]):[0-5]\d$/, message: "Format HH:MM" } },
        }),
        { label: "Zeitfenster (Beginn)", itemLabel: (p) => `${p.value} Uhr` },
      ),
      durationMinutes: fields.integer({ label: "Dauer einer Feier (Minuten)", defaultValue: 150, validation: { isRequired: true, min: 30 } }),
      capacityPerSlot: fields.integer({
        label: "Parallele Feiern je Zeitfenster",
        description: "0 = nicht anzeigen. Belegte Plätze kennt die Website erst mit einem Buchungssystem (Stufe 2).",
        defaultValue: 0,
        validation: { isRequired: true, min: 0 },
      }),
      leadTimeDays: fields.integer({ label: "Vorlauf mindestens (Tage)", defaultValue: 3, validation: { isRequired: true, min: 0 } }),
      maxDaysAhead: fields.integer({ label: "Buchbar höchstens (Tage im Voraus)", defaultValue: 180, validation: { isRequired: true, min: 1 } }),
      note: fields.text({ label: "Interne Notiz", multiline: true }),
    },
  });
}

export default config({
  storage,
  locale: "de-DE",
  ui: {
    brand: { name: "Pepelino – Pflege" },
    navigation: {
      Kiel: ["oeffnungszeitenKiel", "preiseKiel", "geburtstagKiel", "termineKiel", "speisekarteKiel"],
      Westerrönfeld: ["oeffnungszeitenWesterroenfeld", "preiseWesterroenfeld", "geburtstagWesterroenfeld", "termineWesterroenfeld", "speisekarteWesterroenfeld"],
      Allgemein: ["faq"],
    },
  },
  singletons: {
    oeffnungszeitenKiel: oeffnungszeiten(LOCATIONS[0]),
    oeffnungszeitenWesterroenfeld: oeffnungszeiten(LOCATIONS[1]),
    preiseKiel: preise(LOCATIONS[0]),
    preiseWesterroenfeld: preise(LOCATIONS[1]),
    geburtstagKiel: geburtstag(LOCATIONS[0]),
    geburtstagWesterroenfeld: geburtstag(LOCATIONS[1]),
    termineKiel: geburtstagstermine(LOCATIONS[0]),
    termineWesterroenfeld: geburtstagstermine(LOCATIONS[1]),
    speisekarteKiel: speisekarte(LOCATIONS[0]),
    speisekarteWesterroenfeld: speisekarte(LOCATIONS[1]),
    faq: singleton({
      label: "Häufige Fragen",
      path: "src/content/data/faq",
      format: { data: "json" },
      schema: {
        items: fields.array(
          fields.object({
            id: fields.text({ label: "Technischer Schlüssel" }),
            question: fields.text({ label: "Frage" }),
            answer: fields.text({ label: "Antwort", multiline: true }),
            scope: fields.select({
              label: "Gilt für",
              options: [
                { label: "Beide Standorte", value: "global" },
                { label: "Nur Kiel", value: "kiel" },
                { label: "Nur Westerrönfeld", value: "westerroenfeld" },
              ],
              defaultValue: "global",
            }),
            provenance: pruefung(),
          }),
          { label: "Fragen", itemLabel: (p) => p.fields.question.value },
        ),
      },
    }),
  },
});
