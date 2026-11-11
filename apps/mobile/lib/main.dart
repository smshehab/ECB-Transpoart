import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  Object? firebaseError;

  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error) {
    firebaseError = error;
  }

  runApp(
    ProviderScope(
      child: EcbTransportApp(
        firebaseReady: firebaseReady,
        firebaseError: firebaseError,
      ),
    ),
  );
}
