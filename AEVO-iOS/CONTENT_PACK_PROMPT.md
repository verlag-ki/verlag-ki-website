# Masterprompt für ChatGPT Work: ein neues Content-Pack erstellen

Diesen Prompt gemeinsam mit `CONTENT_PACK_SCHEMA.md`, dem Ordner `Schemas/` und dem funktionierenden `ContentPacks/demo-orbit/` an Work übergeben. Der folgende Text kann vollständig kopiert werden.

---

Du arbeitest als Fachredakteur, Prüfungsdidaktiker, Rechercheur und Content-Pack-Entwickler für unsere bestehende native iOS-Lern-Engine. Du sollst die Engine nicht verändern und keine neue Benutzeroberfläche programmieren. Liefere ausschließlich ein neues, technisch validiertes und fachlich nachvollziehbar aufgebautes Inhaltspaket sowie eine passende App-Konfiguration.

## Auftrag

Prüfung oder Lernthema: **[PRÜFUNG EINTRAGEN]**

Zielgruppe und Region: **[EINTRAGEN, sonst deutschsprachige erwachsene Selbstlernende in Deutschland]**

Gewünschter Umfang: **[FRAGENZAHL] Aufgaben und [KARTENZAHL] Lernkarten**

Pack-ID: **[kleingeschriebene-stabile-kennung]**

App-Name: **[NAME, sonst Arbeitsname aus dem Prüfungstitel]**

Arbeite eigenständig. Falls Mengen noch fehlen, schlage nach Prüfung der Lernziele einen realistischen Umfang vor und beginne mit einem klar gekennzeichneten vollständigen ersten Paket. Behaupte niemals, mehr Inhalte erstellt zu haben, als tatsächlich in den Dateien stehen.

## Bestehenden Vertrag lesen

Lies zuerst `CONTENT_PACK_SCHEMA.md` und alle JSON-Schemas. Das Format ist Schema 1. Nutze das Demo nur zur Erklärung der Datenstruktur. Übernimm keine fiktiven Regeln oder AEVO-Inhalte in das neue Fachgebiet.

Dateinamen, Datentypen, Pflichtfelder, optionale Werte und Verknüpfungen sind exakt einzuhalten. Es gibt keine zusätzlichen improvisierten Felder in JSON. Ergänzende Recherche-, Rechte- und Prüfhinweise gehören in `RESEARCH_NOTES.md` und `EDITORIAL_REVIEW.md` neben dem Pack. Die App enthält keine Entwickleroptionen und benötigt keinen nutzerseitigen Inhaltsimport.

## Quellenbasierte Fachrecherche

Recherchiere anhand aktueller offizieller Prüfungsordnungen, Rahmenpläne, zuständiger Prüfungsstellen und sonstiger geeigneter Primärquellen. Dokumentiere Fundstellen, Recherchetag, Geltungsbereich und offene Widersprüche. Trenne bundesweite Regeln von regionalen oder anbieterspezifischen Abläufen. Bei unterschiedlichen Profilen wähle ein ausdrücklich beschriebenes Profil; vermische keine Regeln zu einer erfundenen Prüfung.

Verifiziere Dauer, Aufgabenanzahl, Aufgabenformen, Themengewichtung, Navigation, Antwortänderung, Bestehensgrenze und praktische beziehungsweise mündliche Anforderungen. Falls eine echte Prüfung nicht mit Schema 1 darstellbar ist, liefere keine vorgetäuschte exakte Simulation. Beschreibe stattdessen den kleinsten notwendigen Engine-Ausbau in `EDITORIAL_REVIEW.md` oder ein deutlich benanntes eigenständiges Übungsprofil.

Nutze nur rechtlich verwendbare eigene Fragen und Erklärungen. Kostenlose Lesbarkeit einer fremden Aufgabe ist keine Erlaubnis zur Übernahme. Kopiere keine geschützten Kataloge, Screenshots oder Anbieterformulierungen. Behaupte keine Originalprüfungsaufgaben oder offiziellen Partnerschaften. Eigene Situationsaufgaben sollen Wissen auf neue Fälle übertragen.

## Inhalt planen und schreiben

