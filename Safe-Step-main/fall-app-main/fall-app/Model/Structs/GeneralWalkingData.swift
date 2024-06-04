import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

/// A struct that stores general data of a walking record.
struct GeneralWalkingData {
    
    /// Name of the document.
    /// Not required for uploading new records, but required for editing existing records.
    var docName: String = ""
    
    /// Array of hazard types.
    var hazards_type: [String];
    
    /// Intensity of each hazard type. Size must match that of `hazards_type`.
    var hazards_intensity: [Int];
    
    /// Device identifier, automatically generated.
    let user_id = UIDevice.current.identifierForVendor?.uuidString;
    
    /// Current timestamp in seconds from Jan. 1, 1970
    var timestamp = NSDate().timeIntervalSince1970;
    
    /// Names of realtime data documents
    var realtimeDocNames: [String] = []
    
    /// Image ID as stored on Firebase.
    var image_id: String = ""
    
    /// Retrieves the list of hazards as a form of dictionary.
    /// key = hazard name (String), value = intensity (Int)
    func hazards() -> [String: Int] {
        var dict: [String: Int] = [:];
        
        hazards_type.indices.forEach { index in
            dict[hazards_type[index]] = hazards_intensity[index];
        }
        
        return dict;
    }
    
    /// Retrieves the timestamp as a user-friendly string.
    ///
    /// ### Format
    /// `h:mm a, MMM. d, yyyy`
    /// Example: `11:34 PM, Jan. 15, 2023`
    ///
    func timestampToString() -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a, MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    /// Retrieves the timestamp as a user-friendly string, relative to current date.
    /// (Example: `Today, 1:30 PM`, `Yesterday, 2:53 PM`, `2 days ago, 11:05 AM`)
    ///
    func timestampToStringRelative() -> String {
        // Get time
        let tsDate = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let time = dateFormatter.string(from: tsDate)
        
        // Get relative date
        let todayStart = Date().startOfDay.timeIntervalSince1970
        let tsStart = tsDate.startOfDay.timeIntervalSince1970
        let daysAgo = (Int(todayStart) - Int(tsStart)) / 86400
        
        if daysAgo == 0 {
            return "Today, \(time)"
        }
        else if daysAgo == 1 {
            return "Yesterday, \(time)"
        }
        else if daysAgo < 7 {
            dateFormatter.dateFormat = "EEEE"
            let dayOfWeek = dateFormatter.string(from: tsDate)
            return "\(dayOfWeek), \(time)"
        }
        else {
            dateFormatter.dateFormat = "yyyy"
            let tsYear = dateFormatter.string(from: tsDate)
            let todayYear = dateFormatter.string(from: Date())
            if tsYear == todayYear {
                dateFormatter.dateFormat = "MMM d (E)"
                let date = dateFormatter.string(from: tsDate)
                return "\(date), \(time)"
            }
            else {
                dateFormatter.dateFormat = "MMM d, yyyy"
                let date = dateFormatter.string(from: tsDate)
                return "\(date), \(time)"
            }
        }
    }
    
    /// Retrieves the timestamp as a user-friendly string of date.
    ///
    /// ### Format
    /// `E, MMM d, yyyy`
    /// Example: `Mon, May 15, 2023`
    ///
    func getDate() -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    /// Retrieves the timestamp as a sorting- and human-friendly string.
    ///
    /// ### Format
    /// `yyyyMMdd-HHmmss` (similar to ISO 8601)
    /// Example: `20230115-233405
    ///
    func timestampToDateIso() -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        return dateFormatter.string(from: date)
    }
    
    /// Retrieves the reported hazards in array of strings.
    ///
    /// ### Example
    /// Returns
    /// ```
    /// ["Slippery (low)", "Poor Lighting (high)"]
    /// ```
    /// If no hazard was reported by user,
    /// ```
    /// ["No hazard reported."]
    /// ```
    ///
    func hazardsToStringArr() -> [String] {
        var strArr: [String] = [];
        var index: Int = 0;
        var count: Int = 0;
        let optionTexts: [String] = ["none", "low", "medium", "high"]
        
        for intensity in hazards_intensity {
            if(intensity > 0) {
                count += 1;
                strArr.append(hazards_type[index] + " ("
                              + optionTexts[intensity] + ")")
            }
            index += 1;
        }
        
        if(count <= 0) {
            return ["No hazard reported."]
        }
        else {
            return strArr;
        }
    }
    
    /// Returns the number of types of hazards reported.
    func countHazards() -> Int {
        var index: Int = 0;
        var count: Int = 0;
        
        for intensity in hazards_intensity {
            if(intensity > 0) {
                count += 1;
            }
            index += 1;
        }
        return count
    }
    
    /// Returns true if a hazard has been encountered, false otherwise.
    func hazardEncountered() -> Bool {
        return countHazards() != 0
    }
    
    /// Creates and returns a WalkingRecord object given two arrays.
    static func toRecord(type: [String], intensity: [Int]) -> GeneralWalkingData {
        return GeneralWalkingData(hazards_type: type, hazards_intensity: intensity);
    }
    
    /// Returns whether a hazard photo is available for this record.
    func photoAvailable() -> Bool {
        return image_id != ""
    }
}
