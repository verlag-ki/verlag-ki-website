import type { LocationId, Menu, MenuItem } from "./schema";
import { SOURCES, src } from "./sources";

/**
 * Speisen & Getränke – aus den öffentlich eingebundenen Kartenbildern
 * (Upload 10/2025) von Hand transkribiert. Keine Allergene/Zusatzstoffe
 * ergänzt; dafür verweist die Karte selbst auf das Personal.
 * Preise mit `null` sind auf der Karte ohne eindeutige Zuordnung.
 */
const e = (amount: number) => ({ amount, currency: "EUR" as const });
const one = (name: string, amount: number | null, extra: Partial<MenuItem> = {}): MenuItem => ({
  name,
  variants: [{ price: amount === null ? null : e(amount) }],
  ...extra,
});
const sized = (name: string, v: [string, number | null][], extra: Partial<MenuItem> = {}): MenuItem => ({
  name,
  variants: v.map(([size, amount]) => ({ size, price: amount === null ? null : e(amount) })),
  ...extra,
});

const TRANSCRIBED = "Aus Bilddatei transkribiert – Transkription vor Livegang vom Standort prüfen lassen.";
const NOTICES = [
  "Das Mitbringen und der Verzehr eigener Speisen und Getränke ist nicht gestattet.",
  "Fragen zu Allergenen und Zusatzstoffen beantwortet gern unser Team vor Ort.",
];

