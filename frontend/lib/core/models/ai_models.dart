class SummaryResult {
  const SummaryResult({
    required this.title,
    required this.bullets,
    required this.keyTakeaways,
  });

  final String title;
  final List<String> bullets;
  final List<String> keyTakeaways;

  factory SummaryResult.fromJson(Map<String, dynamic> json) => SummaryResult(
        title: json['title'] as String,
        bullets: List<String>.from(json['bullets'] ?? const []),
        keyTakeaways: List<String>.from(json['key_takeaways'] ?? const []),
      );
}

class FlashcardItem {
  const FlashcardItem({required this.question, required this.answer});
  final String question;
  final String answer;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) => FlashcardItem(
        question: json['question'] as String,
        answer: json['answer'] as String,
      );
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.question,
    required this.type,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String question;
  final String type;
  final List<String> options;
  final String answer;
  final String explanation;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) => QuizQuestionModel(
        question: json['question'] as String,
        type: json['type'] as String,
        options: List<String>.from(json['options'] ?? const []),
        answer: json['answer'] as String,
        explanation: json['explanation'] as String,
      );
}

class AssistantChatResponse {
  const AssistantChatResponse({required this.reply, required this.suggestions});
  final String reply;
  final List<String> suggestions;

  factory AssistantChatResponse.fromJson(Map<String, dynamic> json) => AssistantChatResponse(
        reply: json['reply'] as String,
        suggestions: List<String>.from(json['suggestions'] ?? const []),
      );
}
