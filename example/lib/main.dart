import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _polyGeofenceStreamController = StreamController<PolyGeofence>();

  // Create a [PolyGeofenceService] instance and set options.
  final _polyGeofenceService = PolyGeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    allowMockLocations: false
  );

  // Create a [PolyGeofence] list.
  final _polyGeofenceList = <PolyGeofence>[
    PolyGeofence(
      id: 'Yongdusan_Park',
      data: {
        'address': '37-55 Yongdusan-gil, Gwangbokdong 2(i)-ga, Jung-gu, Busan',
        'about': 'Mountain park known for its 129m-high observation tower, statues & stone monuments.'
      },
      polygon: <LatLng>[
        LatLng(35.101727, 129.031665),
        LatLng(35.101815, 129.033458),
        LatLng(35.100032, 129.034055),
        LatLng(35.099324, 129.033811),
        LatLng(35.099906, 129.031927),
        LatLng(35.101080, 129.031534)
      ]
    )
  ];

  Future<void> _onPolyGeofenceStatusChanged(
      PolyGeofence polyGeofence,
      PolyGeofenceStatus polyGeofenceStatus,
      Position position) async {
    dev.log('id: ${polyGeofence.id}');
    dev.log('data: ${polyGeofence.data as Map}');
    dev.log('status: $polyGeofenceStatus');
    dev.log('timestamp: ${polyGeofence.timestamp}');
    dev.log('passing position: ${position.toJson()}');
    _polyGeofenceStreamController.sink.add(polyGeofence);
  }

  void _onPositionChanged(Position position) {
    dev.log('position: ${position.toJson()}');
  }

  void _onError(dynamic error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      dev.log('Undefined error: $error');
      return;
    }

    dev.log('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _polyGeofenceService.addPolyGeofenceStatusChangedListener(_onPolyGeofenceStatusChanged);
      _polyGeofenceService.addPositionChangedListener(_onPositionChanged);
      _polyGeofenceService.addStreamErrorListener(_onError);
      _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
    });
  }

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
          priority: NotificationPriority.LOW
        ),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Poly Geofence Service'),
            centerTitle: true
          ),
          body: _buildContentView()
        ),
      ),
    );
  }

  @override
  void dispose() {
    _polyGeofenceStreamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return StreamBuilder<PolyGeofence>(
      stream: _polyGeofenceStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          children: [
            Text('•\t\tPolyGeofence (updated: $updatedDateTime)'),
            SizedBox(height: 10.0),
            Text(content)
          ]
        );
      }
    );
  }
}
