import type { MediaAsset } from "./schema";
import { SOURCES } from "./sources";

/**
 * Motiv-Slots der Vorschau.
 *
 * WICHTIG: Alle Fotos stammen von der öffentlichen Website pepelino-fun.de.
 * Ihre Nutzung im Relaunch ist NICHT freigegeben (rightsStatus
 * "public_website_unverified"). Laut Impressum stammen Bilder teils aus
 * Envato Elements; eine Zuordnung einzelner Dateien ist offen.
 * Vor einem Livegang jedes Motiv prüfen oder ersetzen – Datei unter
 * public/images/media/ austauschen und hier Maße/Alt-Text/Status pflegen.
 */
const UP = "https://www.pepelino-fun.de/wp-content/uploads";
const DEMO = "Nur interne Layout-Vorschau; Nutzungsrecht für den Relaunch ungeklärt";

export const media = {
  logo: {
    id: "logo",
    src: "/brand/pepelino-logo.png",
    width: 1020,
    height: 796,
    alt: "Pepelino Spieleparadies",
    motif: "Pepelino-Logo mit Figur",
    location: null,
    origin: "client",
    rightsStatus: "client_provided",
    usageScope: "Vom Auftraggeber am 26.09.2026 zur Verwendung übergeben",
  },
  heroKlettervulkan: {
    id: "heroKlettervulkan",
    src: "/images/media/kiel-klettervulkan-hero.webp",
    width: 1600,
    height: 1067,
    alt: "Kinder klettern den bunten Klettervulkan im Pepelino Kiel hinauf",
    motif: "Klettervulkan Kiel",
    location: "kiel",
    origin: `${UP}/2021/02/Klettervulkan-Pepelino-1-scaled.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
    objectPosition: "50% 60%",
  },
  kielKlettervulkan: {
    id: "kielKlettervulkan",
    src: "/images/media/kiel-klettervulkan.webp",
    width: 1020,
    height: 680,
    alt: "Klettervulkan mit Rutsche in der Halle in Kiel",
    motif: "Klettervulkan mit High-Speed-Rutsche",
    location: "kiel",
    origin: `${UP}/2021/02/Klettervulkan-Pepelino2-1-scaled-e1614360806733.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielTrampolin: {
    id: "kielTrampolin",
    src: "/images/media/kiel-bungee-trampolin.webp",
    width: 1020,
    height: 680,
    alt: "Durch Netze getrennte Trampoline mit Bungee-Gestellen in Kiel",
    motif: "Bungee-Trampoline",
    location: "kiel",
    origin: `${UP}/2021/02/Bungee-Trampolin-scaled-e1614239140702.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielBumper: {
    id: "kielBumper",
    src: "/images/media/kiel-bumper-cars.webp",
    width: 1020,
    height: 680,
    alt: "Bunte Bumper Cars unter der Kletterlandschaft in Kiel",
    motif: "Bumper Cars",
    location: "kiel",
    origin: `${UP}/2021/02/Bumper-1-scaled-e1614359922189.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielBaellebad: {
    id: "kielBaellebad",
    src: "/images/media/kiel-baellebad.webp",
    width: 1020,
    height: 680,
    alt: "Bällebad vor der großen Spiellandschaft im Pepelino Kiel",
    motif: "Bällebad und Spiellandschaft",
    location: "kiel",
    origin: `${UP}/2021/02/Standort-Titelbild-Pepelino-scaled-e1614191433283.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielHochseil: {
    id: "kielHochseil",
    src: "/images/media/kiel-hochseilgarten.webp",
    width: 1020,
    height: 680,
    alt: "Rollenrutsche und Kletterparcours im Kletterpark Kiel",
    motif: "Kletterpark / Hochseilgarten",
    location: "kiel",
    origin: `${UP}/2021/02/hochseilgarten-scaled-e1614361141555.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielKleinkind: {
    id: "kielKleinkind",
    src: "/images/media/kiel-kleinkinderbereich.webp",
    width: 1020,
    height: 680,
    alt: "Weicher Kleinkinderbereich mit Softbausteinen in Kiel",
    motif: "Kleinkinderbereich",
    location: "kiel",
    origin: `${UP}/2021/02/kleinkinder1-scaled-e1614361279860.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielKabinen: {
    id: "kielKabinen",
    src: "/images/media/kiel-geburtstagskabinen.webp",
    width: 1020,
    height: 765,
    alt: "Geburtstagskabinen mit Weltraum-Wandbild im Pepelino Kiel",
    motif: "Geburtstagskabinen",
    location: "kiel",
    origin: `${UP}/2021/02/Geburtstagskabinen-bei-pepelino-1-scaled-e1614337820863.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  kielNische: {
    id: "kielNische",
    src: "/images/media/kiel-geburtstagsnische.webp",
    width: 1020,
    height: 680,
    alt: "Gedeckter Geburtstagstisch in einer Nische in Kiel",
    motif: "Geburtstagsnische",
    location: "kiel",
    origin: `${UP}/2021/03/Geburtstagsnische-1-scaled-e1615126348248.jpg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdKletter: {
    id: "rdKletter",
    src: "/images/media/rd-kletterlandschaft.webp",
    width: 1400,
    height: 1050,
    alt: "Große Kletterlandschaft in der Halle in Westerrönfeld",
    motif: "Kletterlandschaft Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.03-9.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdFahrzeuge: {
    id: "rdFahrzeuge",
    src: "/images/media/rd-kinderfahrzeuge.webp",
    width: 1400,
    height: 1050,
    alt: "Kinderfahrzeuge auf der Fahrbahn in Westerrönfeld",
    motif: "Fahrzeugbahn Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.03-3.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdHuepfburg: {
    id: "rdHuepfburg",
    src: "/images/media/rd-huepfburg.webp",
    width: 1400,
    height: 1050,
    alt: "Hüpfburg mit Palmen-Motiv in Westerrönfeld",
    motif: "Hüpfburg Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.03-11.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdGeburtstag: {
    id: "rdGeburtstag",
    src: "/images/media/rd-geburtstagsbereich.webp",
    width: 1400,
    height: 1050,
    alt: "Spielbereich mit Happy-Birthday-Girlande in Westerrönfeld",
    motif: "Geburtstagsbereich Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.03-5.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdGastro: {
    id: "rdGastro",
    src: "/images/media/rd-gastronomie.webp",
    width: 1400,
    height: 1050,
    alt: "Bunte Sitzplätze im Gastronomiebereich in Westerrönfeld",
    motif: "Gastronomie Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.04-2.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
  rdTrampolin: {
    id: "rdTrampolin",
    src: "/images/media/rd-trampolin.webp",
    width: 1400,
    height: 1050,
    alt: "Trampolinfeld in Gelb, Rot und Schwarz in Westerrönfeld",
    motif: "Trampoline Westerrönfeld",
    location: "westerroenfeld",
    origin: `${UP}/2025/01/WhatsApp-Image-2025-01-17-at-13.47.03-14.jpeg`,
    rightsStatus: "public_website_unverified",
    usageScope: DEMO,
  },
} satisfies Record<string, MediaAsset>;

export type MediaKey = keyof typeof media;

export function getMedia(key: string): MediaAsset {
  const asset = (media as Record<string, MediaAsset>)[key];
  if (!asset) throw new Error(`Unbekanntes Medium: ${key}`);
  return asset;
}

export const MEDIA_SOURCE_PAGES = [SOURCES.kiel, SOURCES.rd, SOURCES.home];
