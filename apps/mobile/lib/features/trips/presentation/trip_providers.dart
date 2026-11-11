import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trip_repository.dart';

final tripRepositoryProvider = Provider((ref) => TripRepository(FirebaseFirestore.instance, FirebaseAuth.instance));
final myTripsProvider = StreamProvider((ref) => ref.watch(tripRepositoryProvider).watchMyTrips());
