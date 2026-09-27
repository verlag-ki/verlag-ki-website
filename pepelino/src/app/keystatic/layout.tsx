import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { cmsEnabled } from "@/lib/cms/enabled";
import KeystaticApp from "./keystatic";

export const metadata: Metadata = { title: "Pflegebereich", robots: { index: false, follow: false } };

export default function KeystaticLayout() {
  if (!cmsEnabled) notFound();
  return <KeystaticApp />;
}
