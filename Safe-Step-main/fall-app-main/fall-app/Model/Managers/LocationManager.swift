import Foundation
import CoreLocation

/// An interface for location data. Handles all location-related actions.
///
/// Note: In this project, an instance of this class is stored in the `MetaWearManager` class.
/// To call any functions here, use `MetaWearManager.locationManager`
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    /// `CLLocationManager` object
    let clm = CLLocationManager()
    
    /// Start recording device location. Required before `getLocation()`.
    func startRecording() {
        clm.delegate = self
        clm.startUpdatingLocation()
        clm.allowsBackgroundLocationUpdates = true
    }
    
    /// Stop recording device location. Required after `getLocation()`.
    func stopRecording() {
        clm.stopUpdatingLocation()
    }
    
    /// Get the current location of the device as an array of doubles: (latitude, longitude, altitude)
    ///`startRecording()` must be called before calling this function.
    /// It is recommended to call `stopRecording()` after all `getLocation()` calls.
    func getLocation() -> [Double] {
        var coord: [Double] = [0, 0, 0]
        
        coord[0] = clm.location?.coordinate.latitude ?? 0
        coord[1] = clm.location?.coordinate.longitude ?? 0
        coord[2] = clm.location?.altitude ?? 0
            
        return coord
    }
    
    func getLocationCoord() -> CLLocationCoordinate2D {
        return clm.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    /// Check if app has location permissions, and ask for permissions as needed
    func requestPermissions() {
        // Handle permissions
        let permStatus = CLLocationManager.authorizationStatus()
        if(permStatus == .denied || permStatus == .restricted) {
            print("Location access denied")
            clm.requestAlwaysAuthorization()
        }
        else if(permStatus == .notDetermined) {
            print("Location access not determined")
            clm.requestAlwaysAuthorization()
        }
    }
    
    /// Determines if user allowed location permissions
    static func locationDisabled() -> Bool {
        let permStatus = CLLocationManager.authorizationStatus()
        return permStatus != .authorizedAlways && permStatus != .authorizedWhenInUse
    }
}
