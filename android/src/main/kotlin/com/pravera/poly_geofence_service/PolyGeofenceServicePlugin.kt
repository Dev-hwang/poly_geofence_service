package com.pravera.poly_geofence_service

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** PolyGeofenceServicePlugin */
class PolyGeofenceServicePlugin: FlutterPlugin, ActivityAware {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // onAttachedToEngine
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // onDetachedFromEngine
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    // onAttachedToActivity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    // onDetachedFromActivity
  }
}
