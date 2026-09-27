# Übertragbare Tests und Nachbesserungen an 0.5.0 (Stand 0.5.1)

Stand: 27. September 2026. Dieser Abschnitt ergänzt `REFACTORING_0_5_0.md`. Die Architektur aus 0.5.0 bleibt unverändert; korrigiert werden drei Dinge, die beim Übernehmen des Pakets aufgefallen sind.

## 1. Befund: die Testsuite war nicht mit umgezogen

Die Engine ist austauschbar, ihre Testsuite war es nicht. Nachgeprüft mit Swift 6.0.3 auf Linux:

| Lauf | Ergebnis vor der Korrektur |
|---|---|
| AEVO-App, `swift test` | 64 Tests, 0 Fehler |
| Generierte Demo-App, `swift test` | 22 Tests erreicht, 15 Fehler, zwei Abbrüche mit „Index out of range" |

Der Generator führte während der Erzeugung nur `--filter RuntimePackTests` aus. Diese zwei Tests sind sauber paketunabhängig geschrieben und bestanden. Die übrigen sechs Suiten liefen dabei nie, obwohl sie mitkopiert wurden. Eine erzeugte App galt damit als fertig, während ihr `swift test` abbrach.

Das ist genau die Stelle, an der es weh tut: Wer eine neue App aus der Engine baut, führt als erstes die Tests aus. 15 Fehler und ein Absturz sagen dann nichts darüber, ob die eigenen Inhalte in Ordnung sind.

Die Ursache war nicht die Engine, sondern fest verdrahtete AEVO-Annahmen in den Tests: 800 Aufgaben, 300 Karten, die Prüfungsquoten 12/18/38/12, 40 Antworten für die Trinkgeldschwelle, `cards[0]` bis `cards[3]` innerhalb einer Kategorie, das Sicherungsformat `de.aevo.learning.backup` und die Anbieterangaben der AEVO-App.

## 2. Korrektur: pro Test statt pro Suite

Eine Einzelauswertung aller 64 Tests gegen das Demo-Pack zeigte, dass nur 13 wirklich an AEVO hängen. 51 prüfen Verhalten der Engine und liefen auch mit fremden Daten korrekt. Ein pauschales Überspringen ganzer Suiten hätte diese 51 verschenkt.

Vier Tests sind jetzt paketunabhängig, weil ihre Absicht es war:

- Die Vorbedingung für Nachfragen baut 40 Antworten auf, indem sie die vorhandenen Fragen wiederverwendet. Geprüft wird die Regel, nicht die Katalogsgröße.
- „Ein Kauf schaltet nichts frei" vergleicht die Katalogsgröße vor und nach dem Kauf, statt auf 800 zu bestehen.
- Der Kartenstapel-Test nimmt die Kategorie mit den meisten Karten, statt fest Handlungsfeld 2. Damit prüft er weiter die Begrenzung auf eine Kategorie und die Fälligkeitsordnung.
- Der Impulstest prüft Anzahl und Eindeutigkeit gegen das jeweilige Pack. Die AEVO-Zahl 31 wird nur noch für AEVO geprüft.

Neun Tests behalten ihre AEVO-Annahmen und melden sie offen an. `Tests/CoreTests/PackRequirement.swift` stellt dafür zwei Hilfen bereit: `aevoPack(_:)` überspringt mit begründetem Hinweis, wenn ein anderes Pack ausgewählt ist, und `cardsOfLargestCategory(_:in:)` überspringt, wenn ein Pack für einen Test zu klein ist. Beides nutzt `XCTSkipUnless`, erscheint also als übersprungen, nicht als bestanden.

| Lauf | Ergebnis nach der Korrektur |
|---|---|
| AEVO-App, `swift test` | 64 Tests, 0 Fehler, 0 übersprungen |
| Generierte Demo-App, `swift test` | 64 Tests, 54 bestanden, 10 übersprungen, 0 Fehler, kein Abbruch |

