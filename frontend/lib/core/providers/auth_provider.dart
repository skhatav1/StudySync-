import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository) {
    _subscription = _repository.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  User? currentUser;
  bool isSubmitting = false;
  String? error;
  late final StreamSubscription<User?> _subscription;

  Future<void> signIn(String email, String password) async {
    await _wrap(() => _repository.signIn(email: email, password: password));
  }

  Future<void> signUp(String email, String password) async {
    await _wrap(() => _repository.signUp(email: email, password: password));
  }

  Future<void> signOut() async {
    ApiClient.instance.clearTokenCache();
    await _repository.signOut();
  }

  Future<void> _wrap(Future<dynamic> Function() action) async {
    isSubmitting = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (exc) {
      error = exc.message;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
