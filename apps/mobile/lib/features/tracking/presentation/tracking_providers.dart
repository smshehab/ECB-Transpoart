import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/location_tracking_service.dart';

final locationTrackingServiceProvider = Provider((ref) => LocationTrackingService(FirebaseDatabase.instance, FirebaseAuth.instance));
