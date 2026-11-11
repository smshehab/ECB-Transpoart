import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/driver/presentation/driver_dashboard_screen.dart';
import '../../features/map/presentation/live_bus_map_screen.dart';
import '../../features/notifications/presentation/passenger_notifications_screen.dart';
import '../../features/passenger/presentation/passenger_data_screen.dart';
import '../../features/passenger/presentation/passenger_home_screen.dart';
import '../../features/tracking/presentation/driver_gps_screen.dart';
import '../../features/trips/presentation/driver_trip_screen.dart';

GoRouter createAppRouter({required bool firebaseReady, Object? firebaseError}) {
  return GoRouter(initialLocation: '/', routes: [
    GoRoute(path: '/', builder: (context, state) => _WelcomeScreen(firebaseReady: firebaseReady, firebaseError: firebaseError)),
    GoRoute(path: '/login', builder: (context, state) => const AuthScreen(register: false)),
    GoRoute(path: '/driver/login', builder: (context, state) => const AuthScreen(register: false, driverMode: true)),
    GoRoute(path: '/register', builder: (context, state) => const AuthScreen(register: true)),
    GoRoute(path: '/passenger', builder: (context, state) => const PassengerHomeScreen()),
    GoRoute(path: '/driver', builder: (context, state) => const DriverDashboardScreen()),
    GoRoute(path: '/driver/trips', builder: (context, state) => const DriverTripScreen()),
    GoRoute(path: '/driver/gps', builder: (context, state) => const DriverGpsScreen()),
    GoRoute(path: '/map', builder: (context, state) => const LiveBusMapScreen()),
    GoRoute(path: '/routes', builder: (context, state) => const PassengerDataScreen(collection: 'routes', title: 'Routes')),
    GoRoute(path: '/notifications', builder: (context, state) => const PassengerNotificationsScreen()),
    GoRoute(path: '/announcements', builder: (context, state) => const PassengerDataScreen(collection: 'announcements', title: 'Announcements')),
  ]);
}

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.firebaseReady, this.firebaseError});
  final bool firebaseReady;
  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.directions_bus_rounded, size: 64, color: Color(0xFF1769AA)),
        const SizedBox(height: 16),
        Text('ECB Transport', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Public transport, connected.', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (!firebaseReady) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('Firebase is not configured for this platform. Run FlutterFire configuration before enabling sign-in and live data. ${firebaseError ?? ''}'))),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: firebaseReady ? () => context.go('/login') : null, icon: const Icon(Icons.login), label: const Text('Sign in')),
        OutlinedButton.icon(onPressed: firebaseReady ? () => context.go('/register') : null, icon: const Icon(Icons.person_add_alt), label: const Text('Create passenger account')),
        TextButton(onPressed: firebaseReady ? () => context.go('/driver/login') : null, child: const Text('Driver sign in')),
      ]),
    )))));
  }
}
