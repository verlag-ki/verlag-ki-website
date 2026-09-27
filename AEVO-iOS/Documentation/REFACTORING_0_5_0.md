# Architektur und kontrollierte Migration 0.5.0

Stand: 21. September 2026. Ausgangspunkt ist das vorhandene Projekt 0.4.0, kein Neubau.

## Bestandsanalyse und Entscheidungen

| Bereich | Vorher | Refactoring |
|---|---|---|
| Fragen, Auswahl, exakte Bewertung | Bereits generisch; Themen auf 1 bis 4 begrenzt | Grenzen entfernt; expliziter Single-/Multiple-Choice-Typ mit Altdatenkompatibilität |
| Karten, Swipe, Wiederholung | Generische IDs und lokale Zustände | Beibehalten; Karten kommen aus dem gewählten Pack |
| Fachlicher Katalog | catalog.json, practice.json; zusätzliche Texte in Swift | ContentPacks mit manifest, Lernzielen, Quellen, Fragen, Karten, Praxis und Lernimpulsen |
| Themenansichten und Abzeichen | Vier feste Handlungsfelder | Kategorien aus Manifest; Fortschritt bleibt ID-basiert |
| Prüfung | 80 Aufgaben, 180 Minuten, Quoten 12/18/38/12, exakte Auswertung | ExamConfig mit Auswahl, Gewichtung, Dauer, Bestehensgrenze, Navigation, Antwortänderung, Timer und Ergebnisdarstellung |
| Praxisplanung | AEVO-Felder und Texte im Swift-Code | Datengetriebenes Formular, optionale Fälle und mündliche Aufgaben |
| Onboarding, Farben, Alltag | Größtenteils generisch | Markenname, Einstieg und Fachbegriffe konfiguriert; acht Farbwelten erhalten |
| Hilfe, Zitate, Exporttitel | Fachbezogene Texte in Swift | experience.json, Praxisformular und AppConfig |
| Speicherung | SwiftData StoredSnapshot, Schlüssel current, JSON-Schema 1 | Modell unverändert; optionale App-/Pack-Kennungen und ExamConfig-Snapshot ergänzt |
| Backup | AEVO-Format, keine Paketkennung | Neues generisches Format, ausdrücklich zugelassene Altdatenmigration und Trennung fremder Packs |
| Apple-Dienste | Native StoreKit-, Bewertungs- und Mitteilungsintegration | Vorhandene Dienste weiterverwendet; Kennungen, Texte und sichtbare Module konfiguriert |
| Xcode-Projekt | Festes AEVO-Projekt und Produkte | Generator mit isolierter Ausgabe und konfiguriertem Namen, Bundle-ID, Ressourcen, Icon und Produktkennungen |

Der Foundation-Kern heißt jetzt `LearningCore`. Das App-Produkt für AEVO heißt weiterhin `AEVOLernen`, die Bundle-ID bleibt `de.juliankuerten.aevo`. Damit bleibt auch der Modulkontext der unveränderten SwiftData-Klasse `StoredSnapshot` erhalten. Projektname und Scheme werden nicht mit der Identität der installierten App verwechselt.

## Aufbau

`Core/` enthält Auswahl, Lernen, Wiederholung, Fortschritt, Prüfung, Paketmodelle und Datenmigration. `App/` enthält die gemeinsame SwiftUI-Oberfläche und Apple-Dienste. `AppConfigs/` enthält Marken- und Anbieterkonfiguration. `ContentPacks/` ist die redaktionelle Quelle. `Core/Resources/SelectedPack` ist nur die gewählte, erzeugte Ressourcenfassung. Sie wird nicht von Hand redaktionell geändert.

Ein Binary lädt genau ein Paket. Es gibt keine Paketverwaltung, keinen Downloadmarkt und keinen Importdialog für Fachinhalte in der Nutzeroberfläche. Die Daten werden mit dem App-Update geliefert. Paketwechsel und das Erzeugen weiterer Apps sind ausschließlich Entwicklerarbeiten.

