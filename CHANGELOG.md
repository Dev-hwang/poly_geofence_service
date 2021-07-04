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
addPolyGeofenceStatusChangedListener -> addPolyGeofenceStatusChangeListener;
addPositionChangedListener -> addPositionChangeListener;
addLocationServiceStatusChangedListener -> addLocationServiceStatusChangeListener;
removePolyGeofenceStatusChangedListener -> removePolyGeofenceStatusChangeListener;
removePositionChangedListener -> removePositionChangeListener;
removeLocationServiceStatusChangedListener -> removeLocationServiceStatusChangeListener;
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
