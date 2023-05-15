import UIKit
import Flutter
// TODOO
import GoogleMaps 

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // TODOO
    GMSServices.provideAPIKey("ADD_YOUR_GOOGLE_MAP_API_KEY")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
