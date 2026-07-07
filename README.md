# BEM-Tools GeoNav

Eine statische Frontend-Anwendung zur Suche von GPS-Koordinaten, Kartenvorschau und Navigation. Die Startseite ist jetzt `index.html`, alle Suchseiten verwenden `suche.html` und das Backend bietet die API unter `/api`.

## Projektstruktur

- `index.html` — neue Startseite der Anwendung
- `suche.html` — Suchseite für die drei Datensätze
- `style.css` — gemeinsames Styling
- `backend/` — FastAPI-Backend mit SQLite
- `empg_bohrungen.json`, `empg_schieber.json`, `gasunie_schieber.json` — Quelldaten

## Neuer Name

Das Projekt heißt jetzt **BEM-Tools GeoNav**. Sichtbare Änderungen:
- `Lokation-Tool` wurde in `BEM-Tools GeoNav` umbenannt
- Alle Zurück-Links verweisen jetzt auf `index.html`
- API-Zugriffe nutzen `/api` statt `/lokationtool/api`

## Backend / API

Das Backend liefert:
- `GET /api/health`
- `GET /api/datasets`
- `GET /api/entries/{dataset}`
- `GET /api/export/{dataset}`
- `POST /api/admin/login`
- `POST /api/entries/{dataset}`
- `PUT /api/entries/{dataset}/{entry_id}`
- `DELETE /api/entries/{dataset}/{entry_id}`

## Einrichtung

1. Python 3.11+ installieren.
2. Im Projektverzeichnis ein virtuelles Environment erstellen:
   - `python -m venv .venv`
   - `source .venv/bin/activate`
3. Abhängigkeiten installieren:
   - `pip install -r backend/requirements.txt`
4. JSON-Daten in die SQLite-Datenbank importieren:
   - `cd backend`
   - `python import_json_to_db.py`
5. Backend starten:
   - `uvicorn main:app --host 127.0.0.1 --port 8010`
6. Statische Dateien mit Apache2 ausliefern.

## Apache2-Konfiguration

Erstelle die Datei `bemtools.conf` für die neue Domain `bemtools.de` und verwende folgenden Inhalt:

```apache
<VirtualHost *:80>
    ServerName bemtools.de
    ServerAlias www.bemtools.de

    # 1. Pfad zum Frontend (Statische Dateien)
    DocumentRoot /var/www/html
#    DirectoryIndex index.html
    <Directory "/var/www/html">
        AllowOverride None
        Require all granted
    </Directory>

    Redirect permanent / https://bemtools.de
    # 2. Reverse Proxy für das Python-Backend
    # Alle Anfragen an /api werden intern an Port 8000 weitergeleitet
#    ProxyPreserveHost On
#    ProxyPass /api http://127.0.0
#    ProxyPassReverse /api http://127.0.0

#    ErrorLog ${APACHE_LOG_DIR}/meinprojekt_error.log
#    CustomLog ${APACHE_LOG_DIR}/meinprojekt_access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerName bemtools.de
    ServerAlias www.bemtools.de

    DocumentRoot /var/www/html

    #  SSL Engine Switch:
    #   Enable/Disable SSL for this virtual host.
    SSLEngine on
    SSLCertificateFile    /home/csx/BEM-Tools/backend/cert/pem.crt
    SSLCertificateKeyFile /home/csx/BEM-Tools/backend/cert/private.key
    #SSLCertificateChainFile /etc/ssl/certs/gd_bundle.crt
</VirtualHost>
```

Passe bei Bedarf die Pfade zu `DocumentRoot` und zu den SSL-Zertifikatsdateien an.

> Caddy wird nicht mehr verwendet. Das statische Frontend wird jetzt mit Apache2 ausgeliefert.

## Deployment

1. Installiere Apache2 und aktiviere ggf. die benötigten Module:
   - `a2enmod ssl`
   - `a2enmod proxy`
   - `a2enmod proxy_http`
2. Lege die Konfigurationsdatei `/etc/apache2/sites-available/bemtools.conf` an.
3. Aktiviere die Site:
   - `sudo a2ensite bemtools.conf`
4. Lade Apache neu:
   - `sudo systemctl reload apache2`
5. Stelle sicher, dass die Domain `bemtools.de` auf die Server-IP zeigt.
6. Öffne `https://bemtools.de` im Browser.

## Adminzugang

Standard-Anmeldedaten für das lokale Setup (kann per Umgebung geändert werden):
- `LOKATION_ADMIN_USER`: `admin`
- `LOKATION_ADMIN_PASSWORD`: `admin123`
- `LOKATION_SECRET_KEY`: Setze einen starken Token-Secret-Wert

## Hinweise

- Die statische Anwendung nutzt jetzt `index.html` als Startseite.
- Die Suche lädt Daten über `/api/export/{dataset}`.
- Die Adminfunktion speichert Änderungen in der SQLite-Datenbank.
