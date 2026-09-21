# Aktuell: Version 0.3.4

Lernkarten laufen jetzt als Swipe-Stapel: tippen deckt auf, nach rechts wischen heißt „Verstanden“, nach links „Noch unsicher“, und die nächste Karte kommt von allein. Dieselben Bewertungen bleiben als große Schaltflächen und als VoiceOver-Aktionen erreichbar. Aufgaben mit einer richtigen Antwort werden durch Antippen der Antwort bewertet; danach folgt direkt „Nächste Aufgabe“. Die Einschätzung „war eher geraten“ steht nun nach der Auswertung und holt die Aufgabe in die Wiederholung zurück.

Die fachliche Prüfung aller 800 Aufgaben, 300 Karten, 16 Fälle und 24 Gesprächsimpulse ist vom Auftraggeber als abgeschlossen bestätigt und mit Datum und prüfender Person eingetragen. Sämtliche Entwurfs- und Vorbehaltshinweise sind aus der Oberfläche entfernt, ebenso der Meldekasten „Inhalt prüfen oder Fehler melden“, die Links auf Impressum und Datenschutz in der Einführung und die dauerhaften Abschalter „Nicht mehr fragen“. Impressum und Datenschutz bleiben über die Einstellungen erreichbar.

Geprüft: 49 Kerntests, Syntax aller 23 App-Dateien, Projektintegrität und fünf Prüfungen der Release-Sperre. Die inhaltliche Sperre ist offen; die Sperre wegen fehlender rechtlicher Freigabe und fehlender öffentlicher Datenschutz- und Supportadressen bleibt bestehen. Kein nativer Build, kein iPhone-Test, keine Gestenprüfung auf dem Gerät. Details: `Documentation/AENDERUNGEN_0_3_4.md`.

# Vorheriger Stand: Version 0.3.3

Die drei freiwilligen Trinkgelder sind jetzt mit Filterkaffee, Cappuccino und Döner beschriftet. Ein freundlicher Einladungstext ergänzt die Auswahl. Preise kommen weiterhin von StoreKit; alle Inhalte bleiben kostenlos. Produktkennungen und Kaufablauf sind unverändert.

Die vom Auftraggeber übermittelten Anbieter- und Kontaktdaten sind in Impressum, Datenschutzerklärung und Mail-Support hinterlegt: Julian Kürten, Spreeallee 207, 24111 Kiel, kontakt@verlag-ki.de. Die Supportansicht bereitet einen Mail-Entwurf an diese Adresse vor. Als Mailanbieter ist IONOS bestätigt. Die öffentlichen Informationsseiten werden in Notion vorbereitet. Die abschließende rechtliche Prüfung, öffentliche URLs und Einzelheiten der externen Datenverarbeitung sind weiterhin offen.

Geprüft wurden die geänderte Swift-Syntax, Projektintegrität, zwei gezielte Tests für Rechtstexte und Mail-Entwürfe, vier Prüfungen der Release-Sperre und die geänderte Vorschau einschließlich schmalem Dunkelmodus. Kein nativer iPhone-Test oder echter Kauf. Details: `Documentation/AENDERUNGEN_0_3_3.md`. Die 45 bestandenen Kerntests aus 0.3.2 gelten als vorheriger Prüfstand.

# Vorheriger Stand: Version 0.3.2

Impressum und Datenschutzerklärung sind als offline lesbare Seiten eingebaut, erreichbar in den Einstellungen und bereits beim ersten Einrichten. Datenschutz ist zusätzlich über das Profil und die Trinkgeldseite erreichbar. Fehlende Anbieterangaben werden ausdrücklich als offen angezeigt. Gemeinsame Textquelle: `Core/Resources/legal.json`. Noch keine rechtliche Freigabe und keine öffentliche Datenschutz- oder Supportadresse.

Neu unter „Hilfe & Kontakt“: acht kurze Anleitungen und Mail-Support. Eine überspringbare Einführung erscheint vor der optionalen Einrichtung beim ersten Start und lässt sich später über die Hilfe erneut öffnen. Der Mailknopf öffnet erst nach Konfiguration einer echten Kontaktadresse einen vom Nutzer selbst versendbaren Entwurf; bei fehlender Mail-App kann die Adresse kopiert werden. Siehe `Documentation/HILFE_0_3_2.md`.

