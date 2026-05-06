# StudySync

StudySync is an AI-powered collaborative study planner built with Flutter, Firebase, FastAPI, and the OpenAI API. It helps students generate realistic study plans, adapt those plans when deadlines change, organize resources, collaborate in live study groups, and turn raw notes into summaries, flashcards, quizzes, and guided explanations.

## Elevator pitch

StudySync turns scattered deadlines, notes, and group chats into one adaptive study operating system that plans what to study next, explains difficult material, and syncs collaboration in real time.

## Core features

- Firebase email/password authentication with session persistence
- Firestore-backed user profiles, onboarding data, courses, exams, and assignments
- FastAPI planning engine with adaptive plan generation and recalculation
- Resource library for study links/references with metadata persisted through the backend
- OpenAI-powered note summarization, flashcard generation, quiz generation, and assistant chat
- Firestore-powered study groups with live collaboration-ready collections
- Analytics dashboard driven by real backend data and completion metrics
- Detail/result screens for study sessions, resources, groups, quizzes, and notifications
- One-tap demo workspace seeding from the app plus a backend Firestore seed script

## System architecture

### Flutter client
- `frontend/lib/app`: root app shell and auth gating
- `frontend/lib/core/models`: typed app models
- `frontend/lib/core/repositories`: Firebase and API integrations
- `frontend/lib/core/providers`: state management with `provider`
- `frontend/lib/features`: screens for auth, onboarding, dashboard, plans, assistant, groups, resources, analytics, and profile

### FastAPI backend
- `backend/app/api/routes`: profile, plans, AI, groups, resources, analytics
- `backend/app/services`: Firestore persistence, OpenAI orchestration, planning, analytics
- `backend/app/schemas`: strongly typed request and response contracts
- `backend/app/core`: environment config, Firebase bootstrap, auth verification

### Firebase
- Firebase Auth for account creation and sign-in
- Cloud Firestore for user, plan, group, analytics, and assistant data
- Firebase Storage support is scaffolded for uploaded study resources; the current Spark-plan demo uses link/reference resources because Storage requires billing in this Firebase project

More detail:
- [architecture.md](/Users/suar/Desktop/StudySync-/docs/architecture.md)
- [api-design.md](/Users/suar/Desktop/StudySync-/docs/api-design.md)
- [database-schema.md](/Users/suar/Desktop/StudySync-/docs/database-schema.md)
- [pitch.md](/Users/suar/Desktop/StudySync-/docs/pitch.md)

## Firestore collections

- `users`
- `courses`
- `exams`
- `assignments`
- `study_plans`
- `study_sessions`
- `resources`
- `study_groups`
- `group_tasks`
- `comments`
- `analytics`
- `assistant_history`
- `notifications`

## Local setup

### 1. Backend

```bash
cd /Users/suar/Desktop/StudySync-/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Populate `.env` with:
- `OPENAI_API_KEY`
- `OPENAI_MODEL`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_CREDENTIALS_PATH`

Run the API:

```bash
uvicorn app.main:app --reload
```

Open:
- [http://127.0.0.1:8000/health](http://127.0.0.1:8000/health)
- [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)

Optional demo seeding:

```bash
../.venv/bin/python -m app.data.seed_firestore
```

### 2. Firebase

Create a Firebase project and enable:
- Authentication: Email/Password
- Firestore
- Storage only if your project has billing enabled

Then:
1. Create a Firebase service account and download the JSON key.
2. Point `FIREBASE_CREDENTIALS_PATH` in `backend/.env` to that JSON file.
3. Replace placeholder values in [firebase_options.dart](/Users/suar/Desktop/StudySync-/frontend/lib/firebase_options.dart) with your real Firebase config.
4. Deploy the rules from:
   - [firestore.rules](/Users/suar/Desktop/StudySync-/firebase/firestore.rules)
   - [storage.rules](/Users/suar/Desktop/StudySync-/firebase/storage.rules)

Note: If Firebase Storage shows an upgrade prompt, skip Storage for now. StudySync still works locally with resource links/references through Firestore and FastAPI.

### 3. Frontend

```bash
cd /Users/suar/Desktop/StudySync-/frontend
flutter pub get
flutter run -d chrome
```

For local backend calls from Flutter web, use:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Verification status

Verified in this workspace:
- Backend Python compilation: `python3 -m compileall app`
- Flutter static analysis: `flutter analyze`
- Flutter web build: `flutter build web`

Not automatically verified here:
- Real Firebase project credentials
- Real OpenAI responses without an `OPENAI_API_KEY`
- End-to-end auth/resource/group flows against your own Firebase project

## Demo flow

1. Sign up with email/password.
2. Complete onboarding with course, exam, assignment, and weak-subject data.
3. Open the plan screen and generate an AI study plan.
4. Recalculate the plan to demonstrate adaptive workload balancing.
5. Add a study resource link in the resource library.
6. Open the resource detail screen.
7. Use the AI assistant to summarize notes or generate a quiz, then open the quiz result screen.
8. Create or open a study group and show the group detail screen.
9. Open the notifications screen from the dashboard header.
10. End on the analytics dashboard to show productivity, streaks, and AI insights.

## Judge demo checklist

Use this exact flow for a reliable 3-minute demo:

1. Start backend: `uvicorn app.main:app --reload`
2. Start frontend: `flutter run -d chrome`
3. Sign in or sign up with a demo account.
4. If onboarding appears, keep the demo defaults and click `Save onboarding`.
5. On `Home`, click `Load demo data`.
6. Open `Plan`, click `Generate AI plan`, then click `Recalculate`.
7. Open `Files`, click `Add`, save the default resource link, then open it.
8. In the resource detail, generate `Summarize`, `Flashcards`, and `Quiz`.
9. Open `Groups`, create a group, open it, add a task and a comment.
10. End on `Stats` to show streak, hours, productivity score, and AI insights.

## Current implementation notes

- Backend routes are auth-aware and expect a valid Firebase ID token in the `Authorization` header.
- The Flutter client injects Firebase auth tokens automatically into backend requests via Dio.
- If `OPENAI_API_KEY` is missing, the backend returns deterministic development fallbacks for AI responses so the app can still be exercised locally.
- Firebase project values in `firebase_options.dart` must match your Firebase web app before real app runtime.
- Resource links work on the free Firebase Spark plan. Direct file uploads require enabling Firebase Storage, which currently requires upgrading the Firebase project billing plan.

## Future improvements

- Richer study session tracking and timer-based completion logging
- Push notifications and reminder scheduling
- Shared task presence indicators for live collaboration boards
- Resource detail screens with inline AI actions and annotation support
- Voice note transcription pipeline and audio summaries
- Calendar sync and exam countdown widgets
