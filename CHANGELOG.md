## 1.1.0

* Add `addPositionChangedListener` function.
* Add `removePositionChangedListener` function.
* Add `addLocationServiceStatusChangedListener` function.
* Add `removeLocationServiceStatusChangedListener` function.
* Change the model's `toMap` function name to `toJson`.
* Update example
* Update README.md
> A service has been added to check the location service status change while the geofence service is running. 
You need to add the code below to your android manifest file. See the Getting started section of the readme for details.
```xml
<service
    android:name="com.pravera.poly_geofence_service.service.LocationProviderIntentService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:stopWithTask="true" />
```

## 1.0.3

* Upgrade flutter_foreground_task: ^1.0.8

## 1.0.2

* Fix an issue where PolyGeofence toMap function did not work properly.

## 1.0.1

* Updates README.md
* Upgrade flutter_foreground_task: ^1.0.7
* Add `statusChangeDelayMs` options.

## 1.0.0

* Initial release.
