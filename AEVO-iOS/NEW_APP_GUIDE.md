# Eine weitere Lern-App aus derselben Engine erstellen

Die Quellcodebasis ist `Core/` plus `App/`. Inhalte und Marke werden separat gepflegt. Änderungen an der Engine erfolgen hier und werden anschließend für die gewünschte App neu erzeugt. Die Ausgabe unter `Generated/` ist ein vorbereiteter Snapshot, keine neue unabhängige Quellcodebasis. Dort nicht dauerhaft weiterentwickeln.

## Sofort mit vorhandenen Paketen

Voraussetzungen: Python 3.10 oder neuer und eine Swift-Toolchain mit Unterstützung für das enthaltene Swift-Paket, getestet mit Swift 6.0.3. Unter macOS bringt Xcode die Swift-Werkzeuge mit. Es werden keine zusätzlichen Python-Pakete benötigt.

```bash
python3 Scripts/create_learning_app.py --config AppConfigs/aevo.json
python3 Scripts/create_learning_app.py --config AppConfigs/orbit-demo.json
```

Der Befehl validiert Paket und Konfiguration, prüft Ressourcenpfade, kopiert dieselbe Engine in einen isolierten Ausgabeordner, setzt Namen, Bundle-ID, Icon, Storetexte, Rechteinformationen und StoreKit-Testprodukte, erzeugt `LearningApp.xcodeproj` und führt Swift-Tests gegen genau das ausgewählte Ressourcenpaket aus. Erst ein erfolgreicher Lauf liefert den fertigen Ausgabeordner.

Standardausgabe ist `Generated/<appId>/`. Ein vorhandener Zielordner wird nie überschrieben. Für die nächste Version:

```bash
python3 Scripts/create_learning_app.py --config AppConfigs/aevo.json --output Generated/aevo-naechster-stand
```

Falls Swift nicht im PATH liegt, `--swift /vollstaendiger/Pfad/zu/swift` angeben oder `LEARNING_SWIFT` setzen. Fehlt Swift, meldet das Skript den fehlenden Testschritt und gibt keinen angeblich getesteten Projektstand aus.

Auf einem funktionierenden Mac lässt sich zusätzlich der unsignierte Simulator-Build auslösen:

```bash
python3 Scripts/create_learning_app.py --config AppConfigs/aevo.json --output Generated/aevo-simulator --build-ios
```

Der Generator meldet im `GenerationReport.json`, welche Tests ausgeführt wurden und ob ein nativer Build erfolgte. Er registriert keine Bundle-ID, legt keine Storeprodukte an und veröffentlicht keine App. In Xcode das passende eigene Team wählen und die Geräteabnahme durchführen.

## Neues Fachgebiet hinzufügen

1. `ContentPacks/_template/` nach `ContentPacks/neue-pruefung/` kopieren. Die Vorlage ist absichtlich unvollständig. Das vollständig funktionierende `demo-orbit` zeigt Syntax und Verknüpfungen.
2. Prüfung und Inhalte anhand offizieller Quellen recherchieren. Das Schema und `CONTENT_PACK_PROMPT.md` an ChatGPT Work geben. Kein Kopieren geschützter Fragenkataloge.
3. Alle Dateien gemäß `CONTENT_PACK_SCHEMA.md` ausfüllen. IDs stabil wählen, Quellen und Versionsstand dokumentieren. AEVO-spezifische Daten oder Freigaben niemals als Vorlage einer bereits bestätigten anderen Prüfung ausgeben.
4. `AppConfigs/_template.json` nach `AppConfigs/neue-pruefung.json` kopieren. Name, Produktname, eindeutige Bundle-ID, Pack-ID, Terminologie, Module, Defaultfarbe, Kennungen und URLs anpassen.
5. `AppConfigs/neue-pruefung/` anlegen: eigene `legal.json`, `store.json` und `AppIcon.appiconset`. Das Icon-Asset enthält Contents.json und die zugehörigen Bilddateien. Storetexte und Screenshottexte sind austauschbar; echte Screenshots werden später von der erzeugten App aufgenommen.
6. Validieren und erzeugen:

```bash
python3 Scripts/validate_content_pack.py ContentPacks/neue-pruefung --config AppConfigs/neue-pruefung.json
python3 Scripts/create_learning_app.py --config AppConfigs/neue-pruefung.json
```

## AEVO weiterentwickeln

Die 800 Aufgaben und 300 Karten liegen unverändert unter `ContentPacks/aevo-de/`. Fachliche Änderungen erfolgen dort, nicht unter `Core/Resources/SelectedPack`. Nach Änderungen die Inhaltsversion erhöhen und Korrekturen in revisions.json beschreiben. Die technische Validierung ersetzt keine erneute fachliche Prüfung.

Die vorhandene AEVO-App behält Bundle-ID `de.juliankuerten.aevo` und Produktname `AEVOLernen`. Diese beiden Werte für ein Update beibehalten. Die Projektdatei heißt nun `LearningApp.xcodeproj`. Die App nicht löschen, sondern aktualisieren; vorher eine Sicherung exportieren. Bereits gespeicherte Notizen und Lernstände bleiben zu ihren stabilen Inhalts-IDs zugeordnet.

Für volle Regressionstests der gemeinsamen Quellcodebasis:

```bash
swift test
python3 -m unittest discover -s Scripts -p 'test_*.py'
python3 Scripts/validate_project.py
```

`Core/Resources/SelectedPack` im Hauptprojekt ist auf AEVO eingestellt. Andere Apps werden mit dem Generator geprüft. Der Generator hat absichtlich keinen Schalter zum Überspringen seiner Laufzeittests.

## Veröffentlichung

Vor einem Store-Release sind die tatsächlichen Apple-Produkte, öffentlichen Rechtstext- und Supportadressen, zutreffende Datenschutzangaben, fachliche Freigaben und Gerätetests abzuschließen. Die generierte StoreKit-Datei enthält nur lokale Testprodukte. Das Demo ist ausschließlich ein technischer Nachweis und wird nicht veröffentlicht.

Technische Wiederverwendung garantiert keine Annahme mehrerer Apps im Store. Apple behandelt weitgehend gleiche Varianten unter den Regeln zu Vorlagen und Spam; eigenständiger Inhalt und Mehrwert müssen tatsächlich vorhanden sein. [Apple App Review Guidelines, 4.2.6 und 4.3](https://developer.apple.com/app-store/review/guidelines/#design)

## Welche Dateien für eine neue Lern-App auszufüllen sind

Für eine weitere App innerhalb der unterstützten Prüfungsformen musst du diese Dateien austauschen beziehungsweise ausfüllen:

- `AppConfigs/neue-pruefung.json`
- `AppConfigs/neue-pruefung/legal.json`
- `AppConfigs/neue-pruefung/store.json`
- `AppConfigs/neue-pruefung/AppIcon.appiconset/Contents.json` und Icon-Bilder
- `ContentPacks/neue-pruefung/manifest.json`
- `ContentPacks/neue-pruefung/learning_objectives.json`
- `ContentPacks/neue-pruefung/questions.json`
- `ContentPacks/neue-pruefung/cards.json`
- `ContentPacks/neue-pruefung/exam_config.json`
- `ContentPacks/neue-pruefung/sources.json`
- `ContentPacks/neue-pruefung/practice.json`
- `ContentPacks/neue-pruefung/experience.json`
- `ContentPacks/neue-pruefung/revisions.json`

Die allgemeine Lernlogik, Swipes, Notizen, Fortschritt, Sicherungen und Apple-Dienste werden dafür nicht neu programmiert.
