import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PassengerHomeScreen extends StatelessWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('ECB Transport'), actions: [IconButton(onPressed: () async { await FirebaseAuth.instance.signOut(); if (context.mounted) context.go('/'); }, icon: const Icon(Icons.logout))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hello, ${user?.displayName ?? 'Passenger'}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          const Text('Find your route and follow active buses.'),
          const SizedBox(height: 20),
          Card(child: ListTile(leading: const Icon(Icons.map_outlined), title: const Text('Live bus map'), subtitle: const Text('See buses sharing their current position'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/map'))),
          Card(child: ListTile(leading: const Icon(Icons.route_outlined), title: const Text('Routes and schedules'), subtitle: const Text('Browse transport routes and departure times'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/routes'))),
          Card(child: ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), subtitle: const Text('Your personal transport notifications'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/notifications'))),
          Card(child: ListTile(leading: const Icon(Icons.campaign_outlined), title: const Text('Announcements'), subtitle: const Text('Public transport notices'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/announcements'))),
          Card(child: ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), subtitle: Text(user?.email ?? ''), trailing: const Icon(Icons.chevron_right))),
        ],
      ),
    );
  }
}
