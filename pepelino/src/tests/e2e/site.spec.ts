import { expect, test } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const ROUTES = [
  "/",
  "/indoorspielplatz-kiel/",
  "/indoorspielplatz-rendsburg/",
  "/kindergeburtstag-kiel/",
  "/kindergeburtstag-rendsburg/",
  "/kinderspieleparadies-kiel/",
  "/kinderspieleparadies-rendsburg/",
  "/gruppenanmeldung-schulklassen/",
  "/indoorspielplatz-in-der-naehe/",
  "/speisekarte-fuer-qr-code/",
  "/speisekarte-qr-code-rd/",
  "/impressum/",
  "/datenschutzerklaerung/",
  "/schutz-und-hygienekonzept/",
];

for (const route of ROUTES) {
  test(`Route ${route}: erreichbar, eine H1, Metadaten, kein horizontales Scrollen`, async ({ page }) => {
    const res = await page.goto(route);
    expect(res?.status()).toBe(200);
    await expect(page.locator("h1")).toHaveCount(1);
    const title = await page.title();
    expect(title.length).toBeGreaterThan(10);
    const desc = await page.locator('meta[name="description"]').getAttribute("content");
    expect(desc && desc.length).toBeGreaterThan(50);
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute("href", /^https:\/\/www\.pepelino-fun\.de\//);
    // Staging: nicht indexierbar
    await expect(page.locator('meta[name="robots"]')).toHaveAttribute("content", /noindex/);
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    expect(overflow).toBeLessThanOrEqual(0);
    // Alle Bilder haben ein alt-Attribut
    const missingAlt = await page.locator("img:not([alt])").count();
    expect(missingAlt).toBe(0);
  });

  test(`Route ${route}: axe WCAG 2.2 AA ohne Verstöße`, async ({ page }) => {
    await page.goto(route);
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"]).analyze();
    const summary = results.violations.map((v) => `${v.id} (${v.impact}): ${v.nodes.length}× – ${v.nodes[0]?.target.join(" ")}`);
    expect(summary, summary.join("\n")).toEqual([]);
  });
}

test("interne Links führen nicht ins Leere", async ({ page, request }) => {
  const seen = new Set<string>();
  for (const route of ROUTES) {
    await page.goto(route);
    const hrefs = await page.locator("a[href^='/']").evaluateAll((as) => as.map((a) => (a as HTMLAnchorElement).getAttribute("href")!));
    for (const h of hrefs) seen.add(h.split("#")[0]);
  }
  for (const h of seen) {
    const res = await request.get(h);
    expect(res.status(), h).toBe(200);
  }
});

test("alte Anmelde-URL leitet auf Geburtstag Kiel weiter", async ({ page }) => {
  await page.goto("/kindergeburtstaganmeldung/");
  await expect(page).toHaveURL(/\/kindergeburtstag-kiel\/$/);
});

test("404-Seite", async ({ page }) => {
  const res = await page.goto("/gibt-es-nicht/");
  expect(res?.status()).toBe(404);
  await expect(page.locator("h1")).toContainText("niemand zum Spielen");
});

test("robots.txt sperrt die Vorschau, Sitemap listet Kernseiten", async ({ request }) => {
  expect(await (await request.get("/robots.txt")).text()).toMatch(/Disallow: \//);
  const sm = await (await request.get("/sitemap.xml")).text();
  expect(sm).toContain("/indoorspielplatz-kiel/");
  expect(sm).not.toContain("speisekarte-fuer-qr-code");
});

test("JSON-LD: LocalBusiness ohne Bewertungen, BreadcrumbList vorhanden", async ({ page }) => {
  await page.goto("/indoorspielplatz-kiel/");
  const blocks = await page.locator('script[type="application/ld+json"]').allTextContents();
  const data = blocks.flatMap((b) => {
    const j = JSON.parse(b);
    return Array.isArray(j) ? j : [j];
  });
  const biz = data.find((d) => Array.isArray(d["@type"]) && d["@type"].includes("LocalBusiness"));
  expect(biz.address.streetAddress).toBe("Göteborgring 83");
  expect(biz.openingHoursSpecification.length).toBe(2);
  expect(JSON.stringify(data)).not.toMatch(/aggregateRating|review/i);
  // strittige Telefonnummer wird nicht ausgezeichnet
  expect(biz.telephone).toBeUndefined();
  expect(data.some((d) => d["@type"] === "BreadcrumbList")).toBe(true);
});

test("Geburtstagsformular: Fehler bei leerem Absenden, Demo-Hinweis bei gültigen Daten", async ({ page }) => {
  await page.goto("/kindergeburtstag-kiel/");
  const form = page.locator("#anfrage form");
  await form.getByRole("button", { name: /Anfrage prüfen/ }).click();
  await expect(form.getByRole("alert")).toContainText("Bitte prüft");
  await expect(form.locator("[aria-invalid=true]").first()).toBeFocused();

  const d = new Date(Date.now() + 14 * 864e5).toISOString().slice(0, 10);
  await form.getByLabel("Pepe Large").check();
  await form.getByLabel(/Kabine oder Nische/).selectOption("kiel-kabine");
  await form.getByLabel(/Vorname des Geburtstagskindes/).fill("Mia");
  await form.getByLabel(/Alter, das gefeiert wird/).fill("7");
  await form.getByLabel(/Wunschdatum/).fill(d);
  await form.getByLabel(/Gewünschte Startzeit/).selectOption("14:00");
  await form.getByLabel(/Anzahl Kinder/).fill("8");
  await form.getByLabel(/Anzahl Erwachsene/).fill("2");
  await form.getByLabel(/Vor- und Nachname/).fill("Alex Beispiel");
  await form.getByLabel(/^E-Mail/).fill("alex@example.org");
  await form.getByLabel(/^Telefon/).fill("0431 123456");
  await form.getByLabel(/Datenschutzhinweise/).check();
  await form.getByRole("button", { name: /Anfrage prüfen/ }).click();
  await expect(form.getByRole("status")).toContainText("Demo: Diese Anfrage wurde nicht an Pepelino gesendet.");
});

test("Westerrönfeld-Formular bietet keine Kabine/Nische an", async ({ page }) => {
  await page.goto("/kindergeburtstag-rendsburg/");
  await expect(page.locator("#anfrage form select[name=addonId]")).toHaveCount(0);
  await expect(page.locator("#anfrage form input[name=packageId]")).toHaveCount(3);
});

test("Paketkarte wählt Paket im Formular vor", async ({ page }) => {
  await page.goto("/kindergeburtstag-rendsburg/");
  await page.getByRole("link", { name: "Pepe Large anfragen" }).click();
  await expect(page.locator('input[name=packageId][value="rd-large"]')).toBeChecked();
});

test("Google Maps lädt erst nach Klick", async ({ page }) => {
  const google: string[] = [];
  page.on("request", (r) => r.url().includes("google.") && google.push(r.url()));
  await page.goto("/indoorspielplatz-in-der-naehe/");
  await expect(page.locator("iframe")).toHaveCount(0);
  expect(google).toEqual([]);
  await page.route(/google\./, (r) => r.fulfill({ status: 200, body: "" }));
  await page.getByRole("button", { name: "Karte laden" }).first().click();
  await expect(page.locator("iframe")).toHaveCount(1);
});

test("Mobiles Menü per Tastatur bedienbar", async ({ page, isMobile }) => {
  test.skip(!isMobile, "nur mobil");
  await page.goto("/");
  const toggle = page.getByRole("button", { name: "Menü öffnen" });
  await toggle.focus();
  await page.keyboard.press("Enter");
  await expect(page.getByRole("navigation", { name: "Mobile Navigation" })).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(page.getByRole("navigation", { name: "Mobile Navigation" })).toBeHidden();
});
