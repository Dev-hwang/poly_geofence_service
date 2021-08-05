import Flutter
import UIKit

public class SwiftPolyGeofenceServicePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftPolyGeofenceServicePlugin()
    instance.initServices()
    instance.initChannels(registrar.messenger())
  }

  private func initServices() {
    // initServices
  }

  private func initChannels(_ messenger: FlutterBinaryMessenger) {
    // initChannels
  }
}
