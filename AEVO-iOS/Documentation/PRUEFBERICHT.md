# Prüfstand 0.5.0 · wiederverwendbare Learning Engine

21. September 2026. 64 Swift-Kerntests mit Swift 6.0.3 und 16 Python-Tests bestanden. Alle bestehenden Tests sind erhalten; hinzugekommen sind Paketvalidierung, explizite Aufgabentypen, drei bis zwölf Kategorien, konfigurierbare Prüfungsregeln, Datenzuordnung und Generatorprüfungen. Die 800 AEVO-Aufgaben und 300 Karten wurden einschließlich stabiler IDs mit dem ursprünglichen Katalog verglichen. Fachliche Texte und Lösungen bleiben unverändert.

Eine mit dem tatsächlichen Code von 0.4.0 erzeugte synthetische Sicherung wurde übernommen. Die Prüfung umfasst persönliche Kartenfassungen, offene Notizen, Name, Termine, Einstellungen, Fortschritt, Kartenstapel, laufende Lernrunden und Simulationen. Fremde App-/Pack-Sicherungen werden abgelehnt. Dies ist ein Nachweis des Datenformats, noch kein SwiftData-Update auf einem iPhone.

Der Generator wurde vollständig für AEVO und das fiktive Orbit-Demo ausgeführt. Beide erzeugten Projekte bestanden jeweils die zwei Laufzeittests gegen ihre eigenen ausgewählten Ressourcen. Die App- und Core-Swift-Dateien beider Ausgaben sind bytegleich mit der gemeinsamen Quellcodebasis. Orbit verwendet drei Kategorien, zehn Fragen, fünf Karten und abweichende Regeln für Dauer, Navigation, Bewertung und Bestehensgrenze. Praxis, Trinkgelder und Bewertungsanfragen sind dort deaktiviert.

Alle zehn JSON-Schemas sowie zwanzig Inhalts-/Konfigurationsdateien wurden zusätzlich unabhängig mit jsonschema 4.23.0 nach Draft 2020-12 geprüft. Dieses Paket ist ausschließlich ein Prüfwerkzeug; der ausgelieferte Validator benötigt keine zusätzlichen Python-Abhängigkeiten. Die Syntax aller 22 SwiftUI-Dateien und die Xcode-Projektstruktur sind geprüft.

Protokolle: `Kerntests_0_5_0.log`, `Pythontests_0_5_0.log`, `Schema_Pruefung_0_5_0.txt`, `Integritaet.json` sowie die beiden `*-0.5.0-GenerationReport.json` und zugehörigen Testlogs. Die generierten Arbeitskopien werden nicht als zusätzliche Quellcodebasis ausgeliefert; der mitgelieferte Generator stellt sie reproduzierbar her.

Der Release-Prüflauf meldet weiterhin die drei bereits offenen rechtlichen Angaben: Freigabe der Rechtstexte, öffentliche Datenschutz-URL und öffentliche Support-URL. Die übernommene AEVO-Inhaltsbestätigung gilt für die unveränderten fachlichen Inhalte. Das technische Demo bleibt ausdrücklich ohne fachliche Freigabe.

Kein Apple-SDK-Typecheck, Simulator-Build, signiertes Archiv oder Gerätetest dieser Refaktorierung. Native Gesten, SwiftData, Mitteilungen, VoiceOver und StoreKit müssen mit `NATIVE_ACCEPTANCE_0_5_0.md` abgenommen werden. Deshalb ist die vollständige native Definition of Done noch nicht nachgewiesen; siehe `DEFINITION_OF_DONE_0_5_0.md`.

## Historische Prüfstände

# Prüfstand 0.4.0

21. September 2026. 52 Foundation-Kerntests mit Swift 6.0.3 auf Linux bestanden, einschließlich sieben neuer Kartenstapelprüfungen. Geprüft wurden unter anderem automatischer Wechsel, veraltete Doppeltipps, unsichere Wiederholung, Filterumfang, Backup/Fortsetzung, alte Sicherungen und Wischrichtung. Alle 64 vollständigen Fallwege sind Teil der vorhandenen Fallprüfung.

Fünf Python-Prüfungen für dokumentierte Freigaben und die Veröffentlichungssperre bestanden. Die Projektintegrität bestätigt 800 Aufgaben, 300 Karten, 16 Fälle und 24 Fachgesprächsimpulse sowie den Bezug der bestätigten Freigabe auf genau diese Fassungen. Die Syntax aller 22 SwiftUI-Dateien wurde mit dem Swift-Parser geprüft.

Der tatsächliche Release-Prüflauf bleibt mit drei offenen Punkten gesperrt: rechtliche Freigabe, öffentliche Datenschutz-URL und öffentliche Support-URL. Die bestätigten fachlichen Inhalte lösen keine Sperre mehr aus.

