# AEVO für iPhone: Produkt- und Gestaltungskonzept

Technischer Nachtrag 0.5.0 vom 21. September 2026: Das bestehende Projekt ist jetzt als gemeinsame Learning Engine mit austauschbarer AppConfig und Content-Pack refaktoriert. Die AEVO-Inhalte und die Nutzerabläufe bleiben erhalten. Maßgeblich für Implementierung, Migration und Prüfstand sind `REFACTORING_0_5_0.md`, `PRUEFBERICHT.md` sowie `../NEW_APP_GUIDE.md`. 64 Swift- und 16 Python-Tests bestanden; der native Build und die Geräteabnahme stehen aus. Die folgenden Produktentscheidungen bleiben gültig, frühere technische Versionsangaben sind historisch.

Stand: 21. September 2026, einschließlich des bestätigten Ablaufs für Prüfungstermine, Countdown, Lernerinnerungen, Storebewertungen und freiwillige Unterstützung. Verbindliche Ausrichtung: ausschließlich iOS, zunächst iPhone. „aevo.“ ist ein Arbeitsname; Verfügbarkeit und Markenrechte sind noch nicht geprüft.

Dieses Konzept konkretisiert die vorhandene Wettbewerbsanalyse. Die frühere Empfehlung einer gemeinsamen technischen Basis für iOS und Android ist durch die Entscheidung des Auftraggebers aufgehoben. Nach ausdrücklichem Auftrag zum Beginn der Programmierung liegt jetzt der native Quellcodestand 0.4.0 vor. Der Mac soll erst möglichst spät eingesetzt werden. Der Foundation-Programmkern wurde auf Linux kompiliert und mit 52 Tests geprüft; zusätzlich bestanden fünf Python-Prüfungen und die Swift-Syntaxprüfung. Der iOS-Build und die Geräteabnahme der neuen Version stehen aus. Der bisherige interaktive Bedienungsentwurf bleibt eine getrennte Vorschau mit Beispieldaten.

## 1. Die Produktentscheidung

Die App soll sich wie ein persönlicher, angenehm ruhiger Lernbegleiter anfühlen. Nach dem Öffnen ist sofort klar, was als Nächstes sinnvoll ist. Eine kurze Runde verbindet eine Entscheidung mit ihrer Erklärung und einer passenden Lernkarte. Die praktische Vorbereitung wird Schritt für Schritt aufgebaut.

Der Mehrwert gegenüber einem günstigen Fragenkatalog liegt in verständlichen Begründungen, der Verbindung von Aufgaben und eigenen Lernnotizen sowie einer gut geführten Vorbereitung auf das Fachgespräch. Ein zeitgemäßes Erscheinungsbild unterstützt diese Nutzung; es beweist allein keinen besseren Lernerfolg.

Alle veröffentlichten Inhalte bleiben dauerhaft kostenlos. Das gilt auch für spätere Ergänzungen, Kartenbearbeitung, Wiederholung, Prüfungssimulation und Sicherung. Keine Werbung, keine Kontopflicht, keine Freischaltungen. Freiwillige Trinkgelder sind der einzige geplante Erlösweg.

## 2. Das Erscheinungsbild

Die Oberfläche verbindet warme helle Flächen mit dunklem Grün und einem hellen gelbgrünen Akzent. Dunkle Ansichten erhalten eigene abgestimmte Farben. Die App übernimmt zunächst die Geräteeinstellung; „System“, „Hell“ und „Dunkel“ sind wählbar.

| Gestaltung | Festlegung | Zweck |
|---|---|---|
| Hintergrund | Hell `#F5F6F2`, dunkel `#141C19` | Ruhige Lesefläche |
| Inhaltsfläche | Hell `#FFFFFF`, dunkel `#1E2924` | Klar begrenzte Aufgaben und Karten |
| Haupttext | Hell `#183A30`, dunkel `#F2F5EF` | Gut lesbare Hierarchie |
| Hauptaktion | Hell `#235847`, dunkel `#B8E4BD`, jeweils mit passender Textfarbe | Eindeutiger nächster Schritt |
| Akzent | `#E0F3A7` auf dunklem Hintergrund | Sparsamer freundlicher Impuls |
| Schrift | iOS-Systemschrift mit Dynamic Type; Fließtext im nativen Entwurf als Ausgangspunkt 17 pt | Vertraut und anpassbar |
| Formen | Runde Inhaltsflächen, weiche Ecken, wenig sichtbare Trennlinien | Übersicht ohne Tabellenanmutung |
| Symbole | Buch mit Häkchen als vorläufiges Appzeichen; in der nativen Oberfläche SF Symbols und verständliche Beschriftungen | Klarer Bezug zum Lernen |
| Bewegung | Kurze Übergänge, dezentes optionales haptisches Feedback | Rückmeldung ohne Ablenkung |

Das anfängliche Pflanzensymbol ist ersetzt. Der Entwurf verwendet ein Buch mit Häkchen als vorläufiges Zeichen für Lernen und Anwendung. Ein finaler nativer App-Icon-Satz ist damit noch nicht erstellt.

Ein gemeldeter Darstellungsfehler betraf schwarze Überschriften und hervorgehobene Texte im Dunkelmodus. Der Entwurf weist diesen Texten nun ausdrücklich die zur jeweiligen Fläche passende Farbe zu. Der Regressionstest umfasst insbesondere einen hellen Chat mit dunkel geschaltetem App-Entwurf.

