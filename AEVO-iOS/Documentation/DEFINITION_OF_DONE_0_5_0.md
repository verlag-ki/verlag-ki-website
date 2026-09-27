# Abgleich mit dem Auftrag

Stand: 21. September 2026. Die Refaktorierung ist implementiert und im verfügbaren Linux-System automatisiert geprüft. Die vollständige native Abnahme erfordert einen funktionierenden Mac mit Xcode.

| Anforderung | Status und Beleg |
|---|---|
| 1. Bestehende AEVO-App funktioniert weiterhin | Kernfunktionen und Ressourcen bestanden; Projekt vorbereitet. SwiftUI-Build, Installation als Update und Geräteabläufe sind noch nicht nachgewiesen. |
| 2. AEVO-Inhalte werden aus einem austauschbaren Pack geladen | Erfüllt. Canonical `ContentPacks/aevo-de`, ausgewählte Bundle-Ressourcen; 800 Fragen und 300 Karten vollständig geladen. |
| 3. Fachbezogene Konfiguration aus der Engine entfernt | Erfüllt im vereinbarten Umfang. Namen, Kategorien, Regeln, Fachtexte, Praxisformular und Module sind Daten. Einige alte interne Speicherschlüssel bleiben zur Kompatibilität bestehen. |
| 4. Zweites Pack ohne Engine-Änderung funktioniert | Automatisiert erfüllt. Orbit mit zehn Fragen, fünf Karten und drei Kategorien, andere Regeln, keine Praxis. Identische Swift-Quellen in beiden generierten Apps. Native Darstellung noch zu prüfen. |
| 5. Validator verarbeitet beide Packs | Erfüllt durch Python- und Swift-Validierung sowie Negativtests. JSON-Schemas zusätzlich unabhängig geprüft. |
| 6. Dokumentierter Weg für eine neue App | Erfüllt. Generator erstellt nach Validierung und Laufzeittests ein eigenes Xcode-Projekt; keine Veröffentlichung oder automatische Registrierung. |
| 7. Alte Nutzerdaten bleiben migrierbar | Formatmigration anhand einer vom Originalcode 0.4.0 erzeugten Sicherung bestanden. SwiftData-Modell, Speicherort und AEVO-Produktidentität erhalten. Tatsächliches Geräteupdate noch zu prüfen. |
| 8. Automatisierte Tests bestanden | 64 Swift-Tests, 16 Python-Tests und beide Generatorläufe mit je zwei Laufzeittests bestanden. Apple-SDK-Tests nicht verfügbar. |
| 9. NEW_APP_GUIDE.md vorhanden | Erfüllt; enthält Dateiliste, Befehle und Pflegeablauf. |
| 10. CONTENT_PACK_PROMPT.md vorhanden | Erfüllt; Masterprompt mit Recherche, Schema, Quellen, Qualitätsprüfung und Lieferung. |

Für den verbleibenden Nachweis `LearningApp.xcodeproj` auf dem Mac öffnen oder den Generator mit `--build-ios` ausführen. Danach die zehn Schritte aus `NATIVE_ACCEPTANCE_0_5_0.md` durchführen. Das bestehende AEVO-Angebot dabei aktualisieren und nicht deinstallieren.

Eine automatische fachliche Freigabe neuer Packs, beliebige neue Aufgabentypen, Live-Inhaltsimporte und eine Store-Veröffentlichung gehören nicht zu diesem technischen Nachweis. Die normale App erhält keine Entwicklerverwaltung.
