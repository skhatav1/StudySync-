# Firestore Schema

## Collections

### `users/{userId}`
- `name`
- `email`
- `avatarUrl`
- `learningStyle`
- `dailyStudyHours`
- `preferredStudyWindows`
- `weakSubjects`
- `timezone`
- `studyStreak`

### `courses/{courseId}`
- `userId`
- `name`
- `examDate`
- `priority`
- `confidence`
- `weakTopics`

### `tasks/{taskId}`
- `userId`
- `courseId`
- `title`
- `dueDate`
- `estimatedHours`
- `status`
- `difficulty`
- `linkedResourceIds`

### `study_plans/{planId}`
- `userId`
- `generatedAt`
- `status`
- `headline`
- `priorities`
- `riskAlerts`
- `dailyPlan`
- `revisionIntervals`

### `study_sessions/{sessionId}`
- `userId`
- `planId`
- `courseId`
- `scheduledFor`
- `durationMinutes`
- `status`
- `actualMinutes`
- `reflection`

### `resources/{resourceId}`
- `ownerId`
- `title`
- `subject`
- `topic`
- `type`
- `storagePath`
- `important`
- `tags`
- `groupIds`
- `aiOutputs`

### `study_groups/{groupId}`
- `name`
- `subject`
- `memberIds`
- `sharedGoal`
- `nextSession`
- `createdBy`

### `group_messages/{messageId}`
- `groupId`
- `authorId`
- `message`
- `resourceId`
- `createdAt`

### `analytics/{userId}`
- `hoursStudiedWeekly`
- `tasksCompletedWeekly`
- `weakAreas`
- `productivityScore`
- `heatmap`
- `aiInsights`

### `AI_history/{entryId}`
- `userId`
- `type`
- `inputHash`
- `promptVersion`
- `output`
- `createdAt`