Aufgaben und Erklärungen liegen auf deckenden Flächen. Aktuelle Systemmaterialien werden später über native Navigations- und Bedienelemente eingesetzt. Apple beschreibt Liquid Glass als Ebene für Navigation und Bedienung; großflächiges Glas hinter Lerntexten ist deshalb keine Gestaltungsvorgabe. Die Vorschau zeigt die Form- und Farbidee, keine originalgetreue Implementierung eines bestimmten iOS-Materials. [Apple: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

## 3. Vier Bereiche, eine klare Startseite

| Bereich | Inhalt | Wichtigste Aktion |
|---|---|---|
| **Heute** | Nächste kurze Lerneinheit, Tagesziel und optionale Lernserie; eine passende Karte | „Los geht’s“ beziehungsweise „Weiterlernen“ |
| **Lernen** | Aufgaben und Lernkarten; Themen, Merkliste, Wiederholungen, eigene Notizen | Thema oder fällige Wiederholung öffnen |
| **Prüfung** | Simulation starten oder fortsetzen, frühere Auswertungen | „Generalprobe starten“ |
| **Praxis** | Ausbildungssituation, Lernziel, Methode, Ablauf, Fachgespräch | Nächsten Planungsschritt bearbeiten |

Einstellungen sind oben erreichbar und erhalten keinen eigenen Haupttab. Während einer abgeschlossenen Lernrunde oder Simulation tritt die Hauptnavigation zurück. Das Beenden der Ansicht verwirft keine Arbeit. In der späteren App behält jeder Hauptbereich seinen Navigationsstand. Das entspricht auch Apples Empfehlung, wenige beschriftete Tabs für dauerhafte Bereiche zu verwenden und den Zustand beim Wechsel zu erhalten. [Apple: Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)

Die Startseite besteht aus einer hervorgehobenen Lernhandlung mit Tagesfortschritt, einer kompakten Lernserie und einem ergänzenden Kartenzugang. Bei eingetragenem Prüfungstermin ergänzt eine ruhige Textzeile den Countdown bis zum nächsten noch offenen Prüfungsteil, beispielsweise „Noch 21 Tage bis zur schriftlichen Prüfung“. Das Abzeichensymbol oben führt zur Sammlung. Weitere Einstellungen und Unterstützung liegen außerhalb der laufenden Lernhandlung.

Beispieltexte: **„Dein nächster Aha-Moment.“**, **„Kleine Schritte. Klarer Kopf.“**, **„Wir machen da weiter, wo du warst.“** Nach einer Runde steht das Erreichte im Mittelpunkt: **„Drei Aufgaben bearbeitet. Das solltest du später noch einmal anwenden.“**

## 4. Lernen soll sich gut anfühlen

Eine Runde dauert nach eigener Wahl ungefähr fünf oder zehn Minuten. Der angezeigte Umfang ist eine Zeitabschätzung, kein Limit. Man kann jederzeit weiterlernen oder aufhören. Zum Start werden Termin und Lernzeit optional abgefragt; „Direkt loslegen“ bleibt gleichwertig erreichbar.

Die Auswahl bevorzugt fällige Wiederholungen, falsche oder unsichere Antworten und danach ein neues Thema. Eine verständliche Begründung erklärt die Auswahl, beispielsweise: „Diese Aufgabe hast du vor drei Tagen noch unsicher beantwortet.“ Themenwahl und freies Üben bleiben jederzeit möglich.

In der Fragenansicht stehen Handlungsfeld, Aufgabe und Antwortmöglichkeiten im Vordergrund. Bei Mehrfachauswahl ist die Aufgabenform eindeutig angegeben. Eine Auswahl wird erst mit „Antwort prüfen“ bewertet. Nach der Bewertung erscheinen zuerst die passende Begründung und danach auf Wunsch Erklärungen zu den falschen Alternativen. „Passende Lernkarte ansehen“ öffnet die Karte und führt anschließend zur unveränderten Aufgabe zurück.

Eine falsche Antwort wird freundlich und konkret aufgegriffen: **„Schauen wir genauer hin.“** Richtig und falsch werden zusätzlich zur Farbe durch Text und Symbol kenntlich. Es gibt keine verlorenen Leben, öffentlichen Ranglisten oder beschämenden Meldungen. Die neu gewünschte freiwillige Lernserie zählt Tagesziele; eine unterbrochene Serie löscht keinen Lernfortschritt und keine erreichten Abzeichen.

Motivation entsteht durch abgeschlossene kleine Einheiten, zunehmend anspruchsvolle Anwendungen und sichtbare eigene Gedanken. Eine erste richtige Antwort bedeutet „bearbeitet“. Erst zeitlich verzögerte Wiederholung und neue Anwendung liefern Hinweise auf gefestigtes Verständnis. Eine Gesamtanzeige wie „90 % prüfungsbereit“ ist nicht vorgesehen.

### Tagesstrecke und Lernserie

Die Tagesstrecke ist ein selbst gewähltes Ziel von zunächst 3, 5 oder 10 Lernschritten. Der Startwert beträgt drei. Als Schritt zählt eine bearbeitete Aufgabe mit geöffneter Erklärung oder eine aufgedeckte und selbst eingeschätzte Kartenwiederholung. Dieselbe Aufgabe beziehungsweise Karte zählt pro lokalem Kalendertag nur einmal. Bloßes Öffnen der App, Kaufen oder schnelles mehrfaches Antippen zählen nicht zusätzlich. Das Tagesziel begrenzt niemals den Zugang zu weiteren Aufgaben.

Die Lernserie zählt aufeinanderfolgende Kalendertage mit erreichtem Tagesziel. Vor Abschluss des heutigen Tages bleibt eine gestern fortgesetzte Serie aktiv. Nach einem ausgelassenen Tag beginnt die aktuelle Serie neu; frühere Abzeichen, längste Serie, Notizen und Lernfortschritt bleiben erhalten. Es gibt keine Zahlung zum Retten einer Serie und keine drohenden Nachrichten. Die Anzeige der Serie ist abschaltbar. Ein schon erreichtes Tagesziel wird bei einer späteren Zieländerung nicht rückwirkend entzogen.

Die native Speicherung verwendet Tageskennungen in der lokalen Zeitzone, Ereigniskennungen für die einmalige Zählung und das am betreffenden Tag geltende Ziel. Mitternacht, Sommerzeit, Wiederherstellung und ein Zeitzonenwechsel werden gesondert geprüft. Eine Kalenderfolge ist ein Motivationssignal, keine Bestehenswahrscheinlichkeit und kein Nachweis fachlicher Beherrschung.

### Sechs Abzeichen mit sichtbaren Bedingungen

| Abzeichen | Bedingung | Aussagegrenze |
|---|---|---|
| Erste Runde | Eine Runde mit drei unterschiedlichen Aufgaben abschließen | Teilnahme, keine behauptete Beherrschung |
| In eigenen Worten | Eine persönliche Kartenfassung oder eigene Notiz speichern | Eigene Lernorganisation, keine fachliche Freigabe der Notiz |
| Heute geschafft | Ein selbst gewähltes Tagesziel erreichen | Aktivität für einen Tag |
| Drei Lerntage | Drei aufeinanderfolgende Tagesziele erreichen | Kontinuität, keine Lernerfolgsgarantie |
| Rundumblick | In jedem Handlungsfeld mindestens eine Aufgabe bearbeiten oder Karte wiederholen und einschätzen | Einstieg in alle vier Bereiche, keine vollständige Abdeckung |
| Plan festgehalten | Situation, Lernziel, Methodenbegründung und Ablauf im Praxisplan ausfüllen | Planentwurf, keine Qualitätsbenotung |

Alle Abzeichen sind vorab sichtbar und ihre Bedingungen lassen sich öffnen. Erreichte Abzeichen bleiben bestehen. Ein Abzeichen ist niemals käuflich. Neue Auszeichnungen werden auf der Abschlussseite oder in der Übersicht gezeigt und unterbrechen keine Frage oder Simulation. Erteilungsdatum, Bedingungsversion und Nachweisreferenzen gehören zur späteren lokalen Sicherung.

Die ersten Abzeichen würdigen überwiegend Mitarbeit und Lernorganisation. Ein späteres Abzeichen für gefestigtes Wissen soll deshalb strenger sein: beispielsweise drei Lernziele nach zeitlichem Abstand wiederholt und jeweils an einer neuen, fachlich geprüften Transferaufgabe korrekt angewendet. Das wird erst umgesetzt, wenn der Fragenkatalog solche Zuordnungen zuverlässig trägt.

### Lernerinnerungen

Die Erinnerung ist zunächst ausgeschaltet. Wählbar sind Uhrzeit, einzelne Wochentage und „Bei erreichtem Tagesziel heute nicht erinnern“. In der Vorschau ist 19:00 Uhr an Werktagen lediglich die voreingestellte Auswahl. Der Nutzer muss die Erinnerung selbst einschalten und speichern. Der native iOS-Berechtigungsdialog folgt erst in diesem Zusammenhang; bei Ablehnung bleibt das Lernen uneingeschränkt möglich. Apple empfiehlt eine verständliche, situationsbezogene Anfrage und die Prüfung des aktuellen Berechtigungsstands. [Apple: Berechtigung für Mitteilungen](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications)

Für die App sind lokale Mitteilungen vorgesehen. iOS kann sie auch bei geschlossener App zustellen; ein eigener Push-Server ist für diesen Zweck nicht nötig. Geplante Mitteilungen lassen sich wieder entfernen. [Apple: Lokale Mitteilungen planen](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app)

Produktentscheidung für die native Umsetzung: höchstens eine Lernerinnerung pro gewähltem Tag, zunächst ein rollierender Plan für vier Wochen. Beim Öffnen und bei Änderungen wird er erneuert. Nach vier Wochen ohne App-Nutzung enden weitere Erinnerungen. Wird das Tagesziel rechtzeitig erreicht, entfällt die noch ausstehende Mitteilung dieses Tages, sofern die entsprechende Option aktiv ist. Ausschalten entfernt alle noch ausstehenden Lernerinnerungen. Nach Gerätewechsel werden Einstellungen wiederhergestellt und die Systemberechtigung neu geprüft. Eine garantierte Zustellung auf die Minute wird nicht versprochen.

Beispieltext: **„Zeit für einen kleinen Lernschritt? Deine nächste Runde wartet auf dich. Du bestimmst das Tempo.“** Diese Erinnerungen enthalten weder Bewertungs- noch Zahlungsaufforderungen und keine Drohung, einen Lernstand zu verlieren. In der Vorschau werden keine echten Mitteilungen versendet.

### Bestätigte Ergänzung: Prüfungstermine und Countdown

Die Person kann beim Einstieg oder später getrennt den schriftlichen und den praktischen Prüfungstermin eintragen. Beide Angaben sind optional, unabhängig voneinander änderbar und Bestandteil der kostenlosen Sicherung. „Direkt loslegen“ bleibt möglich. Ein fehlender praktischer Termin wird nicht aus dem schriftlichen Datum abgeleitet. Die Tageszählung richtet sich nach lokalen Kalendertagen; am Termin steht „Heute ist dein Prüfungstermin“ statt eines negativen Countdowns.

Die verbleibende Zeit beeinflusst die vorgeschlagenen Inhalte. Anfangs stehen Grundlagen und Themenabdeckung im Vordergrund, später neue Anwendungsfälle und gezielte Wiederholung. In der letzten Woche werden konkrete Lücken priorisiert. Die App erhöht weder automatisch die Zahl der Erinnerungen noch das selbst gewählte Tagesziel. Gewählte Wochentage und Uhrzeiten sowie die Obergrenze von einer Lernerinnerung pro gewähltem Tag bleiben verbindlich. Beispiel bei passendem Lernstand: „Noch sieben Tage bis zur schriftlichen Prüfung. Deine nächste kurze Runde wiederholt Themen, bei denen du noch unsicher warst.“

Bei einer Terminänderung werden ausstehende Mitteilungen und Countdown gemeinsam neu berechnet. Erinnerungen für einen Prüfungsteil werden nicht über dessen eingetragenen Termin hinaus geplant. Nach bestätigtem Abschluss des schriftlichen Teils kann die Vorbereitung auf den praktischen Teil weiterlaufen. Wenn dafür kein Datum bekannt ist, bleibt die praktische Vorbereitung ohne Countdown zugänglich.

Ab dem Tag nach einem verstrichenen Termin erscheint beim nächsten Besuch eine unaufdringliche organisatorische Rückfrage: „Ist dein Prüfungstermin wie geplant gelaufen?“ Die Person kann den Teil als abgeschlossen markieren, einen neuen Termin eintragen oder später entscheiden. Ein vergangenes Datum beweist weder Teilnahme noch Bestehen. Auch nach dem letzten bekannten Termin wird ein vollständiger Abschluss nicht automatisch angenommen. Erst wenn die Person die gesamte Vorbereitung beendet, werden alle ausstehenden Lernerinnerungen entfernt; Notizen und Lerninhalte bleiben zugänglich. Dieser Rückblick löst keine automatische Kette aus Bewertung und Trinkgeld aus.

Diese Ergänzung ist als Produktentscheidung bestätigt. Die aktualisierten Termin- und Nachfrageregeln sind im vorliegenden Bedienungsentwurf noch nicht umgesetzt.


## 5. Alle 300 Lernkarten werden persönlich bearbeitbar

Eine Karte zeigt vorne ein Thema und die Einladung, es selbst zu erklären. Hinten stehen kurze Erklärung, Merksatz und gegebenenfalls ein Beispiel. „Noch unsicher“ und „Verstanden“ steuern die nächste Wiederholung; ein Fingertipp allein belegt noch keine Beherrschung.

**Verbindlich ab Version 1:** Titel, Erklärung, Merksatz und Beispiel jeder Karte lassen sich bearbeiten. Zusätzlich gibt es ein separates Feld „Meine Notizen“. „Speichern“ bestätigt das dauerhafte lokale Sichern. Ein Bearbeitungsentwurf wird während der Eingabe gesichert und nach Unterbrechung wieder angeboten.

Es gibt drei getrennte Datenebenen:

| Ebene | Verhalten |
|---|---|
| Redaktionelles Original | Stabile Kartenkennung, Version, Quellen und Prüfstand; jederzeit einsehbar |
| Persönliche Fassung | Eigene Änderungen, sichtbar als „Eigene Fassung“; mit Bezug auf die verwendete Originalversion |
| Eigene Notizen | Separate Gedanken aus Kurs, Arbeit oder Lernen; bleiben auch nach Wiederherstellung des Originals erhalten |

Ein Inhaltsupdate überschreibt keine persönlichen Texte. Wenn sich das Original ändert, erscheint bei Bedarf: **„Das Original wurde aktualisiert. Deine Fassung bleibt erhalten.“** Danach können beide Fassungen verglichen werden. Eine inhaltlich korrigierte Originalkarte erhält einen sichtbaren Hinweis, damit eine ältere persönliche Fassung nicht versehentlich als fachlich aktueller Text erscheint.

„Originaltext übernehmen“ setzt die persönliche Fassung zurück; Notizen bleiben erhalten. Für die native App wird eine Bestätigung oder Rückgängig-Aktion vorgesehen. Änderungen an Karten verändern niemals Lösungsschlüssel oder Prüfungsergebnisse. Export und Import umfassen Originalbezug, persönliche Fassung, Notizen und Wiederholungsstand. „Meine Notizen“ führt gesammelt zu entsprechend bearbeiteten Karten.

## 6. Prüfung und praktische Vorbereitung

Der Prüfungsbereich trennt Üben und Simulation. Vor dem Start stehen Umfang, Zeit, Bewertungsmodell und verwendetes Prüfungsprofil. Grundlage bleiben die verifizierten Regeln im Hauptkonzept; eine äußerlich ähnliche Oberfläche wird nicht als identische IHK-Prüfungssoftware beworben.

Während der Simulation können Aufgaben gewechselt, markiert und Antworten geändert werden. Lösungen erscheinen erst nach Abschluss. Vor vorzeitigem Abgeben zeigt eine Bestätigung die unbeantworteten Aufgaben. Die native App sichert Antwortstand und Zeitbasis. Eine unterbrochene Simulation lässt sich fortsetzen; mit zusätzlicher Pause absolvierte Versuche werden klar als pausiert gekennzeichnet. Der Umgang mit dem Zeitablauf wird je Simulationsmodus transparent beschrieben.

Die Auswertung führt vom Ergebnis zu einem konkreten Lernschritt. Sie unterscheidet bekannte Fragen von erstmals gesehenen Transferaufgaben. Die Vorschau enthält lediglich drei Beispielaufgaben ohne Prüfungstimer und ist ausdrücklich keine vollständige Prüfungssimulation.

Der Praxisbereich führt durch vier Schritte:

1. **Thema:** Ausbildungsberuf, Ausgangssituation und Lernstand der auszubildenden Person.
2. **Lernziel und Methode:** Beobachtbares Ergebnis, Bedingungen, Maßstab und begründete Methodenwahl.
3. **Ablauf:** Einstieg, Erarbeitung, selbstständige Anwendung, Lernkontrolle und Abschluss.
4. **Fachgespräch:** Eigene Entscheidungen erklären, Alternativen bedenken und auf Schwierigkeiten reagieren.

Beispielimpulse: **„Warum passt deine Methode zu diesem Lernziel?“**, **„Woran erkennst du, dass das Lernziel erreicht wurde?“**, **„Wie würdest du auf einen Fehler reagieren?“** Eine Gedankenstütze wird erst auf Wunsch geöffnet. Ein Textplan ist kein Beleg, dass jemand eine praktische Prüfung beherrscht. Die Vorgaben der zuständigen Kammer bleiben sichtbar maßgeblich.

## 7. Drei konkrete Nutzerwege

**Die ersten fünf Minuten:** App öffnen, bei Bedarf „Direkt loslegen“, eine kurze Runde bearbeiten, eine Erklärung verstehen und die passende Karte öffnen. Anschließend eine eigene Notiz ergänzen. Kein Konto, keine Zahlung und keine Berechtigungsabfrage sind für diesen Weg nötig. Prüfungstermin und Lernzeit können später ergänzt werden.

**Nach einem Arbeitstag:** „Weiterlernen“ öffnet eine angefangene Runde; ansonsten startet eine kurze Mischung aus Wiederholung und einem neuen Fall. Bei Unterbrechung bleibt die zuletzt gewählte Antwort erhalten. Die Abschlussansicht nennt einen nächsten Lernschritt und erlaubt einen bewussten Abschluss.

**In der letzten Woche:** Eine vollständige Simulation zeigt konkrete Lücken. Die Person übt neue Fälle aus diesen Bereichen, öffnet eigene Kartennotizen und geht anschließend den Praxisplan samt Fachgespräch durch. Die App erhöht weder Zeitdruck noch Trinkgeldnachfragen.

## 8. Offline, Sicherung und native Grundlage

Für die reine iOS-Ausrichtung empfehle ich **SwiftUI**. Es bietet eine native Grundlage für Navigation, Systemschrift, Animationen und Bedienungshilfen. Die Plattformentscheidung ist getroffen; eine zweite Oberfläche wird nicht mitentwickelt. [Apple: SwiftUI](https://developer.apple.com/swiftui/)

Geplant sind mitgelieferte versionierte Inhaltsdateien und eine getrennte lokale Speicherung der Lern- und Nutzerdaten. **SwiftData** ist die erste Wahl für diese lokale Speicherung; die Mindestversion und Migrationen werden vor dem nativen Aufbau festgelegt und getestet. SwiftData unterstützt dauerhafte Speicherung sowie optional geräteübergreifende Synchronisierung, macht eine solche Synchronisierung aber nicht automatisch zu einem fertigen Produktmerkmal. [Apple: SwiftData](https://developer.apple.com/documentation/swiftdata)

Version 1 bietet kostenlosen Export und Import über die Dateien-Funktionen von iOS. Geräteverlust ohne vorherige externe Sicherung kann durch rein lokale Speicherung nicht aufgefangen werden. Deshalb zeigt die Sicherungsansicht verständlich den Stand der letzten Sicherung. Eine spätere optionale iCloud-Synchronisierung muss Konflikte persönlicher Fassungen lösen und bleibt kostenlos.

Ohne Internet funktionieren sämtliche ausgelieferten Aufgaben, Karten, Notizen, Wiederholungen, Simulationen und Praxisentwürfe. Nur Funktionen mit tatsächlichem Netzzweck benötigen eine Verbindung, etwa neue Inhaltsstände, externe Quellenlinks oder ein freiwilliger Kauf. Inhaltsupdates kommen zunächst über App-Updates. Ein laufender Lernserver ist dafür nicht nötig.

Die späteren In-App-Käufe und Systemanfragen für Bewertungen werden über StoreKit angebunden und strikt vom Lernzugang getrennt. Xcode und geeignete Apple-Hardware werden vor Entwicklungsbeginn konkret eingeplant; ein vorhandener Mac wird nicht unterstellt. [Apple: StoreKit](https://developer.apple.com/documentation/storekit), [Apple: Xcode](https://developer.apple.com/xcode/)

## 9. Unterstützung bleibt freiwillig

„App unterstützen“ liegt in den Einstellungen. Der Text lautet: **„Wenn dir die App hilft, kannst du ihre Weiterentwicklung freiwillig unterstützen. Alle Inhalte bleiben kostenlos.“** Die drei gleichwertig gestalteten Optionen heißen **„Kleines Trinkgeld · 2,99 €“**, **„Mittleres Trinkgeld · 5,99 €“** und **„Großes Trinkgeld · 9,99 €“**. Die Beträge sind geplant; in der nativen App stammt die verbindliche lokalisierte Preisangabe aus dem Storeprodukt. Kein Betrag ist vorausgewählt. Nach der Auswahl folgt die ausdrückliche einmalige Kaufaktion. „Später entscheiden“ und „Nicht mehr fragen“ sind gut sichtbar; die manuelle Unterstützungsseite bleibt auch nach dauerhaftem Ausblenden erreichbar. Für Zahlungen gibt es keine Lernabzeichen oder besseren Lernmöglichkeiten.

Frühestens nach sieben Tagen, fünf abgeschlossenen Einheiten und 40 bearbeiteten Aufgaben ist ein Hinweis vorgesehen. Danach liegen mindestens 30 Tage zwischen Hinweisen; höchstens zwei erscheinen in einem rollierenden Zeitraum von 180 Tagen. Nach einer Zahlung folgen mindestens 180 Tage ohne Nachfrage. „Nicht mehr fragen“ ist dauerhaft wirksam und wird mitgesichert. Diese Regeln sind bestätigte, im Nutzertest zu prüfende Produktentscheidungen. Innerhalb einer Aufgabe, Simulation, Fehlermeldung oder frustrierenden Lernsituation erscheint keine Zahlungsfrage. Kaufabbruch und Zahlungsfehler haben keinerlei Einfluss auf den Lernzugang. In den letzten sieben Tagen vor jedem eingetragenen, noch offenen Prüfungstermin und am Prüfungstag erscheinen weder automatische Bewertungs- noch Trinkgeldanfragen. Store-Bewertung und Unterstützung werden getrennt behandelt, mit mindestens 14 Tagen Abstand zwischen eigenen Anfragen in beide Richtungen. Beide werden ausschließlich innerhalb der App angefragt.

### Bewertungen nach tatsächlichem Nutzen

Die erste automatische Bewertungsanfrage kommt frühestens nach insgesamt 60 aktiven Lernminuten, drei abgeschlossenen Lerneinheiten und Nutzung an mindestens zwei verschiedenen lokalen Kalendertagen infrage. Alle Bedingungen müssen erfüllt sein. Hintergrundzeit und bloßes unbeaufsichtigtes Offenlassen zählen nicht zur Lernzeit. Nach einer abgeschlossenen Runde wartet die App einen natürlichen Ruhepunkt ab; beim Weitergehen entfällt die Anfrage für diesen Moment. Ein hoher Aufgabenwert oder ein bestandener Prüfungsteil ist keine Voraussetzung.

Die App verwendet unmittelbar den nativen Apple-Systemdialog. Es gibt keinen vorgeschalteten emotionalen Bewertungsbildschirm, keine gewünschte Sternezahl, keine Belohnung und keine Vorauswahl zufriedener Personen. Apple verlangt die vorgesehene Bewertungsfunktion und untersagt eigene Bewertungsdialoge. [Apple: App Store Reviews, 5.6.1](https://developer.apple.com/app-store/review/guidelines/#app-store-reviews)

Unsere strengere Produktregel lautet höchstens eine eigene automatische Anforderung in einem rollierenden Zeitraum von 180 Tagen. Der Zeitpunkt des Aufrufs wird gespeichert, auch wenn iOS keinen Dialog zeigt; eine erneute Nachfrage wird deshalb nicht unmittelbar nachgeholt. Apple entscheidet über die Anzeige und begrenzt sie auf höchstens drei Anzeigen innerhalb von 365 Tagen. Die Grenze von 60 Minuten und unsere längeren Abstände sind keine Apple-Vorgaben, sondern zu prüfende Produktannahmen. [Apple: Requesting App Store reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews)

Ein späterer Prüfungsabschluss setzt keine Frist zurück. Am Folgetag wird deshalb nicht automatisch erneut um Bewertung gebeten. Wenn beide Anfragen grundsätzlich möglich wären, erhält die noch nie gestellte Bewertungsanfrage Vorrang; ein Trinkgeldhinweis kommt frühestens 14 Tage danach bei einer eigenen passenden Gelegenheit infrage. Eine freiwillige Meldung über Bestehen oder Nichtbestehen steuert die Auswahl für Storebewertungen nicht. Die manuelle Unterstützungsseite bleibt erreichbar; eine Zahlung ist keine Gegenleistung für eine Bewertung.

Apple sieht Trinkgeld an Entwickler über In-App-Käufe grundsätzlich vor. Geplant sind drei wiederholt freiwillig nutzbare Einmalkaufprodukte, keine wiederkehrende Zahlungsverpflichtung. Die endgültige Produktkonfiguration wird im nativen StoreKit-Ablauf getestet. [Apple: App Review Guidelines, 3.1.1](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)

Die Trinkgeldseite ist im Bedienungsentwurf auswählbar. Die Kaufaktion zeigt ausdrücklich, dass keine Zahlung ausgelöst wurde. Es wird keine echte Apple-Kaufbestätigung nachgeahmt und kein erfolgreicher Kauf behauptet.

## 10. Bestand, erste Umsetzung und Abnahme

Es liegen **800 Aufgabenmanuskripte und 300 Lernkarten** als ausgearbeitete redaktionelle Entwürfe vor. Die unabhängige fachliche Freigabe steht aus. Diese Stückzahlen sind keine Aussage über bereits veröffentlichte oder wissenschaftlich validierte Inhalte. Die Oberfläche muss den später tatsächlich freigegebenen Umfang aus dem Inhaltskatalog auslesen.

Der Bedienungsentwurf verwendet sechs Karten aus diesem Bestand, drei illustrative Aufgaben und drei Fachgesprächsimpulse. Er ergänzt sechs Abzeichen, Tagesziele, eine lokale Lernserienberechnung, Erinnerungsoptionen und die drei Trinkgeldgrößen. Seine Änderungen bleiben nur innerhalb der geöffneten Vorschau erhalten. Er enthält keine dauerhafte App-Datenbank, Gerätesicherung, adaptive Wiederholungsberechnung, echte Prüfungssimulation oder native Zahlungsintegration.

Am Bedienungsentwurf wurden Kartenbearbeitung und Eingabeprüfung, Erhalt beim Ansichtswechsel, Wiederherstellung des Originals bei erhaltenen Notizen, Fortsetzen einer Lernrunde, richtige Auswertung der Beispielantworten und Erhalt von Praxisentwürfen geprüft. Zusätzlich geprüft wurden helle Überschriften trotz schwarzer umgebender Textvorgaben, Abzeichenbedingungen, die Auswahl und Validierung von Erinnerungszeiten, ausbleibende Kaufaktionen, Abschaltung von Unterstützungshinweisen und drei simulierte Kalendertage einer Lernserie. Eine anschließende Pause setzte nur die aktive Serie zurück; das erreichte Abzeichen blieb erhalten. Die Kernansichten einschließlich der neuen Bereiche zeigten bei 320 Pixel verfügbarer Breite keinen horizontalen Überlauf. Das sind Prüfungen der Vorschau; native Datensicherheit, Dynamic Type und VoiceOver sind damit nicht abgenommen.

Der erste native Quellcodestand liegt im Paket `AEVO_iOS_Projekt_0_1_0.zip`. Er enthält den Durchlauf Startseite → Aufgabe → Erklärung → Karte → persönliche Notiz → Speichern, eine SwiftData-Speicherung, kostenloses Exportieren und Importieren, die 800 Aufgaben und 300 Karten als gekennzeichnete Entwürfe sowie Code für Simulation, Praxisplaner, Termine, Erinnerungen, Abzeichen und StoreKit. Persönliche Karten und unfertige Bearbeitungsentwürfe sind von den Originalen getrennt. Die bisherige Browser-Vorschau wurde dadurch nicht zu einer nativen App.

22 ausführbare Kerntests prüfen Bewertung, Wiederaufnahme, Kartenänderungen, Sicherungen, Tagesziele, Termin- und Nachfrageregeln. Die Syntax von 15 App-Dateien und die Xcode-Projektstruktur sind geprüft. SwiftUI, SwiftData, Mitteilungen und Käufe wurden mangels Apple-Umgebung noch nicht ausgeführt. Der entscheidende nächste Nachweis bleibt deshalb: auf dem iPhone speichern, App beenden, erneut öffnen und dieselben Daten wiederfinden; anschließend Inhaltsupdate und Sicherungsimport auf einer zweiten Installation prüfen. Das vorbereitete Skript `Scripts/check_on_mac.sh` und die Abnahmeliste liegen im Projektpaket. Fachliche Freigaben fehlen weiterhin. Der Release-Inhaltscheck verhindert derzeit die versehentliche Veröffentlichung der ungeprüften Entwürfe.

| Abnahme | Nachweis vor Veröffentlichung |
|---|---|
| Verständlicher Einstieg | Mindestens vier von fünf ersten Testpersonen starten ohne Hilfe in höchstens 30 Sekunden eine Runde; Zielwert, noch kein Ergebnis |
| Persönliche Karten | Änderungen und Notizen überstehen Neustart, Update und Gerätewechsel per Sicherung; Originalwiederherstellung erhält Notizen |
| Richtige Bewertung | Falsche, fehlende und zusätzliche Antwortauswahlen werden gemäß dokumentiertem Modell bewertet |
| Sicheres Unterbrechen | Antwort, Position, Prüfungszeitbasis und Bearbeitungsentwurf gehen bei erzwungenem App-Ende nicht verloren |
| Offline | Alle veröffentlichten Lernwege funktionieren nach Installation im Flugmodus |
| Bedienungshilfen | Kernwege mit VoiceOver, großer Schrift, reduzierter Bewegung und erhöhtem Kontrast auf echten Geräten geprüft |
| Freiwillige Unterstützung | Ablehnung, Ausblenden, Abbruch und fehlende Verbindung verändern keine Lernfunktion |
| Fachlicher Umfang | Jede veröffentlichte Aufgabe und Karte hat dokumentierte Freigabe; Quellen, Versionen und Korrekturweg sind zugänglich |
| Abzeichen und Tagesstrecke | Wiederholtes Antippen erzeugt keine zusätzlichen Tagesschritte; Pausen und Zieländerungen löschen keine bereits erreichten Abzeichen; Kaufereignisse zählen nicht |
| Erinnerungen | Ablehnung der Berechtigung, Ausschalten, leere Tagesauswahl, Zeitzonenwechsel und bereits erreichtes Tagesziel führen zu den beschriebenen Zuständen; keine doppelte Zustellung |
| Prüfungstermine | Getrennte optionale Termine, Verschiebung, Kalenderwechsel, fehlender Folgetermin und bestätigter Abschluss ergeben den passenden Countdown und entfernen veraltete Mitteilungen; kein automatisches Bestehen |
| Bewertungsanfragen | Alle drei Nutzungsschwellen, Prüfungssperrzeit, 180-Tage-Abstand und 14-Tage-Abstand zum Trinkgeld greifen auch nach Neustart und Sicherungsimport; unterdrückter Systemdialog wird nicht wiederholt angefordert |
| Dunkelmodus | Überschriften, Karten, Eingaben, Preise und Schaltflächen bleiben auch bei abweichender Systemdarstellung lesbar |

Große Schrift darf längere Ansichten erzeugen; sie darf keine Antworten abschneiden. Ziel sind mindestens 44 × 44 pt große Berührungsflächen, ausreichend kontrastreiche Texte und Statusmeldungen, die ohne Farberkennung verständlich sind. Diese Kriterien orientieren sich an Apples Bedienungshilfen-Empfehlungen. Die browserbasierte Vorschau ersetzt keine VoiceOver- oder Dynamic-Type-Abnahme einer nativen App. [Apple: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

Ein KI-Tutor, automatische Benotung des Fachgesprächs, soziale Ranglisten und umfangreiche Sprachfunktionen gehören zunächst nicht zur ersten Version. Dafür fehlen ein belegter zusätzlicher Lernnutzen und ein tragfähiges Fehler- und Kostenmodell. Der Schwerpunkt bleibt auf einem guten Lernablauf, eigenen Karten und verlässlichen Daten.

## 11. Weitere Ideen nach Nutzen priorisieren

| Idee | Konkreter Nutzen | Entscheidung |
|---|---|---|
| „Ich bin unsicher“ vor der Auswertung | Auch richtig geratene Antworten landen in der gezielten Wiederholung; Trefferquote und Selbsteinschätzung bleiben getrennt | Als nächste kleine Ergänzung des Lernablaufs priorisieren |
| Praktische Generalprobe mit Timer und Selbstcheck | Eigene Vorbereitung laut durchspielen und anschließend Lernziel, Methodenbegründung und Lernkontrolle prüfen | Vor zusätzlichen dekorativen Spielelementen ausarbeiten; keine automatische Note |
| Abzeichen für verzögerten Transfer | Sichtbarer Meilenstein für die Anwendung an wirklich neuen Situationen nach einem Lernabstand | Erst nach verlässlicher redaktioneller Zuordnung der Transferaufgaben |
| Kleines iPhone-Widget | Nächste kurze Einheit oder Tagesziel direkt auf dem Home-Bildschirm erreichen | Später, sobald die native Speicherung und der Hauptlernweg stabil sind |

WidgetKit bietet die technische Grundlage für iPhone-Widgets; der beschriebene Inhalt ist unsere Produktidee. Ein solches Widget ersetzt weder eine Lernrunde noch den Nachweis von Verständnis. [Apple: WidgetKit](https://developer.apple.com/documentation/widgetkit/)

**Entscheidung:** Die erste App wird eine moderne native iPhone-App mit vier klaren Bereichen, kurzen erklärenden Lernrunden und vollständig bearbeitbaren Lernkarten. Der unmittelbar zu prüfende Nutzen lautet: Lernende verstehen eine neue Situation besser und können ihre eigene Begründung festhalten. Gestaltung und Umfang unterstützen dieses Ziel; die fachliche Freigabe und Tests mit echten Prüflingen bleiben die Voraussetzung für die Veröffentlichung.


## 12. Bestätigte und umgesetzte Erweiterungen in 0.2.0

Der Auftrag „Alles umsetzen“ umfasst die acht zuletzt vorgeschlagenen Funktionsbereiche. Diese sind jetzt im nativen Projekt integriert: Tagesplan mit Zeitbudget und beiden Prüfungsterminen, konkrete Rückmeldung zu falschen und fehlenden Antworten mit späterem Anwendungsfall, 16 verzweigte Ausbildungssituationen, geführter Praxisplan mit Text- und Druckexport, 24 Fachgesprächsfragen mit Rückfragen und optionaler lokaler Aufnahme, transparente Kompetenzübersicht, persönliche Lernsammlung und Inhaltsqualität mit Versionshinweisen sowie lokal speicherbaren und manuell teilbaren Fehlermeldungen. Ein Drei-Minuten-Modus, ruhiger Modus und dezente Übergänge ergänzen den Lernablauf.

Alte Sicherungen bleiben lesbar. Neue Texte und Fallentscheidungen gehören zur kostenlosen Sicherung; Audioaufnahmen bleiben ausschließlich auf dem jeweiligen Gerät und werden nicht exportiert oder in der Gerätesicherung abgelegt. Es gibt keine automatische KI-Benotung, keine laufenden KI-Kosten und keinen automatischen Versand von Meldungen ohne eingerichteten Empfänger.

34 Kerntests laufen erfolgreich, darunter alle 64 vollständigen Entscheidungswege, alte Sicherungen, neue Lerndaten, verzögerter Transfer und Datenvalidierung. Die Syntax der 18 App-Dateien sowie die Xcode-Projektstruktur sind geprüft. Native Ausführung, Mikrofon, Druckdialog, SwiftData und Bedienungshilfen müssen später auf dem Mac und iPhone abgenommen werden. Alle 1.140 fachlichen Inhaltseinheiten bleiben redaktionelle Entwürfe. Details: `Documentation/ERWEITERUNGEN_0_2.md` im aktualisierten Projektpaket. Diese Ergänzung ersetzt frühere Aussagen, nach denen die genannten Funktionen erst zukünftige Ideen seien; die separate Browser-Vorschau bleibt unverändert.


## 13. Verbindliche Vereinfachung in 0.2.1

Auf den Folgeauftrag, störende Elemente zu entfernen und die App einfach zu halten, wurden automatische Bewertungs- und Trinkgeldfenster vollständig aus der Oberfläche entfernt. Freiwilliges Trinkgeld bleibt ausschließlich über die Einstellungen erreichbar. Diese Entscheidung ersetzt die früheren Regeln für automatische Nachfragen; alte Datensätze und Opt-outs bleiben lesbar.

Die Startseite konzentriert sich auf Weiterlernen, eine optionale Anpassung der Runde und eine Lernkarte. Nach Abschluss bleiben nur Fertig und Noch eine Runde. Doppelte sofort sichtbare Erklärungen, wiederholte Terminrückfragen, Kapazitätswarnungen und die Liste sämtlicher unerledigter Praxisfelder entfallen. Notizen, Antwortdetails, Aufnahme und ausführliche Planungsfelder öffnen sich erst auf ausdrücklichen Wunsch. Der Praxisbereich startet mit drei Wegen: Ablauf planen, Fachgespräch üben, Alltagssituationen durchspielen. Der Lernbereich zeigt zuerst die eigentlichen Inhalte; Lernsammlung und Fortschritt liegen im Zusatzmenü. Vier aufklappbare Handlungsfelder ersetzen die sofortige lange Kompetenzliste.

Die adaptive Lernlogik, alle Inhalte, Kartenbearbeitung, eigene Texte, Sicherungen, Termine, freiwillige Erinnerungen, Abzeichen und Tagesstrecke bleiben erhalten. Datenformat und vorhandene Nutzerdaten werden nicht gelöscht oder zurückgesetzt. 34 Kerntests und die Syntaxprüfung der 18 App-Dateien bestanden erneut. Die Ablaufprüfung beruht auf dem Quellcode, nicht auf einem nativen iPhone-Test oder beobachteten Nutzerverhalten. Details stehen in `Documentation/VEREINFACHUNG_0_2_1.md`. Dieser Abschnitt hat bei Widersprüchen Vorrang vor früheren Funktionsbeschreibungen.


## 14. Ausdrückliche Korrektur in 0.2.2: Nachfragen wieder aktiv

Automatische Storebewertungen und Trinkgeldhinweise sind wieder eingefügt. Es gelten die bisherigen Regeln aus Abschnitt 9: Bewertung frühestens nach 60 aktiven Minuten, drei Runden und zwei Lerntagen, mindestens 180 Tage Abstand. Trinkgeld frühestens nach sieben Tagen, fünf Runden und 40 Antworten, mindestens 30 Tage Abstand und höchstens zwei Hinweise in 180 Tagen. Nach einer Zahlung 180 Tage Ruhe, zwischen Bewertung und Trinkgeld mindestens 14 Tage. Beide Anfragen bleiben in der letzten Woche vor jedem offenen Prüfungstermin gesperrt und dauerhaft abschaltbar. Gespeicherte Opt-outs werden nicht zurückgesetzt.

Die Anfrage kann nur auf der sichtbaren Abschlussseite nach drei Sekunden Ruhe erfolgen; laufende Aufgaben, Hintergrundnutzung und Fehlermeldungen schließen sie aus. Apple entscheidet über die Anzeige des nativen Bewertungsdialogs. Trinkgeld bietet Später entscheiden und Nicht mehr fragen. Alle übrigen Vereinfachungen aus 0.2.1 bleiben erhalten. Dieser Abschnitt ersetzt die gegenteiligen Aussagen aus Abschnitt 13. Vier gezielte Kerntests bestanden; die native Ausführung bleibt ungeprüft.


## 15. Persönlicher Einstieg und Farbwelten in 0.3.0

Eine einmalige, überspringbare Startseite fragt nach Name oder Spitzname, optionalem Prüfungstag und Lieblingsfarbwelt. Beim Termin ist schriftlicher oder praktischer Teil wählbar; vorhandene andere Termine bleiben erhalten. Es gibt keine Pflichtangaben und kein Konto. Nach Speichern oder Überspringen wird dieser Einstieg nicht bei jedem Start erneut verlangt. Name, Farbwelt und täglicher Impuls lassen sich später in den Einstellungen ändern.

Die Startseite zeigt Guten Morgen von 05:00 bis 10:59, Guten Tag von 11:00 bis 17:59, Guten Abend von 18:00 bis 22:59 und ansonsten Hallo, jeweils mit dem Namen, sofern angegeben. Darunter stehen ein neutraler Countdown ohne „nur noch“ und ein kurzer Lernimpuls. Am Vortag heißt es Morgen, am Prüfungstag Heute; vergangene Termine erzeugen weder negative Werte noch eine Bestehensannahme. Im ruhigen Modus bleibt der Countdown ausgeblendet. Eine laufende Lernrunde wird nicht unterbrochen.

31 eigene motivierende Texte wechseln nach lokalem Kalendertag, bleiben an einem Tag gleich und wiederholen sich nach 31 Tagen. Keine erfundenen Autorenangaben, keine externen Abrufe. Der Impuls ist ausblendbar. Die acht durchgängigen Farbwelten heißen Waldgrün, Ozeanblau, Lavendel, Rosé, Koralle, Sonnengelb, Türkis und Graphit. Jede Welt unterstützt Hell- und Dunkelmodus mit berechneten Textkontrasten von mindestens 4,5:1 für die eigens definierten Haupttextpaare; die tatsächliche native Darstellung bleibt zu prüfen.

Profilwerte werden lokal und in der kostenlosen Sicherung gespeichert. Alte Sicherungen, eigene Texte und vorhandene Opt-outs bleiben erhalten. Die seltenen automatischen Bewertungs- und Trinkgeldanfragen aus Abschnitt 14 bleiben aktiv. 43 Kerntests bestanden; 19 App-Dateien syntaktisch geprüft. Kein nativer Build oder iPhone-Test erfolgt. Details: `Documentation/PERSONALISIERUNG_0_3.md`. Dieser Abschnitt hat Vorrang vor früheren Aussagen zu einer festen einzigen Farbwelt oder fehlendem persönlichen Einstieg.


## 16. Belegte Zitate als Lernimpulse in 0.3.1

Fünf Zitate von Immanuel Kant, Johann Wolfgang von Goethe, Rainer Maria Rilke und Marie von Ebner-Eschenbach ergänzen die 31 eigenen Texte. Die Auswahl bezieht sich auf selbstständiges Denken, Neugier, Geduld, Konzentration und Selbstvertrauen. Sie verspricht keinen bestimmten Lernerfolg. Jeder fremde Text trägt Anführungszeichen, den ausgeschriebenen Urhebernamen und einen Zugang zu Werk, Fundstelle, Originalwortlaut bei Anpassungen und Quellenlink.

Die 36 Texte wechseln nach lokalem Kalendertag. Zitate liegen jeweils mit mehreren eigenen Impulsen dazwischen. Es bleibt bei einem Text pro Tag, auch nach Neustart. Die Anzeige ist weiterhin abschaltbar. Profilvorschau und Startseite verwenden dieselbe Darstellung. Die Quellenansicht öffnet sich ausschließlich auf Wunsch; es gibt keine zusätzliche automatische Nachfrage. Text und Quellenangabe sind offline verfügbar, der externe Originaltext benötigt Internet.

Der Wortlaut wurde am 20. September 2026 anhand von [Kants Aufklärungsaufsatz](https://de.wikisource.org/wiki/Beantwortung_der_Frage:_Was_ist_Aufkl%C3%A4rung%3F), [Goethes Natur und Kunst](https://www.deutschelyrik.de/natur-und-kunst.html), [Rilkes Brief vom 16. Juli 1903](https://www.rilke.de/briefe/160703.htm) und [Ebner-Eschenbachs Aphorismen, Erstes Hundert, Nr. 29 und 73](https://www.gutzitiert.de/aphorismen_parabeln_maerchen_und_gedichte-marie_von_ebner_eschenbach-kapitel_2.html) abgeglichen. Modernisierte Schreibweisen und der einzelne Versauszug sind kenntlich gemacht. Originalimpulse bekommen keine erfundene Autorenangabe. Dokumentation und Nutzungsgrundlage stehen in `Documentation/ZITATE_0_3_1.md`.

43 Kerntests bestanden, 20 App-Dateien syntaktisch geprüft, Xcode-Projektstruktur geprüft. Ein nativer Build und die iPhone-Abnahme stehen aus. Diese Ergänzung ersetzt die frühere Festlegung auf ausschließlich eigene Texte und einen Zyklus von 31 Tagen. Profil, Notizen, Sicherungen und bestehende Nachfrageeinstellungen bleiben erhalten.


## 17. Trinkgeld, Impressum, Datenschutz und Veröffentlichung (0.3.2)

Trinkgeld bleibt in „Einstellungen → App unterstützen → Freiwilliges Trinkgeld“ jederzeit erreichbar. Die iPhone-Vorschau enthält jetzt ebenfalls alle drei Felder. Geplante deutsche Beträge sind 2,99 €, 5,99 € und 9,99 €; die native App zeigt ausschließlich von Apple gelieferte Preise. Es gibt keine Vorauswahl, Freischaltung oder Abos. Die vorhandenen seltenen automatischen Nachfragen und beide dauerhaften Abschaltungen bleiben unverändert.

„Informationen & Recht“ enthält offline lesbare Seiten für Impressum und Datenschutz. Die Datenschutzerklärung ist auch beim ersten Einrichten, im Profil und auf der Unterstützungsseite zugänglich. Sie beschreibt lokale Lernstände und Notizen, Aufnahmen, Berechtigungen, Sicherungen und Exporte, Apple-Käufe, Bewertungen, Quellenlinks sowie Löschung und Rechte. Gewöhnliche iOS-Gerätebackups sind ausdrücklich von einer automatischen App-Synchronisierung unterschieden. Aufnahmen sind vom Backup und JSON-Export ausgeschlossen.

Die Rechtstexte bleiben offen gekennzeichnete Entwürfe, bis Betreiberidentität, Anschrift, Kontakt, E-Mail-/Webdienste, Speicherdauern und öffentliche URLs feststehen und geprüft sind. Diese Angaben werden nicht aus sonstigen persönlichen Kontextdaten erfunden. Die Release-Sperre kontrolliert neben Inhaltsfreigaben nun auch die Vollständigkeit dieser Voraussetzungen. Eine automatische Prüfung ersetzt keine rechtliche oder fachliche Prüfung.

Der nächste Schwerpunkt ist die Veröffentlichungsvorbereitung: unabhängige Prüfung der 800 Aufgaben, 300 Karten und Praxisinhalte, Abschluss der Anbieterinformationen, öffentliche Support-/Datenschutzseite und schließlich Mac/Xcode sowie echte iPhone- und StoreKit-Tests. Weitere Funktionen sind dafür nicht nötig. Die vollständige aktuelle Checkliste, Quellen und Abnahmekriterien liegen in `Documentation/VEROEFFENTLICHUNG_0_3_2.md` des iOS-Projekts.


## 18. Kontakt, Hilfe und erste Einführung

Unter „Einstellungen → Hilfe & Kontakt“ gibt es „Kontakt / Support“ und „Hilfe & Anleitungen“. Der Kontakt öffnet einen E-Mail-Entwurf mit allgemeinem Betreff, App-Version und einer leeren Vorlage für das Anliegen. Name, Lernstände, Notizen und Aufnahmen werden nicht eingefügt. Nutzer prüfen und senden selbst. Ohne verfügbare Mail-App bleibt die Adresse kopierbar. Bis eine echte Kontakt-E-Mail vorliegt, wird der unfertige Zustand ehrlich angezeigt.

Acht kurze Anleitungen erklären Lernrunden, Kartenbearbeitung, Wiederholung, Simulationen, Praxis, Personalisierung, Sicherung sowie Unterstützung. Abschnitte lassen sich bei Bedarf aufklappen. Eine kurze Einführung mit drei Kerngedanken steht vor der optionalen Einrichtung beim ersten Start. „Direkt loslernen“ überspringt sowohl Einführung als auch persönliche Angaben; die bisherige Einrichtung bleibt optional. Der abgeschlossene Start wird lokal gespeichert. Bereits eingerichtete Installationen werden nicht erneut unterbrochen, und eine spätere Wiederholung über Hilfe verändert keine Profildaten.


## 19. Persönliche Trinkgelder und bestätigte Anbieterangaben (0.3.3)

Die Auswahl zeigt „Kleines Trinkgeld: Ein Filterkaffee“, „Mittleres Trinkgeld: Ein Cappuccino“ und „Großes Trinkgeld: Ein Döner“. Die geplanten deutschen Beträge bleiben 2,99 €, 5,99 € und 9,99 €; echte Preise liefert weiterhin Apple. Die Überschrift heißt „Ein kleines Dankeschön.“ Der Einladungstext lautet: „Hat dir die App beim Lernen geholfen? Dann freuen wir uns, wenn du uns auf einen Kaffee oder einen Döner einlädst. Ganz freiwillig, versteht sich.“ Alle veröffentlichten Inhalte bleiben kostenlos. Die Bezeichnungen stehen für freiwillige Unterstützung; es werden keine Waren verkauft. Kaufablauf und seltene Nachfragen ändern sich nicht.

Der Auftraggeber hat Julian Kürten, Spreeallee 207, 24111 Kiel, Deutschland sowie kontakt@verlag-ki.de für Impressum, Datenschutz und Support übermittelt. Diese Angaben sind jetzt hinterlegt und ersetzen die dortigen Platzhalter. Der Supportknopf verwendet diese E-Mail-Adresse für einen vom Nutzer selbst versendbaren Entwurf. Öffentliche Support-/Datenschutzadressen, Angaben zu E-Mail- und Webdiensten sowie die abschließende Prüfung bleiben offen. Angaben zu Firmenregistern, USt-IdNr. oder Telefonnummern werden nicht angenommen.

## 20. Notion-Seiten und bestätigter Mailanbieter

Am 20. September 2026 hat Julian Kürten Notion für die öffentlichen Informationsseiten und IONOS als Anbieter von kontakt@verlag-ki.de bestätigt. In Notion wurden private Entwürfe für Impressum, Datenschutz sowie Kontakt und Support erstellt: [Arbeitsübersicht mit den drei Seiten](https://app.notion.com/p/3e17bc579483812bbaeec684d99cfc87). Sie sind noch nicht öffentlich veröffentlicht. Deshalb bleiben die öffentlichen Datenschutz- und Support-URLs in der App unbefüllt, bis die tatsächlichen öffentlich erreichbaren Adressen feststehen.

Der Datenschutzentwurf in Notion und die offline verfügbare Fassung im iOS-Projekt nennen jetzt IONOS als Anbieter des Supportpostfachs. Die Anbieteranschrift wurde im [IONOS-Impressum](https://www.ionos.de/impressum) abgeglichen. Die App sendet weiterhin keine Nachricht oder Lerndaten automatisch. Die Informationsseiten bei Notion sind vom lokalen Lernbetrieb getrennt und werden nur über einen bewusst gewählten externen Link geöffnet.

Die Bestätigung des Anbieters belegt noch kein bestimmtes Mailprodukt, keine ausschließlich deutsche Datenhaltung, keinen abgeschlossenen AV-Vertrag und keine konkrete Löschfrist. Diese Punkte bleiben als redaktionelle Prüfung vor Veröffentlichung vermerkt. Auch die tatsächliche Notion-Konfiguration und abschließende rechtliche Prüfung bleiben offen. Der Freigabestatus der Texte und der fachlichen Inhalte wurde nicht geändert. Diese Ergänzung aktualisiert die zuvor offenen Entscheidungen zum Mail- und Webanbieter, ohne einen abgeschlossenen App-Store-Release zu behaupten.


## 21. Direkter Lernablauf und bestätigte Fachprüfung in 0.4.0

Lernkarten sind ein fortlaufender Stapel. Rechts wischen oder „Verstanden“ speichert die Einschätzung und öffnet die nächste Karte. Links wischen oder „Noch unsicher“ tut dasselbe mit einer früheren Wiederholung. Senkrechtes Scrollen bewertet keine Karte. Der Stapel samt Position wird gespeichert; die Startseite setzt ihn fort. Themenauswahl, persönliche Kartentexte und Notizen bleiben erhalten. Am Ende ist eine Runde nur mit unsicheren Karten möglich.

Bei Aufgaben lautet der feste Ablauf: auswählen, „Antwort einloggen“, Erklärung lesen, „Nächste Aufgabe“. Bei verzweigten Situationen gilt derselbe Ablauf mit „Nächste Entscheidung“. Prüfungssimulationen zeigen Lösungen weiterhin erst nach Abgabe.

Julian Kürten hat die abgeschlossene fachliche Prüfung für den vorhandenen Inhalt bestätigt. Die Lernoberfläche enthält deshalb keine Entwurfs- oder Fachprüfhinweise mehr. Intern bleibt die Auftraggeberbestätigung mit Bezug auf die konkreten Inhaltsfassungen dokumentiert. Die Darstellung erfindet weder eine unabhängige Prüferidentität noch eine Bestehenswahrscheinlichkeit. Quellen bleiben auf Wunsch sichtbar; Kontakt / Support ersetzt den Meldebereich im Lernfluss.

Impressum und Datenschutz bleiben in den Einstellungen und entfallen in der Einführung. Die dauerhaften Abschalter für Bewertung und Trinkgeld sind auf ausdrücklichen Wunsch entfernt. Alte Sicherungsfelder bleiben lesbar, ihre Abschaltwirkung entfällt. Alle Nachfragen lassen sich freiwillig schließen; Abstände und Schutz laufender Lernphasen bleiben bestehen. Hilfe und Datenschutzentwurf wurden entsprechend angepasst.

Diese Festlegungen ersetzen widersprechende ältere Beschreibungen, insbesondere zu dauerhaften Nachfrage-Abschaltern, einzelnen Karten ohne Weiterlauf und offenen fachlichen Prüfvermerken. Die rechtliche Freigabe sowie öffentliche Notion-URLs bleiben eigene offene Veröffentlichungsschritte. Der erfolgreiche Start der vorherigen App wurde vom Auftraggeber bestätigt; die neue Version benötigt eine native Abnahme auf dem Mac und iPhone.
