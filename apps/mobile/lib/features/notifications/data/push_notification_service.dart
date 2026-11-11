import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  PushNotificationService(this._messaging, this._firestore, this._auth);

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> initializeForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final permission = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (permission.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.collection('users').doc(user.uid).collection('notification_tokens').doc(token.hashCode.toString()).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': 'mobile',
    });
    _messaging.onTokenRefresh.listen((newToken) async {
      await _firestore.collection('users').doc(user.uid).collection('notification_tokens').doc(newToken.hashCode.toString()).set({
        'token': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': 'mobile',
      });
    });
  }
}
