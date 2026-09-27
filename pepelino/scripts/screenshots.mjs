// Erstellt ganzseitige Screenshots (1440×900 und 390×844) gegen einen laufenden Server.
// Nutzung: node scripts/screenshots.mjs [baseUrl] [outDir] [pfad1 pfad2 ...]
import { chromium } from "@playwright/test";
import fs from "node:fs";

const [base = "http://localhost:3100", out = "docs/screenshots", ...paths] = process.argv.slice(2);
const routes = paths.length ? paths : ["/"];
fs.mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ args: ["--no-proxy-server"] });
for (const [name, vp, mobile] of [["desktop", { width: 1440, height: 900 }, false], ["mobile", { width: 390, height: 844 }, true]]) {
  const ctx = await browser.newContext({ locale: "de-DE", timezoneId: "Europe/Berlin", viewport: vp, deviceScaleFactor: mobile ? 2 : 1, isMobile: mobile, hasTouch: mobile });
  const page = await ctx.newPage();
  for (const r of routes) {
    await page.goto(base + r, { waitUntil: "load" });
    await page.evaluate(async () => {
      for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 60)); }
      window.scrollTo(0, 0);
    });
    await page.waitForTimeout(300);
    const slug = r === "/" ? "startseite" : r.replace(/^\/|\/$/g, "").replace(/\//g, "_");
    await page.screenshot({ path: `${out}/${slug}-${name}.png`, fullPage: true });
    console.log("saved", `${out}/${slug}-${name}.png`);
  }
  await ctx.close();
}
await browser.close();
