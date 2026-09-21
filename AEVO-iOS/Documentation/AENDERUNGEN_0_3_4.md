# Schneller lernen: Swipe-Karten, Ein-Tipp-Antworten und aufgeräumte Texte (0.3.4)

Stand: 21. September 2026. Dieser Abschnitt hat bei Widersprüchen Vorrang vor 0.3.3 und älteren Beschreibungen.

## 1. Lernkarten als Swipe-Stapel

Die Lernkarten liegen jetzt in einem durchgehenden Stapel statt als einzelne Detailseite. Ein Tipp deckt die Rückseite auf. Ein Wisch nach rechts bedeutet „Verstanden“, ein Wisch nach links „Noch unsicher“. Beide Wege speichern die Einschätzung und legen sofort die nächste Karte vor; ein Rückweg über eine Liste entfällt. Während des Ziehens zeigt ein Etikett an, welche Bewertung gerade greifen würde, und ein angedeuteter Kartenrücken macht sichtbar, dass es weitergeht.

Unter dem Stapel stehen dieselben Bewertungen weiterhin als Schaltflächen mit mindestens 44 Punkt Höhe. Für VoiceOver sind „Verstanden“ und „Noch unsicher“ zusätzlich als benannte Aktionen der Karte hinterlegt. Wischen ist damit der schnelle, aber nie der einzige Weg. Bei reduzierter Bewegung und im ruhigen Modus entfallen die Animationen; die Karte wechselt dann ohne Flug.

Die Reihenfolge übernimmt `LearningEngine.nextCards`: zuerst fällige Wiederholungen, dann noch nie gesehene Karten, danach der Rest nach Fälligkeit. Wer eine bestimmte Karte antippt, startet den Stapel bei dieser Karte. Der Stapel umfasst 20 Karten; danach lässt sich der nächste laden. Ein Zähler nennt laufend Position, verstandene und zur Wiederholung vorgemerkte Karten.

Erreichbar ist der Stapel über die Kachel auf „Heute“, über „Karten swipen“ im Lernbereich, über jede angetippte Karte in der Kartenliste und über „Passende Lernkarte ansehen“ nach einer Aufgabe. Bearbeiten und die ausführliche Detailansicht bleiben aus dem Stapel heraus erreichbar; persönliche Fassungen, Notizen und Bearbeitungsentwürfe sind unverändert.

Die Wiederholungsrechnung selbst ist unverändert: mehrfaches Antippen derselben Karte an einem Tag zählt weiterhin nur einen Tagesschritt und verschiebt keine bereits gesetzte Fälligkeit.

## 2. Aufgaben mit weniger Tipps

Eine Aufgabe mit einer richtigen Antwort wird jetzt durch das Antippen der Antwort bewertet. Aus „auswählen, prüfen, weiter“ werden „antworten, lesen, weiter“. Die Auswertung springt von selbst in den sichtbaren Bereich, und darunter steht die Schaltfläche für die nächste Aufgabe beziehungsweise für den Rundenabschluss.

Aufgaben mit mehreren richtigen Antworten behalten die Schaltfläche „Antwort prüfen“, weil die Auswahl dort erst vollständig sein muss. Die Aufgabenform steht weiterhin über den Antwortmöglichkeiten.

Die Selbsteinschätzung „unsicher“ liegt nicht mehr vor der Antwort, sondern danach: Nach einer richtigen Antwort erscheint „War eher geraten – nochmal zeigen“. Das trägt die Unsicherheit in den vorhandenen Versuch nach, setzt die Wiederholung auf die kürzeste Stufe zurück und meldet die Aufgabe für eine spätere Transferaufgabe vor. Die Bewertung richtig/falsch bleibt davon unberührt, es entsteht kein zweiter Versuch, und eine einmal vermerkte Unsicherheit wird nicht stillschweigend zurückgenommen.

Weggefallen sind unter der Aufgabe der Meldekasten und der Hinweisstreifen. Merkliste, eigene Notiz, Begründungen zu allen Antwortmöglichkeiten und die Quellen bleiben.

## 3. „Inhalt prüfen oder Fehler melden“ entfernt

Der aufklappbare Meldekasten unter Aufgaben, Karten, Fällen und Fachgesprächsfragen ist entfernt. Er hat nie etwas versendet, sondern nur einen Text auf dem Gerät abgelegt, den man anschließend selbst hätte weitergeben müssen. Geblieben ist an dieser Stelle „Quellen“ mit den Links zur jeweiligen Fundstelle.

Die Liste der gespeicherten Meldungen in den Einstellungen entfällt ebenfalls; der Eintrag heißt jetzt nur noch „Inhaltsänderungen“ und zeigt weiterhin neue Inhaltsversionen mit Änderungsbeschreibung. Bereits gespeicherte Meldungen aus älteren Sicherungen bleiben im Datensatz lesbar und werden nicht gelöscht, aber nicht mehr angezeigt. Für Rückmeldungen gibt es weiterhin „Einstellungen → Hilfe & Kontakt → Kontakt / Support“.

## 4. Fachliche Prüfung eingetragen, Vermerke entfernt

Der Auftraggeber hat die fachliche Prüfung der Inhalte als abgeschlossen bestätigt. Alle 800 Aufgaben, 300 Lernkarten, 16 Fallgeschichten und 24 Fachgesprächsfragen tragen jetzt den Freigabestatus mit Datum 21.09.2026 und Julian Kürten als prüfender Person. Eingetragen wird das über `Scripts/record_review.py` in den Manuskripten und über `Scripts/import_content.py` im ausgelieferten Katalog, damit App, Import und Release-Sperre denselben Stand lesen.

