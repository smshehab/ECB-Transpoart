import 'package:firebase_core/firebase_core.dart';

class EcbFirebaseOptions {
  static const current = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const appCheckSiteKey = String.fromEnvironment('FIREBASE_APP_CHECK_SITE_KEY');
}
