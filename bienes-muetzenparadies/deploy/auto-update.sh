#!/usr/bin/env bash
# Holt neue Versionen von GitHub und spielt sie ein – aber nur, wenn die automatischen Prüfungen bestehen.
# Wird vom systemd-Timer bienes-muetzenparadies-autoupdate alle 5 Minuten aufgerufen.
set -euo pipefail
REPO="${REPO:?}"; BRANCH="${BRANCH:?}"
NAME=bienes-muetzenparadies
PY="${PY:-/opt/$NAME/.venv/bin/python}"
git() { command git -c safe.directory="$REPO" -C "$REPO" "$@"; }

git fetch -q origin "$BRANCH"
LOCAL=$(git rev-parse HEAD); REMOTE=$(git rev-parse "origin/$BRANCH")
[ "$LOCAL" = "$REMOTE" ] && exit 0
echo "Neue Version gefunden: ${REMOTE:0:7} (bisher ${LOCAL:0:7})"
git merge -q --ff-only "origin/$BRANCH"
APPDIR="$REPO/bienes-muetzenparadies"
if ! (cd "$APPDIR" && "$PY" -W ignore check.py); then
  echo "Prüfungen fehlgeschlagen – die Website läuft unverändert mit der bisherigen Version weiter."
  git reset -q --hard "$LOCAL"
  exit 1
fi
"${UPDATE:-$APPDIR/deploy/update.sh}"
echo "Version ${REMOTE:0:7} ist online."
