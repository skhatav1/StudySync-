# Pitch Content

## 1-line elevator pitch

StudySync is an AI-powered collaborative study planner that turns deadlines, weak topics, and shared courses into adaptive schedules, live group study rooms, and instant resource-to-quiz learning tools.

## 30-second pitch

Students usually know they need to study, but they don’t know what to study first, how to build a realistic plan, or how to stay consistent when deadlines pile up. StudySync fixes that by generating personalized AI study schedules, detecting overload before burnout happens, transforming study resources into summaries, quizzes, and flashcards, and syncing study groups in real time. It’s not just a planner; it’s an adaptive study operating system built for how students actually work.

## Problem statement

Students lose time and performance because planning is fragmented across calendars, chat apps, notes, and last-minute cram sessions. Most tools track tasks, but very few actively decide what matters next, rebalance missed work intelligently, and support collaborative studying in one place.

## Key innovation points

- AI-generated study plans that balance urgency, confidence, and sustainability
- Adaptive rescheduling when sessions are missed or deadlines change
- Real-time collaborative study rooms with shared resources and synchronized tasks
- Resource-to-summary, flashcard, and quiz transformations powered by AI
- Weak-area detection tied directly to recommendations and scheduling logic

## Judge-facing technical highlights

- Flutter mobile client with feature-based architecture and polished demo UX
- FastAPI intelligence layer with deterministic planning logic plus OpenAI enrichment
- Firebase Auth and Firestore for identity, collaboration, and resource metadata syncing
- Firebase Storage integration scaffolded for paid-plan file uploads; Spark-plan demo uses resource links
- Reusable prompt-driven AI endpoints for summarization, quizzes, flashcards, and concept coaching
- Caching-ready AI history model to reduce repeated OpenAI costs in production

## 3-minute demo script

1. Sign in and explain that Firebase Auth gates every backend request with an ID token.
2. Show onboarding defaults and save them to create real Firestore profile/course/deadline data.
3. Open the dashboard and click `Load demo data`.
4. Generate an AI plan, then click `Recalculate` to show adaptive rescheduling.
5. Add a resource link, then generate a summary, flashcards, and quiz from it.
6. Create a study group, open the shared board, add a task, and post a comment.
7. End on analytics: streak, hours, productivity score, weak areas, and AI insights.
