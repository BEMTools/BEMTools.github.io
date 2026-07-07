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
6. Statische Dateien mit Caddy ausliefern (siehe `Caddyfile`).

## Caddy-Konfiguration

Erstelle die Datei `Caddyfile` im Projektstamm mit der Domain `chriss97st.ddns.net`.

```caddy
chriss97st.ddns.net {
    root * /var/www/BEM-Tools
    encode gzip

    handle_path /api/* {
        reverse_proxy 127.0.0.1:8010
    }

    file_server
}
```

Passe den Pfad `/var/www/BEM-Tools` an den tatsächlichen Speicherort der Projektdateien an.

> Wenn Caddy auf demselben Server läuft wie das Backend, muss das Backend nur lokal erreichbar sein. TLS wird von Caddy automatisch terminiert.

## Deployment

1. Stelle sicher, dass Caddy auf dem Server läuft.
2. Setze die Domain `chriss97st.ddns.net` auf die Server-IP.
3. Starte das Backend auf `127.0.0.1:8010`.
4. Öffne `https://chriss97st.ddns.net` im Browser.

## Adminzugang

Standard-Anmeldedaten für das lokale Setup (kann per Umgebung geändert werden):
- `LOKATION_ADMIN_USER`: `admin`
- `LOKATION_ADMIN_PASSWORD`: `admin123`
- `LOKATION_SECRET_KEY`: Setze einen starken Token-Secret-Wert

## Hinweise

- Die statische Anwendung nutzt jetzt `index.html` als Startseite.
- Die Suche lädt Daten über `/api/export/{dataset}`.
- Die Adminfunktion speichert Änderungen in der SQLite-Datenbank.
