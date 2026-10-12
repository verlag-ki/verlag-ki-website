#!/usr/bin/env bash
# Einmalig ausführen: richtet die automatische Aktualisierung ein.
# Aufruf als root aus dem Projektordner: sudo ./deploy/enable-autoupdate.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Bitte mit sudo ausführen."; exit 1; }
NAME=bienes-muetzenparadies
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(git -c safe.directory='*' -C "$APPDIR" rev-parse --show-toplevel)"
BRANCH="$(git -c safe.directory='*' -C "$REPO" rev-parse --abbrev-ref HEAD)"
cat > /etc/systemd/system/$NAME-autoupdate.service <<UNIT
[Unit]
Description=Bines Mützenparadies: neue Version holen und einspielen
After=network-online.target

[Service]
Type=oneshot
Environment=REPO=$REPO BRANCH=$BRANCH
ExecStart=/bin/bash $APPDIR/deploy/auto-update.sh
UNIT
cat > /etc/systemd/system/$NAME-autoupdate.timer <<UNIT
[Unit]
Description=Bines Mützenparadies: alle 5 Minuten auf neue Version prüfen

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
UNIT
systemctl daemon-reload
systemctl enable --now $NAME-autoupdate.timer
echo "Automatische Aktualisierung aktiv (Branch $BRANCH). Erster Lauf jetzt:"
systemctl start $NAME-autoupdate.service || true
journalctl -u $NAME-autoupdate.service -n 15 --no-pager
echo
echo "Verlauf ansehen:  journalctl -u $NAME-autoupdate -n 30"
echo "Abschalten:       systemctl disable --now $NAME-autoupdate.timer"
