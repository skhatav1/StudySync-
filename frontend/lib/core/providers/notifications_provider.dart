import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repositories/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider(this._repository);

  final NotificationsRepository _repository;
  List<NotificationItem> notifications = const [];
  StreamSubscription<List<NotificationItem>>? _subscription;

  void bind() {
    _subscription?.cancel();
    _subscription = _repository.streamNotifications().listen((items) {
      notifications = items;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
