class CourseModel {
  const CourseModel({
    this.id,
    required this.name,
    this.currentGrade,
    this.confidence = 5,
  });

  final String? id;
  final String name;
  final String? currentGrade;
  final int confidence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'current_grade': currentGrade,
        'confidence': confidence,
      };
}

class ExamModel {
  const ExamModel({
    this.id,
    required this.courseName,
    required this.title,
    required this.examDate,
    this.targetScore,
  });

  final String? id;
  final String courseName;
  final String title;
  final String examDate;
  final String? targetScore;

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_name': courseName,
        'title': title,
        'exam_date': examDate,
        'target_score': targetScore,
      };
}

class AssignmentModel {
  const AssignmentModel({
    this.id,
    required this.courseName,
    required this.title,
    required this.dueDate,
    required this.estimatedHours,
    this.priority = 'medium',
  });

  final String? id;
  final String courseName;
  final String title;
  final String dueDate;
  final double estimatedHours;
  final String priority;

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_name': courseName,
        'title': title,
        'due_date': dueDate,
        'estimated_hours': estimatedHours,
        'priority': priority,
      };
}
