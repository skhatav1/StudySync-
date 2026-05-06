import '../models/analytics_model.dart';
import '../services/api_client.dart';

class AnalyticsRepository {
  Future<AnalyticsSummary> fetchSummary() async {
    final response = await ApiClient.instance.client.get('/api/analytics/summary');
    return AnalyticsSummary.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
