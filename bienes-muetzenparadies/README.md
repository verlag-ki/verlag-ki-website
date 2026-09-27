# Bienes Mützenparadies

Eine eigenständige, mobil nutzbare Website für individuelle Häkelmützen auf Anfrage. Die Anwendung ist **nicht veröffentlicht**. Produktfotos, Musterfreigaben und rechtliche Inhalte müssen vor dem Livegang ergänzt beziehungsweise geprüft werden.

## Was enthalten ist

- **Startseite im Stil der Vorlage (Variante 1 „Natürlich & modern“):** Header mit Logo, handgeschriebene Überschriften mit kleinem Herz, Hero mit großem Bild rechts, das weich in den Cremeton ausblendet, vier Merkmale mit farbigen Symbolen, quadratische Musterkarten, Infokarten mit farbigen Symbolen, Abschnitt „Mit Liebe gehäkelt.“ und Kontaktbereich. Solange keine echten Fotos vorliegen, zeigt die Seite **als Demo gekennzeichnete Illustrationen**.
- **Designsystem:** Farben als CSS-Variablen in `public/style.css`. Schriften lokal unter `public/fonts/`: Chewy für Überschriften (Apache 2.0) und Figtree für Text (SIL OFL), Lizenztexte liegen bei. Keine externen Schrift- oder Skriptquellen.
- **Logo:** `brand/bee-mark.svg` (Biene mit Häkelmütze), `logo-full.svg`, `logo-compact.svg`, `logo-monochrome.svg`, Favicon `public/favicon.svg`. Die Schrift ist in Pfade umgewandelt, damit die Logos auch im Druck stimmen. Neu erzeugen mit `python3 tools/make_logos.py` (benötigt `fonttools` und `brotli`).
- **Musterseite und „So funktioniert’s“** im selben Stil: Größen als Auswahlkacheln mit hinterlegten Zentimeterbereichen, Farbfelder, Bildergalerie mit Vorschaubildern, nummerierte Schritte mit Symbolen.
- Startseite mit ruhigem Header, Hero, beliebten Mustern, drei Informationskarten, Handarbeitsabschnitt und Kontaktbereich.
- Musterübersicht mit Kategorien und Filter, freigegebene Detailseiten mit Größen, Farben, Kopfumfang und Wünschen.
- Zentrales Kontaktfenster mit WhatsApp-Direktlink zu `+49 157 34487082` und vorausgefüllter, bearbeitbarer Nachricht. Das Formular öffnet innerhalb desselben Fensters und übernimmt die Auswahl.
- Serverseitig geprüftes Anfrageformular, Speicherung in SQLite, SMTP-Benachrichtigung, einfache Begrenzung gegen massenhafte Anfragen.
- Passwortgeschützte Verwaltung für Muster, Fotos, Größen, Farben und Anfragestatus. Neue Muster erfordern kein Deployment.
- Individuelle Titel und Beschreibungen, sprechende URLs, Sitemap, Robots-Datei, kanonische URLs und ein einfaches Unternehmens-Schema.
- Impressum und Datenschutzentwurf mit sichtbar gekennzeichneten offenen Angaben.

Die fünf mitgelieferten Motive stehen zunächst auf **Entwurf**. Ohne echtes Produktfoto kann ein Muster technisch nicht veröffentlicht werden. Im lokalen Katalog erscheinen diese Beispiele deutlich als nicht anfragbare Demo. Veröffentlichte Muster erscheinen stattdessen mit eigener Detailseite.

## Technik

**Python 3.12** (die Vorlagen nutzen f-String-Syntax ab 3.12; das Modul `cgi` fehlt ab 3.13), Pillow zur sicheren Umwandlung hochgeladener Bilder, Gunicorn als WSGI-Server, SQLite und lokale WebP-Dateien. HTML, CSS und JavaScript werden ohne externe Schrift-, Analyse- oder Chatdienste ausgeliefert. Ein einzelner Hetzner-Server genügt bei geringem Anfragevolumen. SQLite-Datei und Uploads liegen im Verzeichnis `DATA_DIR` und dürfen nicht im öffentlich zugänglichen Webroot liegen.

## Lokal starten

```bash
cd bienes-muetzenparadies
python3.12 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python3 - <<'PY'
import hashlib,secrets,getpass
p=getpass.getpass('Verwaltungspasswort: ').encode()
salt=secrets.token_bytes(16)
print('ADMIN_PASSWORD_HASH=pbkdf2$'+salt.hex()+'$'+hashlib.pbkdf2_hmac('sha256',p,salt,310000).hex())
print('SECRET_KEY='+secrets.token_hex(32))
PY
```

