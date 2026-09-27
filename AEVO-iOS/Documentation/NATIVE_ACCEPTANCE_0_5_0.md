# Native Abnahme der modularisierten App

Diese Punkte benötigen Xcode und ein iPhone beziehungsweise einen Simulator. Sie wurden in der Linux-Arbeitsumgebung nicht als durchgeführt verbucht.

1. Bestehende 0.4.0-Installation sichern. AEVO 0.5.0 mit derselben Bundle-ID und demselben Produktnamen aktualisieren, ohne die App zu löschen. SwiftData muss den bestehenden Snapshot laden. Name, Farbe, beide Prüfungstermine, Erinnerung, Abzeichen und persönliche Texte prüfen.
2. Einen gespeicherten Kartenstapel fortsetzen. Beide Swipes und Knöpfe müssen genau eine Karte weitergehen. Eine eigene Notiz ändern, neu starten, wieder öffnen. JSON-Sicherung exportieren, auf zweitem Simulator importieren und vergleichen.
3. Eine bereits eingeloggte Aufgabe öffnen, Erklärung lesen und weitergehen. Neu beginnen, Single- und Multiple-Choice beantworten. Fachgesprächsnotizen und lokale Aufnahme prüfen. Vorhandene Aufnahmedateien dürfen nicht durch die Modularisierung verschoben werden.
4. AEVO-Simulation starten: 80 Fragen, 180 Minuten, Quoten 12/18/38/12, freie Navigation und Antwortänderung. Nach Unterbrechung läuft die Uhr weiter. Erst nach Abgabe Lösungen und Ergebnis ab 50 Prozent prüfen.
5. Orbit-Demo separat erzeugen und starten: anderer Name, andere Farbe, drei Themen, zehn Fragen, fünf Karten. Kein Praxis-Tab, keine mündliche Vorbereitung, keine Trinkgeldauswahl oder entsprechende Anfragen. Kein Mikrofonhinweis im Info.plist.
6. Demo-Simulation: sechs Fragen, fünf Minuten, 70 Prozent, Teilpunkte, Vorwärtsnavigation. Beim Schließen oder Hintergrundwechsel pausiert die Zeit, auf anderen Seiten darf sie nicht weiterlaufen. Bei Rückkehr läuft sie weiter. Ergebnis enthält die Übersicht ohne einzelne Lösungen.
7. AEVO-Backup im Demo ablehnen, ohne den Demo-Lernstand zu ersetzen. Demo-Backup im AEVO-Angebot ebenfalls ablehnen.
8. Einführung, Hilfe, Unterstützung, Quellen, Datenschutz und Kontakt auf korrekte Appnamen und aktivierte Module prüfen. Mailentwürfe müssen freiwillig bleiben. Echte IAP-Kennungen separat in der Apple-Sandbox abnehmen.
9. Kleine Bildschirmgröße, größte unterstützte Schrift, VoiceOver, Hell/Dunkel und Bewegung reduzieren prüfen. Insbesondere feste untere Aktionen und lange Kategorienamen müssen erreichbar bleiben.
10. Abschließend Archive/Release erst nach den weiterhin offenen rechtlichen und Store-Voraussetzungen prüfen. Die fachliche Bestätigung des vorhandenen AEVO-Inhalts ersetzt diese Schritte nicht.
