import 'package:firebase_database/firebase_database.dart';

class LiveBusRepository {
  LiveBusRepository(this._database);
  final FirebaseDatabase _database;

  Stream<DatabaseEvent> watchBus(String busId) => _database.ref('live_buses/$busId').onValue;
  Stream<DatabaseEvent> watchAllBuses() => _database.ref('live_buses').onValue;
}
