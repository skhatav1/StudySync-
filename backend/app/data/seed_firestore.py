from datetime import datetime, timedelta, timezone

from app.core.firebase import get_firestore_client


def seed_demo_workspace(uid: str, email: str) -> None:
    db = get_firestore_client()
    now = datetime.now(timezone.utc)

    db.collection("users").document(uid).set(
        {
            "uid": uid,
            "name": "Alex Johnson",
            "email": email,
            "academic_goals": ["Score above 90 in Calculus and Data Structures"],
            "preferred_study_hours": 3.5,
            "learning_style": "mixed",
            "weak_subjects": ["Calculus", "Biology"],
            "preferred_session_length": 50,
            "preferred_study_times": ["18:00", "20:00"],
            "target_grades": {"Calculus II": "A", "Biology": "A-"},
            "collaboration_preferences": ["group-revision", "resource-sharing"],
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("courses").document(f"{uid}_calculus").set(
        {
            "user_id": uid,
            "name": "Calculus II",
            "current_grade": "B",
            "confidence": 4,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("courses").document(f"{uid}_dsa").set(
        {
            "user_id": uid,
            "name": "Data Structures",
            "current_grade": "B+",
            "confidence": 6,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("assignments").document(f"{uid}_bio_lab").set(
        {
            "user_id": uid,
            "course_name": "Biology",
            "title": "Biology lab report",
            "due_date": (now + timedelta(days=3)).date().isoformat(),
            "estimated_hours": 4,
            "priority": "high",
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("exams").document(f"{uid}_calc_midterm").set(
        {
            "user_id": uid,
            "course_name": "Calculus II",
            "title": "Calculus midterm",
            "exam_date": (now + timedelta(days=5)).date().isoformat(),
            "target_score": "90",
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("study_groups").add(
        {
            "name": "Algorithm Sprint Crew",
            "subject": "Data Structures",
            "shared_goal": "Finish graph traversal revision and a mock whiteboard round.",
            "created_by": uid,
            "member_ids": [uid],
            "member_emails": ["maya@example.com"],
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("resources").add(
        {
            "owner_id": uid,
            "title": "Integration Techniques Summary.pdf",
            "subject": "Calculus",
            "topic": "Integration",
            "storage_path": "demo/resources/integration-techniques-summary.pdf",
            "download_url": "https://example.com/demo/integration-techniques-summary.pdf",
            "mime_type": "application/pdf",
            "tags": ["exam", "weak-area"],
            "favorite": True,
            "created_at": now.isoformat(),
            "updated_at": now.isoformat(),
        }
    )

    db.collection("notifications").add(
        {
            "user_id": uid,
            "title": "Plan recalculation suggestion",
            "body": "You have two deadlines this week. Rebuild your study plan after tonight’s session.",
            "type": "plan",
            "read": False,
            "created_at": now.isoformat(),
        }
    )


if __name__ == "__main__":
    seed_demo_workspace(uid="demo-user", email="demo@studysync.app")
    print("Demo workspace seeded.")
