import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 25),
            headers: const {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  static final ApiClient instance = ApiClient._internal();

  Dio get client => _dio;

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Reuse cached token if it won't expire for at least 5 minutes.
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _cachedToken;
    }

    final token = await user.getIdToken();
    _cachedToken = token;
    // Firebase tokens are valid for 1 hour; cache for 55 minutes.
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));
    return token;
  }

  void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
