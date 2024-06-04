import Foundation
import MapKit

/// Object used to load multiple walking sessions at once.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
class MultiWalkingLoader: ObservableObject {
    
    /// Array of pairs of loaders. One element = one record, two loaders
    var loaders: [(GeneralWalkingData, RealtimeWalkingDataLoader)] = []
    
    /// Update this to refresh the screen
    @Published var isLoading: Bool = false
    var realtimeDataLoaded: Int = 0
    
    func start() {
        isLoading = true
    }
    
    func addRecord(_ g: GeneralWalkingData, _ r: RealtimeWalkingDataLoader) {
        loaders.append((g, r))
    }
    
    /// Called when a realtime data of a single record is done loading.
    func onSingleRealtimeDataLoaded() {
        realtimeDataLoaded += 1
        // done loading
        if(realtimeDataLoaded == loaders.count) {
            isLoading = false
        }
    }
    
    /// Reset
    func reset() {
        realtimeDataLoaded = 0
        isLoading = false
        loaders = []
    }
    
    /// Gets encoded polyline of multiple records
    /// For more information about encoded polylines, see https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    func getEncodedPolylines() -> [String] {
        var arr: [String] = []
        var i: Int = 0
        while i < loaders.count {
            let polyline = loaders[i].1.data.getEncodedPolyline()
            arr.append(polyline)
            i += 1
        }
        return arr
    }
    
    /// Get a boolean array correstponding to `loaders` whether each record has a hazard or not
    func hazardEncountered() -> [Bool] {
        var arr: [Bool] = []
        var i: Int = 0
        while i < loaders.count {
            let hazardEncountered = loaders[i].0.hazardEncountered()
            arr.append(hazardEncountered)
            i += 1
        }
        return arr
    }
    
    /// Returns the final location of a record
    func getFinalLocation() -> [CLLocationCoordinate2D] {
        var arr: [CLLocationCoordinate2D] = []
        var i: Int = 0
        while i < loaders.count {
            let polyline = loaders[i].1.data.getFinalLocation()
            arr.append(polyline)
            i += 1
        }
        return arr
    }
}
