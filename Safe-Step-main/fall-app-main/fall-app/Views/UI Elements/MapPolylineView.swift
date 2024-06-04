import SwiftUI
import MapKit
import Polyline

/// MapView that supports polyline drawing.
///
/// ### Usage
/// ```
/// MapView(realtimeData.data.getEncodedPolyline(),
///         hazardEncountered: generalData.hazardEncountered(),
///         hazardLocation: realtimeData.data.getFinalLocation())
/// ```
/// Used in `WalkingRecordView.swift`.
///
/// ### Author & Version
/// Originally by Mauricio Vazquez (https://rb.gy/h983w), retrieved May 15, 2023
/// Using Polyline library: https://github.com/raphaelmor/Polyline/
/// Modified by Seung-Gu Lee (seunggu@umich.edu), last modified Jan 12, 2024
///
struct MapPolylineView: UIViewRepresentable {
    private let locationViewModel = LocationViewModel()
    private let mapZoomEdgeInsets = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 40.0, right: 40.0)
    let hazardEncountered: [Bool]
    let hazardLocation: [CLLocationCoordinate2D]
    
    /// 0 = hazard, 1 = route
    let displayMode: Int;
    
    // Route
    init(_ encodedPolyline: String,
         destinationPosition: CLLocationCoordinate2D) {
        self.hazardLocation = [destinationPosition]
        self.hazardEncountered = [true]
        self.displayMode = 1
        locationViewModel.load(encodedPolyline)
    }

    // Single hazard record
    init(_ encodedPolyline: String,
         hazardEncountered: Bool,
         hazardLocation: CLLocationCoordinate2D) {
        self.hazardLocation = [hazardLocation]
        self.hazardEncountered = [hazardEncountered]
        self.displayMode = 0
        locationViewModel.load(encodedPolyline)
    }
    
    // Multiple hazard records
    init(_ encodedPolyline: [String],   
         hazardEncountered: [Bool],
         hazardLocation: [CLLocationCoordinate2D]) {
        self.hazardLocation = hazardLocation
        self.hazardEncountered = hazardEncountered
        self.displayMode = 0
        for p in encodedPolyline {
            locationViewModel.load(p)
        }
    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.showsUserLocation = (displayMode == 1) ? true : false
        mapView.setUserTrackingMode((displayMode == 1) ? .followWithHeading : .none, animated: true)
        
        if #available(iOS 17.0, *) {
            mapView.showsUserTrackingButton = true
        }
        
        mapView.delegate = context.coordinator
        return mapView
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapPolylineView>) {
        updateOverlays(from: uiView)
        
        uiView.setUserTrackingMode((displayMode == 1) ? .followWithHeading : .none, animated: true)
        uiView.mapType = (displayMode == 1) ? .satelliteFlyover : .hybridFlyover
    

        // Mark hazards (annotations)
        var i: Int = 0
        while i < hazardLocation.count {
            if(hazardEncountered[i]) {
                uiView.addAnnotation(HazardMapAnnotation(hazardLocation[i]))
            }
            i += 1
        }
    }

    /// Updates overlays on map.
    /// Called in `updateUIView`.
    private func updateOverlays(from mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        
        for loc in locationViewModel.locations {
            let polyline = MKPolyline(coordinates: loc, count: loc.count)
            mapView.addOverlay(polyline)
        }
        
        let combinedPolyline = locationViewModel.combineLocations()
        setMapZoomArea(map: mapView, polyline: combinedPolyline,
                       edgeInsets: mapZoomEdgeInsets, animated: true)
        
    }

    private func setMapZoomArea(map: MKMapView, polyline: MKPolyline,
                                edgeInsets: UIEdgeInsets, animated: Bool = false) {
        if displayMode == 0 { // hazard
            map.setVisibleMapRect(polyline.boundingMapRect,
                                  edgePadding: edgeInsets,
                                  animated: animated)
        }
        else if displayMode == 1 { // route
            let location = MetaWearManager.locationManager.getLocationCoord()
            let region = MKCoordinateRegion( center: location, latitudinalMeters: CLLocationDistance(exactly: 100)!, longitudinalMeters: CLLocationDistance(exactly: 100)!)
            map.setRegion(map.regionThatFits(region), animated: true)
        }
    }
    
    
}


/// Annotations (pins) on map
/// Used in `updateUIView`
class HazardMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.title = ""
        self.subtitle = ""
        self.coordinate = coordinate
    }
}


final class MapViewCoordinator: NSObject, MKMapViewDelegate {
    private let map: MapPolylineView

    init(_ control: MapPolylineView) {
        self.map = control
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotationView = views.first, let annotation = annotationView.annotation {
            
            if annotation is MKUserLocation {
                let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
                mapView.setRegion(region, animated: true)
            }
        }
        
        mapView.userTrackingMode = .followWithHeading
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 4
        return renderer
    }
    
    
}


class LocationViewModel: ObservableObject {
    var locations = [[CLLocationCoordinate2D]]()
  
    func load(_ encodedPolyline: String) {
        fetchLocations(encodedPolyline)
    }
  
    private func fetchLocations(_ encodedPolyline: String) {
        let polyline = Polyline(encodedPolyline: encodedPolyline)
        guard let decodedLocations = polyline.locations else { return }
        locations.append(decodedLocations.map {
            CLLocationCoordinate2D(latitude: $0.coordinate.latitude,
                                   longitude: $0.coordinate.longitude)
        })
    }
    
    func combineLocations() -> MKPolyline {
        var arr: [CLLocationCoordinate2D] = []
        for loc in locations {
            for l in loc {
                arr.append(l)
            }
        }
        return MKPolyline(coordinates: arr, count: arr.count)
    }
}


