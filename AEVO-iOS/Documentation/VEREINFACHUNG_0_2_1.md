# Vereinfachung 0.2.1

Auftrag: mögliche nervige Funktionen prüfen und entfernen; die App soll einfach bleiben.

Die Prüfung erfolgte anhand des Quellcodes und der darin angelegten Nutzerwege. Sie ist eine Produkt- und Ablaufprüfung, kein beobachteter Nutzertest und keine native Sichtprüfung.

## Entfernt

- Automatische Storebewertungen und automatische Trinkgeldfenster. Die App ruft weder den Bewertungsdialog noch die Unterstützungsansicht ungefragt auf. Auch die entsprechenden Abschaltoptionen entfallen, weil sie ohne automatische Nachfrage überflüssig wären. Frühere Nutzungsgrenzen und Opt-outs bleiben als historische Daten und Kernlogik lesbar, werden von der Oberfläche aber nicht mehr aufgerufen.
- Zusätzliche Aufforderungen zu Karte und Praxis auf der Abschlussseite. Es bleiben „Für heute fertig“ und „Noch eine Runde“.
- Die wiederkehrende Rückfrage auf der Startseite nach einem vergangenen Prüfungstermin. Termine und Abschlussstatus lassen sich weiterhin in den Einstellungen bearbeiten.
- Der pauschale Hinweis, dass die verbleibende Zeit möglicherweise nicht für alle Inhalte reicht. Seine Heuristik begründet keine unnötige Druckmeldung mehr in der Oberfläche.
- Die sichtbare Liste aller noch leeren Praxisfelder und die Schaltfläche zum wiederholten Anhängen eines automatisch zusammengesetzten Lernziels.
- Die vier Zusatzangebote vor dem eigentlichen Fragenkatalog und die doppelte Kompetenzverknüpfung auf der Startseite.
- Doppelte sofort angezeigte Antworterklärungen und technische Hinweise auf vorgemerkte Transferfragen. Die Wiederholung selbst arbeitet weiter im Hintergrund.
- Überflüssige „Später entscheiden“ und „Nicht mehr fragen“-Schaltflächen auf der ausschließlich manuell geöffneten Trinkgeldseite. Schließen bleibt jederzeit möglich.

## Auf ausdrücklichen Wunsch erreichbar

- Antwortdetails lassen sich aufklappen. Bei einer neuen Aufgabe beginnen sie wieder geschlossen.
- Eigene Notizen liegen unter der Hauptaktion zum Weiterlernen. Der Texteditor erscheint erst beim Öffnen; Quellen und Inhaltsmeldungen bleiben erreichbar.
- Eigene Lernsammlung und Lernfortschritt liegen im Menü des Lernbereichs. Die Kompetenzübersicht beginnt mit vier aufklappbaren Handlungsfeldern statt sämtlichen Lernzielen.
- Praxis öffnet eine Auswahl aus Ablaufplanung, Fachgespräch und Alltagssituationen. Das ausführliche Formular startet erst nach Auswahl des Planers.
- Im Planer sind Formulierungshilfe, Methodenalternative, zusätzliche Vorkenntnisse, Schwierigkeiten und Selbstcheck eingeklappt. Alle vorhandenen Texte bleiben erreichbar.
- Das Fachgespräch beginnt direkt mit einer Frage. Stichpunkte und Aufnahme sind optional aufklappbar. Einklappen beendet eine laufende Aufnahme oder Wiedergabe; beim Fragenwechsel ist die Aufnahmeansicht wieder geschlossen.

## Bewusst beibehalten

Die vier Hauptbereiche, kurze adaptive Runden, verständliche Erklärungen, editierbare Karten, eigene Notizen, Prüfungssimulation, freiwillige Abzeichen und Tagesstrecke, abschaltbare Lernserie, freiwillige Erinnerungen sowie getrennte Prüfungstermine bleiben erhalten. Der ruhige Modus ist weiter verfügbar. Das freiwillige Trinkgeld bleibt in den Einstellungen mit drei Beträgen erreichbar. Kein Nutzertext und kein Lernstand wird gelöscht; das Datenformat bleibt unverändert.

## Prüfung und Grenzen

Alle 34 vorhandenen Kerntests bestanden erneut. Die 18 App-Dateien bestehen die Swift-Syntaxprüfung. Eine zusätzliche Quellcodekontrolle bestätigt, dass keine automatischen Bewertungs- oder Trinkgeldaufrufe, keine Kapazitätswarnung und keine wiederholte Terminrückfrage im App-Code verbleiben. Die weiterhin vorhandenen Tests der alten Nachfrageregeln prüfen nur rückwärtskompatible Kernlogik, keinen aktiv genutzten Nachfrageablauf.

Apple-SDK-Typecheck, native Darstellung, Navigation, Mikrofonverhalten, VoiceOver und Dynamic Type sind weiterhin auf dem Mac und iPhone zu prüfen. Ein späterer kurzer Nutzertest sollte besonders prüfen, ob Anfänger ohne Hilfe eine Runde beginnen und ob optionale Notizen und Praxisfunktionen bei Bedarf gefunden werden. Es wird keine gemessene Verbesserung der Bedienbarkeit behauptet.
