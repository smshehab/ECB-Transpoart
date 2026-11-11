import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripRepository {
  TripRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyTrips() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in required');
    return _firestore.collection('trips').where('driverId', isEqualTo: uid).snapshots();
  }

  Future<void> startTrip({required String tripId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in required');
    final ref = _firestore.collection('trips').doc(tripId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (!snapshot.exists || data == null || data['driverId'] != uid || data['status'] != 'scheduled') {
        throw StateError('Trip is not assigned to this driver or cannot be started.');
      }
      transaction.update(ref, {'status': 'active', 'startedAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> pauseTrip({required String tripId}) => _changeStatus(tripId, 'active', 'paused');
  Future<void> resumeTrip({required String tripId}) => _changeStatus(tripId, 'paused', 'active');
  Future<void> completeTrip({required String tripId}) => _changeStatus(tripId, 'active', 'completed', completed: true);

  Future<void> _changeStatus(String tripId, String expected, String next, {bool completed = false}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in required');
    final ref = _firestore.collection('trips').doc(tripId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (!snapshot.exists || data == null || data['driverId'] != uid || data['status'] != expected) {
        throw StateError('Trip state changed or assignment is invalid.');
      }
      transaction.update(ref, {
        'status': next,
        'updatedAt': FieldValue.serverTimestamp(),
        if (completed) 'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
