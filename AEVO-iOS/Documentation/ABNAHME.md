# Erste native Abnahme am Mac und iPhone

Diese Liste ist vorbereitet. Sie ist noch nicht als ausgeführt markiert. Die Linux-Ergebnisse stehen separat im Prüfbericht.

## Build und Start

- [ ] `Scripts/check_on_mac.sh` läuft mit einem geeigneten Xcode erfolgreich durch.
- [ ] Frischer Debug-Start im Simulator und auf dem iPhone öffnet die Startseite ohne Konto, Kauf oder Mitteilungsabfrage.
- [ ] 800 Aufgaben und 300 Karten werden geladen. Kein Entwurfs- oder Vorbehaltshinweis erscheint mehr in der Oberfläche.
- [ ] App-Icon zeigt das vorläufige Buchsymbol. Darstellung im hellen und dunklen Modus kontrollieren.

## Speichern und Unterbrechen

- [ ] Antwort auswählen, App beenden, erneut öffnen: dieselbe Auswahl und Position sind vorhanden.
- [ ] Antwort prüfen, App beenden, erneut öffnen: Erklärung und bewerteter Zustand bleiben erhalten; kein doppelter Tagespunkt.
- [ ] Titel, Erklärung und Notizen einer Karte speichern, neu starten: eigene Texte sind erhalten.
- [ ] Kartentext nur teilweise bearbeiten und App beenden: der Bearbeitungsentwurf lässt sich fortsetzen.
- [ ] Original wiederherstellen: gespeicherte zusätzliche Notizen bleiben erhalten; ein offener Entwurf wird erst nach Bestätigung verworfen.
- [ ] Inhaltsversion einer Karte ändern: Original aktualisiert sich, eigene Fassung und Notizen bleiben erhalten.
- [ ] SwiftData-Speicherfehler beziehungsweise voller Speicher: keine falsche Erfolgsmeldung, kein stiller Ersatz durch leere Daten.
- [ ] Praxisplan bearbeiten und neu starten: Felder sind erhalten.

## Sicherung und Offline-Nutzung

- [ ] Export in Dateien, Import auf einer zweiten Installation: Karten, Entwürfe, Notizen, Antworten, Termine, Abzeichen und Nachfrageeinstellungen entsprechen dem Sicherungsstand.
- [ ] Beschädigte, fremde und zukünftige Sicherungsdatei importieren: bisheriger Stand bleibt vollständig erhalten.
- [ ] Import abbrechen: keine Veränderung.
- [ ] Flugmodus nach Installation: Aufgaben, Karten, Notizen und Simulation funktionieren.
- [ ] Nicht erreichbarer Store und abgebrochener Kauf verändern keine Lernfunktion.

## Prüfung und Zeit

- [ ] Eine Simulation hat 80 Aufgaben aus 80 verschiedenen Aufgabenfamilien und läuft 180 Minuten.
- [ ] Offene, beantwortete und markierte Aufgaben sind in der Übersicht unterscheidbar; Antworten lassen sich bis zur Abgabe ändern.
- [ ] Vorzeitige Abgabe zeigt die Zahl offener Aufgaben und erfordert Bestätigung.
- [ ] Im Hintergrund und bei gesperrtem Gerät läuft die Zeit weiter. Nach normaler Rückkehr bleibt die Zeitbasis vergleichbar.
- [ ] Antworten lassen sich nach dem Ablauf nicht mehr ändern; die normale Simulation wird bei der nächsten Prüfung der Zeitbasis abgeschlossen.
- [ ] Uhrzeitverstellung und Geräteneustart werden geprüft. Bei nicht vergleichbarer Zeitbasis bleiben Antworten erhalten und der Versuch ist entsprechend gekennzeichnet.
- [ ] Nach einem Sicherungsimport bleibt die angefangene Prüfung erhalten und ist als zeitlich nicht vergleichbar markiert.
- [ ] Lösungen und richtige Alternativen werden erst nach Abgabe gezeigt.

## Termine, Motivation und Erinnerungen

- [ ] Schriftlicher und praktischer Termin lassen sich unabhängig eintragen, entfernen und verschieben.
- [ ] Countdown ist auch an lokaler Mitternacht und nach Zeitzonenwechsel verständlich und korrekt.
- [ ] Ein vergangener Termin wird nicht automatisch als Teilnahme oder Bestehen gespeichert.
- [ ] Wiederholtes Antippen derselben Karte zählt pro Tag nur einmal. Ein erreichtes Tagesziel bleibt bei Zielerhöhung bestehen.
- [ ] Pause in der Lernserie entfernt keine früheren Abzeichen oder Notizen.
- [ ] Mitteilungsberechtigung wird erst beim Einschalten angefragt. Ablehnung blockiert nichts.
- [ ] Geplante Erinnerungen verwenden gewählte Tage und Uhrzeit, höchstens eine pro Tag. Sommerzeitwechsel und konkurrierende schnelle Einstellungsänderungen prüfen.
- [ ] Tagesziel erreicht, Mitteilungen ausgeschaltet, Termin verschoben oder Vorbereitung abgeschlossen: veraltete ausstehende Meldungen werden entfernt.
- [ ] Nach vier Wochen ohne Nutzung sind keine weiteren Meldungen geplant.

