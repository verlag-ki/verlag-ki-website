# Content-Pack-Schema 1

Die maschinenlesbaren JSON-Schemas in `Schemas/*.schema.json` sind verbindlich. Sie verwenden JSON Schema Draft 2020-12. Der mitgelieferte Python-Validator implementiert exakt die dafür verwendeten Schlüssel offline; ein unabhängiger vollständiger JSON-Schema-Validator kann dieselben Dateien ebenfalls prüfen. Zusätzlich prüfen Python und Swift fachliche Verknüpfungen. Ein formal korrektes Paket ist damit nicht automatisch fachlich richtig.

## Dateien eines Pakets

| Datei | Inhalt |
|---|---|
| manifest.json | schemaVersion 1, stabile packId, positive Inhaltsversion, Titel, Beschreibung, Sprache, Stand, Kategorien, verfügbare Module, Herkunftshinweis, zugelassene alte Backupformate |
| learning_objectives.json | Array aus id, categoryID und title |
| questions.json | Aufgabenarray, siehe unten |
| cards.json | Kartenarray, siehe unten |
| exam_config.json | Ein Prüfungsprofil oder JSON `null` |
| sources.json | Quellenregister mit eindeutiger id sowie title und HTTPS-url |
| practice.json | Formatversion 1, cases, oral und optionales preparation-Formular; leere Module als `[]`, preparation als `null` |
| experience.json | Tägliche impulses, guides und introduction; optionale Modulzuordnung blendet unpassende Anleitungen aus |
| revisions.json | Array aus contentID, version, date, summary; zunächst `[]` |
| approval.json | Optionaler redaktioneller Freigabenachweis; keine Voraussetzung für einen Entwicklungsbuild |

Die Datei- und Feldnamen müssen exakt stimmen. JSON enthält keine Kommentare. Unbekannte JSON-Felder und doppelte Schlüssel werden beim Erzeugen abgelehnt. Inhaltspakete enthalten Daten, keinen ausführbaren Code. Unvollständige `_template`-Dateien werden bewusst abgelehnt.

## Kategorien und Lernziele

Eine Kategorie hat eine positive ganzzahlige `id` und einen `title`. Anzahl und Kennungen sind nicht auf vier begrenzt. Die Schlüssel `field` und `competency` bleiben aus Kompatibilitätsgründen erhalten: `field` ist die Kategorie-ID, `competency` die ID eines Lernziels. Ein Lernziel gehört genau zu einer Kategorie. Es gibt keine implizite AEVO-Bedeutung dieser Felder.

Jede Frage referenziert ein vorhandenes Lernziel aus derselben Kategorie. Allgemeine Orientierungskarten dürfen `field: null` und `competency: null` verwenden. Eine angegebene Kartenkompetenz muss zur angegebenen Kategorie gehören. IDs aller Fragen, Karten, Fälle und mündlichen Impulse sind innerhalb des Pakets gemeinsam eindeutig. Bestehende IDs dürfen bei Überarbeitungen nicht neu vergeben werden.

## Aufgaben

Pflichtfelder: `id`, `version`, `field`, `type`, `competency`, `family`, `topic`, `objective`, `context`, `prompt`, `options`, `correctIDs`, `explanation`, `sources`, `approved`.

`type` ist `singleChoice` oder `multipleChoice`. Single Choice hat genau eine richtige Lösung. Multiple Choice erlaubt eine oder mehrere richtige Lösungen. Jede Antwortoption besitzt eine eindeutige lokale `id`, `text` und `explanation`. Jede richtige Kennung muss einer Option entsprechen. Begründungen beschreiben auch, weshalb die falschen Alternativen in diesem Fall nicht passen. Eine leere Auswahl gilt nicht als richtige Lösung.

`family` gruppiert nahe Aufgabenvarianten. Bei unabhängiger Simulationsauswahl kommt jede Familie nur einmal vor; sie darf dann nicht mehrere Kategorien belegen. Ein großer Katalog von Varianten vergrößert dadurch nicht künstlich die verfügbare Zahl unabhängiger Prüfungsaufgaben.

`sources` enthält `{title, url}`-Objekte. Jedes Objekt muss mit einem Eintrag des zentralen Quellenregisters übereinstimmen. Die bewusst beibehaltenen eingebetteten Quellen machen auch alte gespeicherte Aufgaben verständlich. Das Register ist der gemeinsame Abgleich, seine `id` dient der Redaktion.

Optionale Freigabefelder sind in den Schemas beschrieben. Neue KI-Entwürfe setzen `approved: false`, `reviewedOn: null`, `reviewedBy: null`. Ein technischer Validator erteilt keine Fachfreigabe.

## Karten

Pflichtfelder: `id`, `version`, `field`, `competency`, `title`, `explanation`, `remember`, `example`, `sources`, `approved`. Merksatz und Beispiel dürfen leer sein; Titel und Erklärung nicht. Die Originalkarte bleibt getrennt von persönlichen Änderungen und Notizen. Eine neue Inhaltsversion überschreibt keine persönlichen Texte.