export const menus: Record<LocationId, Menu> = {
  kiel: {
    location: "kiel",
    notices: NOTICES,
    asOf: "Oktober 2025",
    sourceImages: [
      { label: "Speisekarte Kiel (Bild)", url: SOURCES.menuImgKielFood },
      { label: "Getränkekarte Kiel (Bild)", url: SOURCES.menuImgKielDrinks },
    ],
    provenance: src(SOURCES.menuImgKielFood, "verified_public", TRANSCRIBED),
    sections: [
      {
        id: "snacks",
        title: "Snacks & Hauptgerichte",
        kind: "food",
        items: [
          sized("Chicken Nuggets", [["5 Stück", 3.9], ["9 Stück", 6.9]]),
          sized("Chicken Crossies", [["5 Stück", 4.5], ["9 Stück", 6.9]]),
          sized("Chicken Wings", [["6 Stück", 5.9]]),
          sized("Falafel", [["5 Stück", 3.9]]),
          sized("Wiener Würstchen mit Toast", [["1 Paar", 3.5]]),
          one("Currywurst", 5.5),
          one("Currywurst mit Pommes", 8.5),
        ],
      },
      {
        id: "burger",
        title: "Burger",
        kind: "food",
        items: [one("Hamburger", 4.9), one("Cheeseburger", 5.5), one("Nugget-Burger", 5.5)],
      },
      {
        id: "pizza-pasta",
        title: "Pizza & Spaghetti",
        kind: "food",
        items: [
          one("Pizza Salami, Thunfisch oder Margherita", 6.5, {
            note: "Auf der Karte steht der Preis neben Margherita; Geltung für alle drei Sorten prüfen.",
          }),
          one("Spaghetti ohne Soße", 3.9),
          one("Spaghetti mit Tomatenketchup", 4.5),
          one("Spaghetti Napoli", 4.9, { detail: "vegetarisch" }),
        ],
      },
      {
        id: "beilagen",
        title: "Beilagen & Extras",
        kind: "food",
        items: [
          one("Pommes", 3.9),
          one("Country-Kartoffeln", 4.5),
          one("Dip", 0.5, { detail: "Curry- oder Tomatenketchup, Mayonnaise, Senf, Remoulade" }),
        ],
      },
      {
        id: "backwaren",
        title: "Backwaren & Süßes",
        kind: "food",
        items: [
          one("Laugenbrezel", 2.5),
          one("Torte", 3.9, { detail: "je nach Tagesangebot" }),
          one("Weitere Backwaren", null, { detail: "je nach Tagesangebot" }),
        ],
      },
      {
        id: "kalt",
        title: "Kalte Getränke",
        kind: "drinks",
        items: [
          sized("Coca-Cola, Coca-Cola light, Mezzo Mix, Fanta, Sprite", [["0,3 l", 2.5], ["1 l", 4.9]], {
            note: "Größen-/Preiszuordnung aus dem Kartenlayout abgeleitet.",
          }),
          one("Apfelschorle", null, { note: "Auf der Karte ohne eigenen Preis." }),
          sized("Apfelsaft oder Orangensaft", [["0,2 l", 2.9], ["0,7 l", 5.9]]),
          sized("Wasser classic oder still", [["0,5 l", 1.9], ["1 l", 2.9]]),
          one("Capri-Sonne", 1.5, { detail: "je nach Angebot" }),
          sized("Red Bull", [["0,25 l", 3.9]]),
          sized("Slush", [["0,2 l", 2.5]], { detail: "verschiedene Sorten" }),
          sized("fritz-limo & Bio-Säfte", [["0,3 l", 3.9]], {
            detail: "Limo Orange oder Zitrone; Bio-Apfel-, Trauben-, Rhabarbersaft, Apfel-Kirsch-Holunder",
            note: "Preis steht auf der Karte bei den Bio-Säften; Geltung für alle Sorten prüfen.",
          }),
          sized("Erdinger alkoholfrei", [["0,5 l", 4.9]]),
        ],
      },
      {
        id: "heiss",
        title: "Heiße Getränke",
        kind: "drinks",
        items: [
          sized("Filterkaffee", [["Tasse", 2.5], ["Becher", 3.5], ["Kanne (1 l)", 9.9]]),
          sized("Kaffee Crema", [["Tasse", 2.9], ["Becher", 3.9]]),
          one("Espresso", 2.5),
          one("Milchkaffee", 4.9),
          one("Cappuccino", 3.9),
          one("Schokocino", 3.9),
          one("Latte Macchiato", 4.5),
          one("Kaffeearoma", 0.5, { detail: "je nach Angebot" }),
          one("Weiße Schokolade", 3.5),
          one("Heiße Schokolade", 3.5),
          one("Heiße Schokolade mit Sahne", 3.9),
          one("Becher Milch", 2.5),
          one("Tee", 2.9, { detail: "je nach Angebot" }),
        ],
      },
    ],
  },
  westerroenfeld: {
    location: "westerroenfeld",
    notices: NOTICES,
    asOf: "Oktober 2025",
    sourceImages: [
      { label: "Speisekarte Westerrönfeld (Bild)", url: SOURCES.menuImgRdFood },
      { label: "Getränkekarte Westerrönfeld (Bild)", url: SOURCES.menuImgRdDrinks },
    ],
    provenance: src(SOURCES.menuImgRdFood, "verified_public", TRANSCRIBED),
    sections: [
      {
        id: "snacks",
        title: "Snacks & Hauptgerichte",
        kind: "food",
        items: [
          sized("Chicken Nuggets", [["5 Stück", 3.5], ["9 Stück", 5.9]]),
          sized("Falafel", [["5 Stück", 3.5]]),
          one("Hot Dog", 2.9),
          sized("Wiener Würstchen mit Toast", [["1 Paar", 2.9]]),
          one("Currywurst", 4.9),
          one("Currywurst mit Pommes", 7.9),
        ],
      },
      {
        id: "burger",
        title: "Burger",
        kind: "food",
        items: [one("Hamburger", 4.5), one("Chickenburger", 4.9), one("Cheeseburger", 4.9), one("Nugget-Burger", 4.9)],
      },
      {
        id: "beilagen",
        title: "Beilagen & Extras",
        kind: "food",
        items: [
          one("Kartoffelsalat", 2.9),
          one("Pommes frites", 3.5),
          one("Country-Kartoffeln", 3.9),
          one("Dip", 0.5, { detail: "Ketchup, Mayo, Senf, Remoulade oder Curry-Ketchup" }),
        ],
      },
      {
        id: "backwaren",
        title: "Backwaren & Süßes",
        kind: "food",
        items: [
          one("Laugenbrezel", 1.9),
          one("Muffin", 1.5, { detail: "verschiedene Sorten" }),
          one("Kuchen", 1.9),
          one("Kuchen mit Sahne", 2.5),
        ],
      },
      {
        id: "kalt",
        title: "Kalte Getränke",
        kind: "drinks",
        items: [
          sized("Coca-Cola, Coca-Cola light, Mezzo Mix, Fanta, Sprite", [["0,3 l", 2.5], ["1 l", 4.9]], {
            note: "Größen-/Preiszuordnung aus dem Kartenlayout abgeleitet.",
          }),
          sized("Apfelschorle", [["1 l", 4.9]]),
          sized("Apfelsaft oder Orangensaft", [["0,2 l", 2.9], ["0,7 l", 5.9]]),
          sized("Wasser classic oder still", [["0,5 l", 1.9], ["1 l", 2.9]]),
          one("Capri-Sonne", 1.5, { detail: "je nach Angebot" }),
          sized("Slush", [["0,2 l", 2.5]], { detail: "verschiedene Sorten" }),
        ],
      },
      {
        id: "heiss",
        title: "Heiße Getränke",
        kind: "drinks",
        items: [
          sized("Filterkaffee", [["Tasse", 2.5], ["Becher", 3.5], ["Kanne (1 l)", 9.9]]),
          sized("Kaffee Crema", [["Tasse", 2.5], ["Becher", 3.5]]),
          one("Espresso", 1.9),
          one("Milchkaffee", 3.9),
          one("Cappuccino", 3.5),
          one("Schokocino", 3.5),
          one("Latte Macchiato", 3.9),
          one("Kaffeearoma", 0.5, { detail: "je nach Angebot" }),
          one("Weiße Schokolade", 3.5),
          one("Heiße Schokolade", 3.5),
          one("Heiße Schokolade mit Sahne", 3.9),
          one("Becher Milch", 2.5),
          one("Tee", 2.5, { detail: "je nach Angebot" }),
        ],
      },
    ],
  },
};
