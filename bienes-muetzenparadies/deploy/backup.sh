#!/usr/bin/env bash
# Tägliche Sicherung von Datenbank und hochgeladenen Fotos, 14 Tage aufbewahrt.
set -euo pipefail
DATA=/var/lib/bienes-muetzenparadies
DEST=/var/backups/bienes-muetzenparadies
STAMP=$(date +%F)
install -d -m 700 "$DEST"
sqlite3 "$DATA/site.sqlite3" ".backup '$DEST/site.sqlite3'"
tar -czf "$DEST/bienes-$STAMP.tar.gz" -C "$DEST" site.sqlite3 -C "$DATA" uploads
rm -f "$DEST/site.sqlite3"
chmod 600 "$DEST/bienes-$STAMP.tar.gz"
find "$DEST" -name 'bienes-*.tar.gz' -mtime +14 -delete
