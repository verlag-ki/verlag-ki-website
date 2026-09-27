#!/usr/bin/env bash
# Spielt eine neue Programmversion ein. Aufruf als root aus dem aktualisierten Projektordner: sudo ./deploy/update.sh
set -euo pipefail
NAME=bienes-muetzenparadies
APP_DIR=/opt/$NAME
SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"
[ "$(id -u)" -eq 0 ] || { echo "Bitte mit sudo ausführen."; exit 1; }
/usr/local/sbin/$NAME-backup
rsync -a --delete --exclude '.venv' --exclude 'data' --exclude '__pycache__' --exclude '.env' --exclude '.git' "$SRC_DIR/" "$APP_DIR/"
chown -R root:root $APP_DIR
$APP_DIR/.venv/bin/pip install -q -r $APP_DIR/requirements.txt
systemctl restart $NAME
sleep 1
systemctl is-active --quiet $NAME && echo "Aktualisiert und neu gestartet."
