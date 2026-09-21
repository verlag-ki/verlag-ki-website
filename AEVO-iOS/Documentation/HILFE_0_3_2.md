# Kontakt, Anleitungen und Einführung

Stand: 20. September 2026, Bestandteil der Version 0.3.2.

„Einstellungen → Hilfe & Kontakt“ enthält zwei klare Einträge. „Kontakt / Support“ erklärt den freiwilligen Kontakt, öffnet nach Konfiguration der Kontaktadresse einen Mail-Entwurf und bietet das Kopieren der Adresse an. Wenn iOS keine Mail-App öffnen kann, erscheint ein verständlicher Hinweis. Die App setzt einen allgemeinen Betreff einschließlich ihrer Version, keine weiteren Empfänger und keine Anhänge. Die Nachricht wird ausschließlich durch den Nutzer in seiner E-Mail-App versendet. Es existiert kein eigener Versandserver. Die Empfängeradresse kommt aus `Core/Resources/legal.json`, Feld `operatorInfo.email`, und ist noch offen.

„Hilfe & Anleitungen“ enthält acht aufklappbare Themen: Lernrunde, bearbeitbare Lernkarten, Wiederholung, Prüfungssimulation, Praxis/Fachgespräch, Profil/Termine/Erinnerungen, Sicherung sowie Trinkgeld/Bewertungen. Alle Texte werden mitgeliefert und bleiben offline lesbar. Die Hilfe führt bei weiterem Bedarf zum Kontakt.

Die Einführung besteht aus einer kurzen Ansicht mit drei Gedanken: im eigenen Tempo lernen, eigene Gedanken festhalten und Theorie mit Praxis verbinden. Beim ersten Start kann man die App anschließend persönlich einrichten oder mit „Direkt loslernen“ ohne Angaben beginnen. Es gibt keinen Pflichtfilm, keine Kontoanmeldung und keine automatische Nachfrage nach Geld, Bewertung oder Berechtigungen in diesem Ablauf. Datenschutz und Impressum sind bereits hier erreichbar.

Die bereits vorhandene Einstellung `profile.onboardingCompleted` wird erst nach erfolgreichem lokalem Speichern gesetzt. Die neue Einführung benötigt kein zusätzliches Datenfeld, daher werden bestehende Sicherungen nicht um ein neues Pflichtfeld erweitert. Wer die Einrichtung bereits abgeschlossen hat, wird durch ein Update nicht erneut unterbrochen. Ein Abbruch vor erfolgreichem Abschluss lässt den Start beim nächsten Öffnen erneut erscheinen. „Einführung ansehen“ in der Hilfe öffnet denselben Inhalt zum Nachlesen und verändert weder Profil noch Lernstand.

Der Foundation-Test prüft Mail-URLs mit Sonderzeichen im Betreff sowie die Abweisung fehlender Adressen und zusätzlicher eingeschleuster Empfänger/Header. Die App-Syntax wurde geprüft. Native Mail-Weiterleitung, Kopieren, Einführung/Dismiss-Verhalten, VoiceOver und große Schrift benötigen weiterhin einen echten iPhone-Test; sie wurden nicht als bestanden ausgegeben.

Die getrennte interaktive Vorschau zeigt Mail-Support, alle acht Anleitungen und die wieder aufrufbare Einführung. Sie löst keine Nachricht aus. Eine fehlende Empfängeradresse wird auch dort offengelegt.
