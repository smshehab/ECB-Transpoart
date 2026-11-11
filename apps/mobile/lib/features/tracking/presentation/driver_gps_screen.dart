import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracking_providers.dart';

class DriverGpsScreen extends ConsumerStatefulWidget {
  const DriverGpsScreen({super.key});

  @override
  ConsumerState<DriverGpsScreen> createState() => _DriverGpsScreenState();
}

class _DriverGpsScreenState extends ConsumerState<DriverGpsScreen> {
  bool _sharing = false;
  bool _busy = false;
  String? _status;

  Future<void> _start() async {
    if (_busy || _sharing) return;
    setState(() { _busy = true; _status = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('Driver sign-in is required.');
      final assignmentSnapshot = await FirebaseDatabase.instance.ref('driver_assignments/${user.uid}').get();
      final raw = assignmentSnapshot.value;
      if (raw is! Map) throw StateError('No active bus assignment was found. Contact transport administration.');
      final assignment = Map<Object?, Object?>.from(raw);
      final busId = assignment['busId'] as String?;
      final tripId = assignment['activeTripId'] as String?;
      if (busId == null || busId.isEmpty || tripId == null || tripId.isEmpty) {
        throw StateError('Your active bus/trip assignment is incomplete.');
      }
      final tripSnapshot = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
      final trip = tripSnapshot.data();
      if (!tripSnapshot.exists || trip == null || trip['status'] != 'active' ||
          trip['driverId'] != user.uid || trip['busId'] != busId) {
        throw StateError('The assigned trip is not active or does not match your driver account.');
      }
      await ref.read(locationTrackingServiceProvider).start(busId: busId, tripId: tripId);
      if (mounted) setState(() { _sharing = true; _status = 'Live GPS sharing is active for your assigned trip.'; });
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    try {
      await ref.read(locationTrackingServiceProvider).stop();
      if (mounted) setState(() { _sharing = false; _status = 'Location sharing stopped.'; });
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver GPS status')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Location sharing is ${_sharing ? 'ON' : 'OFF'}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Text('GPS can only start after transport administration assigns your driver account to a bus and activates an active trip.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy || _sharing ? null : _start,
            child: Text(_busy ? 'Please wait…' : 'Start assigned trip GPS'),
          ),
          OutlinedButton(
            onPressed: _busy || !_sharing ? null : _stop,
            child: const Text('Stop location sharing'),
          ),
          if (_status != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_status!)),
          const SizedBox(height: 12),
          const Text('Android foreground notification and iOS background-location behavior must be tested on physical devices before production release.'),
        ],
      ),
    );
  }
}
