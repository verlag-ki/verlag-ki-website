# Bienes Mützenparadies

Website für individuelle Häkelmützen auf Anfrage. Besucher suchen sich ein Muster aus, wählen Größe und Farbe und schicken ihre Anfrage **per WhatsApp** an Biene. Es gibt kein Kontaktformular, keinen E-Mail-Versand, keinen Warenkorb und keine Onlinezahlung.

## Was enthalten ist

- **Startseite im Stil der Designvorlage (Variante 1):** Header mit Logo, handgeschriebene Überschriften mit kleinem Herz, fliegende Biene mit Flugbahn, großes Bild rechts mit weicher Ausblendung, vier Merkmale mit Symbolen, beliebte Muster, drei Infokarten, Abschnitt „Mit Liebe gehäkelt.“ und Kontaktbereich.
- **Muster & Ideen** mit Kategoriefilter, **Musterseiten** mit Galerie, Größenkacheln, Farbfeldern, Kopfumfang und Wünschen, **So funktioniert’s**, **Größenhilfe** mit Größenempfehlung, **Wunschfarben**, **Impressum** und **Datenschutz**.
- **Kontaktfenster:** „Kontakt“, „Jetzt anfragen“ und alle Anfrage-Buttons öffnen dasselbe Fenster. Es zeigt die vorbereitete WhatsApp-Nachricht an `+49 157 34487082`, auf Musterseiten mit Muster, Größe, Kopfumfang, Farbe und Wünschen. WhatsApp öffnet sich erst nach dem Tippen, gesendet wird nichts automatisch.
- **Verwaltung** unter `/admin` (ein Passwort): Muster anlegen und bearbeiten, Fotos hochladen und sortieren, Größen und Wollfarben pflegen, Bilder der Startseite austauschen. Neue Muster brauchen kein neues Deployment.
- **SEO:** eigene Titel und Beschreibungen, sprechende URLs, Sitemap, `robots.txt`, kanonische URLs, strukturierte Daten für Organisation und Website.
- **Designsystem:** Farben als CSS-Variablen in `public/style.css`. Schriften lokal unter `public/fonts/`: Chewy (Überschriften, Apache 2.0) und Figtree (Text, SIL OFL). Keine externen Schriften, Skripte, Analyse- oder Chatdienste.
- **Logo:** `brand/bee-mark.svg` (fliegende Biene mit Häkelmütze), `logo-full.svg`, `logo-compact.svg`, `logo-monochrome.svg`, `public/favicon.svg`, `public/img/bee-flight.svg`. Die Schrift ist in Pfade umgewandelt, damit die Logos auch im Druck stimmen. Neu erzeugen mit `python3 tools/make_logos.py` (benötigt `fonttools` und `brotli`).

## Illustrationen, KI-Demobilder und echte Fotos

Solange ein Muster kein Foto hat, zeigt die Website eine gezeichnete Illustration mit dem Hinweis „Illustration · Foto folgt“. Die sechs mitgelieferten Motive (Frosch, Schneemann, Schweinchen, Quatschmonster, Bär, Einhorn) können damit schon veröffentlicht werden. Neue Motive ohne Illustration brauchen ein Foto, bevor sie online gehen.

Sobald echte Fotos in der Verwaltung hochgeladen sind, ersetzen sie die Illustrationen automatisch.

- Illustrationen: `public/img/demo-*.svg`, erzeugt mit `python3 tools/make_illustrations.py`.
- KI-Demobilder: `public/img/ki-*.webp` sind Ausschnitte der KI-generierten Designvorlage (`tools/make_demo_photos.py`). Sie sind nur für Vorschauen gedacht und erscheinen ausschließlich mit `DEMO_IMAGES=ki`, dann mit dem Hinweis „Demo-Bild · KI-generiert“. Auf der echten Website bleibt `DEMO_IMAGES=illustration` (Standard).

## Technik

Python 3.12, Pillow für hochgeladene Bilder, Gunicorn, SQLite, Nginx. Datenbank und Fotos liegen in `DATA_DIR`, getrennt vom Programmcode. Ein kleiner Hetzner-Server reicht.

| Variable | Zweck |
| --- | --- |
| `SITE_ORIGIN` | Öffentliche Adresse mit `https://`, ohne Schrägstrich am Ende. |
| `ADMIN_PASSWORD_HASH` | Hash des Verwaltungspassworts (legt `deploy/setup.sh` an). |
| `SECRET_KEY` | Zufallswert; ohne ihn ist die Anmeldung gesperrt. |
| `DATA_DIR` | Verzeichnis für Datenbank und Fotos. |
| `TRUST_PROXY` | `1` hinter Nginx: Die Anmeldesperre zählt dann die echte Besucheradresse aus `X-Real-IP`. |
| `DEMO_IMAGES` | `illustration` (Standard) oder `ki` nur für Vorschauen. |
| `MAX_UPLOAD_MB` | Maximale Größe je Foto, Standard 8. |

