import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/admin/admin_crud_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var ready = false;
  Object? error;
  try {
    await Firebase.initializeApp(options: EcbFirebaseOptions.current);
    if (EcbFirebaseOptions.appCheckSiteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider(EcbFirebaseOptions.appCheckSiteKey));
    }
    ready = true;
  } catch (exception) { error = exception; }
  runApp(ProviderScope(child: EcbAdminApp(firebaseReady: ready, firebaseError: error)));
}

class EcbAdminApp extends StatelessWidget {
  const EcbAdminApp({required this.firebaseReady, this.firebaseError, super.key});
  final bool firebaseReady;
  final Object? firebaseError;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ECB Transport Admin',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769AA))),
    home: firebaseReady ? const _AdminGate() : _ConfigurationError(error: firebaseError),
  );
}

class _ConfigurationError extends StatelessWidget {
  const _ConfigurationError({this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Firebase is not configured. Run FlutterFire configuration for the Web app before using the admin dashboard. $error'))));
}

class _AdminGate extends StatelessWidget {
  const _AdminGate();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final user = snapshot.data;
      if (user == null) return const _AdminLoginScreen();
      return FutureBuilder<IdTokenResult>(
        future: user.getIdTokenResult(true),
        builder: (context, claims) {
          if (!claims.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final role = claims.data!.claims?['role'];
          if (role != 'super_admin' && role != 'transport_admin') return const _AccessDeniedScreen();
          return const AdminDashboard();
        },
      );
    },
  );
}

class _AdminLoginScreen extends StatefulWidget {
  const _AdminLoginScreen();
  @override
  State<_AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<_AdminLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool busy = false;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  Future<void> login() async {
    setState(() { busy = true; error = null; });
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: password.text);
      final claims = await result.user!.getIdTokenResult(true);
      final role = claims.claims?['role'];
      if (role != 'super_admin' && role != 'transport_admin') {
        await FirebaseAuth.instance.signOut();
        throw StateError('This account does not have administrator access.');
      }
    } catch (exception) { if (mounted) setState(() => error = exception.toString()); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Icon(Icons.directions_bus, size: 56),
    Text('Administrator sign in', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 20),
    TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
    const SizedBox(height: 12),
    TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
    if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    const SizedBox(height: 16),
    FilledButton(onPressed: busy ? null : login, child: Text(busy ? 'Signing in…' : 'Sign in')),
  ])))));
}

class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Administrator access is required.'), TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Sign out'))])));
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selected = 0;
  static const sections = [
    ('Overview', 'buses'), ('Buses', 'buses'), ('Routes', 'routes'), ('Schedules', 'schedules'), ('Announcements', 'announcements'), ('Drivers', 'drivers'), ('Trips', 'trips'), ('Users', 'users'),
  ];
  static const icons = [Icons.dashboard_outlined, Icons.directions_bus_outlined, Icons.route_outlined, Icons.schedule_outlined, Icons.campaign_outlined, Icons.badge_outlined, Icons.route_outlined, Icons.people_outline];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 760;
    final current = sections[selected];
    return Scaffold(
      appBar: AppBar(title: const Text('ECB Transport · Admin'), actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
      body: Row(children: [
        if (wide) NavigationRail(selectedIndex: selected, onDestinationSelected: (index) => setState(() => selected = index), labelType: NavigationRailLabelType.all, destinations: [for (var i = 0; i < sections.length; i++) NavigationRailDestination(icon: Icon(icons[i]), label: Text(sections[i].$1))]),
        if (wide) const VerticalDivider(width: 1),
        Expanded(child: Padding(padding: const EdgeInsets.all(20), child: selected == 0 ? const _Overview() : AdminCrudScreen(collection: current.$2, title: current.$1))),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: selected, onDestinationSelected: (index) => setState(() => selected = index), destinations: [for (var i = 0; i < sections.length; i++) NavigationDestination(icon: Icon(icons[i]), label: sections[i].$1)]),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview();
  @override
  Widget build(BuildContext context) => GridView.count(crossAxisCount: MediaQuery.sizeOf(context).width > 1100 ? 4 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: const [
    _CountCard(collection: 'buses', title: 'Total buses', icon: Icons.directions_bus),
    _CountCard(collection: 'drivers', title: 'Drivers', icon: Icons.badge),
    _CountCard(collection: 'trips', title: 'Trips', icon: Icons.route),
    _CountCard(collection: 'users', title: 'Users', icon: Icons.groups),
  ]);
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.collection, required this.title, required this.icon});
  final String collection;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection(collection).snapshots(), builder: (context, snapshot) => Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(snapshot.hasData ? '${snapshot.data!.size}' : '—', style: Theme.of(context).textTheme.headlineMedium), Text(title),
  ]))));
}
