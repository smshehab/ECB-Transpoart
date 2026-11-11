import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver workspace'), actions: [IconButton(onPressed: () async { await FirebaseAuth.instance.signOut(); if (context.mounted) context.go('/'); }, icon: const Icon(Icons.logout))]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Driver tools', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(child: ListTile(leading: const Icon(Icons.route), title: const Text('Assigned trips'), subtitle: const Text('View and update your assigned trip status'), onTap: () => context.go('/driver/trips'))),
        Card(child: ListTile(leading: const Icon(Icons.gps_fixed), title: const Text('GPS sharing'), subtitle: const Text('Start or stop visible location sharing'), onTap: () => context.go('/driver/gps'))),
      ]),
    );
  }
}
