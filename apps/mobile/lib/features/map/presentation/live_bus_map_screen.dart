import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LiveBusMapScreen extends StatelessWidget {
  const LiveBusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseDatabase.instance.ref('live_buses').onValue;
    return Scaffold(
      appBar: AppBar(title: const Text('Live bus map')),
      body: StreamBuilder<DatabaseEvent>(
        stream: stream,
        builder: (context, snapshot) {
          final markers = <Marker>[];
          if (snapshot.hasData && snapshot.data!.snapshot.value is Map) {
            final buses = Map<Object?, Object?>.from(snapshot.data!.snapshot.value! as Map);
            for (final entry in buses.entries) {
              if (entry.value is! Map) continue;
              final data = Map<Object?, Object?>.from(entry.value! as Map);
              final lat = (data['latitude'] as num?)?.toDouble();
              final lon = (data['longitude'] as num?)?.toDouble();
              final updatedAt = (data['updatedAt'] as num?)?.toInt();
              if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
              final stale = updatedAt == null || DateTime.now().millisecondsSinceEpoch - updatedAt > const Duration(minutes: 2).inMilliseconds;
              markers.add(Marker(
                point: LatLng(lat, lon),
                width: 120,
                height: 56,
                child: Column(children: [
                  Icon(Icons.directions_bus, color: stale ? Colors.grey : Colors.blue, size: 30),
                  Text(stale ? 'Stale bus' : 'Bus ${entry.key}', style: const TextStyle(fontSize: 10, backgroundColor: Colors.white)),
                ]),
              ));
            }
          }
          if (snapshot.hasError) return Center(child: Text('Live map unavailable: ${snapshot.error}'));
          return FlutterMap(
            options: const MapOptions(initialCenter: LatLng(23.8103, 90.4125), initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecbtransport.mobile',
              ),
              MarkerLayer(markers: markers),
              const RichAttributionWidget(attributions: [TextSourceAttribution('© OpenStreetMap contributors')]),
              if (snapshot.connectionState == ConnectionState.waiting) const Align(alignment: Alignment.topCenter, child: LinearProgressIndicator()),
            ],
          );
        },
      ),
    );
  }
}
