/// Defines the status of the polygon geofence.
enum PolyGeofenceStatus {
  /// Occurs when entering the geofence area.
  ENTER,

  /// Occurs when exiting the geofence area.
  EXIT,

  /// Occurs when the loitering delay elapses after entering the geofence area.
  DWELL
}
