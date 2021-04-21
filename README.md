This plugin is a service that can perform geo-fencing by creating a polygon geofence. It does not use the Geofence API implemented on the platform. Therefore, battery efficiency cannot be guaranteed. Instead, this plugin can provide more accurate and realtime geo-fencing by navigating your location while your app is alive.

[![pub package](https://img.shields.io/pub/v/poly_geofence_service.svg)](https://pub.dev/packages/poly_geofence_service)

## Features

* Complex geo-fencing can be performed by creating polygon geofence.
* `PolyGeofenceService` can perform geo-fencing in real time and catch errors during operation.
* `PolyGeofenceService` can be operated in the background using `WillStartForegroundTask` widget.
