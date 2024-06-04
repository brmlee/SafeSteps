import Foundation
import CoreLocation
import MetaWear
import MetaWearCpp
import MapKit
import Polyline
import Foundation

/// A struct that stores GPS location, gyroscope data, and timestamp.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct RealtimeWalkingDataPoint {
    
    /// Data
    var data: MblMwCartesianFloat
    
    /// Type of data (gyroscope, acceleration, etc)
    var dataType: String
    
    /// GPS Location of the data: (latitude, longitude, altitude)
    var location: [Double]
    
    /// Current timestamp in seconds from Jan. 1, 1970
    var timestamp = NSDate().timeIntervalSince1970;
    
    
    var sensorId: Int = 0; // 
}