Die vorhandene freiwillige Unterstützung umfasst kleine, mittlere und große Trinkgelder. Lokale Musterpreise: 2,99 €, 5,99 € und 9,99 €. Echte Preise lädt die App über StoreKit. Ohne konfigurierte Apple-Produkte zeigt die native App eine verständliche Nichtverfügbarkeit. Die ergänzte iPhone-Vorschau zeigt die Auswahl und löst keine Zahlung aus. Automatische Anfragen und ihre Abschaltbarkeit bleiben erhalten.

**Zur Veröffentlichung noch erforderlich:** Abschlussprüfung der Anbieterangaben, passende Rechtstexte und öffentliche Seiten, unabhängige Fachfreigabe, Apple-Mitgliedschaft/Signierung/Trinkgeldprodukte sowie echter Xcode-Build und iPhone-Abnahme. Siehe `Documentation/VEROEFFENTLICHUNG_0_3_2.md`. Die Entwürfe für die öffentlichen Seiten liegen im selben Ordner.

**Geprüft:** 45 XCTest-Prüfungen des Foundation-Kerns, vier Prüfungen der Release-Sperre, Syntax aller 22 App-Dateien und Projektintegrität bestanden. Das Xcode-Projekt wurde unabhängig geparst. Kein Apple-SDK-Typecheck, nativer Build oder iPhone-Test. Der Release-Build ist bewusst gesperrt, solange Inhaltsfreigaben oder vollständige rechtliche Informationen fehlen.

# Vorheriger Stand: Version 0.3.1

Fünf belegte Zitate von Kant, Goethe, Rilke und Marie von Ebner-Eschenbach ergänzen die 31 eigenen Lernimpulse. Unter jedem Zitat steht der Name mit einer aufrufbaren Quellenansicht. Text und Fundstelle funktionieren offline; nur der externe Originaltext benötigt Internet. Kleine Anpassungen historischer Schreibweisen sind sichtbar dokumentiert. Der tägliche Impuls bleibt abschaltbar. Einzelheiten und Quellen: `Documentation/ZITATE_0_3_1.md`.

43 Kerntests bestanden, 20 App-Dateien syntaktisch geprüft, Xcode-Projekt mit 64 Objekten geprüft. Noch kein nativer Build oder iPhone-Test. Alle übrigen Funktionen und gespeicherten Einstellungen bleiben erhalten. Dieser Abschnitt hat Vorrang vor älteren Statusangaben.

# Vorheriger Stand: Version 0.3.0

Neu ist ein einmaliger, überspringbarer Einstieg mit Name, optionalem Prüfungstermin und acht Farbwelten. Die Startseite begrüßt passend zur lokalen Tageszeit, zeigt den Countdown und einen täglich wechselnden eigenen Lernimpuls. Name und Farbwelt bleiben änderbar; der Impuls lässt sich ausblenden. Alle Paletten unterstützen Hell/Dunkel, alle Angaben werden lokal gespeichert und mitgesichert.

43 Kerntests bestanden. 19 App-Dateien syntaktisch geprüft. Noch kein nativer Build oder iPhone-Test. Details und Grenzen stehen in `Documentation/PERSONALISIERUNG_0_3.md`. Die seltenen automatischen Bewertungs- und Trinkgeldanfragen aus 0.2.2 bleiben erhalten. Dieser Abschnitt hat Vorrang vor älteren Statusangaben.

# Aktuell: Version 0.2.2

Automatische Bewertungs- und Trinkgeldanfragen sind auf ausdrücklichen Wunsch wieder enthalten, mit den bisherigen Nutzungsschwellen, Abständen, Prüfungssperrzeiten und dauerhaften Abschaltmöglichkeiten. Alle übrigen Vereinfachungen bleiben erhalten. Details: `Documentation/NACHFRAGEN_0_2_2.md`. Dieser Abschnitt hat Vorrang vor älteren Angaben zum Entfernen der Nachfragen. Noch kein nativer iPhone-Build oder Gerätetest.

# Aktueller Projektstand 0.2.1: einfacher lernen

Die Oberfläche wurde auf Wunsch gestrafft. Automatische Bewertungs- und Trinkgeldfenster, wiederholte Terminrückfragen, Kapazitätswarnungen und Zusatzaufforderungen nach einer Runde sind entfernt. Trinkgeld bleibt freiwillig in den Einstellungen. Notizen, Aufnahme und Detailauswertungen öffnen sich erst auf Wunsch. Praxis startet mit drei klaren Auswahlmöglichkeiten statt einem langen Formular.

