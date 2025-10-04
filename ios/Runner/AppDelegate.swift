import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle Universal Links and forward to Flutter via a MethodChannel
  override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "deep_link_channel", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("onNewLink", arguments: url.absoluteString)
      }
      return true
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // Provide initial link if app launched from a URL
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "deep_link_channel", binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("getInitialLink", arguments: url.absoluteString)
    }
    return super.application(app, open: url, options: options)
  }
}
