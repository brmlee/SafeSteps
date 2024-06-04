import Foundation
import CoreLocation
import MapKit

/// Struct that contains information about a building.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 20, 2023
///
struct Building: Identifiable {
    
    var id: String // building ID as on firebase
    var name: String
    var address: String
    
    var latitude: Double
    var longitude: Double
    
    var floors: [String] // name of floors
    
    /// Gets distance of building in feet, rounded down to nearest integer
    func getDistanceFeet(from: CLLocationCoordinate2D) -> Int {
        let to = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let feet = Int(from.distance(to: to).magnitude / 0.3048)
        return feet
    }
    
    /// Gets distance of building in feet rounded down to nearest integer as string
    func getDistanceString(from: CLLocationCoordinate2D) -> String {
        return "\(getDistanceFeet(from: from)) ft"
    }
}