Die ausgegebenen Werte in `.env` eintragen. Eine `.env`-Datei wird **nicht automatisch eingelesen**: Für lokale Versuche die Werte im Shell-Prozess exportieren oder `set -a; . ./.env; set +a` verwenden. Die Datei niemals ins Versionsarchiv aufnehmen. Danach:

```bash
python3 app.py
python3 check.py
```

Website: `http://127.0.0.1:8000`. Verwaltung: `/admin`. `check.py` verwendet einen eigenen temporären Datenordner und verändert keine echten Muster.

## Muster und Bilder pflegen

1. In `/admin` anmelden und zunächst die tatsächlich angebotenen Größen mit bestätigten Zentimeterbereichen sowie die real verfügbaren Wollfarben eintragen.
2. Unter „Muster“ ein Motiv anlegen oder einen Demo-Entwurf bearbeiten. Namen, URL-Kürzel, Beschreibung, Kategorie, Größen, Farben und gegebenenfalls einen ausdrücklich freigegebenen Preis eintragen.
3. Echte, eigene Produktfotos als JPEG, PNG oder WebP hochladen. Der Server entfernt Bildmetadaten, verkleinert auf höchstens 1800 × 1800 Pixel und speichert WebP. Für jedes Foto eine sachliche Bildbeschreibung und die gewünschte Reihenfolge eintragen. Eine Freigabe der Bildrechte und des Motivs ist organisatorisch erforderlich.
4. Erst nach Bienes inhaltlicher Freigabe den Status auf `published` setzen. Ohne Bild bleibt das Muster automatisch `draft`. `archived` nimmt es aus dem öffentlichen Katalog und der Sitemap.
5. Einzelne Fotos können in derselben Bearbeitungsansicht entfernt, ersetzt oder sortiert werden.

Die Verwaltung speichert Kontaktanfragen in der Rubrik „Anfragen“. Dort lassen sich die Status „Neue Anfrage“, „In Prüfung“, „Angebot versendet“, „Angenommen“, „Abgeschlossen“ und „Abgelehnt“ setzen. Das Löschfeld entfernt eine Anfrage endgültig. WhatsApp-Nachrichten erscheinen dort nicht automatisch.

## Bilder der Startseite austauschen

In `/admin` unter „Startseite“ lassen sich das große Hero-Foto und das Foto im Abschnitt „Mit Liebe gehäkelt.“ hochladen, ersetzen oder entfernen. Pflicht ist eine sachliche Bildbeschreibung (Alt-Text). Ohne Foto erscheint die jeweilige Demo-Illustration mit sichtbarem Hinweis. Biene bitte nicht mit Gesicht zeigen – Hände, Wolle, Häkelnadel oder Etikett passen gut.

Die Demo-Illustrationen unter `public/img/` werden mit `python3 tools/make_illustrations.py` erzeugt. Sie gehören ausschließlich zu den mitgelieferten Demo-Mustern und dürfen nicht als echte Produktfotos verwendet werden.

## Konfiguration

| Variable | Zweck |
| --- | --- |
| `SITE_ORIGIN` | Öffentliche HTTPS-Adresse ohne abschließenden Schrägstrich; für Canonicals, Sitemap, Cookie und Herkunftsprüfung. |
| `ADMIN_PASSWORD_HASH` | PBKDF2-Hash des Passworts, wie oben erzeugt. |
| `SECRET_KEY` | Zufälliger 32-Byte-Wert; ohne ihn ist die Anmeldung gesperrt. |
| `DATA_DIR` | Schreibbares, gesichertes Verzeichnis für SQLite und Fotos. |
| `SMTP_HOST`, `SMTP_PORT` | SMTP-Server und Port 587 (STARTTLS) oder 465 (SSL). |
| `SMTP_USER`, `SMTP_PASSWORD` | Zugangsdaten, falls der SMTP-Server Anmeldung verlangt. |
| `SMTP_FROM` | Verifizierte Absenderadresse. |
| `CONTACT_TO` | Empfängeradresse für Anfragen. |
| `MAX_UPLOAD_MB` | Maximale Dateigröße je Bild, standardmäßig 8 MB. |

Ohne SMTP-Konfiguration wird eine Anfrage gespeichert, aber keine E-Mail gesendet. Der Besucher sieht dann ausdrücklich diesen Zustand samt alternativen Kontaktmöglichkeiten. Nach dem Einrichten einen echten Testversand durchführen und SPF, DKIM sowie DMARC der Absenderdomain prüfen. Die E-Mail-Zustellung hängt vom tatsächlich verwendeten Anbieter und dessen Konfiguration ab.

## Veröffentlichung auf Hetzner vorbereiten

