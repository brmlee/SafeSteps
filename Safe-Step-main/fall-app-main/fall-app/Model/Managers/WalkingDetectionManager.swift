import Foundation
import CoreMotion

/// Handles all actions related to walking detection.
/// All functions are static.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
class WalkingDetectionManager {
    /// CoreMotion (Apple's API) activity manager
    static var motionActivityManager = CMMotionActivityManager()
    
    /// Indicates whether walking detection has been initialized or not
    static var initialized: Bool = false // MUST BE FALSE!!
    
    static var enabled: Bool = true
    
    static var lastWalkingDetected: Double = -1 // Unix timestamp
    
    
    static var lastStationaryDetected: Double = -1
    
    /// Time of continuous motion required (lower bound) to turn walking detection on/off
    /// e.g. if 10, device must be walking for 10 seconds to start automatic recording (same thing other way around)
    static var timeToTrigger: Int = 45; // seconds

    /// Initializes manager
    /// Must be called at least once to start listening to walking.
    /// Can be called multiple times; subsequent calls will be ignored.
    ///
    /// ### Usage
    /// `WalkingDetectionManager.initialize()`
    /// Called in `MainView.swift`
    ///
    static func initialize() {
        // already initialized
        if initialized {
            return
        }
        
        lastWalkingDetected = Date().timeIntervalSince1970
        lastStationaryDetected = Date().timeIntervalSince1970
        
        // If walking detection is active
        if UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") {
            MetaWearManager.locationManager.startRecording()
        }
        
        
        // add listener
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                // called whenever activity data is updated
                handleMotionData(motion)
            }
        }
    }
    
    /// Resets timestamp data of the manager.
    static func reset() {
        lastWalkingDetected = Date().timeIntervalSince1970
        lastStationaryDetected = Date().timeIntervalSince1970
    }
    
    /// Sets whether walking detection is enabled or not.
    static func enableDetection(_ enable: Bool) {
        enabled = enable
    }
    
    /// Handles motion data when received by listener
    /// Called by `initialize()`
    static func handleMotionData(_ motion: CMMotionActivity?) {
        // disabled
        if !enabled {
            return
        }
        
        // FOR DEBUGGING
        let confidence: [CMMotionActivityConfidence? : String] = [.high : "High",
                                                                  .medium : "Medium",
                                                                  .low : "Low"]
        if UserDefaults.standard.bool(forKey: "enableMotionDebugLogs") {
            print("Walking: " + String(motion?.walking ?? false))
            print("Stationary: " + String(motion?.stationary ?? false))
            print("Driving: " + String(motion?.automotive ?? false))
            print("Confidence: " + confidence[motion?.confidence]!)
        }
        
        // Retrieve detection sensitivity settings
        timeToTrigger = UserDefaults.standard.integer(forKey: "walkingDetectionSensitivity")
        
        // update timestamps
        if motion?.confidence == .high {
            if motion?.walking != nil {
                if motion?.walking == true {
                    lastWalkingDetected = Date().timeIntervalSince1970
                }
                else {
                    lastStationaryDetected = Date().timeIntervalSince1970
                }
            }
        }
        
        // update walking status?
        if MetaWearManager.recording { // recording
            if lastStationaryDetected - lastWalkingDetected >= CGFloat(timeToTrigger) {
                
                if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
                    let title = "Walking Stopped Detected"
                    let body = "Don't forget to stop the walking session!"
                    NotificationManager.sendNotificationNow(title: title,
                                                            body: body)
                }
                print("Walking stopped detected")
                
                // upload data
//                let intensity: [Int] = [0, 0, 0, 0, 0, 0]; // none reported
//                MetaWearManager().stopRecording()
//                MetaWearManager.sendHazardReport(hazards: AppConstants.hazards,
//                                                 intensity: intensity,
//                                                 imageId: "")

                reset()
            }
        }
        else { // not recording
            if lastWalkingDetected - lastStationaryDetected >= CGFloat(timeToTrigger) {
                // Error - sensor disconnected
                if(!MetaWearManager.connected()) {
//                    if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
//                        let title = "Cannot Start Recording"
//                        let body = "Walking detected, but the sensor isn't connected. "
//                            + "Please connect to an IMU sensor on the app."
//                        NotificationManager.sendNotificationNow(title: title,
//                                                                body: body, rateLimit: 300, rateLimitId: "cannotStartSessionSensorDisconnected")
//                    }
//                    print("Cannot start session: sensor disconnected")
                    return
                }
                // Error - location disabled
                if(LocationManager.locationDisabled()) {
//                    if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
//                        let title = "Cannot Start Recording"
//                        let body = "Walking detected, but location services are disabled. "
//                            + "Please enable location services to record your walking sessions."
//                        NotificationManager.sendNotificationNow(title: title,
//                                                                body: body,
//                                                                rateLimit: 300, rateLimitId: "cannotStartSessionLocationDisabled")
//                    }
//                    
//                    print("Cannot start session: location disabled")
                    return
                }
                
                // start walking session
//                MetaWearManager().startRecording()
                print("Walking start detected")
                
                // notification
                if (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") && (UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotificationsAllDay") || (Utilities.getHour() >= 8 && Utilities.getHour() < 18))) {
                    let title = "Walking Detected"
                    let body = "Don't forget to start the walking session!"
                    NotificationManager.sendNotificationNow(title: title, body: body)
                }
                reset()
            }
        }
        
        let curLoc = MetaWearManager.locationManager.getLocation()
    }
}
