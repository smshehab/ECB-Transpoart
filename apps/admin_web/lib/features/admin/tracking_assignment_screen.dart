import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TrackingAssignmentScreen extends StatefulWidget {
  const TrackingAssignmentScreen({super.key});
  @override
  State<TrackingAssignmentScreen> createState() => _TrackingAssignmentScreenState();
}

class _TrackingAssignmentScreenState extends State<TrackingAssignmentScreen> {
  final _driverId = TextEditingController();
  final _busId = TextEditingController();
  final _tripId = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() { _driverId.dispose(); _busId.dispose(); _tripId.dispose(); super.dispose(); }

  Future<void> _activate() async {
    final driverId = _driverId.text.trim();
    final busId = _busId.text.trim();
    final tripId = _tripId.text.trim();
    if (driverId.isEmpty || busId.isEmpty || tripId.isEmpty) { setState(() => _message = 'Enter driver UID, bus ID and active trip ID.'); return; }
    setState(() { _busy = true; _message = null; });
    try {
      final trip = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
      final data = trip.data();
      if (!trip.exists || data == null || data['status'] != 'active' || data['driverId'] != driverId || data['busId'] != busId) {
        throw StateError('Trip must exist, be active, and match the driver and bus IDs.');
      }
      await FirebaseDatabase.instance.ref('driver_assignments/$driverId').set({
        'busId': busId,
        'activeTripId': tripId,
        'updatedAt': ServerValue.timestamp,
      });
      if (mounted) setState(() => _message = 'Tracking assignment activated. The driver can now share location for this active trip.');
    } catch (error) {
      if (mounted) setState(() => _message = 'Assignment failed: $error');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _clear() async {
    final driverId = _driverId.text.trim();
    if (driverId.isEmpty) { setState(() => _message = 'Enter the driver UID first.'); return; }
    setState(() { _busy = true; _message = null; });
    try {
      await FirebaseDatabase.instance.ref('driver_assignments/$driverId').remove();
      if (mounted) setState(() => _message = 'Tracking assignment cleared.');
    } catch (error) {
      if (mounted) setState(() => _message = 'Clear failed: $error');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Text('Driver tracking assignment', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),
    const Text('Only an administrator can activate the Realtime Database assignment mirror. Activate it after the trip is marked active in Firestore.'),
    const SizedBox(height: 20),
    TextField(controller: _driverId, decoration: const InputDecoration(labelText: 'Driver Firebase UID')),
    const SizedBox(height: 12),
    TextField(controller: _busId, decoration: const InputDecoration(labelText: 'Assigned bus document ID')),
    const SizedBox(height: 12),
    TextField(controller: _tripId, decoration: const InputDecoration(labelText: 'Active trip document ID')),
    const SizedBox(height: 16),
    FilledButton(onPressed: _busy ? null : _activate, child: const Text('Verify and activate assignment')),
    OutlinedButton(onPressed: _busy ? null : _clear, child: const Text('Clear driver assignment')),
    if (_busy) const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
    if (_message != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_message!)),
  ]);
}
