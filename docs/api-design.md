# API Design

All authenticated routes expect:
- `Authorization: Bearer <firebase-id-token>`

## Health

### `GET /health`
- Returns service health and active environment.

## Profile

### `POST /api/profile/`
- Creates or upserts the signed-in user profile.

### `GET /api/profile/me`
- Fetches the current user profile from Firestore.

### `PUT /api/profile/me`
- Updates profile preferences.

### `POST /api/profile/onboarding`
- Persists onboarding data including profile preferences, courses, exams, and assignments.

## Plans

### `POST /api/plans/generate`
- Builds a structured weekly study plan from courses, exams, assignments, and study preferences.

### `GET /api/plans/current`
- Returns the latest saved study plan for the signed-in user.

### `POST /api/plans/recalculate`
- Rebuilds the plan after missed sessions, deadline changes, or reduced availability.

### `GET /api/plans/recommendations`
- Returns prioritized study recommendations derived from the active plan.

### `POST /api/plans/tasks/complete`
- Marks a planned task as complete and updates the stored plan.

## AI

### `POST /api/ai/summarize`
- Returns a structured summary with title, bullets, and key takeaways.

### `POST /api/ai/flashcards`
- Returns question-answer flashcards from notes or resource content.

### `POST /api/ai/quiz`
- Returns structured quiz questions with answers and explanations.

### `POST /api/ai/explain`
- Returns a beginner-friendly explanation, practical example, and memory tip.

### `POST /api/ai/chat`
- Returns an assistant reply plus suggested follow-up actions.

## Groups

### `GET /api/groups/`
- Lists the current user’s study groups.

### `POST /api/groups/`
- Creates a new study group.

### `POST /api/groups/{group_id}/invite`
- Adds an invited email to the group metadata.

### `POST /api/groups/{group_id}/tasks`
- Creates a shared group task.

### `PATCH /api/groups/tasks/{task_id}`
- Updates a shared group task.

### `DELETE /api/groups/tasks/{task_id}`
- Deletes a shared group task.

### `POST /api/groups/{group_id}/comments`
- Adds a comment on a shared group resource.

## Resources

### `GET /api/resources/`
- Lists the signed-in user’s resources.

### `POST /api/resources/`
- Persists resource metadata after a Firebase Storage upload completes in the client.

### `POST /api/resources/{resource_id}/comments`
- Adds a comment to a resource.

## Analytics

### `GET /api/analytics/summary`
- Returns streak, study hours, completion rate, weak subjects, upcoming deadlines, productivity score, and AI insights.
