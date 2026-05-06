import '../models/ai_models.dart';
import '../services/api_client.dart';

class AssistantRepository {
  Future<SummaryResult> summarize({
    required String subject,
    required String content,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/ai/summarize',
      data: {'subject': subject, 'content': content},
    );
    return SummaryResult.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<List<FlashcardItem>> flashcards({
    required String subject,
    required String content,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/ai/flashcards',
      data: {'subject': subject, 'content': content},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return (data['flashcards'] as List<dynamic>? ?? const [])
        .map((item) => FlashcardItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<QuizQuestionModel>> quiz({
    required String subject,
    required String content,
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/ai/quiz',
      data: {'subject': subject, 'content': content},
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    return (data['questions'] as List<dynamic>? ?? const [])
        .map((item) => QuizQuestionModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<AssistantChatResponse> chat({
    required String message,
    String? subject,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final response = await ApiClient.instance.client.post(
      '/api/ai/chat',
      data: {'message': message, 'subject': subject, 'history': history},
    );
    return AssistantChatResponse.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
