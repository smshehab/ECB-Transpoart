import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  LocationTrackingService(this._database, this._auth);

  final FirebaseDatabase _database;
  final FirebaseAuth _auth;
  StreamSubscription<Position>? _subscription;

  Future<void> start({required String busId, required String tripId}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Driver sign-in is required.');
    if (!await Geolocator.isLocationServiceEnabled()) throw StateError('Enable device location services.');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw StateError('Location permission was not granted.');
    }

    await stop();
    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15, timeLimit: Duration(seconds: 30));
    _subscription = Geolocator.getPositionStream(locationSettings: settings).listen((position) async {
      if (position.accuracy > 80) return;
      final reference = _database.ref('live_buses/$busId');
      await reference.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'speed': position.speed < 0 ? 0 : position.speed,
        'heading': position.heading,
        'accuracy': position.accuracy,
        'updatedAt': ServerValue.timestamp,
        'tripId': tripId,
        'driverId': user.uid,
        'status': 'active',
      });
    }, onError: (Object error) {
      stop();
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
