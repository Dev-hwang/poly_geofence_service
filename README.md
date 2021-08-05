This plugin is a service that can perform geo-fencing by creating a polygon geofence. It does not use the Geofence API implemented on the platform. Therefore, battery efficiency cannot be guaranteed. Instead, this plugin can provide more accurate and realtime geo-fencing by navigating your location while your app is alive.

[![pub package](https://img.shields.io/pub/v/poly_geofence_service.svg)](https://pub.dev/packages/poly_geofence_service)

## Screenshots
| Google Maps | Result |
|---|---|
| <img src="https://user-images.githubusercontent.com/47127353/115559838-07ff7e00-a2ef-11eb-9495-e78093d591de.png" width="216"> | <img src="https://user-images.githubusercontent.com/47127353/115560180-4e54dd00-a2ef-11eb-8d7b-2d73630512b6.png" width="216"> |

## Features

* Complex geo-fencing can be performed by creating polygon geofence.
* `PolyGeofenceService` can perform geo-fencing in real time and catch errors during operation.
* `PolyGeofenceService` can be operated in the background using `WillStartForegroundTask` widget.

## Getting started

To use this plugin, add `poly_geofence_service` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  poly_geofence_service: ^1.3.1
```

After adding the `poly_geofence_service` plugin to the flutter project, we need to specify the platform-specific permissions and services to use for this plugin to work properly.

### :baby_chick: Android

Since geo-fencing operates based on location, we need to add the following permission to the `AndroidManifest.xml` file. Open the `AndroidManifest.xml` file and specify it between the `<manifest>` and `<application>` tags.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

If you want to run the service in the background, add the following permission. If your project supports Android 10, be sure to add the `ACCESS_BACKGROUND_LOCATION` permission.

```
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

And specify the service inside the `<application>` tag as follows.

```
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:stopWithTask="true" />
```

### :baby_chick: iOS

Like Android platform, geo-fencing is based on location, we need to add the following description. Open the `ios/Runner/Info.plist` file and specify it inside the `<dict>` tag.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to provide geofence service.</string>
```

If you want to run the service in the background, add the following description.

```
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Used to provide geofence services in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Used to provide geofence services in the background.</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```

## How to use

1. Create a `PolyGeofenceService` instance and set options. `PolyGeofenceService.instance.setup()` provides the following options:
* `interval`: The time interval in milliseconds to check the polygon geofence status. The default is `5000`.
* `accuracy`: Geo-fencing error range in meters. The default is `100`.
* `loiteringDelayMs`: Sets the delay between `PolyGeofenceStatus.ENTER` and `PolyGeofenceStatus.DWELL` in milliseconds. The default is `300000`.
* `statusChangeDelayMs`: Sets the status change delay in milliseconds. `PolyGeofenceStatus.ENTER` and `PolyGeofenceStatus.EXIT` events may be called frequently when the location is near the boundary of the polygon geofence. Use this option to minimize event calls at this time. If the option value is too large, realtime geo-fencing is not possible, so use it carefully. The default is `10000`.
* `allowMockLocations`: Whether to allow mock locations. The default is `false`.
* `printDevLog`: Whether to show the developer log. If this value is set to true, logs for geofence service activities (start, stop, etc.) can be viewed. It does not work in release mode. The default is `false`.

```dart
// Create a [PolyGeofenceService] instance and set options.
final _polyGeofenceService = PolyGeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    allowMockLocations: false,
    printDevLog: false);
```

2. Create a `PolyGeofence` list. `PolyGeofence` provides the following parameters:
* `id`: Identifier for `PolyGeofence`.
* `data`: Custom data for `PolyGeofence`.
* `polygon`: A list of coordinates to create a polygon. The polygon is always considered closed, regardless of whether the last point equals the first or not.

```dart
// Create a [PolyGeofence] list.
final _polyGeofenceList = <PolyGeofence>[
  PolyGeofence(
    id: 'Yongdusan_Park',
    data: {
      'address': '37-55 Yongdusan-gil, Gwangbokdong 2(i)-ga, Jung-gu, Busan',
      'about': 'Mountain park known for its 129m-high observation tower, statues & stone monuments.',
    },
    polygon: <LatLng>[
      const LatLng(35.101727, 129.031665),
      const LatLng(35.101815, 129.033458),
      const LatLng(35.100032, 129.034055),
      const LatLng(35.099324, 129.033811),
      const LatLng(35.099906, 129.031927),
      const LatLng(35.101080, 129.031534),
    ],
  ),
];
```

3. Register the listener and call `PolyGeofenceService.instance.start()`.

```dart
// This function is to be called when the geofence status is changed.
Future<void> _onPolyGeofenceStatusChanged(
    PolyGeofence polyGeofence,
    PolyGeofenceStatus polyGeofenceStatus,
    Location location) async {
  print('polyGeofence: ${polyGeofence.toJson()}');
  print('polyGeofenceStatus: ${polyGeofenceStatus.toString()}');
}

// This function is to be called when the location has changed.
void _onLocationChanged(Location location) {
  print('location: ${location.toJson()}');
}

// This function is to be called when a location services status change occurs
// since the service was started.
void _onLocationServicesStatusChanged(bool status) {
  print('isLocationServicesEnabled: $status');
}

// This function is used to handle errors that occur in the service.
void _onError(error) {
  final errorCode = getErrorCodesFromError(error);
  if (errorCode == null) {
    print('Undefined error: $error');
    return;
  }

  print('ErrorCode: $errorCode');
}

@override
void initState() {
  super.initState();
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    _polyGeofenceService.addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
    _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
    _polyGeofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _polyGeofenceService.addStreamErrorListener(_onError);
    _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
  });
}
```

4. Add `WillStartForegroundTask` widget for background execution on Android platform. `WillStartForegroundTask` provides the following options:
* `onWillStart`: Called to ask if you want to start the foreground task.
* `notificationOptions`: Optional values for notification detail settings.
* `notificationTitle`: The title that will be displayed in the notification.
* `notificationText`: The text that will be displayed in the notification.
* `child`: A child widget that contains the `Scaffold` widget.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // A widget used when you want to start a foreground task when trying to minimize or close the app.
    // Declare on top of the [Scaffold] widget.
    home: WillStartForegroundTask(
      onWillStart: () {
        // You can add a foreground task start condition.
        return _polyGeofenceService.isRunningService;
      },
      notificationOptions: NotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription: 'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      notificationTitle: 'Geofence Service is running',
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Poly Geofence Service'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    ),
  );
}
```

