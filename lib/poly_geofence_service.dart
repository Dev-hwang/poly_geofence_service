import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poly_geofence_service/models/error_codes.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/models/poly_geofence_status.dart';
import 'package:poly_geofence_service/utils/poly_utils.dart';

export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:geolocator/geolocator.dart';
export 'package:poly_geofence_service/models/error_codes.dart';
export 'package:poly_geofence_service/models/lat_lng.dart';
export 'package:poly_geofence_service/models/poly_geofence.dart';
export 'package:poly_geofence_service/models/poly_geofence_status.dart';
export 'package:poly_geofence_service/utils/poly_utils.dart';

/// Function to notify polygon geofence status changes.
typedef PolyGeofenceStatusChanged = Future<void> Function(
    PolyGeofence polyGeofence,
    PolyGeofenceStatus polyGeofenceStatus,
    Position position);

/// A class provides polygon geofence management and geo-fencing.
class PolyGeofenceService {
  PolyGeofenceService._internal();

  /// Instance of [PolyGeofenceService].
  static final instance = PolyGeofenceService._internal();

  /// Whether the service is running.
  bool _isRunningService = false;

  /// Returns whether the service is running.
  bool get isRunningService => _isRunningService;

  /// The time interval in milliseconds to check the polygon geofence status.
  /// The default is `5000`.
  int _interval = 5000;

  /// Geo-fencing error range in meters.
  /// The default is `100`.
  int _accuracy = 100;

  /// Sets the delay between [PolyGeofenceStatus.ENTER] and [PolyGeofenceStatus.DWELL] in milliseconds.
  /// The default is `300000`.
  int _loiteringDelayMs = 300000;

  /// Sets the status change delay in milliseconds.
  /// [PolyGeofenceStatus.ENTER] and [PolyGeofenceStatus.EXIT] events may be called frequently
  /// when the location is near the boundary of the polygon geofence. Use this option to minimize event calls at this time.
  /// If the option value is too large, realtime geo-fencing is not possible, so use it carefully.
  /// The default is `10000`.
  int _statusChangeDelayMs = 10000;

  /// Whether to allow mock locations.
  /// The default is `false`.
  bool _allowMockLocations = false;

  StreamSubscription<Position>? _positionStream;
  final _polyGeofenceList = <PolyGeofence>[];
  final _polyGeofenceStatusChangedListeners = <PolyGeofenceStatusChanged>[];
  final _streamErrorListeners = <ValueChanged>[];

  /// Setup [PolyGeofenceService].
  /// Some options do not change while the service is running.
  PolyGeofenceService setup({
    int? interval,
    int? accuracy,
    int? loiteringDelayMs,
    int? statusChangeDelayMs,
    bool? allowMockLocations
  }) {
    _interval = interval ?? _interval;
    _accuracy = accuracy ?? _accuracy;
    _loiteringDelayMs = loiteringDelayMs ?? _loiteringDelayMs;
    _statusChangeDelayMs = statusChangeDelayMs ?? _statusChangeDelayMs;
    _allowMockLocations = allowMockLocations ?? _allowMockLocations;

    return this;
  }

  /// Start [PolyGeofenceService].
  /// It can be initialized with [polyGeofenceList].
  Future<void> start([List<PolyGeofence>? polyGeofenceList]) async {
    if (_isRunningService) return Future.error(ErrorCodes.ALREADY_STARTED);

    await _checkPermissions();
    await _listenStream();

    if (polyGeofenceList != null) _polyGeofenceList.addAll(polyGeofenceList);

    _isRunningService = true;
    if (!kReleaseMode) dev.log('PolyGeofenceService started.');
  }

  /// Stop [PolyGeofenceService].
  Future<void> stop() async {
    await _cancelStream();

    _polyGeofenceList.clear();

    _isRunningService = false;
    if (!kReleaseMode) dev.log('PolyGeofenceService stopped.');
  }

  /// Pause [PolyGeofenceService].
  void pause() {
    _positionStream?.pause();
    // if (!kReleaseMode) dev.log('PolyGeofenceService paused.');
  }

