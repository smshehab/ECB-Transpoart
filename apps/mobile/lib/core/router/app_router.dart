import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/map/presentation/live_bus_map_screen.dart';
import '../../features/notifications/presentation/passenger_notifications_screen.dart';
import '../../features/passenger/presentation/passenger_data_screen.dart';
import '../../features/passenger/presentation/passenger_home_screen.dart';

GoRouter createAppRouter({required bool firebaseReady, Object? firebaseError}) {
  final authRefresh = firebaseReady ? _AuthRefreshNotifier() : null;
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authRefresh,
    redirect: (context, state) async {
      if (!firebaseReady) return state.matchedLocation == '/' ? null : '/';
      final path = state.matchedLocation;
      final user = FirebaseAuth.instance.currentUser;
      const guestPaths = {'/', '/login', '/register', '/map', '/routes', '/announcements'};
      const userPaths = {'/passenger', '/notifications'};
      if (user == null) {
        return guestPaths.contains(path) ? null : '/';
      }

      final token = await user.getIdTokenResult();
      final role = token.claims?['role'];
      final isAdmin = role == 'admin';
      final isUser = role == null || role == 'user';

      if (isAdmin) return path == '/access-denied' ? null : '/access-denied';
      if (!isUser) return path == '/access-denied' ? null : '/access-denied';
      if (path == '/access-denied') return '/passenger';
      if (path == '/login' || path == '/register' || path == '/') return '/passenger';
      if (userPaths.contains(path)) return null;
      if (guestPaths.contains(path)) return null;
      return '/passenger';
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => _WelcomeScreen(firebaseReady: firebaseReady, firebaseError: firebaseError)),
      GoRoute(path: '/access-denied', builder: (context, state) => const _MobileAccessDeniedScreen()),
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen(register: false)),
      GoRoute(path: '/register', builder: (context, state) => const AuthScreen(register: true)),
      GoRoute(path: '/passenger', builder: (context, state) => const PassengerHomeScreen()),
      GoRoute(path: '/map', builder: (context, state) => const LiveBusMapScreen()),
      GoRoute(path: '/routes', builder: (context, state) => const PassengerDataScreen(collection: 'routes', title: 'Routes')),
      GoRoute(path: '/notifications', builder: (context, state) => const PassengerNotificationsScreen()),
      GoRoute(path: '/announcements', builder: (context, state) => const PassengerDataScreen(collection: 'announcements', title: 'Announcements')),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
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
                  FilledButton.icon(
                    onPressed: firebaseReady ? () => context.go('/login') : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in'),
                  ),
                  OutlinedButton.icon(
                    onPressed: firebaseReady ? () => context.go('/register') : null,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Create user account'),
                  ),
                  TextButton(
                    onPressed: firebaseReady ? () => context.go('/map') : null,
                    child: const Text('Continue as guest · View buses'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileAccessDeniedScreen extends StatelessWidget {
  const _MobileAccessDeniedScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 12),
                const Text('This account does not have access to the mobile user app.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      );
}