## StoreKit und Bewertungen

- [ ] Mit der lokalen StoreKit-Konfiguration alle drei Beträge prüfen. Keine Vorauswahl und keine zusätzlichen Lernrechte.
- [ ] Abbruch, ausstehender Kauf, Verifizierungsfehler, fehlende Produkte und fehlendes Netz ergeben verständliche Zustände.
- [ ] Verifizierte Transaktionen werden vor Abschluss gespeichert; doppelte Lieferung erzeugt keinen doppelten Eintrag.
- [ ] Kaufbestätigung während geschlossener Unterstützungsansicht wird beim nächsten Transaktionsabgleich verarbeitet.
- [ ] Bewertungsanfrage erst nach 60 aktiven Lernminuten, drei abgeschlossenen Einheiten und Lernen an zwei Kalendertagen; keine vorgeschaltete Sterneauswahl.
- [ ] 180 Tage Abstand zwischen Bewertungsaufrufen, 14 Tage zwischen Bewertungs- und Trinkgeldanfragen sowie Sperrzeit vor beiden Prüfungsterminen einhalten.
- [ ] iOS darf den Dialog unterdrücken. Die App startet deshalb keine unmittelbare zweite Anfrage.
- [ ] Trinkgeldgrenzen und Sicherungswiederherstellung prüfen. Seit 0.3.4 gibt es kein dauerhaftes Ausblenden mehr; eine alte Sicherung mit den früheren Schaltern darf die Hinweise nicht unterdrücken.

## Bedienbarkeit

- [ ] Kernwege mit VoiceOver, großer und sehr großer Schrift, erhöhtem Kontrast und reduzierter Bewegung ausprobieren.
- [ ] Heller und dunkler Modus: Überschriften, Antworten, Erklärung, Texteditoren, Picker, Preise und Fehlermeldungen bleiben lesbar.
- [ ] Kleines iPhone und Querformat: keine abgeschnittenen Antworten, alle Aktionen erreichbar.
- [ ] Kritische Speichermeldungen auch innerhalb einer geöffneten Karten- oder Lernsitzung sichtbar und verständlich.
- [ ] Mindestens fünf Lernende bearbeiten neue Situationen und erklären ihre Lösung. Gestaltung und Wiedererkennen allein gelten nicht als Lernnachweis.


## Zusätzliche Abnahme für Version 0.2.0

Die zusätzlichen Geräteprüfungen für Tagesplan, alte Sicherungen, Fallverläufe, Sprachaufnahme, Druckexport und Inhaltsversionen stehen in `ERWEITERUNGEN_0_2.md`. Keine dieser nativen Prüfungen ist bisher als bestanden markiert.


## Vorrangige Abnahme 0.2.1

- Keine automatische Storebewertung und kein automatisches Trinkgeldfenster nach langen Lernphasen oder Prüfungsterminen.
- Lernrunde mit einer Hauptaktion starten; Abschlussseite bietet nur Fertig und Noch eine Runde.
- Notizen, Quellen, Merkliste und Antwortdetails finden; neue Aufgabe beginnt mit geschlossenen Details.
- Lernfortschritt und persönliche Sammlung aus dem Menü des Lernbereichs öffnen.
- Praxiswege ohne langes vorgeschaltetes Formular nutzen; bestehende persönliche Texte hinter den optionalen Detailfeldern prüfen.
- Aufnahme stoppen beim Einklappen, Fragenwechsel oder Verlassen; keine Mikrofonabfrage ohne ausdrückliche Aufnahmeaktion.

Diese UI-Prüfungen wurden noch nicht auf einem iPhone ausgeführt. Frühere Abnahmekriterien zu automatischen Nachfragen sind aufgehoben.


## Vorrangige Korrektur 0.2.2

Automatische Nachfragen sind wieder beabsichtigt. Die frühere Forderung, sie grundsätzlich auszuschließen, entfällt. Prüfen: Schwellen und Abstände, dauerhafte Abschaltung, keine Anzeige nach Verlassen der Abschlussseite oder im Hintergrund sowie erfolgreiche native StoreKit-Anbindung. Alle anderen Vereinfachungsprüfungen bleiben bestehen.


## Zusätzlich für 0.3.0

