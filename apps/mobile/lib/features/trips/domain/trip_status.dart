enum TripStatus { scheduled, active, paused, completed, cancelled }

extension TripStatusValue on TripStatus {
  String get value => name;

  static TripStatus parse(String? value) {
    return TripStatus.values.firstWhere((status) => status.name == value, orElse: () => TripStatus.scheduled);
  }
}
