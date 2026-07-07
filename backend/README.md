Lokation Suche Backend

Uebersicht
- FastAPI API fuer die drei Datensaetze:
  - empg_bohrungen
  - empg_schieber
  - gasunie_schieber
- SQLite Datenbankdatei: lokation_suche.db
- JWT Admin Login fuer Create/Update/Delete
- Einmaliger JSON Import mit import_json_to_db.py

Dateien
- main.py: API Server
- import_json_to_db.py: JSON -> Datenbank Migration
- requirements.txt: Python Abhaengigkeiten

Schnellstart
1) Virtualenv erstellen und Pakete installieren
- python -m venv .venv
- .venv\Scripts\activate
- pip install -r requirements.txt

2) JSON in Datenbank importieren
- python import_json_to_db.py

3) API starten
- uvicorn main:app --host 127.0.0.1 --port 8010

Wichtige Umgebungsvariablen
- LOKATION_SECRET_KEY
- LOKATION_ADMIN_USER
- LOKATION_ADMIN_PASSWORD

Beispiel (PowerShell)
- $env:LOKATION_SECRET_KEY = "super-long-random-secret"
- $env:LOKATION_ADMIN_USER = "admin"
- $env:LOKATION_ADMIN_PASSWORD = "dein-starkes-passwort"
- uvicorn main:app --host 127.0.0.1 --port 8010

API Endpunkte
- GET /api/health
- GET /api/datasets
- GET /api/entries/{dataset}
- GET /api/export/{dataset}
- POST /api/admin/login
- POST /api/entries/{dataset} (Bearer Token)
- PUT /api/entries/{dataset}/{entry_id} (Bearer Token)
- DELETE /api/entries/{dataset}/{entry_id} (Bearer Token)

Dataset Werte
- empg_bohrungen
- empg_schieber
- gasunie_schieber

Caddy Einbindung
Hinweis: Beispiel fuer Domain setup mit Frontend und API auf demselben Host.

Beispiel Caddyfile
example.de {
    root * /var/www/Chriss97ST.github.io
    encode gzip

    handle_path /api/* {
        reverse_proxy 127.0.0.1:8010
    }

    file_server
}

Wenn dein Frontend auf anderer Domain liegt, CORS in main.py einschranken und dort nur diese Domain erlauben.

Apache2 Einbindung
- Das Frontend wird jetzt statisch mit Apache2 bereitgestellt.
- Apache kann `DocumentRoot /var/www/html` nutzen und Anfragen an `/api` an das lokale Backend weiterleiten.
- Falls ein Reverse-Proxy gewünscht ist, aktiviere `ssl`, `proxy` und `proxy_http`.

Beispiel-Bemtools Apache-Konfiguration
```apache
<VirtualHost *:80>
    ServerName bemtools.de
    ServerAlias www.bemtools.de

    DocumentRoot /var/www/html
    <Directory "/var/www/html">
        AllowOverride None
        Require all granted
    </Directory>

    Redirect permanent / https://bemtools.de
</VirtualHost>

<VirtualHost *:443>
    ServerName bemtools.de
    ServerAlias www.bemtools.de

    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile    /home/csx/BEM-Tools/backend/cert/pem.crt
    SSLCertificateKeyFile /home/csx/BEM-Tools/backend/cert/private.key
</VirtualHost>
```

Falls Apache `/api` weiterleiten soll, kannst du folgende Zeilen aktivieren:
```apache
    ProxyPreserveHost On
    ProxyPass /api http://127.0.0.1:8010
    ProxyPassReverse /api http://127.0.0.1:8010
```

Empfohlener Betrieb als Dienst
- Starte uvicorn über systemd oder Task Scheduler (je nach Server OS).
- Port 8010 nur lokal binden (`127.0.0.1`), nicht direkt ins Internet.
- TLS wird vom Apache-Host terminiert.

JSON zu DB Umstellung (empfohlener Ablauf)
1) Backup der drei JSON Dateien erstellen.
2) Backend deployen und mit Importskript Datenbank fuellen.
3) Frontend lesen zuerst aus API:
   - /api/export/empg_bohrungen
   - /api/export/empg_schieber
   - /api/export/gasunie_schieber
4) Adminbereich auf API CRUD umstellen.
5) Nach Testphase JSON nur noch als Backup behalten.

Frontend Integration kurz
- Login: POST /api/admin/login => access_token speichern
- Lesen: GET /api/entries/{dataset}
- Anlegen: POST /api/entries/{dataset}
- Bearbeiten: PUT /api/entries/{dataset}/{entry_id}
- Loeschen: DELETE /api/entries/{dataset}/{entry_id}
- Bei allen schreibenden Requests Header setzen:
  Authorization: Bearer <token>