Alle Inhalte, eigenen Texte und Lernstände bleiben erhalten. 34 Kerntests erneut bestanden; 18 App-Dateien syntaktisch geprüft. Noch kein nativer Build oder iPhone-Test. Die Details und Prüflimits stehen in `Documentation/VEREINFACHUNG_0_2_1.md`.

Die folgenden Abschnitte dokumentieren ältere Entwicklungsstände. Für Oberfläche und automatische Nachfragen hat 0.2.1 Vorrang.

# Erweiterter Projektstand 0.2.0

Die acht bestätigten Erweiterungen sind als native Quellcodefunktionen integriert. Neu sind adaptiver Tagesplan, gezielte Antworterklärungen mit späterem Anwendungsfall, 16 verzweigte Fallgeschichten, geführter Praxisplan samt Export, 24 Fachgesprächsfragen mit optionaler lokaler Aufnahme, Kompetenzübersicht, persönliche Lernsammlung und nachvollziehbare Inhaltsmeldungen. Hinzu kommen Drei-Minuten-Modus und ruhige Darstellung.

**Status:** 34 ausführbare Kerntests bestanden. 18 App-Dateien syntaktisch geprüft. Noch kein nativer Xcode-Build, kein Test auf einem iPhone und keine unabhängige Fachfreigabe. Audiodateien sind bewusst nicht Bestandteil der JSON-Sicherung. Der Browser-Bedienungsentwurf wurde in diesem Arbeitsschritt nicht aktualisiert.

Die vollständige Beschreibung und die zusätzlichen Gerätetests stehen in `Documentation/ERWEITERUNGEN_0_2.md`. Das Xcode-Projekt kann später direkt auf dem Mac geöffnet werden. Alle Inhalte und Funktionen bleiben kostenlos.

Die nachfolgende Einrichtung beschreibt die seit 0.1 vorhandene Basis; Versions- und Testangaben darin sind historisch. Maßgeblich ist dieser 0.2-Status.

# aevo. für iPhone

Stand: 20. September 2026 · erster nativer Entwicklungsstand · Arbeitsname

Dieses Paket enthält ein natives SwiftUI-Projekt mit lokalem Swift-Paket. Es wurde auf Linux vorbereitet. Der Programmkern wurde mit Swift 6.0.3 kompiliert und getestet. Die iOS-Oberfläche und die Apple-Systemdienste sind geschrieben, aber noch nicht mit Xcode gebaut oder auf einem iPhone ausgeführt. Das Paket ist deshalb ein prüfbarer Entwicklungsstand, keine bereits installierbare oder veröffentlichungsfertige App.

Julian muss seinen Mac jetzt noch nicht einsetzen. Die Arbeit am Quellcode, an den Inhalten und an den plattformunabhängigen Tests kann ohne ihn weitergehen. Der erste notwendige Mac-Einsatz ist der unten beschriebene Simulator-Build samt Geräteprüfung.

## Was enthalten ist

| Bereich | Im Quellcode angelegt |
|---|---|
| Heute | Klarer Einstieg, angefangene Runde fortsetzen, Tagesstrecke, Lernserie, nächste Karte und Countdown |
| Lernen | Alle 800 Aufgaben und 300 Lernkarten, Suche, Handlungsfelder, Merkliste, Fehler und Unsicherheit sowie neue Aufgaben |
| Lernrunde | Eigene Antwort bestätigen, genaue Auswahl bewerten, Begründungen für alle Optionen lesen, passende Karte öffnen; pro Runde unterschiedliche Aufgabenfamilien |
| Persönliche Karten | Titel, Erklärung, Merksatz, Beispiel und eigene Notizen bearbeiten; Eingabeentwürfe sichern; Original vergleichen und bei erhaltenen gespeicherten Notizen wiederherstellen |
| Speicherung | Lokale SwiftData-Datenbank mit ausdrücklich bestätigten Speichervorgängen; fehlgeschlagene Änderungen ersetzen nicht den letzten erfolgreichen Stand |
| Sicherung | Kostenloser JSON-Export und geprüfter Import einschließlich Notizen, Bearbeitungsentwürfen, Lernstand, Terminen und Nachfrageeinstellungen |
| Prüfung | 80 Aufgaben, 180 Minuten, Antwortänderungen, Markierungen, Aufgabenübersicht, Ergebnis und nachträgliche Erklärungen |
| Praxis | Eigener Ausbildungsplan mit Situation, Lernziel, Methodenbegründung, Ablauf und sechs Fachgesprächsimpulsen; einfacher 15-Minuten-Übungstimer |
| Motivation | Drei wählbare Tagesziele, abschaltbare Serie und sechs Abzeichen mit sichtbaren Bedingungen |
| Termine | Zwei optionale Prüfungstermine, Countdown, Verschiebung und ausdrücklich bestätigter Abschluss |
| Mitteilungen | Lokale iOS-Erinnerungen nach gewählten Wochentagen und Uhrzeit; Berechtigung erst beim Einschalten; höchstens eine pro Tag |
| Unterstützung | StoreKit-Anbindung für drei freiwillige Einmalkäufe; keine vorausgewählte Summe und keinerlei Lernfreischaltung |
| Bewertung | Nativer Systemdialog nach den vereinbarten Nutzungsschwellen und Abständen; kein emotionaler Vorabdialog |
| Gestaltung | Native Navigation, helle und dunkle Farben, Systemschrift und ein vorläufiges Buchsymbol als App-Icon |

