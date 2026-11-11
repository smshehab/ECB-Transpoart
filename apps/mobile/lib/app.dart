import 'package:flutter/material.dart';

import 'core/router/app_router.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class EcbTransportApp extends StatelessWidget {
  const EcbTransportApp({required this.firebaseReady, this.firebaseError, super.key});

  final bool firebaseReady;
  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'ECB Transport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769AA)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      routerConfig: createAppRouter(firebaseReady: firebaseReady, firebaseError: firebaseError),
    );
  }
}
