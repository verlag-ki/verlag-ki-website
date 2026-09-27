# Learning App Engine · Version 0.5.0 mit Nachbesserungen (0.5.1)

Drei Punkte sind nach der Übernahme korrigiert. Erstens lief in einer generierten App nur ein Teil der Tests: die übrigen Suiten hingen an AEVO-Zahlen und schlugen mit fremden Daten fehl oder brachen ab, während der Generator sie nicht ausführte. Jetzt sind 54 der 64 Tests paketunabhängig, die restlichen zehn melden ihre AEVO-Bindung und werden übersprungen. Zweitens ist das Entwurfsbanner über Impressum und Datenschutz wieder entfernt; die Release-Sperre prüft den rechtlichen Stand unverändert weiter. Drittens erfasst `Dateipruefsummen.json` wieder alle Dateien. Einzelheiten und Messwerte: `Documentation/PORTABLE_TESTS_0_5_1.md`.

Das bestehende native iOS-Projekt ist zur wiederverwendbaren Lern-App-Basis refaktoriert. Die AEVO-App bleibt das ausgewählte Hauptprojekt. Ihre 800 Aufgaben, 300 Lernkarten, 16 Fälle und 24 Fachgesprächsimpulse sowie alle stabilen Inhalts-IDs sind erhalten.

## Direkt öffnen

Öffne `LearningApp.xcodeproj`, Scheme `AEVOLernen`, Konfiguration `Debug`. Bundle-ID und Produktname der bisherigen AEVO-App sind unverändert. Die alte Projektdatei `AEVO.xcodeproj` wurde durch die generische Projektdatei ersetzt. Vor einem Update einen Backup-Export erstellen und die bestehende App nicht löschen.

## Eine andere App erzeugen

```bash
python3 Scripts/create_learning_app.py --config AppConfigs/orbit-demo.json
```

Voraussetzung: Python 3.10+ und Swift, getestet mit 6.0.3. Der Generator validiert Daten, erzeugt ein isoliertes Xcode-Projekt und führt Tests gegen die ausgewählten Ressourcen aus. Das Demo enthält zehn Fragen, fünf Karten und drei Kategorien. Praxis und Trinkgeld sind dort deaktiviert. Kein Paketwechsel und keine Entwicklerverwaltung in der Nutzeroberfläche.

## Die wichtigen Dateien

- `NEW_APP_GUIDE.md`: vollständiger Entwicklerablauf und genaue Dateiliste
- `CONTENT_PACK_SCHEMA.md` und `Schemas/`: verbindlicher Datenvertrag
- `CONTENT_PACK_PROMPT.md`: Masterprompt für neue Content-Packs durch ChatGPT Work
- `ContentPacks/aevo-de/`: kanonische AEVO-Inhalte
- `ContentPacks/demo-orbit/`: technisch lauffähiges, fiktives Demo
- `ContentPacks/_template/`: absichtlich leere Vorlage
- `AppConfigs/`: App-Namen, Markenressourcen, Module, Kennungen und Anbietertexte
- `Documentation/REFACTORING_0_5_0.md`: Bestandsanalyse, Architektur und Migration
- `Documentation/NATIVE_ACCEPTANCE_0_5_0.md`: noch durchzuführende native Abnahme

## Prüfstand

64 Swift-Kerntests und 16 Python-Tests bestanden. Sie prüfen unter anderem beide Pakete, stabile IDs, echte 0.4.0-Backups, Swipes, Wiederholung, konfigurierbare Prüfungen, ungültige Daten und den Schutz vorhandener Generatorausgaben. Die Syntax aller 22 App-Dateien und die ausgewählte Projektstruktur sind geprüft. Details und Protokolle liegen in `Documentation/`.

Ein Apple-SDK-Typecheck, Simulator-Build und iPhone-Test dieser Refaktorierung wurden hier nicht ausgeführt. Das Xcode-Projekt ist vorbereitet, kein signiertes Installationspaket. Die weiterhin offenen rechtlichen Informationen und öffentlichen URLs bleiben eine gesonderte Release-Voraussetzung; das Demo besitzt keine fachliche Freigabe.

Ältere Entwicklungsnotizen liegen unter `Documentation/README_bis_0_4_0.md`. Bei Widersprüchen gelten diese Version und der neue Guide.
