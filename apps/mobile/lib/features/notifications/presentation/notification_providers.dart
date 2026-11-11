import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/push_notification_service.dart';

final pushNotificationServiceProvider = Provider((ref) => PushNotificationService(FirebaseMessaging.instance, FirebaseFirestore.instance, FirebaseAuth.instance));
