import SwiftUI
import UIKit
import CoreLocation

/// View to modify settings of the application.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct SettingsView: View {
    
    /// Minimum time required for walking detection to trigger.
    /// For example, if this is 45, users must walk for at least 45 seconds continuously for recording to begin.
    /// Same thing for automatically ending the recording.
    @AppStorage("walkingDetectionSensitivity")
    var walkingDetectionSensitivity: Int = 45
    
    /// Receive walking detection notifications
    /// Used in`MetaWearManager`.
    @AppStorage("receiveWalkingDetectionNotifications")
    var receiveWalkingDetectionNotifications: Bool = true
    
    @AppStorage("receiveWalkingDetectionNotificationsAllDay")
    var receiveWalkingDetectionNotificationsAllDay: Bool = false
    
    /// Receive error notifications such as "sensor unexpectedly disconnected".
    @AppStorage("receiveErrorNotifications")
    var receiveErrorNotifications: Bool = true
    
    /// Receive notifications when app is terminated
    @AppStorage("receiveAppTerminationNotifications")
    var receiveAppTerminationNotifications: Bool = true
    
    @AppStorage("receiveSensorDisconnectNotificationsRegardless")
    var receiveSensorDisconnectNotificationsRegardless: Bool = false
    
    @AppStorage("enableAutomaticDeviceScanning")
    var enableAutomaticDeviceScanning: Bool = false
    
    @AppStorage("showAllRoutes")
    var showAllRoutes: Bool = false
    
    @AppStorage("testingMode")
    var testingMode: Bool = false
    
    @AppStorage("enableMotionDebugLogs")
    var enableMotionDebugLogs: Bool = false
    
    @AppStorage("userDismissedPitchHintView")
    var userDismissedPitchHintView: Bool = false
    
    /// Some variables for testing purposes.
    @State var test: String = ""
    @State var testBool: Bool = false
    

    var body: some View {
        NavigationView {
            Form {
                // Devices
//                Section(header: Text("MetaWear Sensor"),
//                        footer: Text("When enabled, the app will attempt to automatically connect to a nearby sensor when a sensor is disconnected.")
//                ) {
//                    Toggle(isOn: $enableAutomaticDeviceScanning) {
//                        Text("Automatic Reconnect")
//                    }
//                    Link("Read User Manual",
//                         destination: URL(string: "https://mbientlab.com/tutorials/MetaMotionS.html")!)
//                }
                
                // Walking Detection
                Section(header: Text("Walking Detection"),
                        footer: Text("When enabled, the app will detect your walking and remind you to start/stop the walking session. May increase battery usage.")
                ) {
                    Toggle(isOn: $receiveWalkingDetectionNotifications) {
                        Text("Enable")
                    }
                    .onChange(of: receiveWalkingDetectionNotifications) { value in
                        if value == true {
                            MetaWearManager.locationManager.startRecording()
                        }
                        else {
                            if !MetaWearManager.recording {
                                MetaWearManager.locationManager.stopRecording()
                            }
                        }
                    }
                    
                    if receiveWalkingDetectionNotifications {
                        Picker(selection: $receiveWalkingDetectionNotificationsAllDay, label: Text("Hours")) {
                            Text("8 AM - 6 PM").tag(false)
                            Text("All day").tag(true)
                        }
                        
                        // walking sensitivity
                        Picker(selection: $walkingDetectionSensitivity,
                               label: Text("Sensitivity")) {
                            if testingMode {
                                Text("[T] Instant (0s)").tag(0)
                                Text("[T] Extremely High (5s)").tag(5)
                            }
                            Text("Very High (15s)").tag(15)
                            Text("High (30s)").tag(30)
                            Text("Medium (45s)").tag(45)
                            Text("Low (60s)").tag(60)
                            Text("Very Low (90s)").tag(90)
                        }
                    }
                }
//                
//                // Walking Detection
//                Section(header: Text("Recording"),
//                        footer: Text("Sessions shorter than this will automatically be discarded.")
//                ) {
//                    // walking sensitivity
//                    Picker(selection: $walkingDetectionSensitivity,
//                           label: Text("Minimum Session Length")) {
//                        Text("0s").tag(0)
//                        Text("5s").tag(5)
//                        Text("15s").tag(15)
//                        Text("30s").tag(30)
//                        Text("45s (default)").tag(45)
//                        Text("60s").tag(60)
//                        Text("90s").tag(90)
//                        Text("120s").tag(120)
//                        Text("180s").tag(180)
//                    }
//                }
//                
                // Notifications
                Section(header: Text("Notifications"),
                        footer: Text("Notifications are only sent when the app is in the background.")) {
                    Toggle(isOn: $receiveErrorNotifications) {
                        Text("Error Messages")
                    }
                }
                
                // App Info
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                Section(header: Text("App Info"),
                        footer: Text("Version " + (appVersion ?? "?"))) {
                    NavigationLink("SafeSteps Guide") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/onboarding.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Help & Support") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/guide.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Privacy Policy") {
                        WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/privacy-policy.html"))
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    Button(action: {
                        let email = "umdpmlab@gmail.com"
                        let subject = ""
                        let body = "\n\n---\nPlease do not delete the following information:\n• Device ID: \(Utilities.deviceId())\n• Device: \(Utilities.getDeviceCode()) running iOS \(Utilities.getIosVersion())\n• App: SafeSteps v\(appVersion ?? "?")"
                        guard let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") else { return }
                        UIApplication.shared.open(url)
                    }) {
                        Text("Contact Us")
                    }
                }
                
                // Quit App
                Section(header: Text("Quit"),
                        footer: Text("This will disable walking detection and location tracking until you open the app again.")) {
                    Button("Quit App") {
                        exit(0)
                    }
                }
                
                // Testing Mode
                Section(header: Text("Testing"),
                        footer: Text("For testing and debugging the app. Some features have not yet been tested and may be unstable.")) {
                    Toggle(isOn: $testingMode) {
                        Text("Testing Mode")
                    }
                    // reset values back to "normal"
                    .onChange(of: testingMode) { newValue in
                        if newValue && walkingDetectionSensitivity < 15 {
                            walkingDetectionSensitivity = 15
                        }
                        receiveAppTerminationNotifications = false
                        enableMotionDebugLogs = false
                    }
                    if testingMode {
                        Toggle(isOn: $testingMode) {
                            Text("More walking detection sensitivity options")
                        }
                        .disabled(true)
                        Toggle(isOn: $receiveAppTerminationNotifications) {
                            Text("Received app terminated notifications")
                        }
                        Toggle(isOn: $receiveSensorDisconnectNotificationsRegardless) {
                            Text("Receive Sensor Disconnected Notifications while Autoconnect is enabled")
                        }
                        Toggle(isOn: $enableMotionDebugLogs) {
                            Text("Print walking detection debug logs")
                        }
                        Toggle(isOn: $showAllRoutes) {
                            Text("Show all routes regardless of distance")
                        }
                        NavigationLink(destination: OnboardingView(userOnboarded: $testBool)) {
                            Text("OnboardingView (edit profile)")
                        }
                        NavigationLink(destination: MultiRecordsInfoView()) {
                            HStack {
                                Text("View records from all trips")
                                Image(systemName: "arrow.right")
                                    .imageScale(.small)
                            }
                        }
                        Toggle(isOn: $userDismissedPitchHintView) {
                            Text("Dismiss pitch hint view")
                        }
                        Button("Send test request to server") {
                            testServerCall()
                        }
                        Button("Debug") {
                            debug()
                        }
                    }
                }
            } // form
            .navigationTitle(Text("Settings"))
        }
    } // NavigationView
    
    /// Test server call
    func testServerCall() {
        let url = URL(string: "\(AppConstants.getUrl())/calculate/15")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            test = String(data: data, encoding: .utf8)!
            print(test)
        }

        task.resume()

    }
    
    /// Debugging done here!
    func debug() {
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
