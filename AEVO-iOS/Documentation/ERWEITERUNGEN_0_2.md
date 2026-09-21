# AEVO iOS 0.2.0: umgesetzte Erweiterungen

Stand: 20. September 2026. Ausschließlich iPhone, mindestens iOS 17. Alle Lernfunktionen bleiben kostenlos, ohne Konto, Werbung oder Serverpflicht. Dieser Stand ist ein Quellcodeprojekt, keine bereits auf dem iPhone ausgeführte App.

## Was jetzt im Projekt enthalten ist

| Bereich | Konkretes Verhalten | Grenze |
|---|---|---|
| Adaptiver Tagesplan | Zeitbudget für Werktage und Wochenende; spontane 3-, 5- oder 10-Minuten-Runde; fällige und neue Familien, passende Karte, Praxiszeit; beide Prüfungstermine; Hinweis bei grob unzureichender Inhaltskapazität | Zeitabschätzung ist eine Heuristik, keine Garantie der Themenabdeckung oder des Bestehens. Keine Mehrarbeit als Strafe nach Pausen. |
| Fehlerverständnis | Erklärungen gezielt für falsch gewählte und fehlende richtige Antworten; anderer Fall zum selben Lernziel nach zwei Tagen vorgemerkt | Keine Behauptung, aus einem Klick den psychologischen Denkfehler sicher zu kennen. Die Erklärung kommt aus dem redaktionellen Katalog. |
| Ausbildungssituationen | 16 eigene Fallgeschichten, je zwei Entscheidungen mit verzweigtem zweitem Schritt, insgesamt 64 mögliche vollständige Wege; Reaktionen, Begründungen, eigene Reflexion; Unterbrechung und Neustart | Mögliche Reaktionen sind illustrative Beispiele. Abschluss zählt als Aktivität, nicht als Kompetenzbeweis. Alle Fälle benötigen unabhängige Fachprüfung. |
| Praxisassistent | Beruf, Situation, Vorkenntnisse, beobachtbare Handlung, Bedingungen, Erfolgskriterium, Lernziel, Methode, Alternative, Ablauf, Lernkontrolle, Plan bei Schwierigkeiten, Transfer; Text- und Druckexport | Der Check erkennt leere Felder, nicht die fachliche Richtigkeit. Der Entwurf muss den Vorgaben der jeweiligen Kammer entsprechen. |
| Fachgespräch | 24 eigene Fragen mit je einer Rückfrage und drei Orientierungspunkten; zuerst eigene Antwort, dann Kriterien; gespeicherte Stichpunkte und Selbsteinschätzung; freiwillige lokale Aufnahme und Wiedergabe | Keine automatische Benotung, Transkription oder KI-Auswertung. Fragen und Kriterien sind Entwürfe. |
| Kompetenzübersicht | Alle vier Handlungsfelder, Lernziele und Familienabdeckung; getrennte Anzeigen für Bearbeitung, verzögerten Abruf und neue Anwendung | Die Stufen sind transparente Produktregeln, keine validierte Bestehenswahrscheinlichkeit. |
| Persönliche Lernsammlung | Eigene Beispiele direkt an Aufgaben, bestehende persönliche Karten und Entwürfe, Suche, eigene Notiz-Aufgaben üben, Text teilen | Originale und eigene Texte bleiben getrennt. Notizen ändern keine Lösungen. |
| Inhaltsqualität | Kennung, Version, Erstellungsdatum, Quellen und dokumentierter Freigabestatus; lokale Fehlermeldungen mit manuellem Teilen; Versionsänderungen und optionale redaktionelle Änderungsbeschreibungen | Kein automatischer Meldungsversand ohne eingerichteten Empfänger. Fehlende Prüfungen und Änderungsbeschreibungen werden nicht erfunden. |
| Ruhiger Modus | Countdown, Tagesstrecke und Serie auf der Startseite ausblenden; dezente neue Übergänge respektieren auch die Systemeinstellung für reduzierte Bewegung | Prüfungszeit bleibt in der Simulation sichtbar. |

## Die 16 Fälle

1. Feedback vor Kunden im Autohaus
2. Messung unter Zeitdruck in der Werkstatt
3. Stille im Lernteam
4. Schnelle Auszubildende angemessen fordern
5. Fachbegriffe im Lager
6. Fehler im Testprogramm selbst entdecken
7. Konkretes Feedback zur Beratung
8. Digitale Anleitung an reale Arbeitsmittel anpassen
9. Ausbildungsbedarf begründen
10. Fehlenden Ausbildungsinhalt ergänzen
11. Faire Bewerberauswahl
12. Ausbildungsplan und Betriebsalltag verbinden
13. Zusammenarbeit mit der Berufsschule
14. Die letzte Prüfungswoche
15. Ausgewogene Beurteilung für das Zeugnis
16. Perspektiven nach dem Abschluss

Die Fälle wurden eigenständig formuliert. § 3 AEVO dient als Kompetenzrahmen, nicht als Beleg für die erfundenen Reaktionen der handelnden Personen: https://www.gesetze-im-internet.de/ausbeignv_2009/__3.html

## Daten und Migration

