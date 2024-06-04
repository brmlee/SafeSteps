import Foundation
import CoreLocation

/// Object used to load route information from database
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Oct 27, 2023
///
class RoutesLoader: ObservableObject {
    var routes: [Route] = []
    @Published var loading: Bool = false
    
    /// Sorts `routes` by distance to start point in ascending order.
    func sortByDistance(from: CLLocationCoordinate2D) {
        routes.sort {
            $0.route_points[0].getDistanceFeet(from: from) < $1.route_points[0].getDistanceFeet(from: from)
        }
    }
    
    func append(_ route: Route) {
        routes.append(route);
    }
    
    func clear() {
        routes = []
        loading = false
    }
}