## Lokal ausprobieren

```bash
cd bienes-muetzenparadies
python3.12 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
python3 app.py          # http://127.0.0.1:8000
python3 check.py        # automatische Prüfung, nutzt einen eigenen Testordner
```

Für die Verwaltung lokal `SECRET_KEY` und `ADMIN_PASSWORD_HASH` setzen (siehe `.env.example`).

## Veröffentlichen auf dem Hetzner-Server

Voraussetzung: Ubuntu oder Debian mit Zugang als root bzw. per `sudo`. Andere Websites auf dem Server bleiben unberührt; die App läuft auf `127.0.0.1:8081` hinter Nginx. Ist der Port belegt, vor dem Aufruf `PORT=8090` voranstellen.

1. **DNS:** Beim Domain-Anbieter A-Einträge (und bei Bedarf AAAA-Einträge) für `bines-muetzenparadies.de` und `www.bines-muetzenparadies.de` auf die IP des Servers setzen.
2. **Code auf den Server holen:**
   ```bash
   git clone --depth 1 -b claude/bienes-muetzenparadies-homepage-41alul https://github.com/verlag-ki/verlag-ki-website.git
   cd verlag-ki-website/bienes-muetzenparadies
   ```
   Ist das Repository privat, klappt das nur mit Zugangsdaten. Alternativ den Ordner als ZIP herunterladen und mit `scp` hochladen.
3. **Einrichten:**
   ```bash
   sudo ./deploy/setup.sh bines-muetzenparadies.de info@mieten-macht-sinn.de
   ```
   Das Skript installiert Nginx, Certbot und Python 3.12, legt den Systembenutzer `biene` an, fragt das Verwaltungspasswort ab, richtet Dienst, Nginx, Log-Löschung nach 14 Tagen und die tägliche Sicherung ein und holt das HTTPS-Zertifikat, sobald die Domain auf den Server zeigt. Es kann gefahrlos erneut ausgeführt werden.
4. **In der Verwaltung** (`https://bines-muetzenparadies.de/admin`) Größen mit echten Zentimetern und Wollfarben eintragen und die von Biene freigegebenen Muster auf `published` stellen.
5. **Datenschutzerklärung und Impressum** vervollständigen (Stellen in eckigen Klammern bzw. gelb markiert), dann auf Handy und Computer durchklicken.

**Updates** einspielen: neuen Stand holen (`git pull`), dann `sudo ./deploy/update.sh`. Das Skript sichert vorher die Daten.

**Sicherungen** liegen täglich unter `/var/backups/bienes-muetzenparadies` (14 Tage). Da sie auf demselben Server liegen, zusätzlich die Backup-Funktion von Hetzner einschalten oder die Dateien regelmäßig woanders ablegen.

**Nützliche Befehle:** `systemctl status bienes-muetzenparadies`, `journalctl -u bienes-muetzenparadies -n 50`, Server-Protokolle unter `/var/log/bienes-muetzenparadies/`.

## Muster pflegen

1. Unter „Größen“ die angebotenen Größen mit den von Biene gemessenen Zentimeterbereichen anlegen, unter „Farben“ die vorrätigen Wollfarben.
2. Unter „Muster“ ein Motiv anlegen oder eines der mitgelieferten bearbeiten: Name, URL-Kürzel, Beschreibung, Kategorie, Größen, Farben, optional ein freigegebener Preis.
3. Fotos hochladen (JPEG, PNG, WebP). Der Server entfernt Metadaten, verkleinert und speichert WebP. Zu jedem Foto eine kurze, sachliche Bildbeschreibung eintragen.
4. Status `published` erst nach Bienes Freigabe. `archived` nimmt ein Muster aus Katalog und Sitemap.
5. Unter „Startseite“ lassen sich das große Bild oben und das Bild bei „Mit Liebe gehäkelt.“ austauschen. Biene bitte nicht mit Gesicht zeigen; Hände, Wolle oder Häkelnadel passen gut.

## Vor dem Livegang offen

- Impressum mit den aktuellen Betreiberangaben abgleichen; USt-IdNr. oder W-IdNr. prüfen.
- Datenschutzerklärung: Rechenzentrum, Auftragsverarbeitungsvertrag mit Hetzner, Löschfrist für WhatsApp-Chats und Datum eintragen; rechtlich prüfen lassen.
- Größen in Zentimetern und echte Wollfarben eintragen, Muster freigeben.
- Rechtliche Prüfung zu Produktsicherheit bei Kindermützen, Textilkennzeichnung, Versand, Widerruf und Verbraucherinformationen für den tatsächlichen Bestellablauf.
- Echte Fotos, sobald vorhanden.
