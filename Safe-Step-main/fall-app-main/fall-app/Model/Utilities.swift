import Foundation
import SwiftUI
import CoreLocation
import MapKit
import UIKit

/// Contains useful general functions for the app
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
class Utilities {
    /// Detects if dark mode is enabled or not.
    static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    /// Returns device ID string
    static func deviceId() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    /// Returns iOS version
    static func getIosVersion() -> String {
        return "\(UIDevice.current.systemVersion)"
    }
    
    static func getDeviceCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return modelCode ?? ""
    }
    
    /// Get hour 0-23
    static func getHour() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour;
    }
}


