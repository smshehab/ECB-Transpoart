import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: EcbFirebaseOptions.current);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  Object? firebaseError;
  try {
    await Firebase.initializeApp(options: EcbFirebaseOptions.current);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    try {
      final siteKey = EcbFirebaseOptions.appCheckSiteKey;
      if (kIsWeb && siteKey.isNotEmpty) {
        await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(siteKey));
      } else if (!kIsWeb) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
          appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        );
      }
    } catch (_) {}
    firebaseReady = true;
  } catch (error) {
    firebaseError = error;
  }
  runApp(ProviderScope(child: EcbTransportApp(firebaseReady: firebaseReady, firebaseError: firebaseError)));
}
