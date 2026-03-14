# Geo-Photo-App
An app that captures photos with GPS coordinates, stores them locally, and uploads to a Django REST API.

**Status**
- MVP complete: capture, preview, local save, gallery view, backend upload.

**Features**
- Camera capture with GPS tagging
- Preview screen with coordinates
- Local gallery (offline-safe)
- Upload to backend via multipart POST

**Tech Stack**
- Flutter
- Django + Django REST Framework
- PostgreSQL (default) or SQLite (dev)

## Project Structure
- `lib/` Flutter app
- `backend/` Django API

## Prerequisites
- Flutter SDK
- Python 3.x
- Django + DRF
- PostgreSQL (optional, default DB)

## Backend Setup
1. Go to backend folder:
```powershell
cd backend
```

2. Install backend deps:
```powershell
pip install -r requirements.txt
```

3. Database config (optional)
Default is PostgreSQL:
- `DATABASE_NAME=geo_photo`
- `DATABASE_USER=postgres`
- `DATABASE_PASSWORD=1234` (if needed)
- `DATABASE_HOST=localhost`
- `DATABASE_PORT=5432`

For SQLite:
- `DATABASE_ENGINE=sqlite`

4. Run migrations:
```powershell
python manage.py migrate
```

5. Start server:
```powershell
python manage.py runserver 0.0.0.0:8000
```

## Flutter App Setup
1. Fetch packages:
```powershell
flutter pub get
```

2. Run the app (set upload URL):
```powershell
flutter run --dart-define=PHOTO_UPLOAD_URL=http://127.0.0.1:8000/api/upload-photo/
```

## Ngrok (Optional)
If testing on a device outside your network:
```powershell
ngrok http 8000
```

Then use the ngrok URL:
```powershell
flutter run --dart-define=PHOTO_UPLOAD_URL=https://<ngrok-id>.ngrok-free.app/api/upload-photo/
```

## API Endpoint
`POST http://<host>:8000/api/upload-photo/`

Form-data fields:
- `image` (file)
- `latitude` (float)
- `longitude` (float)

Success response:
```json
{
  "status": "success",
  "message": "Photo stored successfully"
}
```

## Environment Variables (Backend)
- `DJANGO_SECRET_KEY`
- `DJANGO_DEBUG`
- `DJANGO_ALLOWED_HOSTS`
- `DATABASE_ENGINE`
- `DATABASE_NAME`
- `DATABASE_USER`
- `DATABASE_PASSWORD`
- `DATABASE_HOST`
- `DATABASE_PORT`

## Environment Variables (Flutter)
- `PHOTO_UPLOAD_URL`
