import 'dart:math' as math;

class ContributorLocation {
  const ContributorLocation({
    required this.contributorId,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.updatedAt,
    this.speedMetersPerSecond,
    this.headingDegrees,
  });

  final String contributorId;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime updatedAt;
  final double? speedMetersPerSecond;
  final double? headingDegrees;

  bool isValidAt(DateTime now, {Duration maxAge = const Duration(seconds: 65)}) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        accuracyMeters.isFinite &&
        accuracyMeters >= 0 &&
        accuracyMeters <= 80 &&
        !updatedAt.isAfter(now.add(const Duration(seconds: 5))) &&
        now.difference(updatedAt) <= maxAge;
  }
}

class AggregatedBusPosition {
  const AggregatedBusPosition({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    required this.activeContributorCount,
    required this.confidence,
    required this.contributorIds,
    this.speedMetersPerSecond,
  });

  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final int activeContributorCount;
  final double confidence;
  final List<String> contributorIds;
  final double? speedMetersPerSecond;
}

class OfflinePosition {
  const OfflinePosition({
    required this.latitude,
    required this.longitude,
    required this.isEstimated,
    required this.age,
  });

  final double latitude;
  final double longitude;
  final bool isEstimated;
  final Duration age;
}

class LocationAggregation {
  static AggregatedBusPosition? aggregate(
    Iterable<ContributorLocation> observations, {
    DateTime? now,
    Duration maxAge = const Duration(seconds: 65),
    double outlierRadiusMeters = 250,
  }) {
    final instant = now ?? DateTime.now();
    final valid = observations.where((item) => item.isValidAt(instant, maxAge: maxAge)).toList();
    if (valid.isEmpty) return null;

    valid.sort((a, b) => a.latitude.compareTo(b.latitude));
    final medianLat = _median(valid.map((item) => item.latitude).toList());
    valid.sort((a, b) => a.longitude.compareTo(b.longitude));
    final medianLon = _median(valid.map((item) => item.longitude).toList());

    final candidates = valid.where((item) {
      return distanceMeters(item.latitude, item.longitude, medianLat, medianLon) <=
          math.max(outlierRadiusMeters, item.accuracyMeters * 2);
    }).toList();
    if (candidates.isEmpty) return null;

    var totalWeight = 0.0;
    var latitude = 0.0;
    var longitude = 0.0;
    var speedTotal = 0.0;
    var speedWeight = 0.0;
    var newest = candidates.first.updatedAt;
    for (final item in candidates) {
      final accuracy = math.max(item.accuracyMeters, 5);
      final ageSeconds = math.max(0, instant.difference(item.updatedAt).inSeconds);
      final weight = 1 / (accuracy * accuracy * (1 + ageSeconds / 30));
      totalWeight += weight;
      latitude += item.latitude * weight;
      longitude += item.longitude * weight;
      if (item.speedMetersPerSecond != null &&
          item.speedMetersPerSecond!.isFinite &&
          item.speedMetersPerSecond! >= 0 &&
          item.speedMetersPerSecond! <= 45) {
        speedTotal += item.speedMetersPerSecond! * weight;
        speedWeight += weight;
      }
      if (item.updatedAt.isAfter(newest)) newest = item.updatedAt;
    }

    final confidence = candidates.length == 1
        ? 0.45
        : math.min(0.99, 0.65 + (candidates.length - 2) * 0.1);
    return AggregatedBusPosition(
      latitude: latitude / totalWeight,
      longitude: longitude / totalWeight,
      updatedAt: newest,
      activeContributorCount: candidates.length,
      confidence: confidence,
      contributorIds: candidates.map((item) => item.contributorId).toList(),
      speedMetersPerSecond: speedWeight == 0 ? null : speedTotal / speedWeight,
    );
  }

  static OfflinePosition estimate({
    required AggregatedBusPosition lastPosition,
    required DateTime now,
    required List<({double latitude, double longitude})> route,
    Duration maximumDuration = const Duration(minutes: 5),
  }) {
    final age = now.difference(lastPosition.updatedAt);
    if (age <= Duration.zero || age > maximumDuration) {
      return OfflinePosition(
        latitude: lastPosition.latitude,
        longitude: lastPosition.longitude,
        isEstimated: false,
        age: age.isNegative ? Duration.zero : age,
      );
    }

    final speed = lastPosition.speedMetersPerSecond;
    if (speed == null || !speed.isFinite || speed <= 0 || route.length < 2) {
      return OfflinePosition(
        latitude: lastPosition.latitude,
        longitude: lastPosition.longitude,
        isEstimated: false,
        age: age,
      );
    }

    final travelledMeters = speed * age.inMilliseconds / 1000;
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < route.length; i++) {
      final distance = distanceMeters(
        lastPosition.latitude,
        lastPosition.longitude,
        route[i].latitude,
        route[i].longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    var remaining = travelledMeters;
    var lat = lastPosition.latitude;
    var lon = lastPosition.longitude;
    for (var i = bestIndex; i < route.length - 1; i++) {
      final next = route[i + 1];
      final segment = distanceMeters(lat, lon, next.latitude, next.longitude);
      if (segment <= remaining) {
        remaining -= segment;
        lat = next.latitude;
        lon = next.longitude;
      } else {
        final fraction = segment == 0 ? 0 : remaining / segment;
        lat += (next.latitude - lat) * fraction;
        lon += (next.longitude - lon) * fraction;
        remaining = 0;
        break;
      }
    }

    return OfflinePosition(
      latitude: lat,
      longitude: lon,
      isEstimated: true,
      age: age,
    );
  }

  static double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _median(List<double> values) {
    if (values.isEmpty) return 0;
    values.sort();
    final middle = values.length ~/ 2;
    if (values.length.isOdd) return values[middle];
    return (values[middle - 1] + values[middle]) / 2;
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
