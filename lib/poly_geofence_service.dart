import 'dart:async';
// import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poly_geofence_service/models/error_codes.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/models/poly_geofence_service_options.dart';
import 'package:poly_geofence_service/models/poly_geofence_status.dart';
import 'package:poly_geofence_service/utils/poly_utils.dart';

export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:geolocator/geolocator.dart';
export 'package:poly_geofence_service/models/error_codes.dart';
export 'package:poly_geofence_service/models/lat_lng.dart';
export 'package:poly_geofence_service/models/poly_geofence.dart';
export 'package:poly_geofence_service/models/poly_geofence_service_options.dart';
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

  final _options = PolyGeofenceServiceOptions();

  final _locationServiceStatusChangeEventChannel =
      const EventChannel('poly_geofence_service/location_service_status');

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<bool>? _locationServiceStatusStream;

  final _polyGeofenceList = <PolyGeofence>[];
  final _polyGeofenceStatusChangeListeners = <PolyGeofenceStatusChanged>[];
  final _positionChangeListeners = <ValueChanged<Position>>[];
  final _locationServiceStatusChangeListeners = <ValueChanged<bool>>[];
  final _streamErrorListeners = <ValueChanged>[];

  /// Setup [PolyGeofenceService].
  /// Some options do not change while the service is running.
  PolyGeofenceService setup(
      {int? interval,
      int? accuracy,
      int? loiteringDelayMs,
      int? statusChangeDelayMs,
      bool? allowMockLocations}) {
    _options.interval = interval;
    _options.accuracy = accuracy;
    _options.loiteringDelayMs = loiteringDelayMs;
    _options.statusChangeDelayMs = statusChangeDelayMs;
    _options.allowMockLocations = allowMockLocations;

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
    // if (!kReleaseMode) dev.log('PolyGeofenceService started.');
  }

  /// Stop [PolyGeofenceService].
  Future<void> stop() async {
    await _cancelStream();

    _polyGeofenceList.clear();

    _isRunningService = false;
    // if (!kReleaseMode) dev.log('PolyGeofenceService stopped.');
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
  void addPolyGeofenceStatusChangeListener(
      PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangeListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [PolyGeofenceStatus] changes.
  void removePolyGeofenceStatusChangeListener(
      PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangeListeners.remove(listener);
  }

  /// Register a closure to be called when the [Position] changes.
  void addPositionChangeListener(ValueChanged<Position> listener) {
    _positionChangeListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [Position] changes.
  void removePositionChangeListener(ValueChanged<Position> listener) {
    _positionChangeListeners.remove(listener);
  }

  /// Register a closure to be called when the location service status changes.
  void addLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the location service status changes.
  void removeLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.remove(listener);
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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
            intervalDuration: Duration(milliseconds: _options.interval))
        .handleError(_handleStreamError)
        .listen(_onPositionReceive);

    _locationServiceStatusStream = _locationServiceStatusChangeEventChannel
        .receiveBroadcastStream()
        .map((event) => event == true)
        .listen(_onLocationServiceStatusChange);
  }

  Future<void> _cancelStream() async {
    await _positionStream?.cancel();
    _positionStream = null;

    await _locationServiceStatusStream?.cancel();
    _locationServiceStatusStream = null;
  }

  void _onPositionReceive(Position position) async {
    if (position.isMocked && !_options.allowMockLocations) return;
    if (position.accuracy > _options.accuracy) return;

    for (final listener in _positionChangeListeners) listener(position);

    // Pause the service and process the position.
    _positionStream?.pause();

    PolyGeofence polyGeofence;
    PolyGeofenceStatus polyGeofenceStatus;
    final currTimestamp = position.timestamp ?? DateTime.now();
    DateTime? polyTimestamp;
    Duration diffTimestamp;
    for (var i = 0; i < _polyGeofenceList.length; i++) {
      polyGeofence = _polyGeofenceList[i];

      polyTimestamp = polyGeofence.timestamp;
      diffTimestamp = currTimestamp.difference(polyTimestamp ?? currTimestamp);

      if (PolyUtils.containsLocation(
          position.latitude, position.longitude, polyGeofence.polygon)) {
        polyGeofenceStatus = PolyGeofenceStatus.ENTER;

        if ((diffTimestamp.inMilliseconds > _options.loiteringDelayMs &&
                polyGeofence.status == PolyGeofenceStatus.ENTER) ||
            polyGeofence.status == PolyGeofenceStatus.DWELL) {
          polyGeofenceStatus = PolyGeofenceStatus.DWELL;
        }
      } else {
        polyGeofenceStatus = PolyGeofenceStatus.EXIT;
      }

      if (polyTimestamp != null &&
          diffTimestamp.inMilliseconds < _options.statusChangeDelayMs) continue;
      if (!polyGeofence.updateStatus(polyGeofenceStatus, position)) continue;

      for (final listener in _polyGeofenceStatusChangeListeners)
        await listener(polyGeofence, polyGeofenceStatus, position)
            .catchError(_handleStreamError);
    }

    // Service resumes when position processing is complete.
    _positionStream?.resume();
  }

  void _onLocationServiceStatusChange(bool status) {
    for (final listener in _locationServiceStatusChangeListeners)
      listener(status);
  }

  void _handleStreamError(error) {
    for (final listener in _streamErrorListeners) listener(error);
  }
}
