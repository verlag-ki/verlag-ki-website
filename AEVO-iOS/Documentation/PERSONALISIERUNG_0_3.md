# Persönlicher Einstieg und acht Farbwelten in 0.3.0

Stand: 20. September 2026. Diese Ergänzung setzt den Wunsch nach Name, Prüfungstag, zeitabhängiger Begrüßung, täglich wechselndem Lernimpuls und acht Farbwelten um.

## Der erste Einstieg

Beim ersten Start ohne abgeschlossenes Profil erscheint eine einzelne überspringbare Seite. Sie fragt nach Vorname oder Spitzname, einem optionalen Prüfungstag und der Lieblingsfarbwelt. Wer einen Prüfungstag einträgt, kann zwischen schriftlichem und praktischem Teil wählen. Ein fehlender zweiter Termin wird nicht erfunden. Der andere bestehende Prüfungstermin bleibt erhalten. Das ist insbesondere bei einer alten Sicherung wichtig.

„Loslernen“ übernimmt die ausgewählten Angaben. „Direkt loslegen, ohne Angaben“ schließt den Einstieg ohne Pflichtangaben ab und behält bereits gespeicherte Einstellungen. Die Farbe ist mit einer Begrüßung sofort auf derselben Seite als Vorschau sichtbar. Alle acht Varianten sind kostenlos. Eine noch nicht gespeicherte Eingabe auf der Einrichtungsseite ist kein dauerhafter Entwurf; erst Loslernen speichert sie. Der Abschluss des Einstiegs wird gespeichert, damit die Abfrage nicht bei jedem Start wieder erscheint. Ältere Datenbestände ohne Profil können diese Seite einmalig ebenfalls überspringen.

Name, Farbwelt und Sichtbarkeit des täglichen Impulses sind später unter Einstellungen → Name, Farbwelt & Lernimpuls änderbar. Dort wird ausdrücklich gespeichert; Abbrechen verwirft die Änderung. Prüfungstermine bleiben zusätzlich in ihrer vorhandenen Einstellungsansicht bearbeitbar.

## Persönliche Startseite

Die hervorgehobene Lernfläche zeigt in dieser Reihenfolge die Begrüßung, den optionalen Countdown, einen kurzen Tagesimpuls und die nächste Lernaktion. Eine zweite große Motivationsüberschrift entfällt. Die bisherige Kartenempfehlung heißt nun „Deine Lernkarte“, damit sie nicht mit dem Tagesimpuls verwechselt wird.

| Lokale Uhrzeit | Begrüßung mit einem Beispielnamen |
|---|---|
| 05:00 bis 10:59 | Guten Morgen, Julian. |
| 11:00 bis 17:59 | Guten Tag, Julian. |
| 18:00 bis 22:59 | Guten Abend, Julian. |
| 23:00 bis 04:59 | Hallo, Julian. |

Ohne Name steht die entsprechende Anrede ohne leeren Namensplatzhalter. Namen dürfen bis zu 40 Zeichen lang sein; Umlaute bleiben erhalten. Überflüssige Leerzeichen werden bereinigt. Lange Namen dürfen umbrechen und werden nicht mit einer festen Zeilenhöhe abgeschnitten.

Der Countdown bezieht sich auf den nächsten eingetragenen, nicht abgeschlossenen Prüfungsteil. Beispiele: „Noch 21 Tage bis zu deiner schriftlichen Prüfung.“, „Morgen ist deine praktische Prüfung.“ und „Heute ist deine schriftliche Prüfung.“ Es gibt kein „nur noch“, keine negativen Tage und kein automatisches Bestehen nach einem vergangenen Termin. Ohne passenden Termin entfällt die Zeile. Im bereits vorhandenen ruhigen Modus bleibt sie verborgen. Die Zeile öffnet die Terminbearbeitung.

Die Tageszählung verwendet lokale Kalendertage statt durch 24 Stunden geteilter Zeitabstände. Begrüßung und Tagesimpuls aktualisieren sich beim Öffnen, nach dem Zurückkehren in den Vordergrund und bei sichtbarer Startseite ungefähr alle 30 Sekunden. Eine begonnene Lernrunde wird nicht durch ein Begrüßungsfenster unterbrochen.

## Täglicher Lernimpuls

31 kurze eigenständig formulierte Texte sind offline enthalten. Sie werden deterministisch nach lokalem Kalendertag ausgewählt und wiederholen sich nach 31 Tagen. Am selben Tag bleibt der Text auch nach erneutem Öffnen gleich. Es werden keine bekannten Personen als Autoren genannt und keine fremden Zitate als eigene ausgegeben. Die Texte sind Anregungen, keine Versprechen einer bestimmten Lernwirkung. Beispiel: „Ein kleiner Lernschritt darf für heute genug sein.“

