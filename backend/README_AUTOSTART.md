# Autostart für das BEM-Tools Backend (Linux)

Dieses Dokument beschreibt, wie das Backend als `systemd`-Service auf einem Linux-Server gestartet und automatisch beim Systemstart aktiviert wird.

## Dateien

- `backend/install_service.sh` - Installationsskript für den systemd-Service
- `/etc/bem-tools-backend.env` - Umgebungsvariablen für den Dienst
- `/etc/systemd/system/bem-tools-backend.service` - systemd-Service-Unit

## Voraussetzungen

- Linux-Server mit `systemd`
- Python 3 installiert
- Zugriffsrechte zum Ausführen von `sudo`

## Installation

1. In das `backend`-Verzeichnis wechseln:

   ```bash
   cd /Users/csx/Documents/DEV/BEM-Tools/backend
   ```

2. Installationsskript mit Root-Rechten ausführen:

   ```bash
   sudo ./install_service.sh
   ```

   Das Skript erstellt eine Python-Virtualenv im Backend-Ordner, installiert alle Abhängigkeiten aus `requirements.txt` und erstellt den `systemd`-Service.

## Umgebungsvariablen konfigurieren

Die Datei `/etc/bem-tools-backend.env` wird automatisch erstellt. Öffne sie und passe die Werte an:

```ini
LOKATION_SECRET_KEY=change-me-super-secret
LOKATION_ADMIN_USER=admin
LOKATION_ADMIN_PASSWORD=dein-starkes-passwort
```

Wichtig:

- `LOKATION_SECRET_KEY` sollte ein zufälliger, langer Schlüssel sein.
- `LOKATION_ADMIN_USER` und `LOKATION_ADMIN_PASSWORD` sollten sichere Zugangsdaten sein.

## Service verwalten

- Dienststatus prüfen:

  ```bash
  sudo systemctl status bem-tools-backend.service
  ```

- Dienst stoppen:

  ```bash
  sudo systemctl stop bem-tools-backend.service
  ```

- Dienst starten:

  ```bash
  sudo systemctl start bem-tools-backend.service
  ```

- Dienst neu laden (nach Änderung der Service-Datei):

  ```bash
  sudo systemctl daemon-reload
  sudo systemctl restart bem-tools-backend.service
  ```

- Logs in Echtzeit verfolgen:

  ```bash
  sudo journalctl -u bem-tools-backend.service -f
  ```

## Hinweise

- Der Service bindet `uvicorn` an `127.0.0.1:8010`. Für den Zugriff aus dem Internet solltest du einen Reverse-Proxy wie Caddy vorsehen.
- Falls du den Dienst auf einem anderen Port betreiben willst, passe `install_service.sh` und die `ExecStart`-Zeile in der Service-Datei an.

## Alternative manuelle Installation

Falls du den Service nicht automatisch installieren möchtest, kannst du die folgenden Schritte einzeln ausführen:

1. Virtualenv erstellen:
   ```bash
   python3 -m venv backend/.venv
   ```

2. Abhängigkeiten installieren:
   ```bash
   backend/.venv/bin/pip install --upgrade pip
   backend/.venv/bin/pip install -r backend/requirements.txt
   ```

3. `systemd`-Service-Datei erstellen:
   - Siehe `/etc/systemd/system/bem-tools-backend.service` mit dem Inhalt aus dem Installationsskript.

4. Service aktivieren und starten:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now bem-tools-backend.service
   ```
