"""Übernimmt die Muster und Fotos aus seed/katalog.json in die Datenbank.

- Fehlende Muster werden angelegt.
- Ein Muster bekommt das Foto nur, wenn es noch keins hat.
- Name, Beschreibung, Kategorie und Status werden nur bei unbearbeiteten
  Entwürfen ohne Foto übernommen (z. B. dem mitgelieferten Frosch-Beispiel).
- Bilder der Startseite werden nur gesetzt, wenn dort noch keins hinterlegt ist.
Mehrfaches Ausführen ist unbedenklich. Aufruf: DATA_DIR=… python3 tools/import_catalog.py
"""
import json
import secrets
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))
import app  # noqa: E402

SEED = ROOT / 'seed'


def copy_photo(name):
    filename = secrets.token_hex(16) + '.webp'
    shutil.copyfile(SEED / 'fotos' / name, app.DATA / 'uploads' / filename)
    return filename


def main():
    catalog = json.loads((SEED / 'katalog.json').read_text())
    app.init()
    created = photos = updated = 0
    with app.db() as c:
        for m in catalog['muster']:
            row = c.execute('SELECT * FROM patterns WHERE slug=?', (m['slug'],)).fetchone()
            has_photo = row and c.execute('SELECT 1 FROM images WHERE pattern_id=?', (row['id'],)).fetchone()
            values = (m['name'], m['beschreibung'], m['kategorie'], m['status'], 1 if m['startseite'] else 0)
            if not row:
                pid = c.execute("INSERT INTO patterns(slug,name,description,category,status,featured,created_at) VALUES(?,?,?,?,?,?,?)",
                                (m['slug'], *values, app.now())).lastrowid
                created += 1
            else:
                pid = row['id']
                if row['status'] == 'draft' and not has_photo:
                    c.execute('UPDATE patterns SET name=?,description=?,category=?,status=?,featured=? WHERE id=?', (*values, pid))
                    updated += 1
            if not has_photo:
                c.execute('INSERT INTO images(pattern_id,filename,alt,position) VALUES(?,?,?,0)', (pid, copy_photo(m['foto']), m['alt']))
                photos += 1
            if m.get('pruefen'):
                print(f"Hinweis {m['name']}: {m['pruefen']}")
        for key, img in catalog['startseite'].items():
            if not c.execute('SELECT 1 FROM site_images WHERE key=?', (key,)).fetchone():
                c.execute('INSERT INTO site_images VALUES(?,?,?)', (key, copy_photo(img['foto']), img['alt']))
                photos += 1
    print(f'Katalog übernommen: {created} Muster neu, {updated} Entwürfe ergänzt, {photos} Fotos hinzugefügt.')


if __name__ == '__main__':
    main()