Die 800 Aufgaben und 300 Karten stammen aus dem vorhandenen eigenen Bestand. Seit 0.3.4 tragen sie den vom Auftraggeber bestätigten fachlichen Freigabestand mit Datum und prüfender Person. Der Import übernimmt diesen Stand aus den Manuskripten in `ContentInputs`, erfindet keine Freigaben und ersetzt fehlende optionale Beispiele lediglich durch ein leeres Feld. Das Original bleibt in `ContentInputs` erhalten.

## Projekt öffnen, wenn der Mac wieder bereit ist

1. Das ZIP vollständig entpacken. Die Dateien innerhalb des Ordners müssen zusammenbleiben.
2. `AEVO.xcodeproj` mit einer zum Mac und iPhone passenden Xcode-Version öffnen. Technisches Mindestziel der App ist iOS 17. Es werden keine Drittanbieterpakete für die App benötigt.
3. Das Scheme `AEVOLernen`, die Konfiguration `Debug` und einen iPhone-Simulator auswählen. Dann mit Run starten.
4. Für ein echtes iPhone unter Signing & Capabilities das eigene Apple-Team auswählen. Die vorgeschlagene Bundle-ID `de.juliankuerten.aevo` ist noch nicht in einem Entwicklerkonto registriert oder auf Verfügbarkeit geprüft.
5. Die Geräteprüfungen in `Documentation/ABNAHME.md` durchführen. Erst anschließend lässt sich der native Stand als tatsächlich lauffähig bezeichnen.

Für einen ersten lokalen Bauversuch ist zusätzlich `bash Scripts/check_on_mac.sh` vorbereitet. Das Skript führt die Inhaltsprüfung und die Swift-Kerntests aus und versucht danach einen unsignierten Simulator-Build. Die übliche Xcode-Ersteinrichtung bleibt erforderlich. Es publiziert nichts und nimmt keine Zahlungen vor.

Die drei StoreKit-Produkte sind noch nicht in App Store Connect angelegt. Für lokale Kaufprüfungen in Xcode unter Product → Scheme → Edit Scheme → Run → Options die enthaltene Datei `Configuration/Tips.storekit` auswählen. Sie enthält Testpreise von 2,99 €, 5,99 € und 9,99 €. In der App werden grundsätzlich die von StoreKit geladenen Preise angezeigt. Ohne verfügbare Produkte bleibt die Unterstützungsseite freundlich deaktiviert; das Lernen ist davon unabhängig. Eine echte Zahlung wurde hier nicht durchgeführt.

## Jetzt ohne Mac prüfen

Mit einer installierten Swift-Toolchain:

```bash
swift test
python3 Scripts/validate_project.py
```

`swift test` prüft den gemeinsamen Programmkern. Es kompiliert nicht SwiftUI, SwiftData, UserNotifications oder StoreKit. Die zusätzlichen Struktur- und Inhaltsprüfungen ersetzen ebenfalls keinen Xcode-Build. Die tatsächlich erfolgten Prüfungen stehen in `Documentation/PRUEFBERICHT.md`.

Nach einer redaktionellen Änderung an den Originaldateien:

```bash
python3 Scripts/import_content.py
python3 Scripts/validate_project.py
swift test
```

Die Xcode-Projektdatei ist bereits enthalten. Das Python-Skript `Scripts/create_project.py` wird nur benötigt, wenn weitere App-Dateien aufgenommen werden sollen. Es arbeitet ohne zusätzliche Python-Pakete.

