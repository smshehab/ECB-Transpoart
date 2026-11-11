import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: EcbAdminApp()));
}

class EcbAdminApp extends StatelessWidget {
  const EcbAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECB Transport Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1769AA)),
      ),
      home: const AdminDashboardShell(),
    );
  }
}

class AdminDashboardShell extends StatelessWidget {
  const AdminDashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ECB Transport · Admin')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Overview')),
                    NavigationRailDestination(icon: Icon(Icons.directions_bus_outlined), label: Text('Fleet')),
                    NavigationRailDestination(icon: Icon(Icons.route_outlined), label: Text('Routes')),
                    NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text('Users')),
                  ],
                ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.count(
                    crossAxisCount: wide ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: const [
                      _MetricCard(label: 'Total buses', value: '—', icon: Icons.directions_bus),
                      _MetricCard(label: 'Active drivers', value: '—', icon: Icons.person_pin),
                      _MetricCard(label: 'Active trips', value: '—', icon: Icons.route),
                      _MetricCard(label: 'Passengers', value: '—', icon: Icons.groups),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ],
        ),
      ),
    );
  }
}