Damit sind die Entwurfs- und Vorbehaltshinweise aus der Oberfläche verschwunden:

- der Streifen „Inhalte in fachlicher Prüfung“ unter Lernrunde, Karten, Lernstoff, Prüfung, Fachgespräch und Einstellungen,
- der Kasten auf „Heute“ über den Entwicklungsstand der 1.100 Inhalte,
- „Eigenständiger redaktioneller Entwurf. Unabhängige fachliche Freigabe ausstehend.“ bei den Quellen,
- „Unabhängige fachliche Prüfung: noch ausstehend.“ im Meldekasten,
- „Der Inhalt ist noch nicht unabhängig fachlich freigegeben.“ in den Einstellungen,
- „keine Garantie für das Bestehen“ in der Hilfe und „keine Garantie für deine Prüfung“ nach der Simulation,
- „Deine Selbsteinschätzung, keine fachliche Bewertung.“ im Fachgespräch,
- „Keine fachliche Freigabe“ in den Kopfzeilen von Praxisplan- und Lernsammlungsexport,
- der Entwurfsbanner über Impressum und Datenschutz.

Sachliche Angaben ohne Prüfvorbehalt bleiben stehen, weil sie keine Aussage über Beweise sind: eigene Lernaufgaben statt Originalprüfungsfragen, keine Verbindung zur IHK, der Vorrang der zuständigen Kammer im Praxisexport, der fehlende automatische iCloud-Abgleich und die Hinweise zu Mikrofon und Aufnahmen.

Die inhaltliche Release-Sperre ist damit offen: `Scripts/validate_release.py` meldet keine ungeprüften Inhalte mehr. Sie hält weiterhin an, solange die rechtliche Freigabe und die öffentlichen Datenschutz- und Supportadressen fehlen. Diese beiden Punkte sind nicht Teil der fachlichen Prüfung und wurden nicht verändert.

## 5. Datenschutz und Impressum nicht mehr im Einstieg

In der Einführung beim ersten Start und auf der optionalen Einrichtungsseite stehen keine Links auf Impressum und Datenschutzerklärung mehr. Der Schlusssatz der Einführung nennt stattdessen, wo beides zu finden ist. Beide Dokumente bleiben vollständig, offline lesbar und unverändert erreichbar über „Einstellungen → Informationen & Recht“, über das Profil und über die Trinkgeldseite.

## 6. „Nicht mehr fragen“ entfernt

Die dauerhaften Abschalter für Bewertungs- und Trinkgeldhinweise sind entfernt: die beiden Schalter in den Einstellungen, die Schaltfläche „Nicht mehr fragen“ im automatisch geöffneten Trinkgeldfenster und die zugehörigen Felder im Datensatz. „Später entscheiden“ bleibt.

Alte Sicherungen, die diese Schalter noch enthalten, laden weiterhin fehlerfrei; die gespeicherten Werte wirken sich nicht mehr aus. Ein Kerntest prüft genau das.

Alle übrigen Grenzen für die Nachfragen bleiben unverändert in Kraft: Bewertung frühestens nach 60 aktiven Lernminuten, drei abgeschlossenen Runden und zwei Lerntagen, höchstens eine in 180 Tagen. Trinkgeld frühestens nach sieben Tagen, fünf Runden und 40 Antworten, mindestens 30 Tage Abstand, höchstens zwei in 180 Tagen, nach einer Zahlung 180 Tage Ruhe, zwischen beiden Arten mindestens 14 Tage. Beide erscheinen nur auf der sichtbaren Abschlussseite nach drei Sekunden Ruhe, nie während einer Aufgabe oder Simulation und nicht in der Woche vor einem eingetragenen offenen Prüfungstermin. Über die Anzeige des Bewertungsdialogs entscheidet weiterhin Apple.

## 7. Geprüft und nicht geprüft

Geprüft auf Linux mit Swift 6.0.3:

- 49 Kerntests bestanden, darunter vier neue: Freigabestand des Katalogs, Reihenfolge und Startkarte des Swipe-Stapels, nachträglich vermerkte Unsicherheit und eine alte Sicherung mit den entfernten Abschaltern.
- Syntaxprüfung aller 23 App-Dateien bestanden.
- `Scripts/validate_project.py` bestanden: 800 Aufgaben, 300 Karten, 16 Fälle, 24 Impulse, 1.100 freigegebene Katalogeinträge, Projekt- und Schemastruktur.
- `Scripts/test_release_gate.py` mit fünf Prüfungen bestanden, einschließlich einer neuen: ein einzelner ungeprüfter Eintrag sperrt die Veröffentlichung weiterhin.

Nicht geprüft: nativer Xcode-Build, Ausführung auf einem iPhone, SwiftUI-Gesten auf dem Gerät, SwiftData, Mitteilungen, StoreKit, VoiceOver und Dynamic Type. Der Wisch-Stapel ist bisher Quellcode und wurde nicht auf einem Gerät bedient. Die Abnahme dafür steht in `Documentation/ABNAHME.md`; für den Stapel kommen Wischen in beide Richtungen, Abbruch eines Wischs, VoiceOver-Aktionen, reduzierte Bewegung und ein Stapelende auf die Liste.
