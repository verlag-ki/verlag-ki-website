// Baut eine statische Vorschau für einen Unterordner, z. B. verlag-ki.de/pepelino
//   npm run build:static        (= node scripts/build-static.mjs /pepelino)
// Ergebnis: dist-static/pepelino/ und dist-static/pepelino.zip
// → Inhalt auf dem Webserver in den Ordner /pepelino/ kopieren.
//
// Server-Funktionen (Pflegebereich, API, Weiterleitungs-Proxy) werden für den
// Bau kurz beiseitegelegt und danach IMMER wiederhergestellt.
import { execSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const basePath = process.argv[2] ?? "/pepelino";
const root = path.resolve(import.meta.dirname, "..");
const stash = path.join(root, ".static-stash");
const moves = ["src/app/keystatic", "src/app/api", "src/proxy.ts", "src/lib/forms/actions.ts"];
const revalidateFiles = execSync("grep -rl 'export const revalidate' src/app || true", { cwd: root }).toString().split("\n").filter(Boolean);

if (fs.existsSync(stash)) throw new Error(".static-stash existiert noch – vorherigen Abbruch prüfen und Dateien zurückkopieren.");
fs.mkdirSync(stash);
try {
  for (const p of [...moves, ...revalidateFiles]) {
    fs.mkdirSync(path.dirname(path.join(stash, p)), { recursive: true });
    fs.cpSync(path.join(root, p), path.join(stash, p), { recursive: true });
  }
  for (const p of moves) fs.rmSync(path.join(root, p), { recursive: true, force: true });
  fs.copyFileSync(path.join(root, "scripts/static/actions.client.ts"), path.join(root, "src/lib/forms/actions.ts"));
  for (const f of revalidateFiles) {
    const file = path.join(root, f);
    fs.writeFileSync(file, fs.readFileSync(file, "utf8").replace(/\n\/\/ Sonderzeiten laufen ab:.*\nexport const revalidate = \d+;\n/, "\n"));
  }
  fs.rmSync(path.join(root, ".next-static"), { recursive: true, force: true });
  execSync("npx next build", {
    cwd: root,
    stdio: "inherit",
    env: { ...process.env, STATIC_EXPORT: "1", NEXT_PUBLIC_BASE_PATH: basePath, NEXT_TELEMETRY_DISABLED: "1" },
  });
} finally {
  for (const p of [...moves, ...revalidateFiles]) {
    fs.rmSync(path.join(root, p), { recursive: true, force: true });
    fs.cpSync(path.join(stash, p), path.join(root, p), { recursive: true });
  }
  fs.rmSync(stash, { recursive: true, force: true });
}

const name = basePath.replace(/^\//, "") || "site";
fs.rmSync(path.join(root, "dist-static"), { recursive: true, force: true });
fs.mkdirSync(path.join(root, "dist-static"));
// Mit eigenem distDir schreibt Next.js die statische Ausgabe direkt dorthin.
fs.renameSync(path.join(root, ".next-static"), path.join(root, "dist-static", name));
execSync(`zip -qr ${name}.zip ${name}`, { cwd: path.join(root, "dist-static") });
console.log(`\nFertig: dist-static/${name}/ und dist-static/${name}.zip`);
