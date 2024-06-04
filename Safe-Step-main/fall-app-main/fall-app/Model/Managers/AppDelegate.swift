import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

/// Connects to Firebase on app launch
///
/// ### Usage
/// ```
/// struct YourApp: App {
///     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
///     // stuff...
/// }
/// ```
///
/// ### Author & Version
/// Provided by Firebase, as of Apr. 14, 2023.
/// Modified by Seung-Gu Lee, last modified Jul 12, 2023
///
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("App terminating")
        if UserDefaults.standard.bool(forKey: "receiveAppTerminationNotifications") {
            NotificationManager.sendNotificationNow(title: "App Terminated",
                                                    body: "If this wasn't intentional, please reopen the app to continue using the app's features.")
        }
        
    }
}