## Speicherung und Wiederherstellung

Die ausgelieferten Inhalte sind schreibgeschützt und vom persönlichen Datenstand getrennt. Laufende Lernrunden und Prüfungen enthalten außerdem eine Kopie ihrer verwendeten Fragen, damit ein späteres Inhaltsupdate nicht während eines Versuchs den Lösungsschlüssel verändert. Persönliche Karten referenzieren die ursprüngliche Kartenversion. Ein neues Original überschreibt eigene Texte nicht.

SwiftData speichert in dieser ersten Version einen versionierten Datensatz. Das hält zusammengehörige Änderungen, etwa Antwort, Wiederholungsstand und Tagesfortschritt, in einem Speichervorgang zusammen. Autosave ist deaktiviert; eine Erfolgsmeldung folgt erst nach `save()`. Bei Lesefehlern startet die App keinen leeren Ersatzstand. Neue Inhaltsstände sind zunächst App-Updates. Ein Server, Login, Analyse- oder Werbe-SDK ist nicht enthalten.

Ein Import wird vollständig gelesen und validiert, bevor er den bisherigen Stand ersetzt. Die App bittet um Bestätigung. Es findet keine automatische Zusammenführung zweier verschiedener Sicherungen statt. Ohne vorherigen Export außerhalb des Geräts ist ein Geräteverlust noch nicht abgesichert. Automatische iCloud-Synchronisierung gehört zu einer späteren Ausbaustufe.

Die Prüfung verwendet eine monotone Zeitbasis einschließlich Geräteschlaf und eine absolute Endzeit. Nach erkennbarer Änderung der Zeitbasis, Neustart mit nicht vergleichbarer Zeitbasis oder Import auf ein anderes Gerät bleibt der Antwortstand erhalten; der Versuch wird als zeitlich nicht vergleichbar gekennzeichnet. Ein solcher Versuch wird nicht unbemerkt als reguläre Generalprobe ausgegeben. Gerätelaufzeit wird nicht in Sicherungsdateien exportiert.

## Die ersten Versionsgrenzen

Der Code bildet den ersten zusammenhängenden Ausbau ab. Er enthält noch keine automatische iCloud-Synchronisierung, keine Abnahme mit VoiceOver und großer Schrift auf Geräten, keine validierte Bestehensprognose und keine fachlich freigegebenen Lerninhalte. Die praktische Vorbereitung enthält eigene Eingabefelder und sechs Gesprächsimpulse; die später vorgesehenen sechs ausgearbeiteten Praxisbeispiele und 24 Impulse sind noch nicht vollständig eingebunden.

Der einfache Praxistimer ist ein Hilfsmittel innerhalb der geöffneten Ansicht. Sein Timerstand und die drei Selbstcheck-Häkchen werden noch nicht wiederhergestellt. Die eigentlichen Praxistexte werden gespeichert. Abzeichen bewerten Mitarbeit und Organisation, nicht die Qualität der Antworten im Fachgespräch.

Der Release-Build prüft den fachlichen Freigabestatus der mitgelieferten Inhalte und die Vollständigkeit der Anbieterangaben. Die Inhalte kommen seit 0.3.4 durch; der Release-Build stoppt jetzt an der noch fehlenden rechtlichen Freigabe und den fehlenden öffentlichen Datenschutz- und Supportadressen. Interne Arbeit läuft über Debug. Für eine Veröffentlichung fehlen außerdem der tatsächliche iOS-Build, Geräteprüfungen, registrierte Storeprodukte und App-Store-Metadaten. Diese Punkte sind keine bereits erledigten Leistungen.

## Technische Quellen

Die Umsetzung orientiert sich an [SwiftUI](https://developer.apple.com/swiftui/), [SwiftData und ModelContext.save](https://developer.apple.com/documentation/swiftdata/modelcontext/save()), [lokalen Mitteilungen](https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app), [StoreKit-Käufen](https://developer.apple.com/documentation/storekit/product/purchase(options:)) und [Apples Bewertungsfunktion](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews). Die Datenschutzdeklaration zur lokalen Zeitmessung folgt dem vorgesehenen Timer-Zweck in [Apples Required-Reason-API-Kategorien](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). Der Hintergrund zur kontinuierlichen Zeitbasis steht im [Apple-Kernel-Header mach_time.h](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/mach_time.h). Stand der technischen Recherche: 20. September 2026.