Die bestehende Praxisplanung nutzt für ihre sieben bisherigen Eingaben weiterhin dieselben Speicherfelder. Weitere frei definierte Formularfelder nutzen das vorhandene Wörterbuch `practiceDetails`. So bleiben alte Texte erhalten und neue Fachgebiete können andere Formularfragen verwenden. Eine echte neue Prüfungsform wie Freitextkorrektur oder eine Grafikaufgabe wäre eine spätere Engine-Erweiterung, kein konfigurierbarer Multiple-Choice-Typ.

## Refactoring-Reihenfolge

1. Vorhandene Dateien, Fachbezüge, feste Zahlen, Ressourcen, Dienste und Tests analysiert.
2. Vorhandene Inhalte unverändert ausgegliedert, stabile IDs und Originalkatalog als Migrationsnachweis erhalten.
3. AppConfig, ContentPack, Validator und konfigurierbares ExamConfig eingebaut.
4. Fachtexte und Modulnavigation auf die ausgewählten Daten umgestellt.
5. Backup-Zuordnung, Prüfungssnapshots und echten Altbestand getestet.
6. Demo und Generator erstellt, Vorlagen und Agentenworkflow dokumentiert.

## Nutzerdaten und Migration

Vor dem Update bleibt ein freiwilliger Sicherungsexport sinnvoll. Nicht deinstallieren, dieselbe Bundle-ID und dasselbe Produkt weiterverwenden. Es wird weder ein neuer SwiftData-Speicherort gewählt noch ein Datenbankfehler mit einem leeren Lernstand überschrieben.

Eine alte, ungebundene AEVO-Sicherung wird nur beim dafür ausdrücklich konfigurierten AEVO-Pack angenommen. Inhaltszuordnungen werden geprüft. Danach enthalten lokale Daten und neue Sicherungen App- und Pack-Kennung. Ein anderes Pack erhält sie nicht. Eigene Kartentexte, offene Bearbeitungsentwürfe, Notizen, Antworten, Wiederholungen, Markierungen, Abzeichen, Termine, Profil und Einstellungen bleiben bestehen.

Laufende alte Simulationen behalten Fragen, Antworten und Frist. Die fehlenden Prüfungsregeln werden aus dem AEVO-Profil ergänzt. Neue Versuche speichern ihre Regeln als Snapshot, damit spätere Inhaltsupdates alte Auswertungen nicht still verändern. Bei einer veränderten Zeitbasis bleibt der Versuch als zeitlich nicht vergleichbar markiert. Ein nicht sauber beendeter Versuch mit pausierbarer Zeit wird nach Neustart ebenfalls entsprechend markiert.

`Tests/Fixtures/legacy-0.4.0-backup.json` wurde mit dem unveränderten Code der Version 0.4.0 erzeugt. Sie enthält ausschließlich synthetische Testdaten und prüft echte Formatkompatibilität.

## Fachliche Freigaben

Die vorhandene Bestätigung des Auftraggebers bleibt erhalten. Die strukturelle Migration ergänzt lediglich den zuvor impliziten Aufgabentyp und die Inhaltsversion der mündlichen Aufgaben. Alte und neue Inhaltsprüfsummen sowie die Transformationsbeschreibung stehen im AEVO-Approval-Datensatz. Es wurde kein neuer fachlicher Prüfer oder neuer fachlicher Prüftermin erfunden. Änderungen an fachlichen Texten passen nicht mehr zur Freigabeprüfsumme.

## Grenzen und Abnahme

Der automatisierte Nachweis betrifft Foundation-Logik, Ressourcen, Dateischemas, Migration und Projekterzeugung. Ein erfolgreicher Linux-Lauf ist kein iOS-Build. SwiftUI, SwiftData auf dem Gerät, Gesten, Mitteilungen, VoiceOver und echte Käufe werden auf dem Mac beziehungsweise iPhone geprüft. `NATIVE_ACCEPTANCE_0_5_0.md` beschreibt die konkreten Schritte.

Die erste Schemageneration unterstützt Single und Multiple Choice, ein konfiguriertes schriftliches Simulationsprofil, einen optionalen zweiten Prüfungstermin, optionale Formularplanung, verzweigte Fälle und mündliche Impulse. Sie behauptet keine beliebige Prüfungssoftware ohne weitere Entwicklung.
