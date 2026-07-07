#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_CMD=python3
if ! command -v "$PYTHON_CMD" >/dev/null 2>&1; then
  PYTHON_CMD=python
fi
if ! command -v "$PYTHON_CMD" >/dev/null 2>&1; then
  echo "Fehler: Python 3 wurde nicht gefunden. Bitte installiere Python 3."
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Dieses Skript muss mit root-Rechten ausgeführt werden. Nutze z.B. 'sudo ./install_service.sh'"
  exit 1
fi

VENV_DIR="$SCRIPT_DIR/.venv"
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt"
ENV_FILE="/etc/bem-tools-backend.env"
SERVICE_FILE="/etc/systemd/system/bem-tools-backend.service"
SERVICE_NAME="bem-tools-backend.service"

if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
  echo "Fehler: requirements.txt wurde im Backend-Verzeichnis nicht gefunden."
  exit 1
fi

SERVICE_USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
SERVICE_GROUP="${SERVICE_USER}"
if ! getent group "$SERVICE_GROUP" >/dev/null 2>&1; then
  SERVICE_GROUP=""
fi

printf "Backend Pfad: %s\n" "$SCRIPT_DIR"
printf "Virtuelle Umgebung: %s\n" "$VENV_DIR"

# Virtuelle Umgebung einrichten
"$PYTHON_CMD" -m venv "$VENV_DIR"
"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r "$REQUIREMENTS_FILE"

# Environment-Datei erstellen
cat > "$ENV_FILE" <<'EOF'
# BEM-Tools Backend Umgebungsvariablen
# Bitte diese Werte vor dem ersten Dienststart anpassen.
LOKATION_SECRET_KEY=change-me-super-secret
LOKATION_ADMIN_USER=admin
LOKATION_ADMIN_PASSWORD=dein-starkes-passwort
EOF
chmod 600 "$ENV_FILE"

# systemd Service-Datei anlegen
{
  cat <<EOF
[Unit]
Description=BEM-Tools Lokation Suche Backend
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
EOF
  if [[ -n "$SERVICE_GROUP" ]]; then
    printf 'Group=%s\n' "$SERVICE_GROUP"
  fi
  cat <<EOF
WorkingDirectory=$SCRIPT_DIR
EnvironmentFile=$ENV_FILE
ExecStart=$VENV_DIR/bin/uvicorn main:app --host 127.0.0.1 --port 8010
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=bem-tools-backend

[Install]
WantedBy=multi-user.target
EOF
} > "$SERVICE_FILE"

chmod 644 "$SERVICE_FILE"

# Dienst aktivieren
systemctl daemon-reload
systemctl enable --now "$SERVICE_NAME"

printf "\nService '%s' wurde installiert und gestartet.\n" "$SERVICE_NAME"
printf "Die Umgebungsdatei lautet: %s\n" "$ENV_FILE"
printf "Passe die Variablen in %s an, bevor du den Dienst erneut startest.\n" "$ENV_FILE"
printf "Status prüfen mit: sudo systemctl status %s\n" "$SERVICE_NAME"
printf "Logs ansehen mit: sudo journalctl -u %s -f\n" "$SERVICE_NAME"
