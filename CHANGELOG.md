## 1.5.7

* Upgrade dependencies.
* [[#42](https://github.com/Dev-hwang/flutter_foreground_task/issues/42)] Only minimize app on pop when there is no route to pop.

## 1.5.6

* [**iOS**] Fixed an issue where notifications not related to the service were removed.
* [**iOS**] Improved compatibility with other plugins that use notifications.
  - Additional settings are required, so please check the Readme-Getting started.

## 1.5.5

* Add process exit code to prevent memory leak. [#16](https://github.com/Dev-hwang/geofence_service/issues/16)

## 1.5.4

* Upgrade dependencies.
* [**Bug**] Fixed an issue where lockMode(wakeLock, wifiLock) was not properly released when the service was forcibly shutdown.
* [**Bug**] Fixed an issue where foreground service notification UX was delayed on Android version 12.

## 1.5.3

* Upgrade dependencies.
* Bump Android minSdkVersion to 23.
* Bump Android compileSdkVersion to 31.

## 1.5.2

* Upgrade flutter_foreground_task: ^3.2.2
* [Bug] Fixed an issue where RemoteServiceException occurred intermittently.

## 1.5.1

* Upgrade flutter_foreground_task: ^3.2.0

## 1.5.0

* Upgrade flutter_foreground_task: ^3.0.0
* Changed parameter name of `WillStartForegroundTask` widget.

## 1.4.2

* Fix errorCodes parsing function not working properly.

## 1.4.1

* Upgrade fl_location: ^1.0.1

## 1.4.0

* Upgrade flutter_foreground_task: ^2.1.0
* [**BREAKING**] Replace plugin from `location` to `fl_location`.
* [**BREAKING**] Replace data model from `LocationData` to `Location`.
* Rename the listener function.
```text
addLocationDataChangeListener -> addLocationChangeListener
addLocationServiceStatusChangeListener -> addLocationServicesStatusChangeListener
removeLocationDataChangeListener -> removeLocationChangeListener
removeLocationServiceStatusChangeListener -> removeLocationServicesStatusChangeListener
```
* Rename the error code.
```text
LOCATION_SERVICE_DISABLED -> LOCATION_SERVICES_DISABLED
```
* Add `clearAllListeners` function.
* Add `foregroundServiceType` to android service tag.
* Fixed DWELL status change being delayed due to statusChangeDelayMs.

## 1.3.1

* Upgrade flutter_foreground_task: ^2.0.4

## 1.3.0

* [**BREAKING**] Replace plugin from `geolocator` to `location`.
* [**BREAKING**] Replace data model from `Position` to `LocationData`.
* Rename the listener function.
```text
addPositionChangeListener -> addLocationDataChangeListener
removePositionChangeListener -> removeLocationDataChangeListener
```
* Fix location permission request not working properly.
* Fix an issue that the location stream is not closed even when the service is stopped.

## 1.2.5

* Move component declaration inside the plugin. Check the readme for more details.
* Upgrade flutter_foreground_task: ^2.0.3

## 1.2.4

* Upgrade flutter_foreground_task: ^2.0.1

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
addPolyGeofenceStatusChangedListener -> addPolyGeofenceStatusChangeListener
addPositionChangedListener -> addPositionChangeListener
addLocationServiceStatusChangedListener -> addLocationServiceStatusChangeListener
removePolyGeofenceStatusChangedListener -> removePolyGeofenceStatusChangeListener
removePositionChangedListener -> removePositionChangeListener
removeLocationServiceStatusChangedListener -> removeLocationServiceStatusChangeListener
```

## 1.1.0

* Add `addPositionChangedListener` function.
* Add `removePositionChangedListener` function.
* Add `addLocationServiceStatusChangedListener` function.
* Add `removeLocationServiceStatusChangedListener` function.
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
