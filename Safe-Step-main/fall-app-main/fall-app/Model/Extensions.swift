import Foundation
import SwiftUI
import CoreLocation
import MapKit

extension Date {
    /// Returns 00:00:00 of today as a `Date` object
    /// Example: `Date().startOfDay`
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

/// Extension to help with distance calculation.
extension CLLocationCoordinate2D {
    /// Returns the distance between two coordinates in meters.
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        MKMapPoint(self).distance(to: MKMapPoint(to))
    }

}
