import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracking_providers.dart';

class DriverGpsScreen extends ConsumerStatefulWidget {
  const DriverGpsScreen({super.key});

  @override
  ConsumerState<DriverGpsScreen> createState() => _DriverGpsScreenState();
}

class _DriverGpsScreenState extends ConsumerState<DriverGpsScreen> {
  final _busId = TextEditingController();
  final _tripId = TextEditingController();
  bool _sharing = false;
  String? _status;

  @override
  void dispose() {
    _busId.dispose();
    _tripId.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busId.text.trim().isEmpty || _tripId.text.trim().isEmpty) {
      setState(() => _status = 'Bus and trip IDs are required.');
      return;
    }
    try {
      await ref.read(locationTrackingServiceProvider).start(busId: _busId.text.trim(), tripId: _tripId.text.trim());
      if (mounted) setState(() { _sharing = true; _status = 'Location sharing is active while this screen session runs.'; });
    } catch (error) {
      if (mounted) setState(() => _status = error.toString());
    }
  }

  Future<void> _stop() async {
    await ref.read(locationTrackingServiceProvider).stop();
    if (mounted) setState(() { _sharing = false; _status = 'Location sharing stopped.'; });
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
          TextField(controller: _busId, decoration: const InputDecoration(labelText: 'Assigned bus ID')),
          const SizedBox(height: 12),
          TextField(controller: _tripId, decoration: const InputDecoration(labelText: 'Active trip ID')),
          const SizedBox(height: 16),
          FilledButton(onPressed: _sharing ? null : _start, child: const Text('Start location sharing')),
          OutlinedButton(onPressed: _sharing ? _stop : null, child: const Text('Stop location sharing')),
          if (_status != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(_status!)),
          const SizedBox(height: 12),
          const Text('Keep this app open during this initial foreground tracking implementation. Background/foreground-service support requires native platform configuration and device testing.'),
        ],
      ),
    );
  }
}
