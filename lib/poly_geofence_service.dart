import 'dart:async';
import 'dart:developer' as dev;

import 'package:fl_location/fl_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poly_geofence_service/errors/error_codes.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/models/poly_geofence_service_options.dart';
import 'package:poly_geofence_service/models/poly_geofence_status.dart';
import 'package:poly_geofence_service/utils/poly_utils.dart';

export 'package:fl_location/fl_location.dart';
export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:poly_geofence_service/errors/error_codes.dart';
export 'package:poly_geofence_service/models/lat_lng.dart';
export 'package:poly_geofence_service/models/poly_geofence.dart';
export 'package:poly_geofence_service/models/poly_geofence_service_options.dart';
export 'package:poly_geofence_service/models/poly_geofence_status.dart';
export 'package:poly_geofence_service/utils/poly_utils.dart';

/// Callback function to handle polygon geofence status changes.
typedef PolyGeofenceStatusChanged = Future<void> Function(
    PolyGeofence polyGeofence,
    PolyGeofenceStatus polyGeofenceStatus,
    Location location);

/// Callback function to handle location changes.
typedef LocationChanged = void Function(Location location);

/// A class provides polygon geofence management and geo-fencing.
class PolyGeofenceService {
  PolyGeofenceService._internal();

  /// Instance of [PolyGeofenceService].
  static final instance = PolyGeofenceService._internal();

  /// Whether the service is running.
  bool _isRunningService = false;

  /// Returns whether the service is running.
  bool get isRunningService => _isRunningService;

  final PolyGeofenceServiceOptions _options = PolyGeofenceServiceOptions();

  StreamSubscription<Location>? _locationSubscription;
  StreamSubscription<bool>? _locationServicesStatusSubscription;

  final _polyGeofenceList = <PolyGeofence>[];
  final _polyGeofenceStatusChangeListeners = <PolyGeofenceStatusChanged>[];
  final _locationChangeListeners = <LocationChanged>[];
  final _locationServicesStatusChangeListeners = <ValueChanged<bool>>[];
  final _streamErrorListeners = <ValueChanged>[];

  /// Setup [PolyGeofenceService].
  /// Some options do not change while the service is running.
  PolyGeofenceService setup(
      {int? interval,
      int? accuracy,
      int? loiteringDelayMs,
      int? statusChangeDelayMs,
      bool? allowMockLocations,
      bool? printDevLog}) {
    _options.interval = interval;
    _options.accuracy = accuracy;
    _options.loiteringDelayMs = loiteringDelayMs;
    _options.statusChangeDelayMs = statusChangeDelayMs;
    _options.allowMockLocations = allowMockLocations;
    _options.printDevLog = printDevLog;

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
    _printDevLog('PolyGeofenceService started.');
  }

  /// Stop [PolyGeofenceService].
  /// Note that the registered geofence list is cleared when this function is called.
  Future<void> stop() async {
    await _cancelStream();

    _polyGeofenceList.clear();

    _isRunningService = false;
    _printDevLog('PolyGeofenceService stopped.');
  }

  /// Pause [PolyGeofenceService].
  void pause() {
    _locationSubscription?.pause();
    _printDevLog('PolyGeofenceService paused.');
  }

  /// Resume [PolyGeofenceService].
  void resume() {
    _locationSubscription?.resume();
    _printDevLog('PolyGeofenceService resumed.');
  }