1. Leite Kategorien und Lernziele aus den Quellen ab. Erstelle eine Abdeckungsmatrix mit Anzahl Grundlagenfragen, Situationsfragen und Karten je Lernziel. Verwende so viele Kategorien, wie fachlich sinnvoll sind.
2. Jede Frage bekommt stabile ID, Version, Kategorie, Aufgabentyp, Lernziel, Aufgabenfamilie, klare Aufgabenstellung, richtige Lösungen und Quellen.
3. Jede Option braucht eine konkrete Erklärung. Keine Platzhalter wie „falsch, weil falsch“. Vermeide uneindeutige Verneinungen und Antwortoptionen, die abhängig von nicht genannten Bedingungen ebenfalls richtig wären.
4. Vergib dieselbe family nur für eng verwandte Varianten. Unabhängige Situationsaufgaben erhalten eigene Familien. Erfinde keine Inhaltsbreite durch bloßes Austauschen von Namen.
5. Karten behandeln jeweils einen überschaubaren Gedanken mit kurzer Erklärung, Merksatz und geeignetem Beispiel. Die Engine ergänzt später persönliche Texte und Notizen; diese gehören nicht in das redaktionelle Paket.
6. Verwende ein zentrales sources.json mit eindeutigen IDs und passenden HTTPS-Quellen. Eingebettete Quellenobjekte müssen exakt mit Registereinträgen übereinstimmen. Quellen müssen die konkrete fachliche Aussage tragen.
7. Alle neuen Entwürfe bleiben `approved: false`. Erfinde keine Reviewer, Prüfungen oder Freigaben. Eine spätere menschliche Freigabe wird gesondert dokumentiert.

## Optionale Module und Lernimpulse

Aktiviere ausschließlich Module mit passendem Inhalt: writtenExam, flashcards, practicePreparation, oralExam und scenarioTraining. Nicht benötigte Arrays sind leer, preparation und exam_config gegebenenfalls null. Im AppConfig dürfen nur tatsächlich verfügbare Module aktiv sein.

Ein Praxisformular verwendet für neue Felder storage „detail“. Die reservierten legacy-Felder dürfen nicht zweckentfremdet werden. Verzweigte Fälle müssen vollständig bis zu einem Ende führen und dürfen weder fehlende Knoten noch Zyklen haben. Mündliche Aufgaben bekommen nachvollziehbare Orientierungskriterien ohne automatisches Notenversprechen.

Liefere verständliche Hilfe und Einführung passend zu den aktivierten Funktionen. Kurze eigene Lernimpulse sind bevorzugt. Bei echten Zitaten sind Urheber, Werk, Fundstelle, Originalwortlaut, Quellen-URL und Prüfdatum anzugeben. Keine erfundenen oder nur zugeschriebenen Zitate. Der Text muss zur Zielgruppe passen.

## Konfiguration und Veröffentlichungsangaben

Erstelle `AppConfigs/[appId].json` anhand des Schemas. Bereits bestätigte Anbieterangaben können ausdrücklich wiederverwendet werden; unbekannte rechtliche Angaben, Storeprodukte und öffentliche URLs dürfen nicht erfunden werden. Technische Beispiele bleiben klar als Beispiele dokumentiert. `legacyMigration` bleibt für neue Fachgebiete false, legacyBackupFormats bleibt leer.

Trinkgelder bleiben freiwillige Einmalkäufe ohne inhaltliche Vorteile. Keine Werbung, keine Kontopflicht, keine Abos und keine Bezahlschranken einführen. Neue Bundle- und Produktkennungen werden vorbereitet, aber weder registriert noch veröffentlicht. Storebeschreibungen und Screenshottexte müssen den tatsächlichen Umfang wiedergeben.

## Technisch und redaktionell prüfen

Führe mindestens aus:

```bash
python3 Scripts/validate_content_pack.py ContentPacks/[packId] --config AppConfigs/[appId].json
```

Wenn die bestehende Engine und Swift verfügbar sind, führe zusätzlich den dokumentierten Generator aus. Behebe konkrete Validierungsfehler in den Daten, ohne den Validator abzuschwächen oder Tests zu deaktivieren.

Prüfe außerdem redaktionell Lösungen, Begründungen, Quellenbezug, Lernzielabdeckung, Variantenhäufung und mögliche Mehrdeutigkeit. Wenn keine unabhängige fachliche Prüfung stattgefunden hat, bleibt dies im redaktionellen Status offen. Formale JSON-Validierung ist kein Nachweis inhaltlicher Richtigkeit.

## Lieferung

Liefere die echten Dateien in folgenden Ordnern:

- `ContentPacks/[packId]/` mit sämtlichen Dateien aus Schema 1
- `AppConfigs/[appId].json` und zugehörigen rechtlichen sowie Markenressourcen, soweit belastbar verfügbar
- `RESEARCH_NOTES.md` mit Quellen, Stand, Prüfungsprofil und Unsicherheiten
- `EDITORIAL_REVIEW.md` mit Abdeckungsmatrix, tatsächlichen Stückzahlen, fachlichem Prüfstatus und offenen Freigaben
- `VALIDATION_REPORT.md` mit tatsächlich ausgeführten Prüfungen und Ergebnissen

Beende den Auftrag mit dem konkreten Erzeugungsbefehl. Behaupte weder einen erfolgreichen Xcode-Build noch fachliche Freigabe oder Veröffentlichung, wenn diese Schritte nicht tatsächlich stattgefunden haben.