5. To add or remove `PolyGeofence` while the service is running, use the following function:

```text
_polyGeofenceService.addPolyGeofence(Object);
_polyGeofenceService.addPolyGeofenceList(List);
_polyGeofenceService.removePolyGeofence(Object);
_polyGeofenceService.removePolyGeofenceList(List);
_polyGeofenceService.removePolyGeofenceById(String);
_polyGeofenceService.clearPolyGeofenceList();
```

6. If you want to pause or resume the service, use the function below.

```text
_polyGeofenceService.pause();
_polyGeofenceService.resume();
```

7. When you are finished using the service, unregister the listener and call `PolyGeofenceService.instance.stop()`.

```text
_polyGeofenceService.removePolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
_polyGeofenceService.removeLocationChangeListener(_onLocationChanged);
_polyGeofenceService.removeLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
_polyGeofenceService.removeStreamErrorListener(_onError);
_polyGeofenceService.stop();
```

**Note**: When calling the stop function, the listener is not removed, but the added geofence is cleared.

## Models

### :chicken: LatLng

A model representing the latitude and longitude of GPS.

| Property | Description |
|---|---|
| `latitude` | The latitude of GPS. |
| `longitude` | The longitude of GPS. |

### :chicken: PolyGeofence

A model representing a polygon geofence.

| Property | Description |
|---|---|
| `id` | Identifier for `PolyGeofence`. |
| `data` | Custom data for `PolyGeofence`. |
| `polygon` | A list of coordinates to create a polygon. The polygon is always considered closed, regardless of whether the last point equals the first or not. |
| `status` | The status of `PolyGeofence`. |
| `timestamp` | The timestamp when polygon geofence status changes. |

### :chicken: PolyGeofenceStatus

Defines the status of the polygon geofence.

| Value | Description |
|---|---|
| `ENTER` | Occurs when entering the geofence area. |
| `EXIT` | Occurs when exiting the geofence area. |
| `DWELL` | Occurs when the loitering delay elapses after entering the geofence area. |

### :chicken: ErrorCodes

Error codes that may occur in the service.

| Value | Description |
|---|---|
| `ALREADY_STARTED` | Occurs when the service has already been started but the start function is called. |
| `LOCATION_SERVICES_DISABLED` | Occurs when location services are disabled. When this error occurs, you should notify the user and request activation. |
| `LOCATION_PERMISSION_DENIED` | Occurs when location permission is denied. |
| `LOCATION_PERMISSION_PERMANENTLY_DENIED` | Occurs when location permission is permanently denied. In this case, the user must manually allow the permission. |

## Support

If you find any bugs or issues while using the plugin, please register an issues on [GitHub](https://github.com/Dev-hwang/poly_geofence_service/issues). You can also contact us at <hwj930513@naver.com>.
