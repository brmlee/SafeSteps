import Foundation
import UserNotifications

/// An interface for notifications. Handles all notification-related actions.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 23, 2023
///
class NotificationManager {
    
    /// Requests for notifications permissions.
    /// Returns true if request was successful, false otherwise (usage optional)
    static func requestPermissions() -> Bool {
        var ok: Bool = false
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            ok = success
        }
        return ok
    }
    
    /// Sends notification of `title` and `body` now.
    /// User must have given notification permissions for this to work.
    static func sendNotificationNow(title: String, body: String) {
        // content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // trigger
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, // tiny delay
                                                        repeats: false)
        
        // request
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Error sending notifications: \(error)")
            }
        }
    }
    
    /// Sends notification of `title` and `body` ONLY IF a notification of same `rateLimitId` hasn't been sent with in the last `rateLimit` seconds
    /// User must have given notification permissions for this to work.
    static func sendNotificationNow(title: String, body: String, rateLimit: Double, rateLimitId: String) {
        let lastSent: Double = UserDefaults.standard.double(forKey: "__notificationRateLimit__id=\(rateLimitId)")
        let now = Date().timeIntervalSince1970
        
        // Check rate limit
        if lastSent + rateLimit < now { // ok
            UserDefaults.standard.set(now, forKey: "__notificationRateLimit__id=\(rateLimitId)")
            sendNotificationNow(title: title, body: body)
        }
    }
}
