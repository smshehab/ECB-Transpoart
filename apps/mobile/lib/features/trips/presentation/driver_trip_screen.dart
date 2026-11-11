import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tracking/presentation/tracking_providers.dart';
import 'trip_providers.dart';

class DriverTripScreen extends ConsumerWidget {
  const DriverTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(myTripsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned trips')),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Unable to load trips: $error')),
        data: (snapshot) {
          if (snapshot.docs.isEmpty) return const Center(child: Text('No trips assigned.'));
          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.docs[index];
              final data = doc.data();
              final status = data['status'] as String? ?? 'scheduled';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['routeName'] as String? ?? 'Assigned route'),
                  subtitle: Text('Bus: ${data['busId'] ?? 'Not assigned'} · Status: $status'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      try {
                        final repository = ref.read(tripRepositoryProvider);
                        if (action == 'start') {
                          final busId = data['busId'] as String?;
                          if (busId == null || busId.isEmpty) throw StateError('This trip has no assigned bus. Contact transport administration.');
                          await repository.startTrip(tripId: doc.id);
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip started. Ask an administrator to activate tracking, then start GPS sharing.')));
                        }
                        if (action == 'pause') {
                          await repository.pauseTrip(tripId: doc.id);
                          await ref.read(locationTrackingServiceProvider).stop();
                        }
                        if (action == 'resume') {
                          await repository.resumeTrip(tripId: doc.id);
                          final busId = data['busId'] as String?;
                          if (busId == null || busId.isEmpty) throw StateError('This trip has no assigned bus.');
                          await ref.read(locationTrackingServiceProvider).start(busId: busId, tripId: doc.id);
                        }
                        if (action == 'complete') {
                          await repository.completeTrip(tripId: doc.id);
                          await ref.read(locationTrackingServiceProvider).stop(completed: true);
                        }
                      } catch (error) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                      }
                    },
                    itemBuilder: (context) => [
                      if (status == 'scheduled') const PopupMenuItem(value: 'start', child: Text('Start trip')),
                      if (status == 'active') const PopupMenuItem(value: 'pause', child: Text('Pause trip')),
                      if (status == 'paused') const PopupMenuItem(value: 'resume', child: Text('Resume trip')),
                      if (status == 'active' || status == 'paused') const PopupMenuItem(value: 'complete', child: Text('Complete trip')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
