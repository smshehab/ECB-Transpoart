import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class EcbFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static FirebaseOptions get current {
    final appId = kIsWeb
        ? const String.fromEnvironment('FIREBASE_WEB_APP_ID')
        : defaultTargetPlatform == TargetPlatform.iOS
            ? const String.fromEnvironment('FIREBASE_IOS_APP_ID')
            : const String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
    return FirebaseOptions(
      apiKey: _apiKey,
      appId: appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
      authDomain: _authDomain,
      databaseURL: _databaseUrl,
      storageBucket: _storageBucket,
    );
  }

  static const appCheckSiteKey = String.fromEnvironment('FIREBASE_APP_CHECK_SITE_KEY');
}
