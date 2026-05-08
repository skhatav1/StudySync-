# Deployment Guide

StudySync uses two deploy targets for a simple personal live demo:

- FastAPI backend: Render
- Flutter web frontend: Vercel
- Auth/database: Firebase Auth and Firestore

## 1. Deploy Backend On Render

1. Push the repo to GitHub.
2. Open Render and create a new Blueprint from the repo.
3. Render reads `render.yaml` and creates `studysync-api`.
4. Add these Render environment variables:

```text
OPENAI_API_KEY=your_openai_key
FIREBASE_CREDENTIALS_JSON=the_full_firebase_service_account_json_on_one_line
API_CORS_ORIGINS=https://YOUR_VERCEL_DOMAIN
```

For the first backend deploy, you can temporarily set:

```text
API_CORS_ORIGINS=http://localhost:3000
```

After the Vercel frontend is live, replace it with the real Vercel domain and redeploy/restart Render.

Keep `FIREBASE_CREDENTIALS_JSON` private. Do not commit it.

After Render deploys, verify:

```text
https://YOUR_RENDER_SERVICE.onrender.com/health
```

## 2. Build Flutter Web For Render

Replace the backend URL with your Render service URL:

```bash
cd /Users/suar/Desktop/StudySync-/frontend
flutter build web --dart-define=API_BASE_URL=https://YOUR_RENDER_SERVICE.onrender.com
```

## 3. Deploy Flutter Web To Vercel

Install Vercel CLI if needed:

```bash
npm install -g vercel
```

Deploy the generated static web app:

```bash
cd /Users/suar/Desktop/StudySync-/frontend/build/web
vercel
```

For production:

```bash
vercel --prod
```

Vercel will print a live URL. Copy that URL and update Render:

```text
API_CORS_ORIGINS=https://YOUR_VERCEL_DOMAIN
```

Then restart/redeploy the Render backend.

## Notes

- `backend/.env` stays local and must not be committed.
- `backend/firebase-service-account.json` stays local and must not be committed.
- Firebase web config in `frontend/lib/firebase_options.dart` is safe to commit.
- Firebase Storage may require a paid Firebase plan; the current demo supports resource links on Spark.
- Vercel is serving only the compiled Flutter static files. Render runs the API.

