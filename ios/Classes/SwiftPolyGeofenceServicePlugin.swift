import Flutter
import UIKit

public class SwiftPolyGeofenceServicePlugin: NSObject, FlutterPlugin {
  private var methodCallHandler: MethodCallHandlerImpl? = nil
  private var locationServiceStatusStreamHandler: LocationServiceStatusStreamHandlerImpl? = nil
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftPolyGeofenceServicePlugin()
    instance.setupChannels(registrar.messenger())
  }

  private func setupChannels(_ messenger: FlutterBinaryMessenger) {
    methodCallHandler = MethodCallHandlerImpl(messenger: messenger)
    locationServiceStatusStreamHandler = LocationServiceStatusStreamHandlerImpl(messenger: messenger)
  }
}
