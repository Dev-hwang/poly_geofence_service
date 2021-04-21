#import "PolyGeofenceServicePlugin.h"
#if __has_include(<poly_geofence_service/poly_geofence_service-Swift.h>)
#import <poly_geofence_service/poly_geofence_service-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "poly_geofence_service-Swift.h"
#endif

@implementation PolyGeofenceServicePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPolyGeofenceServicePlugin registerWithRegistrar:registrar];
}
@end
