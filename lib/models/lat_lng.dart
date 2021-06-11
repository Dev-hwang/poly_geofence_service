/// A model representing the latitude and longitude of GPS.
class LatLng {
  /// The latitude of GPS.
  final double latitude;

  /// The longitude of GPS.
  final double longitude;

  /// Constructs an instance of [LatLng].
  const LatLng(this.latitude, this.longitude);

  /// Returns the data fields of [PolyGeofence] in JSON format.
  Map<String, dynamic> toJson() =>
      {'latitude': latitude, 'longitude': longitude};
}