  /// Register a closure to be called when the [PolyGeofenceStatus] changes.
  void addPolyGeofenceStatusChangeListener(PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangeListeners.add(listener);
    _printDevLog(
        'Added PolyGeofenceStatusChange listener. (size: ${_polyGeofenceStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [PolyGeofenceStatus] changes.
  void removePolyGeofenceStatusChangeListener(
      PolyGeofenceStatusChanged listener) {
    _polyGeofenceStatusChangeListeners.remove(listener);
    _printDevLog(
        'The PolyGeofenceStatusChange listener has been removed. (size: ${_polyGeofenceStatusChangeListeners.length})');
  }

  /// Register a closure to be called when the [Location] changes.
  void addLocationChangeListener(LocationChanged listener) {
    _locationChangeListeners.add(listener);
    _printDevLog(
        'Added LocationChange listener. (size: ${_locationChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [Location] changes.
  void removeLocationChangeListener(LocationChanged listener) {
    _locationChangeListeners.remove(listener);
    _printDevLog(
        'The LocationChange listener has been removed. (size: ${_locationChangeListeners.length})');
  }

  /// Register a closure to be called when the location services status changes.
  void addLocationServicesStatusChangeListener(ValueChanged<bool> listener) {
    _locationServicesStatusChangeListeners.add(listener);
    _printDevLog(
        'Added LocationServicesStatusChange listener. (size: ${_locationServicesStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the location services status changes.
  void removeLocationServicesStatusChangeListener(ValueChanged<bool> listener) {
    _locationServicesStatusChangeListeners.remove(listener);
    _printDevLog(
        'The LocationServicesStatusChange listener has been removed. (size: ${_locationServicesStatusChangeListeners.length})');
  }

  /// Register a closure to be called when a stream error occurs.
  void addStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.add(listener);
    _printDevLog(
        'Added StreamError listener. (size: ${_streamErrorListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when a stream error occurs.
  void removeStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.remove(listener);
    _printDevLog(
        'The StreamError listener has been removed. (size: ${_streamErrorListeners.length})');
  }

  /// Clears all listeners registered with the service.
  void clearAllListeners() {
    _polyGeofenceStatusChangeListeners.clear();
    _locationChangeListeners.clear();
    _locationServicesStatusChangeListeners.clear();
    _streamErrorListeners.clear();
  }

  /// Add polygon geofence.
  void addPolyGeofence(PolyGeofence polyGeofence) {
    _polyGeofenceList.add(polyGeofence);
    _printDevLog(
        'Added PolyGeofence(${polyGeofence.id}) (size: ${_polyGeofenceList.length})');
  }

  /// Add polygon geofence list.
  void addPolyGeofenceList(List<PolyGeofence> polyGeofenceList) {
    for (var i = 0; i < polyGeofenceList.length; i++)
      addPolyGeofence(polyGeofenceList[i]);
  }

  /// Remove polygon geofence.
  void removePolyGeofence(PolyGeofence polyGeofence) {
    _polyGeofenceList.remove(polyGeofence);
    _printDevLog(
        'The PolyGeofence(${polyGeofence.id}) has been removed. (size: ${_polyGeofenceList.length})');
  }

  /// Remove polygon geofence list.
  void removePolyGeofenceList(List<PolyGeofence> polyGeofenceList) {
    for (var i = 0; i < polyGeofenceList.length; i++)
      removePolyGeofence(polyGeofenceList[i]);
  }

  /// Remove polygon geofence by [id].
  void removePolyGeofenceById(String id) {
    _polyGeofenceList.removeWhere((polyGeofence) => polyGeofence.id == id);
    _printDevLog(
        'The PolyGeofence($id) has been removed. (size: ${_polyGeofenceList.length})');
  }

  /// Clear polygon geofence list.
  void clearPolyGeofenceList() {
    _polyGeofenceList.clear();
    _printDevLog('The PolyGeofenceList has been cleared.');
  }

  Future<void> _checkPermissions() async {
    // Check whether location services are enabled.
    if (!await FlLocation.isLocationServicesEnabled)
      return Future.error(ErrorCodes.LOCATION_SERVICES_DISABLED);

    // Check whether to allow location permission.
    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever)
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _locationSubscription = FlLocation.getLocationStream(
      accuracy: LocationAccuracy.navigation,
      interval: _options.interval,
    ).handleError(_handleStreamError).listen(_onLocationReceive);

    _locationServicesStatusSubscription =
        FlLocation.getLocationServicesStatusStream()
            .map((event) => event == LocationServicesStatus.enabled)
            .listen(_onLocationServicesStatusChange);
  }

  Future<void> _cancelStream() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    await _locationServicesStatusSubscription?.cancel();
    _locationServicesStatusSubscription = null;
  }

  void _onLocationReceive(Location location) async {
    if (location.isMock && !_options.allowMockLocations) return;
    if (location.accuracy > _options.accuracy) return;

    for (final listener in _locationChangeListeners) listener(location);

    // Pause the service and process the location.
    _locationSubscription?.pause();

    PolyGeofence polyGeofence;
    PolyGeofenceStatus polyGeofenceStatus;

    final currTimestamp = location.timestamp;
    DateTime? polyTimestamp;
    Duration diffTimestamp;
    bool containsLocation;

    for (var i = 0; i < _polyGeofenceList.length; i++) {
      polyGeofence = _polyGeofenceList[i];

      polyTimestamp = polyGeofence.timestamp;
      diffTimestamp = currTimestamp.difference(polyTimestamp ?? currTimestamp);

      containsLocation = PolyUtils.containsLocation(
          location.latitude, location.longitude, polyGeofence.polygon);

      if (containsLocation) {
        polyGeofenceStatus = PolyGeofenceStatus.ENTER;

        if ((diffTimestamp.inMilliseconds > _options.loiteringDelayMs &&
                polyGeofence.status == PolyGeofenceStatus.ENTER) ||
            polyGeofence.status == PolyGeofenceStatus.DWELL) {
          polyGeofenceStatus = PolyGeofenceStatus.DWELL;
        }
      } else {
        polyGeofenceStatus = PolyGeofenceStatus.EXIT;
      }

      if (polyGeofenceStatus != PolyGeofenceStatus.DWELL &&
          polyTimestamp != null &&
          diffTimestamp.inMilliseconds < _options.statusChangeDelayMs) continue;
      if (!polyGeofence.updateStatus(polyGeofenceStatus, currTimestamp))
        continue;

      for (final listener in _polyGeofenceStatusChangeListeners)
        await listener(polyGeofence, polyGeofenceStatus, location)
            .catchError(_handleStreamError);
    }

    // Service resumes when the location processing is complete.
    _locationSubscription?.resume();
  }

  void _onLocationServicesStatusChange(bool status) {
    for (final listener in _locationServicesStatusChangeListeners)
      listener(status);
  }

  void _handleStreamError(dynamic error) {
    for (final listener in _streamErrorListeners) listener(error);
  }

  void _printDevLog(String message) {
    if (kReleaseMode) return;
    if (!_options.printDevLog) return;

    final nowDateTime = DateTime.now().toString();
    dev.log('$nowDateTime\t$message');
  }
}
