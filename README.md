This plugin is a service that can perform geo-fencing by creating a polygon geofence. It does not use the Geofence API implemented on the platform. Therefore, battery efficiency cannot be guaranteed. Instead, this plugin can provide more accurate and realtime geo-fencing by navigating your location while your app is alive.

[![pub package](https://img.shields.io/pub/v/poly_geofence_service.svg)](https://pub.dev/packages/poly_geofence_service)

## Features

* Complex geo-fencing can be performed by creating polygon geofence.
* `PolyGeofenceService` can perform geo-fencing in real time and catch errors during operation.
* `PolyGeofenceService` can be operated in the background using `WillStartForegroundTask` widget.

## Getting started

To use this plugin, add `poly_geofence_service` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  poly_geofence_service: ^1.0.0
```

After adding the `poly_geofence_service` plugin to the flutter project, we need to specify the platform-specific permissions and services to use for this plugin to work properly.

### :baby_chick: Android

Since geo-fencing operates based on location, we need to add the following permission to the `AndroidManifest.xml` file. Open the `AndroidManifest.xml` file and specify it between the `<manifest>` and `<application>` tags.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

In addition, if you want to run the service in the background, add the following permission. If your project supports Android 10, be sure to add the `ACCESS_BACKGROUND_LOCATION` permission.

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

Like Android platform, geo-fencing is based on location, so you need to specify location permission. Open the `ios/Runner/Info.plist` file and add the following permission inside the `<dict>` tag.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to provide geofence service.</string>
```

If you want to run the service in the background, add the following permissions.

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