`AppState.coachingData` ist ein optionaler zusätzlicher Datenbereich. Alte Sicherungen ohne diesen Bereich erhalten Standardwerte, ihre vorhandenen Antworten, Karten, Entwürfe, Termine, Zahlungen und Opt-outs bleiben unverändert. Eine laufende alte Runde bleibt erhalten; fehlende Neuheitsmarkierungen werden nicht nachträglich als Transfernachweis interpretiert. Neue Versuche halten fest, ob die Aufgabe vor Beginn der Runde schon im Lern- oder Prüfungsverlauf gesehen wurde.

Alle neuen Texte, Einstellungen, Fallentscheidungen, Prüffelder, Fehlermeldungen und Wiederholungsaufträge sind Bestandteil der vorhandenen lokalen Speicherung und der kostenlosen JSON-Sicherung. Die Datenbank wird weiterhin erst nach erfolgreicher Validierung und Speicherung ersetzt.

Audio ist davon ausdrücklich ausgenommen: je Fachgesprächsfrage eine lokal gespeicherte M4A-Datei, maximal fünf Minuten. Mikrofonberechtigung wird erst auf ausdrücklichen Aufnahmewunsch angefragt. Die Aufnahme stoppt bei Hintergrundwechsel, Unterbrechung oder Verlassen. Aufnahmeersatz und Löschen erfordern eine Bestätigung. Audiodateien sind vom Gerätebackup ausgeschlossen und nicht im JSON-Export enthalten. Bei Neuinstallation oder Geräteverlust gehen sie verloren. Die Oberfläche erklärt dies vor der Nutzung. Es wird nichts hochgeladen.

## Ehrliche Kompetenzregeln

Gezählt werden Aufgabenfamilien pro Lernziel. Nur Versuche zur aktuellen Inhaltsversion zählen für die Einordnung. „Im Aufbau“ bedeutet mindestens eine bearbeitete Familie. „Wiederholt abrufbar“ erfordert mindestens zwei Familien, die nach mindestens 24 Stunden erneut sicher richtig gelöst wurden. „Angewendet“ erfordert zusätzlich mindestens zwei zuvor im Lern- oder Prüfungsverlauf ungesehene Aufgaben anderer Familien desselben Lernziels, mindestens 24 Stunden nach einer sicheren Lösung aus einer anderen Familie. Der jüngste Familienversuch muss richtig und ohne Unsicherheitsmarkierung sein. Ein späterer Fehler kann die Einordnung zurücksetzen.

Diese Mindestschwellen sind eine vorsichtige Produktentscheidung. Zwei Familien belegen keine vollständige Themenbeherrschung; deshalb bleibt daneben immer die gesamte Familienabdeckung sichtbar. Neue Aufgaben innerhalb bereits geübter Themen sind nur ein begrenzter Transfernachweis. Ein Test mit echten Prüflingen muss die Aussagekraft noch prüfen.

## Inhaltspflege

Die 800 Aufgaben und 300 Karten werden weiterhin aus `ContentInputs` importiert. Der Import übernimmt nur tatsächlich vorhandene Freigabedaten. `ContentInputs/revisions.json` enthält künftig redaktionelle Änderungen im Format `contentID`, `version`, `date`, `summary`. Aktuell ist die Liste leer, weil keine fachliche Korrektur erfunden werden soll. Inhaltsänderungen werden zusätzlich durch Versionsvergleich erkannt. Persönliche Texte werden nicht überschrieben. Der neue Praxiskatalog liegt in `Core/Resources/practice.json` und besitzt stabile Kennungen.

Der Release-Check bezieht jetzt auch die 16 Fälle und 24 Fachgesprächsimpulse ein. Insgesamt 1.140 Inhaltseinheiten sind noch nicht unabhängig freigegeben. Der Debug-Build dient der internen Entwicklung. Eine Freigabe lässt sich nicht durch einen Softwaretest ersetzen.

## Native Abnahme auf dem Mac und iPhone

Vor Veröffentlichung zusätzlich zur bisherigen Abnahmeliste durchführen:

- 0.1-Sicherung in 0.2 importieren; eigene Karten, offene Runde, Termine und Opt-outs vergleichen.
- Einen Fall nach jeder Entscheidung beenden, App erzwingen zu schließen, anschließend exakt fortsetzen.
- Große Schrift und VoiceOver in Tagesplan, Kompetenzübersicht, Praxisformular, Fällen und Fachgespräch prüfen.
- Ruhigen Modus mit Hell/Dunkel, reduzierter Bewegung und Unterbrechung testen.
- Mikrofonfreigabe erlauben und verweigern; erneute Anfrage nach Ablehnung; Anruf, Sperren, Hintergrund, automatisches Ende nach fünf Minuten, Wiedergabe, Ersetzen und Löschen testen.
- Druckansicht und PDF-Sicherung mit langen Umlauttexten testen; vorher keine vertraulichen Betriebsdaten in Beispieltexte schreiben.
- Frage und Karte in einer separaten Testkopie fachlich ändern, Version erhöhen und Änderungsbeschreibung ergänzen; Hinweise und Erhalt eigener Texte kontrollieren.
- Fehlermeldung offline speichern, anschließend über den Teilen-Dialog selbst an einen gewählten Empfänger geben.
- Tip- und Bewertungsabstände auch beim Wechsel in neue Lernbereiche kontrollieren; keine Abfrage mitten in einer Übung.

Technische Referenzen: https://developer.apple.com/documentation/avfaudio/avaudiorecorder und https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller . Native API-Ausführung und vollständiger Apple-SDK-Typecheck stehen aus.
