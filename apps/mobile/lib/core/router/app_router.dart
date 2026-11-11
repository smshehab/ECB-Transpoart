import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({required bool firebaseReady, Object? firebaseError}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _WelcomeScreen(firebaseReady: firebaseReady, firebaseError: firebaseError),
      ),
      GoRoute(path: '/passenger', builder: (context, state) => const _RoleScreen(title: 'Passenger')),
      GoRoute(path: '/driver', builder: (context, state) => const _RoleScreen(title: 'Driver')),
    ],
  );
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.firebaseReady, this.firebaseError});

  final bool firebaseReady;
  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.directions_bus_rounded, size: 64, color: Color(0xFF1769AA)),
                  const SizedBox(height: 16),
                  Text('ECB Transport', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('Public transport, connected.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (!firebaseReady)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Firebase is not configured for this platform. Run FlutterFire configuration before enabling sign-in and live data. ${firebaseError ?? ''}'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(onPressed: () => context.go('/passenger'), icon: const Icon(Icons.person_outline), label: const Text('Passenger preview')),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(onPressed: () => context.go('/driver'), icon: const Icon(Icons.drive_eta_outlined), label: const Text('Driver preview')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleScreen extends StatelessWidget {
  const _RoleScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ECB Transport · $title')),
      body: Center(child: Text('$title workspace foundation', style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}
