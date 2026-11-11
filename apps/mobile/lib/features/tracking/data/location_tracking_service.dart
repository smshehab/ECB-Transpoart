import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  LocationTrackingService(this._database, this._auth);

  final FirebaseDatabase _database;
  final FirebaseAuth _auth;
  StreamSubscription<Position>? _subscription;
  String? _activeBusId;

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
    _activeBusId = busId;
    final LocationSettings settings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ECB Transport location sharing',
          notificationText: 'Your location is shared during your active trip.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15);
    }
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

  Future<void> stop({bool completed = false}) async {
    await _subscription?.cancel();
    _subscription = null;
    final busId = _activeBusId;
    _activeBusId = null;
    if (busId != null && _auth.currentUser != null) {
      final reference = _database.ref('live_buses/$busId');
      if (completed) {
        await reference.remove();
      } else {
        await reference.update({'status': 'paused', 'updatedAt': ServerValue.timestamp});
      }
    }
  }
}
