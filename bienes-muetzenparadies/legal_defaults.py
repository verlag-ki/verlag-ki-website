"""Vorlagen für Impressum und Datenschutz.

Sie werden beim ersten Start in die Datenbank übernommen und lassen sich danach
in der Verwaltung unter „Rechtliches“ ändern. Schreibweise:
  ## Überschrift        neue Zwischenüberschrift
  Leerzeile             neuer Absatz
  [Text in Klammern]    wird gelb markiert: hier fehlt noch etwas
E-Mail-Adressen und Links (https://…) werden automatisch anklickbar.
"""

IMPRESSUM = """[Bitte prüfen: Angaben mit dem aktuellen Impressum von Mieten macht Sinn abgleichen. Danach diesen Hinweis löschen.]

## Angaben zum Anbieter
Bienes Mützenparadies
Julian Kürten
Spreeallee 207
24111 Kiel
Deutschland

## Kontakt
Telefon: 0176 47147503
E-Mail: info@mieten-macht-sinn.de
WhatsApp: +49 157 34487082

## Umsatzsteuer
[Umsatzsteuer-Identifikationsnummer oder Wirtschafts-Identifikationsnummer eintragen, falls vorhanden. Sonst diesen Abschnitt löschen.]
"""

DATENSCHUTZ = """[Bitte ergänzen und rechtlich prüfen lassen: alle gelb markierten Stellen. Danach diesen Hinweis löschen.]

## 1. Verantwortlicher
Julian Kürten, Bienes Mützenparadies
Spreeallee 207, 24111 Kiel, Deutschland
E-Mail: info@mieten-macht-sinn.de
Telefon: 0176 47147503

## 2. Das Wichtigste in Kürze
Diese Website kommt ohne Analyse- oder Werbedienste und ohne Cookies für Besucherinnen und Besucher aus. Schriften, Bilder und Skripte werden vom eigenen Server geladen, nicht von Drittanbietern. Anfragen kannst du per WhatsApp oder über unser Kontaktformular schicken. Das Formular verschickt keine E-Mails: Deine Nachricht wird nur auf unserem eigenen Server gespeichert.

## 3. Hosting
Die Website läuft auf einem Server der Hetzner Online GmbH, Industriestr. 25, 91710 Gunzenhausen, Deutschland. Standort des Servers: [Rechenzentrum eintragen, z. B. Nürnberg oder Falkenstein]. Mit Hetzner besteht ein Vertrag zur Auftragsverarbeitung nach Art. 28 DSGVO [Abschluss prüfen].

## 4. Aufruf der Website
Beim Aufruf einer Seite verarbeitet der Server technisch notwendige Angaben wie deine IP-Adresse, Datum und Uhrzeit, die aufgerufene Adresse und die Browserkennung. Das ist nötig, um dir die Seite auszuliefern und sie vor Angriffen zu schützen. Rechtsgrundlage ist Art. 6 Abs. 1 lit. f DSGVO.

Zugriffsprotokolle über einzelne Seitenaufrufe speichern wir nicht. Technische Fehlermeldungen des Servers können eine IP-Adresse enthalten und werden nach [Frist anhand der Serverkonfiguration eintragen] gelöscht.

## 5. Kontaktformular
Wenn du uns über das Kontaktformular schreibst, speichern wir deinen Namen, deine Telefonnummer oder E-Mail-Adresse, deine Nachricht und – falls angegeben – das gewünschte Muster, deinen Kopfumfang und deine Wünsche. Die Nachricht liegt ausschließlich in der Datenbank auf unserem Server und ist nur im passwortgeschützten Verwaltungsbereich sichtbar. Es werden keine E-Mails verschickt und keine Dritten eingebunden.

Wir nutzen die Angaben nur, um dir zu antworten und gegebenenfalls deine Mütze anzufertigen. Rechtsgrundlage ist Art. 6 Abs. 1 lit. b DSGVO. Erledigte Nachrichten löschen wir zeitnah, spätestens werden alle Nachrichten nach 6 Monaten automatisch gelöscht. Zum Schutz vor massenhaften Einsendungen speichern wir kurzzeitig einen nicht rückrechenbaren Hashwert deiner IP-Adresse, höchstens 24 Stunden.

## 6. Kontakt per WhatsApp
Für Anfragen bieten wir einen Direktlink zu WhatsApp an. Es ist kein WhatsApp-Widget eingebunden, und beim bloßen Besuch der Website entsteht keine Verbindung zu WhatsApp. Deine Angaben zu Muster, Kopfumfang und Wünschen bleiben zunächst nur in deinem Browser. Erst wenn du auf „WhatsApp öffnen“ tippst, werden sie als vorbereiteter Text an WhatsApp übergeben. Gesendet wird nichts automatisch: Du kannst die Nachricht in WhatsApp ändern oder verwerfen.

Anbieter von WhatsApp ist die WhatsApp Ireland Limited, 4 Grand Canal Square, Grand Canal Harbour, Dublin 2, Irland. Dabei können Daten auch an die Meta Platforms, Inc. in den USA übermittelt werden. Details findest du in den Datenschutzhinweisen von WhatsApp: https://www.whatsapp.com/legal/privacy-policy-eea

Schreibst du uns, verarbeiten wir deine Telefonnummer, deinen WhatsApp-Namen und den Inhalt eurer Nachrichten, um deine Anfrage zu beantworten und gegebenenfalls deine Mütze anzufertigen und zu versenden. Deine Lieferadresse geben wir dafür an den Versanddienstleister weiter [Versanddienstleister eintragen, z. B. Deutsche Post/DHL]. Rechtsgrundlage ist Art. 6 Abs. 1 lit. b DSGVO. Wir löschen den Chat, wenn deine Anfrage erledigt ist [Frist festlegen], soweit keine gesetzlichen Aufbewahrungspflichten bestehen, etwa für Rechnungen.

## 7. Cookies
Für Besucherinnen und Besucher setzt die Website keine Cookies. Nur im passwortgeschützten Verwaltungsbereich wird ein technisch notwendiges Sitzungs-Cookie für die Anmeldung gesetzt. Es läuft nach spätestens 8 Stunden ab (§ 25 Abs. 2 Nr. 2 TDDDG, Art. 6 Abs. 1 lit. f DSGVO). Zum Schutz vor Passwort-Ausprobieren speichern wir bei Anmeldeversuchen einen nicht rückrechenbaren Hashwert der IP-Adresse für höchstens 24 Stunden.

## 8. Deine Rechte
Du hast nach der DSGVO das Recht auf Auskunft (Art. 15), Berichtigung (Art. 16), Löschung (Art. 17), Einschränkung der Verarbeitung (Art. 18) und Datenübertragbarkeit (Art. 20). Du kannst einer Verarbeitung, die auf Art. 6 Abs. 1 lit. f DSGVO beruht, widersprechen (Art. 21). Eine erteilte Einwilligung kannst du jederzeit für die Zukunft widerrufen. Schreib uns dafür einfach an die oben genannte Adresse.

## 9. Beschwerde bei der Aufsichtsbehörde
Du kannst dich bei einer Datenschutzaufsichtsbehörde beschweren. Für uns zuständig ist das Unabhängige Landeszentrum für Datenschutz Schleswig-Holstein, Holstenstraße 98, 24103 Kiel, Telefon 0431 988-1200, E-Mail mail@datenschutzzentrum.de [Kontaktdaten vor Veröffentlichung prüfen].

Stand: [Datum eintragen]
"""
