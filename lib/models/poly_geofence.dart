import 'package:geolocator/geolocator.dart';
import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence_status.dart';

/// A model representing a polygon geofence.
class PolyGeofence {
  /// Identifier for [PolyGeofence].
  final String id;

  /// Custom data for [PolyGeofence].
  final dynamic data;

  /// A list of coordinates to create a polygon.
  /// The polygon is always considered closed, regardless of whether the last point equals the first or not.
  final List<LatLng> polygon;

  /// The status of [PolyGeofence].
  PolyGeofenceStatus _status = PolyGeofenceStatus.EXIT;

  /// Returns the status of [PolyGeofence].
  PolyGeofenceStatus get status => _status;

  /// The timestamp when polygon geofence status changes.
  DateTime? _timestamp;

  /// Returns the timestamp of [PolyGeofence].
  DateTime? get timestamp => _timestamp;

  /// Constructs an instance of [PolyGeofence].
  PolyGeofence({required this.id, this.data, required this.polygon})
      : assert(id.isNotEmpty),
        assert(polygon.isNotEmpty);

  /// Returns the data fields of [PolyGeofence] in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'polygon': polygon.map((e) => e.toJson()).toList(),
      'status': _status,
      'timestamp': _timestamp
    };
  }

  /// Update the status of [PolyGeofence].
  /// Returns true if the status changes, false otherwise.
  bool updateStatus(PolyGeofenceStatus status, Position position) {
    if (status != _status) {
      _status = status;
      _timestamp = position.timestamp;
      return true;
    }

    return false;
  }
}
