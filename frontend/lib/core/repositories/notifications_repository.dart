import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<NotificationItem>> streamNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<NotificationItem>>.empty();
    }
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationItem.fromJson({'id': doc.id, ...doc.data()}))
              .toList(),
        );
  }
}