  /// Resume [PolyGeofenceService].
  void resume() {
    _positionStream?.resume();
    // if (!kReleaseMode) dev.log('PolyGeofenceService resumed.');
  }

  /// Register a closure to be called when the [PolyGeofenceStatus] changes.
  void addPolyGeofenceStatusChangedListener(
      PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangedListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [PolyGeofenceStatus] changes.
  void removePolyGeofenceStatusChangedListener(
      PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangedListeners.remove(listener);
  }

  /// Register a closure to be called when a stream error occurs.
  void addStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when a stream error occurs.
  void removeStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.remove(listener);
  }

  /// Add polygon geofence.
  void addPolyGeofence(PolyGeofence polyGeofence) {
    _polyGeofenceList.add(polyGeofence);
  }

  /// Add polygon geofence list.
  void addPolyGeofenceList(List<PolyGeofence> polyGeofenceList) {
    _polyGeofenceList.addAll(polyGeofenceList);
  }

  /// Remove polygon geofence.
  void removePolyGeofence(PolyGeofence polyGeofence) {
    _polyGeofenceList.remove(polyGeofence);
  }

  /// Remove polygon geofence list.
  void removePolyGeofenceList(List<PolyGeofence> polyGeofenceList) {
    for (int i = 0; i < polyGeofenceList.length; i++)
      removePolyGeofence(polyGeofenceList[i]);
  }

  /// Remove polygon geofence by [id].
  void removePolyGeofenceById(String id) {
    _polyGeofenceList.removeWhere((polyGeofence) => polyGeofence.id == id);
  }

  /// Clear polygon geofence list.
  void clearPolyGeofenceList() {
    _polyGeofenceList.clear();
  }

  Future<void> _checkPermissions() async {
    // Check that the location service is enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      return Future.error(ErrorCodes.LOCATION_SERVICE_DISABLED);

    // Check whether to allow location permission.
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever)
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission != LocationPermission.whileInUse &&
          locationPermission != LocationPermission.always)
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.best,
            intervalDuration: Duration(milliseconds: _interval))
        .handleError(_handleStreamError)
        .listen(_onPositionReceive);
  }

  Future<void> _cancelStream() async {
    await _positionStream?.cancel();
    _positionStream = null;
  }

  void _onPositionReceive(Position position) async {
    if (!_allowMockLocations && position.isMocked) return;
    if (position.accuracy > _accuracy) return;

    // Pause the service and process the position.
    pause();

    PolyGeofence polyGeofence;
    PolyGeofenceStatus polyGeofenceStatus;
    final currTimestamp = position.timestamp ?? DateTime.now();
    DateTime? polyTimestamp;
    Duration diffTimestamp;
    for (int i = 0; i < _polyGeofenceList.length; i++) {
      polyGeofence = _polyGeofenceList[i];

      polyTimestamp = polyGeofence.timestamp;
      diffTimestamp = currTimestamp.difference(polyTimestamp ?? currTimestamp);

      if (PolyUtils.containsLocation(
          position.latitude, position.longitude, polyGeofence.polygon)) {
        polyGeofenceStatus = PolyGeofenceStatus.ENTER;

        if ((diffTimestamp.inMilliseconds > _loiteringDelayMs
            && polyGeofence.status == PolyGeofenceStatus.ENTER)
            || polyGeofence.status == PolyGeofenceStatus.DWELL) {
          polyGeofenceStatus = PolyGeofenceStatus.DWELL;
        }
      } else {
        polyGeofenceStatus = PolyGeofenceStatus.EXIT;
      }

      if (polyTimestamp != null
          && diffTimestamp.inMilliseconds < _statusChangeDelayMs) continue;
      if (!polyGeofence.updateStatus(polyGeofenceStatus, position)) continue;

      for (final listener in _polyGeofenceStatusChangedListeners)
        await listener(polyGeofence, polyGeofenceStatus, position)
            .catchError(_handleStreamError);
    }

    // Service resumes when position processing is complete.
    resume();
  }

  void _handleStreamError(dynamic error) {
    for (final listener in _streamErrorListeners) listener(error);
  }
}
