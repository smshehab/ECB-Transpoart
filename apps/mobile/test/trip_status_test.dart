import 'package:ecb_transport_mobile/features/trips/domain/trip_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses known trip statuses', () {
    expect(TripStatusValue.parse('active'), TripStatus.active);
    expect(TripStatusValue.parse('paused'), TripStatus.paused);
    expect(TripStatusValue.parse('completed'), TripStatus.completed);
  });

  test('uses scheduled as the safe fallback for unknown status', () {
    expect(TripStatusValue.parse('unexpected'), TripStatus.scheduled);
    expect(TripStatusValue.parse(null), TripStatus.scheduled);
  });
}
