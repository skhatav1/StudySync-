import 'package:flutter/material.dart';

import '../models/analytics_model.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider(this._repository);

  final AnalyticsRepository _repository;
  AnalyticsSummary? summary;
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      summary = await _repository.fetchSummary();
    } catch (exc) {
      error = exc.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