1. Debian oder Ubuntu mit Sicherheitsupdates, einer eigenen nicht privilegierten Systemkennung und einem ausreichend geschützten Datenverzeichnis einrichten.
2. Projekt nach `/opt/bienes-muetzenparadies` kopieren, virtuelle Python-Umgebung erstellen, Pakete installieren und die Variablen über eine nur für den Dienst lesbare Environment-Datei setzen. `DATA_DIR` außerhalb des Codeverzeichnisses wählen.
3. Gunicorn ausschließlich lokal binden, beispielsweise `gunicorn --workers 2 --bind 127.0.0.1:8080 app:app`. Ein systemd-Dienst startet diesen Prozess mit dem Projekt als Arbeitsverzeichnis.
4. Nginx als Reverse Proxy mit HTTPS und gültigem Zertifikat auf `127.0.0.1:8080` weiterleiten. `client_max_body_size 12m` setzen. `SITE_ORIGIN` auf die endgültige HTTPS-Adresse setzen und HTTP auf HTTPS umleiten.
5. Dateien unter `DATA_DIR` regelmäßig verschlüsselt sichern: SQLite konsistent mit `sqlite3.Connection.backup()` sichern und den Upload-Ordner in dieselbe Sicherung aufnehmen. Eine Wiederherstellung probeweise durchführen.
6. In Nginx Serverlogs nur so lange wie tatsächlich erforderlich vorhalten und diese Frist in der Datenschutzerklärung exakt benennen. Admin-Pfad durch Rate-Limit und gegebenenfalls zusätzliche Zugangsbeschränkung absichern.
7. Erst nach der unten stehenden Freigabeliste DNS umstellen und öffentlich freischalten. **Dieses Projekt führt keinen automatischen Livegang aus.**

Ein konkreter Server, eine Domain, ein SMTP-Konto und Zugangsdaten liegen derzeit nicht vor. Deshalb enthält das Projekt keine ausführbare produktive systemd- oder Nginx-Datei mit geratenen Pfaden oder Hostnamen.

## Prüfstand und offene Punkte

Der Integrationstest `python3 check.py` deckt öffentliche Routen, versteckte Demo-Muster, Formularvalidierung und Speicherung, Anmeldung, Pflege von Größen und Farben, Bildpflicht bei Veröffentlichung, Musterseite und Sitemap ab. Zusätzlich vor Livegang im Browser auf Desktop, Tablet und kleinem iPhone prüfen: Fokusführung und Escape im Kontaktfenster, mobiles Menü, Farb- und Größenauswahl, WhatsApp-Text, Wechsel der Kontaktmethode und E-Mail-Fehlerfall. Die technische E-Mail-Zustellung und reale Bilddarstellung können erst mit den tatsächlichen Diensten und Fotos vollständig getestet werden.

Vor dem Livegang offen:

- Echte Produktfotos, ausdrücklich freigegebene Muster, Bildrechte und Motivrechte.
- Gemessene Größenbereiche und reale Wollfarben, gegebenenfalls Stoffzusammensetzung und Textilkennzeichnung.
- Tatsächliche aktuelle Angaben des Betreibers mit dem ursprünglichen Impressum abgleichen; dieses war bei der Erstellung nicht erreichbar. Vorhandensein und Angabepflicht von USt-IdNr. oder W-IdNr. prüfen.
- Datenschutzerklärung auf Hostingstandort, tatsächliche Logs und Fristen, Auftragsverarbeitung, SMTP-Anbieter, Datentransfers und festgelegte Löschfrist abstimmen; rechtlich prüfen lassen.
- Rechtsprüfung zu Produktsicherheit, insbesondere Kindermützen und ablösbaren Teilen, sowie Versand, Verpackung, Fernabsatzinformationen und Widerruf für den tatsächlichen späteren Bestellabschluss.
- Eigene Domain, HTTPS, E-Mail-Konto, Backup, Monitoring, konkrete Löschroutine und tatsächlichen Testversand einrichten.
- Bei wachsendem Volumen oder mehreren Administratoren Authentifizierung, Datenbank und Betriebskonzept neu bewerten. Die aktuelle Verwaltung hat genau einen Passwortzugang.

## Abgleich mit dem Auftrag

Die Seiten, das zentrale Kontaktfenster und seine beiden Wege, die Verwaltung, Produktfilter, SEO-Grundlagen und responsive Gestaltung sind umgesetzt. Die fotografischen Bereiche zeigen bewusst gekennzeichnete neutrale Platzhalter, weil echte Aufnahmen fehlen. Rechtliche Texte sind Entwürfe. SMTP ist funktionsfähig, sobald echte Zugangsdaten hinterlegt sind; der Liveversand ist noch nicht nachgewiesen. Die Seite wurde weder veröffentlicht noch mit einer Hetzner-Instanz verbunden.
