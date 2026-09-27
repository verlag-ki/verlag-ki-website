# Version 0.4.0: direkter lernen

Stand: 21. September 2026, Build 9. Die folgenden Angaben ersetzen widersprechende Funktionsbeschreibungen älterer Entwicklungsstände.

## Lernkarten

Rechts wischen bedeutet „Verstanden“, links „Noch unsicher“. Beide Knöpfe bieten dieselben Aktionen ohne Wischgeste. Nach jeder Einschätzung erscheint automatisch die nächste Karte. Senkrechtes Scrollen und kurze Bewegungen lösen keine Bewertung aus. Große Schrift erhält untereinander angeordnete Knöpfe; VoiceOver bietet benannte Aktionen.

Einschätzung und Position werden gemeinsam gespeichert. Ein verspäteter Tipp auf die alte Karte verändert die nächste Karte nicht. Die Startseite setzt den angefangenen Stapel fort. Aus der Bibliothek geöffnete Karten verwenden die aktuelle Themen- oder Suchauswahl als Stapel. Fällige Karten haben Vorrang, danach folgen neue und später fällige Karten. Am Ende können ausschließlich unsichere Karten oder der ganze Stapel wiederholt werden. Persönliche Fassungen, Notizen, Bearbeitungsentwürfe und Quellen bleiben erreichbar.

## Aufgaben und Situationen

Die feste untere Aktion lautet zunächst „Antwort einloggen“. Danach erscheint die Erklärung, und derselbe Bereich bietet „Nächste Aufgabe“ beziehungsweise „Runde abschließen“. Eine gewählte Aufgabe in der Bibliothek beginnt eine Runde von bis zu 20 Aufgaben innerhalb der aktuellen Auswahl. Das ist eine Rundengröße, kein Zugriffslimit.

Auch Alltagssituationen trennen Auswahl, Einloggen, Erklärung und nächste Entscheidung. Der Erklärungsschritt bleibt nach einem Neustart erhalten. Prüfungssimulationen behalten ihre eigene Logik: Lösungen erst nach Abgabe.

## Ruhigere Oberfläche

Impressum und Datenschutz erscheinen nicht mehr in der Einführung. Sie bleiben unter Einstellungen erreichbar. Der Link „Inhalt prüfen oder Fehler melden“ entfällt im Lernfluss; Quellen bleiben aufklappbar und Support bleibt in den Einstellungen. Die fachlichen Entwurfs- und Prüfhinweise sind entfernt.

Julian Kürten hat die abgeschlossene fachliche Prüfung am 20.09.2026 bestätigt. Diese Auftraggeberbestätigung gilt für den vorhandenen Stand von 800 Aufgaben, 300 Karten, 16 Fällen und 24 Fachgesprächsimpulsen. Intern dokumentiert ContentInputs/FACHFREIGABE.json die Bestätigung mit Inhaltsprüfsummen. Es wird kein unbekannter unabhängiger Prüfer erfunden. Inhaltliche Änderungen brauchen eine erneute Freigabe; alte Quelldateien bleiben als Herkunftsnachweis erhalten.

Die dauerhaften Abschalter für Bewertungs- und Trinkgeldanfragen entfallen ausdrücklich auf Wunsch. Entsprechende alte Sicherungsfelder bleiben lesbar, beeinflussen die Nachfragelogik jedoch nicht mehr. Schließen beziehungsweise „Später entscheiden“ bleibt möglich. Nutzungsschwellen, Abstände, Prüfungssperrzeiten und Schutz laufender Aufgaben bleiben erhalten. Es gibt keine Zahlungspflicht. Hilfetexte und Datenschutzentwurf sind angepasst.

## Abnahme auf dem iPhone

1. Vor dem Update eine Sicherung exportieren. Das neue Projekt mit derselben Bundle-ID installieren, ohne die bestehende App zu löschen.
2. Eine Karte öffnen, rechts und links wischen sowie beide Knöpfe verwenden. Es muss jeweils genau eine Karte weitergehen. Senkrechtes Scrollen darf keine Einschätzung speichern.
3. Eine persönliche Karte bearbeiten, App schließen und erneut öffnen. Notizen und aktuelle Stapelposition müssen erhalten bleiben. Export und Import ebenfalls prüfen.
4. Themenfilter setzen und einen Stapel durchlaufen. Am Ende nur unsichere Karten wiederholen.
5. Aufgabe auswählen, einloggen, Erklärung lesen und nächste Aufgabe öffnen. Dasselbe in einer Alltagssituation prüfen, einschließlich Neustart während der Erklärung.
6. Mit großer Schrift, VoiceOver, Hell- und Dunkelmodus sowie „Bewegung reduzieren“ prüfen. Der untere Aktionsbereich darf keinen Text unzugänglich machen.
7. Einführung erneut über die Hilfe öffnen: keine Rechtstextlinks. Einstellungen: Rechtstexte und Kontakt vorhanden, dauerhafte Nachfrage-Schalter entfernt.

Der vorherige App-Start wurde vom Auftraggeber bestätigt. Die neue Version benötigt weiterhin einen Xcode-Build und eine native Bedienprüfung. Die rechtliche Freigabe sowie öffentliche Datenschutz- und Support-URLs sind weiterhin offen und bleiben vom fachlichen Status getrennt.

## Automatische Prüfungen

52 Kerntests, fünf Python-Prüfungen, Projektintegrität und Swift-Syntax bestanden. Details und Grenzen: PRUEFBERICHT.md.