## Prüfungssimulation

| Feld | Verhalten |
|---|---|
| questionCount | Positive Aufgabenanzahl; höchstens 10.000 als technische Sicherheitsgrenze |
| durationSeconds | Positive Dauer bis sieben Tage; Sekunden |
| passPercentage | Grenze zwischen 0 und 100, Vergleich erfolgt ohne Rundung |
| selection | `random` aus dem Gesamtkatalog oder `weightedRandom` mit Kategoriengewichtung |
| categoryWeights | Bei gewichteter Auswahl positive Gewichte für vorhandene Kategorien; sonst leeres Array |
| uniqueFamilies | Bei true höchstens eine Frage je Familie |
| navigation | `free` oder `forwardOnly` |
| allowsAnswerChanges | Bei false wird die Antwort nach Verlassen der Aufgabe gesperrt; die anfängliche Auswahl bleibt bis zum Weitergehen änderbar |
| timing | `continuous`: Zeit läuft bei Unterbrechungen weiter. `activeOnly`: Zeit läuft nur während der sichtbaren aktiven Simulation |
| scoring | `allOrNothing`: exakte Auswahl zählt 1, sonst 0. `partialCredit`: (gewählte richtige minus gewählte falsche Optionen) / Anzahl richtiger Optionen, mindestens 0 |
| results | `detailed`: Übersicht, Lösungen und Erklärungen nach Abgabe. `summary`: nur Ergebnisübersicht |

Gewichte werden auf die Aufgabenanzahl normiert. Zunächst werden die Quoten abgerundet, Restplätze gehen nach größtem Nachkommaanteil an Kategorien, bei Gleichstand nach aufsteigender Kategorie-ID. Das ergibt reproduzierbare Quoten und exakt die gewünschte Anzahl. Reichen Fragen oder unabhängige Familien nicht aus, scheitert die Validierung mit der betroffenen Kategorie. Es wird nichts still aufgefüllt.

Alle Aufgaben werden gleich stark gewichtet. Eine alternative Punktevergabe je Aufgabe, mündliche Gesamtnoten oder mehrstufige Bestehensregeln sind nicht Teil von Schema 1. Neue Regeln benötigen eine ausdrücklich implementierte Engine-Erweiterung.

## Optionale Module

`writtenExam`, `flashcards`, `practicePreparation`, `oralExam`, `scenarioTraining` werden im Manifest als verfügbar angegeben. Die App aktiviert eine Teilmenge über Feature Flags. `tips` und `ratings` sind ausschließlich App-Funktionen. Eine aktivierte Funktion mit fehlenden Daten wird abgelehnt.

Ein Fall hat stabile ID, Version, Kategorie, Ziel, Kontext und Knoten. Der erste Knoten heißt `start`. Jede Auswahl enthält text, consequence, reasoning und `next` als Knoten-ID oder `null`. Fehlende Verweise und Zyklen werden abgelehnt.

Ein mündlicher Impuls hat ID, Version, question, followUp, mindestens zwei criteria, sources und approved. Das vorhandene Aufnahmeverfahren bleibt eine optionale lokale Funktion, ohne automatische Benotung.

`preparation.fields` enthält frei definierbare Felder mit `id`, `title`, `prompt`, `storage`. Für neue Felder ist `storage: "detail"` vorgesehen. `legacy` ist ausschließlich für die erhaltenen AEVO-Speicherfelder occupation, situation, topic, objective, method, steps und conversationNotes vorgesehen. Das Formular enthält außerdem title, description, exportTitle, timerSeconds und checklist.

## AppConfig

`Schemas/app_config.schema.json` beschreibt alle Pflichtfelder. `appId` und `contentPackId` sind stabile kleingeschriebene Kennungen. `productName` ist ein technischer Xcode-Name ohne Leerzeichen; `appName` und `shortName` sind sichtbare Namen. Alle Datenpfade sind relativ zum Projektordner und dürfen ihn nicht verlassen.

`tipProductIds` und `tipLabels` gehören positionsweise zusammen. Die drei AEVO-Trinkgelder bleiben erhalten, eine andere App darf sie deaktivieren. `testPrice` dient ausschließlich der lokalen StoreKit-Testdatei; echte Preise kommen weiter aus StoreKit. `brandAccent` ist `null` oder enthält zwei RGB-Integerwerte light und dark. Ein individueller Akzent gilt für die als Standard gewählte Farbwelt; die weiteren sieben Farbwelten bleiben nutzbar.

Support-, Datenschutz- und Impressumsadressen sind austauschbar. Leere Webadressen sind im Entwicklungsbuild erlaubt, aber keine Veröffentlichungsvoraussetzung. Anbieter- und Rechtstexte liegen in der pro App angegebenen `legalFile`. Sie werden nicht blind aus einer anderen App übernommen.
