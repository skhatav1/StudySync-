import 'package:flutter/material.dart';

import '../models/ai_models.dart';
import '../repositories/assistant_repository.dart';

class AssistantProvider extends ChangeNotifier {
  AssistantProvider(this._repository);

  final AssistantRepository _repository;
  bool loading = false;
  String? error;
  SummaryResult? summary;
  List<FlashcardItem> flashcards = const [];
  List<QuizQuestionModel> quiz = const [];
  AssistantChatResponse? chatResponse;

  Future<void> summarize(String subject, String content) async {
    await _wrap(() async => summary = await _repository.summarize(subject: subject, content: content));
  }

  Future<void> createFlashcards(String subject, String content) async {
    await _wrap(() async => flashcards = await _repository.flashcards(subject: subject, content: content));
  }

  Future<void> createQuiz(String subject, String content) async {
    await _wrap(() async => quiz = await _repository.quiz(subject: subject, content: content));
  }

  Future<void> chat(String message, {String? subject}) async {
    await _wrap(() async => chatResponse = await _repository.chat(message: message, subject: subject));
  }

  Future<void> _wrap(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