Es fand kein Apple-SDK-Typecheck, Xcode-Build oder iPhone-Test der neuen Version statt. Syntax und Foundation-Tests prüfen keine nativen Gesten, VoiceOver-Ausgabe, SwiftData-Integration oder StoreKit-Dialoge. Dafür enthält AENDERUNGEN_0_4_0.md die gezielte Geräteabnahme. Die Aussage des Auftraggebers zum erfolgreichen App-Start betrifft die vorherige Version.

Beim ersten Testlauf erwartete ein bestehender Exporttest noch den ausdrücklich entfernten Fachfreigabe-Hinweis. Die Erwartung wurde an den neuen persönlichen Planungstext angepasst; der anschließende vollständige Lauf bestand ohne Fehler. Protokoll: Kerntests_0_4_0.log.

## Historischer Prüfstand

# Aktueller Prüfstand 0.3.3

Zwei gezielte XCTest-Prüfungen der gebündelten Datenschutzdaten und sicheren Mail-Entwürfe sowie vier Release-Prüfungen bestanden. Geänderte App-Dateien syntaktisch und Projektintegrität geprüft. Die Vorschau zeigt Filterkaffee/Cappuccino/Döner mit korrekter Betragsauswahl, ohne Vorauswahl und mit gut lesbarem Text im schmalen Dunkelmodus. Anbieter- und Maildaten wurden im gerenderten Entwurf geprüft, ohne eine Nachricht zu öffnen oder zu versenden. Kein Apple-SDK-Build, nativer iPhone-Test oder tatsächlicher Kauf. Kauf- und Lernlogik wurden nicht geändert.

# Vorheriger Prüfstand 0.3.2

45 XCTest-Prüfungen bestanden, einschließlich Offline-Laden und Auflösen der Rechtstextvorlagen ohne erfundene Betreiberidentität sowie sichere Mail-Entwurfs-URLs ohne zusätzliche Empfänger oder private Anhänge. Vier gezielte Python-Prüfungen belegen, dass Inhaltsfreigabe und Vervollständigung der rechtlichen Informationen unabhängig erforderlich sind; ein einzelnes Freigabe-Flag reicht nicht aus. Syntaxprüfung aller 22 App-Dateien ohne Fehler. Xcode-Projekt mit 68 Objekten unabhängig geparst; Datei- und Inhaltsintegrität bestanden.

13 Browserprüfungen der getrennten iPhone-Vorschau bestanden: drei Beträge ohne Vorauswahl, keine vorgetäuschte Zahlung, Erreichbarkeit und Abschaltbarkeit, beide Rechtstexte, helle Schrift im Dunkelmodus, 320-Pixel-Ansichten und fortbestehende Profilbearbeitung. Zusätzlich wurden die acht Anleitungen, Einführung und Kontaktansicht bei schmalem Bildschirm geprüft; eine fehlende Empfängeradresse täuscht keine Mailfunktion vor. Keine JavaScript-Seitenfehler. Diese Prüfungen ersetzen keine native iPhone-Abnahme.

Kein Apple-SDK-Typecheck, nativer Build, StoreKit-Sandboxkauf, TestFlight-Test oder unabhängige fachliche/rechtliche Freigabe. Alle 1.140 Lerninhalte sind weiterhin Entwürfe. Die reale Release-Prüfung stoppt erwartungsgemäß wegen fehlender Fachfreigabe, öffentlicher URLs und noch unvollständiger beziehungsweise ungeprüfter Rechtstexte. `VEROEFFENTLICHUNG_0_3_2.md` benennt die nächsten Schritte und die am 20.09.2026 abgeglichenen Quellen.

# Vorheriger Prüfstand 0.3.1

43 XCTest-Prüfungen erneut bestanden. Der vorhandene Tageswechseltest berücksichtigt jetzt den Zyklus mit 36 Texten. Der Foundation-Kern einschließlich Quellenmetadaten und Zitatauswahl wurde auf Linux kompiliert und ausgeführt. 20 App-Dateien syntaktisch geprüft; Xcode-Projekt mit 64 Objekten unabhängig geparst und Dateiverweise sowie Inhalte auf Integrität geprüft. Die fünf Zitate wurden anhand der in `ZITATE_0_3_1.md` dokumentierten historischen Texte abgeglichen.

Kein Apple-SDK-Typecheck, nativer Build, iPhone-Test oder unabhängiges Zitatlektorat. Quellenansicht, Dynamic Type und VoiceOver sind noch nativ abzunehmen. Die automatische Rotation ist keine Serverfunktion und verändert keine Sicherungsdaten.

