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