Der Impuls lässt sich in den Profileinstellungen ausblenden. Er erzeugt keine Benachrichtigung und keinen zusätzlichen Bestätigungsdialog.

## Acht Farbwelten

| Farbwelt | Dunkle Hauptfläche | Helle Aktionsfläche |
|---|---|---|
| Waldgrün | #142920 | #E0F3A7 |
| Ozeanblau | #12385B | #D5EAFE |
| Lavendel | #3C2B58 | #E8DDFA |
| Rosé | #55283E | #F9DDEA |
| Koralle | #652D21 | #FFE1CB |
| Sonnengelb | #4D3B13 | #F6E5A6 |
| Türkis | #12443D | #CAF3E9 |
| Graphit | #2B303A | #E2E6ED |

Jede Welt besitzt eigene helle und dunkle Hintergrund-, Inhalts- und Akzentfarben. Die Auswahl wird als SwiftUI-Umgebungswert durch die Ansichten gereicht. Ein Wechsel verändert Hauptfläche, Schaltflächen, Karten, Markierungen und Lernanzeigen ohne einen künstlichen Neustart der Navigation. Die Farbvorschau verwendet die gleichen Paletten wie die App. Farbnamen, Häkchen und VoiceOver-Auswahlzustand machen die Auswahl unabhängig von reiner Farberkennung. Bei sehr großer Schrift wird die Auswahl einspaltig.

Die bereits vorhandene Wahl System/Hell/Dunkel bleibt unabhängig vom Farbthema. Die wichtigsten eigens definierten Textpaare haben rechnerisch mindestens 4,5:1 Kontrast: Akzenttext auf Hintergrund und Inhaltsfläche in beiden Darstellungen, Weiß auf der Hauptfläche und Schaltflächentext auf der Aktionsfläche. Das ist keine vollständige native Barrierefreiheitsabnahme; insbesondere Systemtexte, tatsächliche Transparenzen, Fokus und Eingabefelder müssen noch auf einem Gerät geprüft werden. Das bisherige vorläufige Appsymbol wird dadurch nicht verändert.

## Daten, Schutz bestehender Entscheidungen und Prüfung

Das zusätzliche Profil ist ein optionaler Bereich des bestehenden lokalen Zustands. Alte Sicherungen bleiben lesbar und starten mit Waldgrün ohne Namen. Gespeichert werden Name, Farbwelt, abgeschlossener Einstieg und die Sichtbarkeit des Tagesimpulses. Diese Angaben gehören zur kostenlosen JSON-Sicherung und bleiben lokal, solange die Person ihre Sicherung nicht selbst weitergibt. Ein neues Konto, Server oder Analyseanbieter ist nicht erforderlich.

Eine Profiländerung setzt weder Lernstände noch eigene Notizen, Trinkgeld-Opt-outs oder Bewertungs-Opt-outs zurück. Ein geändertes Prüfungsdatum setzt nur den betroffenen Abschlussstatus zurück und veranlasst die vorhandene Neuplanung der Lernerinnerungen. Ohne Datum werden bestehende Termine nicht gelöscht. Automatische Bewertungs- und Trinkgeldanfragen bleiben gemäß 0.2.2 aktiv und selten; der persönliche Einstieg löst sie nicht aus.

43 Kerntests bestanden. Die neun neuen Tests prüfen die Zeitgrenzen der Begrüßung, Namensbereinigung, Sommerzeit und Prüfungstage, täglichen Textwechsel, Zeitzonenwechsel, Sicherung der Profilwerte, alte Daten und übersprungenen Einstieg, Erhalt abgeschlossener Prüfungen bei reiner Profiländerung sowie die genannten Kontraste aller acht Welten. Der Swift-Kern wurde kompiliert und ausgeführt. Alle 19 App-Dateien bestehen die Syntaxprüfung, und die Projektstruktur wurde mit 62 Objekten eingelesen.

Weiterhin ausstehend: vollständiger Apple-SDK-Typecheck und nativer Build, tatsächliche Darstellung in allen acht Welten mit Hell/Dunkel, erste Einrichtung auf dem iPhone, Tastatur und große Schrift, VoiceOver, Wiederaufnahme nach App-Ende und Farberhalt beim Öffnen verschachtelter Ansichten. Die Browser-Vorschau wurde nicht aktualisiert. Die fachlichen Lerninhalte sind weiterhin nicht unabhängig freigegeben.
