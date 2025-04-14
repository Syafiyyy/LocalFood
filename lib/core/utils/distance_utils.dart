import 'package:latlong2/latlong.dart';

class DistanceUtils {
  static final Distance _distance = const Distance();
  
  // Calculate distance between two points in meters
  static double calculateDistance(LatLng point1, LatLng point2) {
    return _distance.as(LengthUnit.Meter, point1, point2);
  }
  
  // Format distance into a readable string (e.g., "500m" or "2.5km")
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      final distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }
  
  // Get readable distance between two points
  static String getDistanceString(LatLng point1, LatLng point2) {
    final distanceInMeters = calculateDistance(point1, point2);
    return formatDistance(distanceInMeters);
  }
}
