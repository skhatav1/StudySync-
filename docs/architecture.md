# StudySync Architecture

## Product architecture

StudySync is designed as a mobile-first, AI-assisted collaboration platform with three major layers:

1. Flutter client
   - Owns onboarding, authentication flow, dashboard, study planning UI, analytics, and collaboration surfaces.
   - Uses a clean feature-first structure with shared widgets and centralized app state.
   - Can run in demo mode with seeded data or connect to FastAPI and Firebase services.

2. FastAPI intelligence layer
   - Exposes endpoints for plan generation, adaptive rescheduling, analytics summaries, assistant actions, and resource transformations.
   - Encapsulates scheduling logic, prioritization rules, and OpenAI request orchestration.
   - Designed so expensive AI outputs can be cached in Firestore under `AI_history`.

3. Firebase platform layer
   - Firebase Auth for sign-in and group identity.
   - Firestore for user profiles, tasks, plans, study groups, comments, analytics, and cached AI outputs.
   - Firebase Storage for note uploads, screenshots, PDFs, and audio notes.
   - Real-time listeners power shared group boards, task updates, and resource comments.

## Primary flows

### AI planning flow

Flutter collects:
- courses
- exams
- deadlines
- available study hours
- weak subjects
- preferred study windows
- learning style

FastAPI planner:
- computes urgency, confidence pressure, and workload balance
- uses deterministic ranking rules first
- optionally enriches rationale and phrasing with OpenAI
- stores generated plans in Firestore for retrieval and analytics

### Collaboration flow

- User creates or joins a study group in Flutter.
- Group metadata, shared tasks, and comments are stored in Firestore.
- Group boards subscribe to live snapshots.
- Shared resources reference Storage URLs plus Firestore metadata.

### AI resource flow

- User uploads notes, PDF, screenshots, or audio.
- Storage stores file content; Firestore stores tags and ownership.
- FastAPI transforms resource text into summaries, quizzes, or flashcards.
- Generated outputs can be attached to future study sessions.

## Clean architecture layout

### Frontend

- `app/`: app shell and root configuration
- `core/`: theme, services, config, models, repositories, providers
- `features/`: feature-specific screens and widgets
- `shared/`: reusable UI primitives

### Backend

- `api/routes/`: FastAPI endpoints
- `schemas/`: request and response contracts
- `services/`: business logic and OpenAI orchestration
- `core/`: config and environment
- `data/`: demo seed data

## Demo posture

The repo is optimized for a hackathon demo:
- dashboard-triggered demo seeding creates an instant story
- adaptive recalculation is visible on a single tap
- AI assistant outputs route into dedicated result/detail screens
- collaboration and notifications surfaces are wired to Firestore-backed collections
