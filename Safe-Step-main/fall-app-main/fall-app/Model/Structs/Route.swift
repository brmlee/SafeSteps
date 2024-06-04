import Foundation
import CoreLocation
import MapKit
import Polyline

/// Struct that contains information about a route.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Oct 27, 2023
///
struct Route: Identifiable {
    var id: String // route ID
    var name: String
    var description: String
    var city: String
    var start_location: String
    var end_location: String
    
    /// Must have 2 or more elements, including start and end points.
    var route_points: [RoutePoint] = []
    
    /// Loads route points from an array of dictionary (raw from Firebase)
    mutating func loadRoutePoints(raw: [[String: Any]], startLatitude: Double, startLongitude: Double, startLocation: String) {
        let temp_rp_first = RoutePoint(latitude: startLatitude,
                                  longitude: startLongitude,
                                  label: startLocation)
        route_points.append(temp_rp_first);
        
        for dict in raw {
            let temp_rp = RoutePoint(latitude: dict["latitude"] as! Double,
                                      longitude: dict["longitude"] as! Double,
                                      label: dict["label"] as? String ?? "")
            route_points.append(temp_rp);
        }
    }
    
    /// Calculates the distance remaining from the given location to the end location in feet
    /// rounded down to nearest integer. Assumes a straight-line distance between all points.
    func distanceRemaining(from: CLLocationCoordinate2D) -> Int {
        // Find closest route line
        var minDist: Double = -1;
        var minRoutePointIndex: Int = 0; // endpoint index of the closest line
        for i in 1..<route_points.count {
            let distToLine = RoutePoint.distanceToLine(point1: route_points[i-1],
                                                       point2: route_points[i],
                                                       from: from)
            if minDist < 0 || distToLine <= minDist {
                minRoutePointIndex = i;
                minDist = distToLine;
            }
        }
        
        // Calculate distance from `from` to route_points[minRoutePointIndex]
        // and sum of distances of following route point pairs
        var dist: Int = 0;
        dist += route_points[minRoutePointIndex].getDistanceFeet(from: from)
        for i in minRoutePointIndex..<route_points.count-1 {
            dist += route_points[i+1].getDistanceFeet(from: route_points[i])
        }
        
        return dist;
    }
    
    func distanceRemaining() -> Int {
        let loc: [Double] = MetaWearManager.locationManager.getLocation()
        let coord = CLLocationCoordinate2D(latitude: loc[0], longitude: loc[1])
        return distanceRemaining(from: coord)
    }
    
    func getDestinationPosition() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: route_points[route_points.count-1].latitude,
                                      longitude: route_points[route_points.count-1].longitude)
    }
    
    /// Gets encoded polyline (string) of the path
    func getEncodedPolyline() -> String {
        var coordinates: [CLLocationCoordinate2D] = [];
        for rp in route_points {
            coordinates.append(CLLocationCoordinate2D(latitude: rp.latitude,
                                       longitude: rp.longitude))
        }
        
        let polyline = Polyline(coordinates: coordinates)
        return polyline.encodedPolyline
    }
    
    
}

/// Struct that contains information about an individual route point in a route.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Oct 27, 2023
///
struct RoutePoint {
    var latitude: Double
    var longitude: Double
    var label: String
    
    /// Calculates straight-line distance between the RoutePoint and the specified location
    /// in feet rounded down to nearest integer.
    func getDistanceFeet(from: CLLocationCoordinate2D) -> Int {
        let to = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let feet = Int(from.distance(to: to).magnitude / 0.3048)
        return feet
    }
    
    /// Calculates straight-line distance between the RoutePoint and the specified location
    /// in feet rounded down to nearest integer.
    func getDistanceFeet(from: RoutePoint) -> Int {
        let to = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let from_coord = CLLocationCoordinate2D(latitude: from.latitude, longitude: from.longitude)
        let feet = Int(from_coord.distance(to: to).magnitude / 0.3048)
        return feet
    }
    
    
    func getDistanceAngle(from: CLLocationCoordinate2D) -> Double {
        return sqrt((from.latitude - latitude) * (from.latitude - latitude) + (from.longitude - longitude) * (from.longitude - longitude))
    }
    
    /// Calculates straight-line distance from the specified location to the nearest line in degrees.
    /// Assumes Euclidian geometry (flat Earth); may be inaccurate near poles.
    static func distanceToLine(point1: RoutePoint, point2: RoutePoint, from: CLLocationCoordinate2D) -> Double {
        
        let dotProduct = ((point2.longitude - point1.longitude) * (from.latitude - point1.latitude)
                         - (point2.latitude - point1.latitude) * (from.longitude - point1.longitude))
        let segmentLength = sqrt((point2.longitude - point1.longitude) *  (point2.longitude - point1.longitude)
                               + (point2.latitude - point1.latitude) * (point2.latitude - point1.latitude))
        let distToLine = abs(dotProduct/segmentLength)
        
        let t = dotProduct / (segmentLength * segmentLength)
        if t < 0 {
            return point1.getDistanceAngle(from: from)
        }
        else if t > 1 {
            return point2.getDistanceAngle(from: from)
        }
        else {
            let px = point1.longitude + t * (point2.longitude - point1.longitude)
            let py = point1.latitude + t * (point2.latitude - point1.latitude)
            return sqrt((from.longitude - px) * (from.longitude - px) + (from.latitude - py) * (from.latitude - py))
        }
    }
    
    
    
}