- Erster Start mit und ohne Name/Termin, unmittelbares Überspringen, Abschluss speichern und App neu starten: Einstieg erscheint nicht erneut.
- Datum dem richtigen Prüfungsteil zuordnen; vorhandener anderer Termin bleibt bestehen. Reine Profiländerung öffnet abgeschlossene Prüfungsteile nicht wieder.
- Alle acht Farbwelten im Hell- und Dunkelmodus: Startseite, Aufgaben, Karten, Eingaben, Einstellungen, Support und verschachtelte Sheets prüfen.
- Langer Name, Umlaute, sehr große Schrift, Tastatur und VoiceOver: nichts abschneiden, alle acht Farben erreichbar, Auswahl auch ohne Farberkennung verständlich.
- Farbwechsel verändert keine laufende Runde und keine persönlichen Kartentexte; Export/Import erhält Name, Farbe und Opt-outs.
- Begrüßung und Impuls nach Mitternacht, Sommerzeitwechsel und Vordergrundwechsel prüfen; keine Unterbrechung einer laufenden Lernrunde.
- Täglichen Impuls ausblenden und ruhigen Modus aktivieren; Countdown bleibt dort verborgen.

Alle genannten nativen Prüfungen sind weiterhin offen.


## Quellen für tägliche Zitate ab 0.3.1

- [ ] An einem Zitat-Tag stehen Text, vollständiger Urhebername und „Quelle“ auf Startseite und Profilvorschau; eigene Impulse haben keine fremde Zuschreibung.
- [ ] „Quelle“ öffnet ausschließlich auf Wunsch die passende Fundstelle. „Fertig“ führt zur unveränderten Ausgangsansicht zurück.
- [ ] Quellenansicht im Flugmodus öffnen: Text, Werk und Wortlauthinweise bleiben lesbar; nur der Weblink braucht Internet.
- [ ] Alle acht Farbwelten in Hell/Dunkel sowie große Dynamic-Type-Stufen und VoiceOver prüfen. Autorennamen und Zitat werden nicht abgeschnitten; in der Quellenansicht bleibt Text lesbar.
- [ ] App mehrfach starten: Impuls bleibt am selben lokalen Tag gleich. Über Mitternacht aktualisiert die Startseite; eine bereits offene Quelle behält das angetippte Zitat.
- [ ] Impuls ausblenden, speichern und neu starten: Startseite und Profilvorschau respektieren die Auswahl; vorhandene Termine, Notizen und Nachfrage-Opt-outs bleiben erhalten.


## Swipe-Kartenstapel und Ein-Tipp-Antworten ab 0.3.4

- [ ] Karte antippen deckt die Rückseite auf; erneutes Antippen klappt sie wieder zu.
- [ ] Wisch nach rechts wertet als „Verstanden“, nach links als „Noch unsicher“. Die nächste Karte steht danach ohne weiteren Tipp bereit.
- [ ] Ein abgebrochener Wisch unter der Auslöseschwelle federt zurück und verändert keinen Wiederholungsstand.
- [ ] Dieselbe Karte mehrfach an einem Tag bewerten: der Tagesfortschritt zählt weiterhin nur einen Schritt.
- [ ] Zähler für Position, verstandene und vorgemerkte Karten stimmt mit den tatsächlichen Wischen überein.
- [ ] Am Stapelende erscheint die Abschlussansicht; „Nächster Stapel“ lädt weitere Karten, „Fertig“ schließt.
- [ ] VoiceOver: Karte ist ein zusammenhängendes Element mit den Aktionen „Verstanden“ und „Noch unsicher“; Wischen ist nicht erforderlich.
- [ ] Reduzierte Bewegung und ruhiger Modus: Karten wechseln ohne Flug- und Federanimation, die Bewertung greift unverändert.
- [ ] Große Dynamic-Type-Stufen: Kartentext scrollt innerhalb der Karte, die Bewertungsschaltflächen bleiben mit mindestens 44 × 44 pt sichtbar.
- [ ] Aus dem Stapel „Bearbeiten“ öffnen, speichern und zurückkehren: der Stapel steht weiterhin bei derselben Karte.
- [ ] Aufgabe mit einer richtigen Antwort: ein Tipp auf die Antwort wertet sofort aus, die Auswertung wird sichtbar, darunter steht „Nächste Aufgabe“.
- [ ] Aufgabe mit mehreren richtigen Antworten: die Auswahl bleibt änderbar, erst „Antwort prüfen“ wertet aus.
- [ ] Nach einer richtigen Antwort „War eher geraten – nochmal zeigen“ antippen: die Aufgabe erscheint im Filter „Fehler & Unsicherheit“, die Antwort bleibt als richtig gezählt, es entsteht kein zweiter Versuch.
- [ ] App während einer bewerteten Aufgabe beenden und erneut öffnen: Antwort, Auswertung und ein gesetzter Unsicherheitsvermerk sind erhalten.