# Vorheriger Prüfstand 0.3.0

43 XCTest-Prüfungen bestanden, darunter neun neue für Begrüßung, Datum und Sommerzeit, tägliche Lernimpulse, Zeitzonen, Profil und Sicherungen sowie die mathematischen Kontraste aller acht Farbwelten. Swift-Kern kompiliert und ausgeführt; 19 App-Dateien syntaktisch geprüft. Xcode-Projektstruktur: 62 Objekte, Ressourcen und Dateiverweise geprüft. Keine alten statischen Farbzugriffe mehr in den App-Ansichten.

Noch kein Apple-SDK-Typecheck, nativer Build, iPhone-Test oder vollständiger Nachweis der Barrierefreiheit. Siehe `PERSONALISIERUNG_0_3.md`. Ältere Berichte folgen als Verlauf.

# Ergänzung 0.2.2

Vier gezielte Kerntests für die wieder aktivierten Nachfragen bestanden. Swift-Syntaxprüfung aller 18 App-Dateien und Projektintegritätsprüfung bestanden. Native Dialoge, Abbruch beim Verlassen und Systemverhalten sind weiterhin ungeprüft. Frühere Aussagen über vollständig entfernte Nachfragen sind durch den ausdrücklichen Folgeauftrag aufgehoben. Siehe `NACHFRAGEN_0_2_2.md`.

# Ergänzung zur Prüfung von 0.2.1

34 vorhandene Kerntests erneut bestanden. Syntaxprüfung aller 18 App-Dateien bestanden. Quellcodekontrolle: keine Aufrufe automatischer Storebewertungen oder Trinkgeldfenster; Kapazitätswarnung und wiederholte Terminrückfrage aus der Oberfläche entfernt. Datenmodell und fachliche Inhalte unverändert. Die Tests alter Nachfrageregeln betreffen nur noch ungenutzte kompatible Kernlogik. Neue Detailansichten, Menüführung und Einklappverhalten müssen nativ geprüft werden. Es gab keinen nativen UI-Test.

Siehe `VEREINFACHUNG_0_2_1.md`. Nachfolgend der vorherige Kernprüfbericht.

# Prüfbericht 0.2.0

Stand: 20. September 2026.

- Foundation-Kern auf Linux mit Swift 6.0.3 kompiliert und ausgeführt: 34 XCTest-Prüfungen bestanden.
- 22 bisherige Prüfungen plus 12 neue Integrations- und Logikprüfungen. Neue Prüfungen umfassen Abwärtskompatibilität, Datensicherung, alle 64 möglichen vollständigen Fallwege, Umgang mit Inhaltsversionen, Zeitbudget, Transfer, Kompetenzregeln und Eingabevalidierung.
- Swift-Syntaxprüfung für alle 18 App-Dateien bestanden. Dies ist ausdrücklich kein Typecheck gegen das Apple SDK.
- Xcode-Projekt mit einem unabhängigen OpenStep-Parser gelesen: 60 gültige Objekte. Projektdateiverweise, Ressourcen, Plists, Scheme und StoreKit-Testkonfiguration geprüft.
- 800 Fragen und 300 Karten auf Übereinstimmung mit den redaktionellen Quelldateien geprüft. 16 Fallgeschichten und 24 Fachgesprächsimpulse vorhanden. Alle 1.140 Einheiten noch ohne unabhängige Freigabe.
- Der Release-Inhaltscheck sperrt erwartungsgemäß die Veröffentlichung dieser Entwürfe. Interne Debug-Entwicklung bleibt möglich.

Nicht geprüft: nativer Build, SwiftUI-Ausführung, SwiftData-Migration auf einem Gerät, Mikrofon und Wiedergabe, Druck/PDF, lokale Mitteilungen, StoreKit, echte Storebewertungen, VoiceOver, Dynamic Type und reale Hell-/Dunkel-Darstellung. Es liegt keine installierbare oder veröffentlichte App vor. Fachliche Freigabe und Lernerfolg mit echten Prüflingen sind nicht durch Softwaretests ersetzt.

Die Rohdaten stehen in `Kerntests.log` und `Integritaet.json`. Der enthaltene frühere Bericht zur Wettbewerbs- und Fachgrundlage ist als Recherchegrundlage zu verstehen, nicht als Implementierungsinventar von 0.2.

Ergänzung vom 20.09.2026: IONOS als bestätigter Mailanbieter und Notion als gewählter Anbieter der Informationsseiten ergänzt. Die zwei vorhandenen Rechtstext- und Mail-URL-Tests bestanden erneut. Keine Änderungen am Freigabestatus, an öffentlichen URLs oder an der Versandlogik. Kein nativer iPhone-Test.
