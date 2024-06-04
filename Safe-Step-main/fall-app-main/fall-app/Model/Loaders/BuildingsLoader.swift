import Foundation
import CoreLocation

/// Object used to load building information from the database
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 20, 2023
///
class BuildingsLoader: ObservableObject {
    
    var buildings: [Building] = []
    
    @Published var loading: Bool = false
    
    /// Adds new building to array.
    func append(id: String, name: String, address: String,
                latitude: Double, longitude: Double, floors: [String]) {
        buildings.append(Building(id: id, name: name, address: address, latitude: latitude,
                                  longitude: longitude, floors: floors))
    }
    
    /// Returns array of building markers used in `SurveyBuildingView`.
    func getBuildingMarkers() -> [SurveyBuildingsView.BuildingMarker] {
        var val: [SurveyBuildingsView.BuildingMarker] = []
        for building in buildings {
            val.append(.init(name: building.name,
                             coordinate: CLLocationCoordinate2D(latitude: building.latitude,
                                                                longitude: building.longitude)))
        }
        return val
    }
    
    /// Sorts `buildings` by distance  in ascending order.
    func sortByDistance(from: CLLocationCoordinate2D) {
        buildings.sort {
            $0.getDistanceFeet(from: from) < $1.getDistanceFeet(from: from)
        }
    }
    
    /// Clears buildings.
    func clear() {
        buildings = []
        loading = false
    }
}
