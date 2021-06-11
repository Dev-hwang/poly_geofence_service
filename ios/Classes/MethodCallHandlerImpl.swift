//
//  MethodCallHandlerImpl.swift
//  poly_geofence_service
//
//  Created by WOO JIN HWANG on 2021/06/11.
//

import Foundation

class MethodCallHandlerImpl {
  private let methodChannel: FlutterMethodChannel
  
  init(messenger: FlutterBinaryMessenger) {
    self.methodChannel = FlutterMethodChannel(
      name: "poly_geofence_service/method", binaryMessenger: messenger)
    self.methodChannel.setMethodCallHandler(methodCallHandler)
  }
  
  private func methodCallHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
