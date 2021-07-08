import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:poly_geofence_service/models/error_codes.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/models/poly_geofence_service_options.dart';
import 'package:poly_geofence_service/models/poly_geofence_status.dart';
import 'package:poly_geofence_service/utils/poly_utils.dart';

export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:location/location.dart';
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
    LocationData locationData);

/// A class provides polygon geofence management and geo-fencing.
class PolyGeofenceService {
  PolyGeofenceService._internal();

  /// Instance of [PolyGeofenceService].
  static final instance = PolyGeofenceService._internal();

  /// Whether the service is running.
  bool _isRunningService = false;

  /// Returns whether the service is running.
  bool get isRunningService => _isRunningService;

  final _location = Location();
  final _options = PolyGeofenceServiceOptions();

  final _locationServiceStatusChangeEventChannel =
      const EventChannel('poly_geofence_service/location_service_status');

  StreamSubscription<LocationData>? _locationDataSubscription;
  StreamSubscription<bool>? _locationServiceStatusSubscription;

  final _polyGeofenceList = <PolyGeofence>[];
  final _polyGeofenceStatusChangeListeners = <PolyGeofenceStatusChanged>[];
  final _locationDataChangeListeners = <ValueChanged<LocationData>>[];
  final _locationServiceStatusChangeListeners = <ValueChanged<bool>>[];
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
    _locationDataSubscription?.pause();
    _printDevLog('PolyGeofenceService paused.');
  }

  /// Resume [PolyGeofenceService].
  void resume() {
    _locationDataSubscription?.resume();
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

  /// Register a closure to be called when the [LocationData] changes.
  void addLocationDataChangeListener(ValueChanged<LocationData> listener) {
    _locationDataChangeListeners.add(listener);
    _printDevLog(
        'Added LocationDataChange listener. (size: ${_locationDataChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [LocationData] changes.
  void removeLocationDataChangeListener(ValueChanged<LocationData> listener) {
    _locationDataChangeListeners.remove(listener);
    _printDevLog(
        'The LocationDataChange listener has been removed. (size: ${_locationDataChangeListeners.length})');
  }

  /// Register a closure to be called when the location service status changes.
  void addLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.add(listener);
    _printDevLog(
        'Added LocationServiceStatusChange listener. (size: ${_locationServiceStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the location service status changes.
  void removeLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.remove(listener);
    _printDevLog(
        'The LocationServiceStatusChange listener has been removed. (size: ${_locationServiceStatusChangeListeners.length})');
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
    // Check that the location service is enabled.
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled)
      return Future.error(ErrorCodes.LOCATION_SERVICE_DISABLED);

    // Check whether to allow location permission.
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);
    } else if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever)
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _location.changeSettings(
        accuracy: LocationAccuracy.navigation, interval: _options.interval);
    _locationDataSubscription = _location.onLocationChanged
        .handleError(_handleStreamError)
        .listen(_onLocationDataReceive);

    _locationServiceStatusSubscription =
        _locationServiceStatusChangeEventChannel
            .receiveBroadcastStream()
            .map((event) => event == true)
            .listen(_onLocationServiceStatusChange);
  }

  Future<void> _cancelStream() async {
    await _locationDataSubscription?.cancel();
    _locationDataSubscription = null;

    await _locationServiceStatusSubscription?.cancel();
    _locationServiceStatusSubscription = null;
  }

  void _onLocationDataReceive(LocationData locationData) async {
    if (locationData.latitude == null || locationData.longitude == null) return;
    if ((locationData.isMock ?? false) && !_options.allowMockLocations) return;
    if ((locationData.accuracy ?? 0.0) > _options.accuracy) return;

    for (final listener in _locationDataChangeListeners) listener(locationData);

    // Pause the service and process the location data.
    _locationDataSubscription?.pause();

    PolyGeofence polyGeofence;
    PolyGeofenceStatus polyGeofenceStatus;
    final currTimestamp = (locationData.time == null)
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(locationData.time!.toInt());
    DateTime? polyTimestamp;
    Duration diffTimestamp;
    bool containsLocation;
    for (var i = 0; i < _polyGeofenceList.length; i++) {
      polyGeofence = _polyGeofenceList[i];

      polyTimestamp = polyGeofence.timestamp;
      diffTimestamp = currTimestamp.difference(polyTimestamp ?? currTimestamp);

      containsLocation = PolyUtils.containsLocation(locationData.latitude!,
          locationData.longitude!, polyGeofence.polygon);

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

      if (polyTimestamp != null &&
          diffTimestamp.inMilliseconds < _options.statusChangeDelayMs) continue;
      if (!polyGeofence.updateStatus(polyGeofenceStatus, currTimestamp))
        continue;

      for (final listener in _polyGeofenceStatusChangeListeners)
        await listener(polyGeofence, polyGeofenceStatus, locationData)
            .catchError(_handleStreamError);
    }

    // Service resumes when the location data processing is complete.
    _locationDataSubscription?.resume();
  }

  void _onLocationServiceStatusChange(bool status) {
    for (final listener in _locationServiceStatusChangeListeners)
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
