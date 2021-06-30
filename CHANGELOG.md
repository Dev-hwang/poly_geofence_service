## 1.2.3

* Upgrade geolocator: ^7.2.0+1

## 1.2.2

* Upgrade geolocator: ^7.1.1
* Upgrade flutter_foreground_task: ^2.0.0

## 1.2.1

* Update example
* Update README.md

## 1.2.0

* Upgrade geolocator: ^7.1.0
* Add `printDevLog` option.
* Rename the listener function.
```text
// addPolyGeofenceStatusChangedListener(_onPolyGeofenceStatusChanged);
// addPositionChangedListener(_onPositionChanged);
// addLocationServiceStatusChangedListener(_onLocationServiceStatusChanged);
// removePolyGeofenceStatusChangedListener(_onPolyGeofenceStatusChanged);
// removePositionChangedListener(_onPositionChanged);
// removeLocationServiceStatusChangedListener(_onLocationServiceStatusChanged);

addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
addPositionChangeListener(_onPositionChanged);
addLocationServiceStatusChangeListener(_onLocationServiceStatusChanged);
removePolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
removePositionChangeListener(_onPositionChanged);
removeLocationServiceStatusChangeListener(_onLocationServiceStatusChanged);
```

## 1.1.0

* Add `addPositionChangedListener` function.
* Add `removePositionChangedListener` function.
* Add `addLocationServiceStatusChangedListener` function.
* Add `removeLocationServiceStatusChangedListener` function.
> A service has been added to check the location service status change while the geofence service is running. 
You need to add the code below to your android manifest file. See the Getting started section of the readme for details.
```xml
<service
    android:name="com.pravera.poly_geofence_service.service.LocationProviderIntentService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:stopWithTask="true" />
```
* Change the model's `toMap` function name to `toJson`.
* Update example
* Update README.md

## 1.0.3

* Upgrade flutter_foreground_task: ^1.0.8

## 1.0.2

* Fix an issue where PolyGeofence toMap function did not work properly.

## 1.0.1

* Updates README.md
* Upgrade flutter_foreground_task: ^1.0.7
* Add `statusChangeDelayMs` option.

## 1.0.0

* Initial release.
