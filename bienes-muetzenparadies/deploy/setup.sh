#!/usr/bin/env bash
# Richtet Bienes Mützenparadies auf einem Ubuntu- oder Debian-Server ein.
# Aufruf als root aus dem Projektordner:   sudo ./deploy/setup.sh DOMAIN [E-MAIL-FÜR-LETSENCRYPT]
# Beispiel:                                 sudo ./deploy/setup.sh bines-muetzenparadies.de info@mieten-macht-sinn.de
# Das Skript lässt andere Websites auf dem Server unangetastet und kann gefahrlos erneut ausgeführt werden.
set -euo pipefail

DOMAIN="${1:?Bitte die Domain angeben, z. B. ./deploy/setup.sh bines-muetzenparadies.de}"
CERT_EMAIL="${2:-}"
PORT="${PORT:-8081}"
NAME=bienes-muetzenparadies
SERVICE_USER=biene
APP_DIR=/opt/$NAME
DATA_DIR=/var/lib/$NAME
LOG_DIR=/var/log/$NAME
ENV_FILE=/etc/$NAME.env
SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"

say() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
[ "$(id -u)" -eq 0 ] || { echo "Bitte mit sudo ausführen."; exit 1; }
command -v apt-get >/dev/null || { echo "Dieses Skript unterstützt Ubuntu und Debian."; exit 1; }

say "Pakete installieren"
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -yq nginx certbot python3-certbot-nginx sqlite3 rsync curl python3-venv

say "Python 3.12 bereitstellen"
if command -v python3.12 >/dev/null; then
  PY=$(command -v python3.12)
  DEBIAN_FRONTEND=noninteractive apt-get install -yq python3.12-venv || true
else
  # Ältere oder neuere Systeme: Python 3.12 über uv installieren
  if ! command -v uv >/dev/null; then curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh; fi
  UV_PYTHON_INSTALL_DIR=/opt/python uv python install 3.12
  PY=$(UV_PYTHON_INSTALL_DIR=/opt/python uv python find 3.12)
fi
echo "Python: $PY"

say "Port $PORT prüfen"
if ss -ltn "( sport = :$PORT )" | grep -q LISTEN && ! systemctl is-active --quiet $NAME; then
  echo "Port $PORT ist schon belegt. Bitte einen freien Port wählen: PORT=8090 sudo ./deploy/setup.sh $DOMAIN"; exit 1
fi

say "Systembenutzer und Verzeichnisse"
id $SERVICE_USER >/dev/null 2>&1 || useradd --system --home-dir $DATA_DIR --shell /usr/sbin/nologin $SERVICE_USER
install -d -o $SERVICE_USER -g $SERVICE_USER -m 750 $DATA_DIR $DATA_DIR/uploads
install -d -o www-data -g adm -m 750 $LOG_DIR

say "Programmdateien nach $APP_DIR kopieren"
install -d -m 755 $APP_DIR
rsync -a --delete --exclude '.venv' --exclude 'data' --exclude '__pycache__' --exclude '.env' --exclude '.git' "$SRC_DIR/" "$APP_DIR/"
chown -R root:root $APP_DIR
[ -x $APP_DIR/.venv/bin/python ] || "$PY" -m venv $APP_DIR/.venv
$APP_DIR/.venv/bin/pip install -q --upgrade pip
$APP_DIR/.venv/bin/pip install -q -r $APP_DIR/requirements.txt

if [ ! -f $ENV_FILE ]; then
  say "Zugang zur Verwaltung festlegen"
  while true; do
    read -rsp "Neues Passwort für die Verwaltung (mind. 12 Zeichen): " PW1; echo
    read -rsp "Passwort wiederholen: " PW2; echo
    [ "$PW1" = "$PW2" ] && [ ${#PW1} -ge 12 ] && break
    echo "Die Passwörter stimmen nicht überein oder sind zu kurz."
  done
  HASH=$(BM_PW="$PW1" $APP_DIR/.venv/bin/python -c 'import hashlib,os,secrets; s=secrets.token_bytes(16); print("pbkdf2$"+s.hex()+"$"+hashlib.pbkdf2_hmac("sha256",os.environ["BM_PW"].encode(),s,310000).hex())')
  unset PW1 PW2
  umask 027
  cat > $ENV_FILE <<EOF
SITE_ORIGIN=https://$DOMAIN
DATA_DIR=$DATA_DIR
ADMIN_PASSWORD_HASH=$HASH
SECRET_KEY=$(openssl rand -hex 32)
TRUST_PROXY=1
DEMO_IMAGES=illustration
MAX_UPLOAD_MB=8
EOF
  chown root:$SERVICE_USER $ENV_FILE; chmod 640 $ENV_FILE
else
  echo "$ENV_FILE existiert bereits und bleibt unverändert."
fi

say "Dienst einrichten"
sed -e "s|@PORT@|$PORT|g" -e "s|@APP_DIR@|$APP_DIR|g" -e "s|@DATA_DIR@|$DATA_DIR|g" -e "s|@ENV_FILE@|$ENV_FILE|g" -e "s|@USER@|$SERVICE_USER|g" \
  "$SRC_DIR/deploy/$NAME.service" > /etc/systemd/system/$NAME.service
install -m 750 "$SRC_DIR/deploy/backup.sh" /usr/local/sbin/$NAME-backup
cp "$SRC_DIR/deploy/$NAME-backup.service" "$SRC_DIR/deploy/$NAME-backup.timer" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now $NAME.service $NAME-backup.timer
systemctl restart $NAME.service

say "Nginx einrichten"
if [ -d /etc/nginx/sites-available ]; then
  NGINX_CONF=/etc/nginx/sites-available/$NAME
  ln -sf $NGINX_CONF /etc/nginx/sites-enabled/$NAME
else
  NGINX_CONF=/etc/nginx/conf.d/$NAME.conf
fi
# Eine bereits von certbot ergänzte Konfiguration nicht überschreiben
if [ ! -f $NGINX_CONF ] || ! grep -q "managed by Certbot" $NGINX_CONF; then
  sed -e "s|@DOMAIN@|$DOMAIN|g" -e "s|@PORT@|$PORT|g" -e "s|@LOG_DIR@|$LOG_DIR|g" "$SRC_DIR/deploy/nginx.conf" > $NGINX_CONF
fi
sed -e "s|@LOG_DIR@|$LOG_DIR|g" "$SRC_DIR/deploy/logrotate" > /etc/logrotate.d/$NAME
nginx -t
systemctl reload nginx

say "App-Test"
sleep 1
curl -fsS -o /dev/null "http://127.0.0.1:$PORT/" && echo "Die App antwortet auf Port $PORT."

say "HTTPS-Zertifikat"
SERVER_IP=$(curl -4fsS https://api.ipify.org || true)
DNS_IP=$(getent ahostsv4 "$DOMAIN" | awk 'NR==1{print $1}' || true)
if [ -n "$DNS_IP" ] && [ "$DNS_IP" = "$SERVER_IP" ]; then
  certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --redirect --non-interactive --agree-tos --keep-until-expiring \
    ${CERT_EMAIL:+-m "$CERT_EMAIL"} ${CERT_EMAIL:---register-unsafely-without-email}
  echo "Fertig: https://$DOMAIN"
else
  echo "Die Domain $DOMAIN zeigt noch nicht auf diesen Server (DNS: ${DNS_IP:-keine Antwort}, Server: ${SERVER_IP:-unbekannt})."
  echo "Setze bei deinem Domain-Anbieter A-Einträge für $DOMAIN und www.$DOMAIN auf ${SERVER_IP:-die Server-IP} und starte das Skript danach erneut."
fi