Für AEVO ändert sich nichts. Eine neue App bekommt 54 echte Prüfungen ihrer eigenen Daten und eine Liste der Tests, die sie nicht betreffen.

## 3. Korrektur: Entwurfsbanner über den Rechtstexten

`App/LegalViews.swift` zeigte über Impressum und Datenschutz wieder „Entwurf · Prüfung noch offen". Dieser Hinweis war auf ausdrücklichen Wunsch bereits entfernt worden; die 0.5.0-Linie ist vor dieser Änderung abgezweigt und hat ihn zurückgebracht. Er ist erneut entfernt.

Die Release-Sperre prüft den rechtlichen Freigabestand unverändert weiter. `Scripts/validate_release.py` meldet nach wie vor die fehlende rechtliche Freigabe und die fehlenden öffentlichen Adressen für Datenschutz und Support. Aus der Oberfläche verschwindet nur der Hinweis, nicht die Voraussetzung.

## 4. Korrektur: Prüfsummenliste

`Dateipruefsummen.json` enthielt noch drei Einträge aus einem früheren Stand. Alle drei Dateien gibt es nicht mehr, und keine der 172 tatsächlichen Dateien war erfasst. Als Integritätsnachweis war die Liste damit wertlos.

`Scripts/write_checksums.py` erzeugt sie wieder aus dem Projektstand und lässt Buildausgaben, `__pycache__` und `Generated/` aus. Die Liste umfasst jetzt alle Dateien des Pakets. Vor jeder Weitergabe erneut ausführen.

## 5. Was am Paket gut ist

Nachgeprüft, nicht übernommen:

- Der Generator arbeitet in einem temporären Ordner und benennt erst am Ende um. Ein Abbruch hinterlässt kein halbes Projekt. Ein bereits vorhandenes Ziel wird nicht überschrieben.
- Pfade aus der Konfiguration werden gegen den Projektstamm geprüft, verlassen ihn also nicht.
- Die Kontaktadresse im Rechtstext muss zur Supportadresse der Konfiguration passen, sonst bricht die Erzeugung ab. Das verhindert eine App mit fremder Kontaktadresse.
- Buildcaches mit absoluten Pfaden werden vor der Auslieferung entfernt.
- Der Freigabevermerk hängt an Inhalts-Hashes. Wird eine Aufgabe geändert, passt ihr Hash nicht mehr und die Freigabe gilt für sie nicht weiter. Der Vermerk benennt ausdrücklich eine Bestätigung des Auftraggebers und erfindet keine unabhängige Prüferidentität.
- Der Kartenstapel liegt im gespeicherten Zustand, eine unterbrochene Runde läuft weiter. Ein Wisch wird nur als Bewertung gewertet, wenn er deutlich waagerecht ist, und eine verspätete Berührung kann nicht die nachfolgende Karte bewerten.

## 6. Weiterhin offen

Unverändert gegenüber 0.5.0: kein Apple-SDK-Typecheck, kein Simulator-Build, kein iPhone-Test, keine Prüfung der Wischgesten auf einem Gerät, keine Abnahme mit VoiceOver und Dynamic Type. Die rechtliche Freigabe und die öffentlichen Adressen für Datenschutz und Support bleiben Voraussetzung für eine Veröffentlichung. Das Demo-Pack hat keine fachliche Freigabe und ist nicht zur Veröffentlichung gedacht.

Zwei kleinere Punkte sind bewusst nicht angefasst, weil sie nichts kaputt machen: `ContentQualityView` ist nur noch eine Hülle um `SourceLinks` mit vier ungenutzten Parametern, und die Felder `hideTipPrompts`, `hideReviewPrompts` sowie `draftNoticeAcknowledged` liegen als bewusst gekennzeichnete Altlasten im Datensatz, damit ältere Sicherungen weiter lesbar bleiben.
