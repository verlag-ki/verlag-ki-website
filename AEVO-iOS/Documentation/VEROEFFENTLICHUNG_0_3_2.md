# Veröffentlichung vorbereiten: Stand 0.3.2

Recherche und Projektprüfung: 20. September 2026. Arbeitsname: aevo. Zielmarkt Deutschland, ausschließlich iPhone. Dieses Dokument beschreibt den tatsächlich vorliegenden Entwicklungsstand. Es ist keine Zusage einer App-Store-Zulassung und keine abschließende rechtliche Prüfung.

## Was ergänzt wurde

In den Einstellungen führt „App unterstützen → Freiwilliges Trinkgeld“ zu drei einmaligen Käufen. Geplante deutsche Preise sind 2,99 €, 5,99 € und 9,99 €. Die StoreKit-Testkonfiguration enthält diese Beträge; in der ausgelieferten App kommen Verfügbarkeit und lokalisierter Preis immer von Apple. Es ist kein Betrag vorausgewählt. Ein Kauf verbessert oder entsperrt nichts. Es wurden noch keine echten Produkte in App Store Connect angelegt und keine echten Käufe getestet.

Die bisherigen seltenen automatischen Trinkgeld- und Bewertungsanfragen bleiben bestehen. Beide sind dauerhaft abschaltbar; die freiwillige Unterstützung bleibt trotzdem erreichbar. Es gibt keine Kombination aus Bewertung und Bezahlung. Apple erlaubt Trinkgeld an Entwickler über In-App-Käufe; die Regeln verbieten manipulierte oder belohnte Bewertungen. [Apple App Review Guidelines, 3.1.1 und 5.6.1](https://developer.apple.com/app-store/review/guidelines/).

Neu sind eigenständige, offline lesbare Seiten „Impressum“ und „Datenschutzerklärung“ unter „Informationen & Recht“. Datenschutz ist zusätzlich im Profil, beim ersten Einrichten und auf der Trinkgeldseite erreichbar. Die Rechtstexte sind ausdrücklich Entwürfe. Die App erfindet keine Anschrift, Firma oder Kontaktadresse.

Kontakt / Support öffnet einen Entwurf in der E-Mail-App, sobald eine gültige Empfängeradresse hinterlegt ist. Ohne eingerichtete E-Mail-App gibt es einen Hinweis und die Möglichkeit, die Adresse zu kopieren. Die App sendet nichts selbst und fügt keine privaten Lerndaten an. Acht offline verfügbare Anleitungen und eine überspringbare Einführung ergänzen den ersten Start; die Einführung ist über die Hilfe erneut aufrufbar.

## Was zur Veröffentlichung konkret fehlt

| Voraussetzung | Tatsächlicher Stand | Nächster überprüfbarer Schritt |
|---|---|---|
| Anbieter und Kontakt | Name der verantwortlichen Person/Firma, Anschrift und E-Mail für dieses Angebot nicht verbindlich benannt | Betreiberform bestimmen; ladungsfähige Anschrift und betreute Kontaktadresse liefern; eventuell Rechtsform, Vertretung, Register, USt-IdNr. und weitere einschlägige Angaben ergänzen |
| Rechtstexte | In der App eingebaut; Datenflüsse anhand des Codes beschrieben; externe Anbieter unbekannt | Tatsächlichen E-Mail- und Webhost festlegen, Empfänger/Verarbeitungsorte/Löschfristen ergänzen, Dokumente passend zum Betrieb prüfen und freigeben |
| Öffentliche Seiten | Keine belegte, veröffentlichte Datenschutz- oder Supportadresse | Kleine öffentliche HTTPS-Seiten ohne Anmeldung bereitstellen, von einem fremden Gerät aufrufen und Links in App Store Connect eintragen |
| Fachliche Inhaltsfreigabe | 800 Aufgaben, 300 Karten, 16 Fälle und 24 Fachgesprächsimpulse sind Entwürfe; null unabhängige Freigaben | Qualifizierte AEVO-Fachperson prüft Lösungen, Begründungen, Quellen, Abdeckung und Prüfungsdarstellung; Freigaben dokumentieren und Inhalte neu importieren |
| Native App | Foundation-Kern läuft auf Linux; SwiftUI-Code bislang nur syntaktisch geprüft | Auf einem geeigneten Mac mit aktuellem Xcode bauen; Apple-SDK-Fehler beheben; Simulator und echtes iPhone prüfen |
| Apple-Mitgliedschaft und Identität | Konto, Mitgliedschaft, Team und Rollen nicht nachgewiesen | Eigene Apple-Developer-Mitgliedschaft klären, Identität verifizieren, App-ID und Signierung einrichten |
| Trinkgeldprodukte | StoreKit-2-Code und lokale Testprodukte vorhanden | Drei „Consumable“-Produkte registrieren, Preise/Lokalisierungen/Review-Screenshots ergänzen; Paid Apps Agreement sowie Steuer- und Bankangaben erledigen |
| Datenschutzangaben für Apple | Privacy-Manifest vorhanden; keine Werbe-/Analyse-SDKs im Code | Finale App samt Abhängigkeiten und Datenwegen prüfen; App-Privacy-Fragen passend beantworten; Manifest und Antworten auf Konsistenz prüfen |
| Store-Auftritt | Arbeitsname und App-Icon im Projekt; noch keine finale Store-Eintragung | Namens- und Rechteprüfung, Untertitel/Beschreibung, echte App-Screenshots, Altersfreigabe, Review-Kontakt, Support-URL, Exportangaben vervollständigen |
| Abnahme und Support | Linux- und Vorschauprüfungen bestanden; keine TestFlight-/Geräteabnahme | Abnahmeplan unten durchführen; kleine Testgruppe über TestFlight; kritische Fehler beheben; erreichbaren Support und Inhaltskorrekturen organisatorisch sichern |

Apple verlangt eine öffentliche Datenschutz-URL und einen leicht zugänglichen Datenschutzlink in der App. Ein lokaler Text allein erfüllt die Store-Vorgabe nicht. [App-Privacy-Verwaltung](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/), [Review Guidelines, 5.1.1](https://developer.apple.com/app-store/review/guidelines/).

§ 5 DDG benennt für einschlägige Angebote die Anbieter- und Kontaktangaben sowie zusätzliche Angaben je nach Rechtsform und Tätigkeit. Für dieses auf Dauer angebotene Produkt mit In-App-Unterstützung wird ein vollständiges Impressum vorbereitet; kostenloses Lernen wird nicht pauschal als Ausnahme behandelt. Ob weitere Pflichten für den konkreten Betreiber gelten, wird nach Festlegung der Betreiberform geprüft. [DDG, § 5, amtliche PDF, Seiten 6–7](https://www.gesetze-im-internet.de/ddg/DDG.pdf). Die Datenschutzerklärung muss insbesondere Verantwortlichen, Zwecke, Rechtsgrundlagen, Empfänger, Speicherdauer und Rechte passend zur tatsächlichen Verarbeitung nennen. [DSGVO, Art. 13](https://eur-lex.europa.eu/eli/reg/2016/679/oj/deu).

## Apple-Einrichtung und Kosten

Die Developer-Mitgliedschaft kostet regulär 99 US-Dollar pro Mitgliedschaftsjahr beziehungsweise den von Apple angebotenen lokalen Betrag. Der genaue deutsche Rechnungsbetrag wird bei der Anmeldung geprüft. Xcode dient zum nativen Build und Upload. Apples veröffentlichte Mindestanforderung für Uploads gilt seit dem 28. April 2026: Xcode 26 oder neuer mit iOS-26-SDK oder neuer. Das ist eine Build-Anforderung; die App kann weiterhin einen niedrigeren unterstützten iOS-Mindeststand haben. Das Projekt setzt derzeit iOS 17 voraus. Vor dem tatsächlichen Upload sind die Anforderungen erneut abzugleichen. [Mitgliedschaft und Gebühr](https://developer.apple.com/programs/whats-included/), [aktuelle Upload-Anforderungen](https://developer.apple.com/news/upcoming-requirements/).

Für In-App-Käufe ist auch bei einer kostenlos ladbaren App das Paid Apps Agreement erforderlich. Dazu gehören passende Steuer- und Bankangaben in App Store Connect. Die ersten Trinkgeldprodukte sollen zusammen mit der ersten App-Version zur Prüfung eingereicht werden. Niemand hat diese Verträge im Rahmen dieser Arbeit akzeptiert. [Apple-Verträge](https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/), [erste In-App-Käufe einreichen](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase/).

Für die EU ist der Händlerstatus zu erklären. Apple verlangt bei Händlern die Verifizierung und Veröffentlichung von Adresse, Telefonnummer und E-Mail. In-App-Einnahmen sind ein Faktor der Selbsteinschätzung, aber keine automatische abschließende rechtliche Einstufung. Als Einzelperson erscheint grundsätzlich der bürgerliche Name als Verkäufer; eine Organisation hat zusätzliche Identitätsanforderungen. Eine von Apple im DSA-Verfahren akzeptierte Postfachadresse ersetzt nicht automatisch die erforderliche Anbieteranschrift nach deutschem Recht. [DSA bei Apple](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/), [Anmeldung als Person oder Organisation](https://developer.apple.com/programs/enroll/).

Weitere Aufwände bleiben Inhaltsprüfung, Wartung, Kontaktpostfach/öffentliche Seiten und gegebenenfalls die Instandsetzung oder Bereitstellung eines geeigneten Macs. Eine Domain, Hosting- oder E-Mail-Lizenz sowie ein aktives Apple-Konto werden nicht als vorhanden vorausgesetzt. Eine Serverinfrastruktur für Lernstände ist derzeit nicht nötig.

## Dateninventar für die Datenschutzabnahme

| Verarbeitung | Implementierung | Grenze oder offene Prüfung |
|---|---|---|
| Lernstand, Profil, Termine, eigene Texte | SwiftData-Snapshot lokal; CloudKit explizit deaktiviert | iOS kann gewöhnliche App-Daten je nach Systemeinstellungen in Gerätebackups aufnehmen |
| Inhaltspakete | Im App-Paket enthalten | Updates derzeit nur mit App-Versionen; kein eigener Content-Server |
| Sicherung | Freiwilliger JSON-Export/Import, vom Nutzer gewählter Ort | Export ist nicht zusätzlich durch ein App-Passwort verschlüsselt; externe Kopien separat löschen |
| Fachgesprächsaufnahme | Lokale M4A-Datei, maximal fünf Minuten, explizite Mikrofonfreigabe | Aufnahmeordner von Systembackup ausgeschlossen; nicht im JSON-Export; auf Gerät verifizieren |
| Erinnerungen | Lokale iOS-Mitteilungen, Tage/Uhrzeit einstellbar | Berechtigungsablehnung, Ausschalten und geplante Erinnerungen nativ abnehmen |
| Inhaltsmeldung | Lokal gespeichert; Export nur bei freiwilliger Nutzeraktion | Kein automatischer Versand; empfangender Supportdienst noch festzulegen |
| Trinkgeld | Apple StoreKit; Transaktionskennung und Kaufzeitpunkt lokal | Keine eigenen Bank-/Kreditkartendaten; Kaufzustände und Neustartbehandlung in Sandbox prüfen |
| Bewertungen | iOS-Systemdialog, Häufigkeit lokal begrenzt | Apple entscheidet über die tatsächliche Anzeige; keine Rückmeldung über abgegebene Bewertung |
| Quellenlinks | Vom Nutzer geöffnete externe Website | Website verarbeitet eigene Verbindungsdaten; keine Lerndaten im Quellenlink |
| Support/öffentliche Seiten | Mail-Entwurf technisch vorbereitet; Empfänger und Dienste noch offen | Anbieter, Standorte, Löschfristen und gegebenenfalls Auftragsverarbeitung/Drittlandgarantien ergänzen |

Apple zählt ausschließlich auf dem Gerät verarbeitete Daten bei den App-Privacy-Antworten grundsätzlich nicht als erhoben. Eine Antwort „Keine Daten erfasst“ ist trotzdem erst nach Prüfung des fertigen Produkts und aller tatsächlichen externen Wege zulässig. Apples eigene Verarbeitung und Daten, die der Entwickler über Apple-Dienste erhält, sind auseinanderzuhalten. Das Privacy-Manifest ersetzt weder Datenschutzerklärung noch App-Privacy-Antworten. [Apples Definitionen](https://developer.apple.com/app-store/app-privacy-details/).

## Abnahme auf Mac und iPhone

1. Debug-Build mit Apple-SDK fehlerfrei starten; Erststart, Überspringen der Personalisierung und spätere Änderung prüfen. Name und beide Termine müssen entfernbar bleiben.
2. Bei abgelehntem Mikrofon- und Mitteilungszugriff weiterlernen. Keine Berechtigung beim bloßen App-Start anfragen. Quellen und Käufe dürfen offline verständlich ausfallen, der Lernbetrieb muss funktionieren.
3. Neue und bearbeitete Karten, Entwürfe, Notizen und Lernstände nach Beenden/Neustart wiederfinden. Sicherung auf zweitem Gerät importieren; defekte Sicherung darf bestehende Daten nicht ersetzen.
4. Simulation mit App-Wechsel, Sperrbildschirm, Neustart, Zeitablauf und Abgabe prüfen. Keine Antwortänderung nach endgültiger Abgabe; korrekte Bewertung bei Mehrfachauswahl.
5. VoiceOver, größere Schrift, alle acht Farbwelten und beide Erscheinungsbilder abnehmen. Lange deutsche Texte und kleine iPhones ohne abgeschnittene Aktionen prüfen.
6. Aufnahmen starten, unterbrechen, anhören und löschen; Bestätigung vor Überschreiben; Ausschluss aus Export und Backup auf dem Gerät bestätigen.
7. Alle drei Trinkgeldprodukte in StoreKit/Sandbox prüfen: Erfolg, Abbruch, ausstehender Kauf, fehlendes Netz, nicht verfügbare Produkte und erneut gelieferte Transaktion. Kauf darf keine Inhalte verändern. Lokale Testkonfiguration nicht mit einer erfolgreichen Sandbox-Abnahme verwechseln.
8. Anfragen dürfen erst nach tatsächlichen Nutzungsschwellen, nur nach beendeter Lernrunde und mit den vorhandenen Abständen erscheinen. Beide Abschaltungen müssen Neustart und Sicherung überstehen. Keine Nachfrage mitten in Prüfung, Fehlerzustand oder aktiver Aufgabe.
9. Impressum und Datenschutz vom ersten Einrichten und von Einstellungen aus öffnen; Text ohne Netz lesen. Öffentliche Datenschutz- und Supportseite ohne Anmeldung erreichen. In-App-Fassung und veröffentlichte Erklärung müssen inhaltlich zusammenpassen.
10. Einführung beim ersten Start, direktes Überspringen, optionales Einrichten und späteres Wiederholen über Hilfe prüfen. Kontakt über die konfigurierte Standard-Mail-App öffnen und abbrechen; ohne Mail-App Adresse kopieren. Ohne bewusstes Senden darf keine Nachricht verschickt werden.
11. Nach dokumentierter fachlicher und rechtlicher Fertigstellung Release-Build, Archiv, Signierung, App-Store-Validierung und TestFlight durchführen. Erst danach die finale Version mitsamt Käufen einreichen. Die Veröffentlichung bleibt eine eigene Entscheidung.

## Konfiguration und offene Angaben

Die gemeinsame Quelle der Rechtstexte liegt in `Core/Resources/legal.json`. `operatorInfo` enthält Namen, Anschrift, E-Mail, optionale Telefonnummer und zusätzliche einschlägige Impressumsangaben. `privacyURL` und `supportURL` bleiben leer, bis echte öffentliche Seiten existieren. `supportProcessing` und `websiteProcessing` nehmen die tatsächlichen Datenwege auf. Keine privaten Steuernummern, Zugangsdaten oder Bankdaten in diese öffentliche Datei schreiben.

Erst nach inhaltlicher Vervollständigung und Prüfung dürfen `approved`, `reviewedBy` und `reviewedOn` gesetzt werden. Diese Metadaten dokumentieren eine erfolgte Prüfung und ersetzen sie nicht. `Scripts/validate_release.py` blockiert Release weiterhin bei fehlender Fachfreigabe und jetzt zusätzlich bei unvollständigen Anbieterangaben, fehlenden HTTPS-Seiten oder ungeprüften Rechtstexten. Debug bleibt für interne Arbeit nutzbar. Die zusätzlichen Rechtstext-Prüfungen sind eine Umsetzungskontrolle für diesen Projektstand, keine vollständige automatische Rechtsprüfung.

Die lesbaren Entwürfe unter `Documentation/IMPRESSUM_ENTWURF.md` und `Documentation/DATENSCHUTZ_ENTWURF.md` sind Arbeitskopien. Änderungen immer zuerst in der gemeinsamen JSON-Quelle pflegen und die Arbeitskopien anschließend erneut erzeugen. Sie wurden noch nicht als öffentliche Website veröffentlicht.

## Empfohlene Reihenfolge

Zunächst Betreiberform und Kontaktdaten festlegen und die unabhängige Inhaltsprüfung beginnen. Parallel können öffentliche Support-/Datenschutztexte finalisiert sowie Store-Texte vorbereitet werden. Den Mac erst für den echten nativen Build und die Geräteabnahme hinzunehmen. Apple-Käufe und TestFlight folgen auf einen funktionierenden Build. Weitere Funktionsideen erhöhen derzeit den Veröffentlichungsumfang; die nächste Arbeit sollte die vorhandenen Funktionen zuverlässig und fachlich belastbar machen.
