import SwiftUI
import MapKit
import UIKit
import SkeletonUI

/// View that shows nearby buildings and allows user to select one they're in.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modifiedJun 21, 2023
///
struct SurveyBuildingsView: View {

    
    @ObservedObject var buildings: BuildingsLoader
    
    var deviceCoordinate: CLLocationCoordinate2D
    
    /// Area to be showed in map, configured in `init`
    @State private var region: MKCoordinateRegion
    
    @Binding var showSurvey: Bool
    @Binding var tabSelection: Int
    var singlePointReport: Bool // true if reporting without recording
    @Environment(\.dismiss) private var dismiss
    
    // Constructor
    init(showSurvey: Binding<Bool>, tabSelection: Binding<Int>,
         singlePointReport: Bool = false) {
        buildings = BuildingsLoader()
        let deviceLocation = MetaWearManager.locationManager.getLocation()
        deviceCoordinate = CLLocationCoordinate2D(latitude: deviceLocation[0],
                                           longitude: deviceLocation[1])
        _region = State(initialValue: MKCoordinateRegion(center: deviceCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.003,
                                                           longitudeDelta: 0.003)))
        self._showSurvey = showSurvey
        self._tabSelection = tabSelection
        self.singlePointReport = singlePointReport
        FirebaseManager.connect()
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if singlePointReport {
                        Button(action: {
                            dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                       Text("No Hazard")
                                           .font(.system(size: 10, weight: .light))
                                           .foregroundColor(.white)
                                       Text("(Close)")
                                           .font(.system(size: 10, weight: .light))
                                           .foregroundColor(.white)
                                   }
                                   .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                   .background(Color.blue)
                                   .cornerRadius(5)
                               }
                               .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    // Map
                    Map(coordinateRegion: $region,
                        showsUserLocation: true,
                        annotationItems: buildings.getBuildingMarkers()) { bldg in
                        MapAnnotation(coordinate: bldg.coordinate) {
                            PlaceAnnotationView(title: bldg.name)
                        }
                    }
                    
                    VStack {
                        // Info
                        Text("Please select the building you're currently in.")
                            .font(.system(size: 16))
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        
                        // List of nearby buildings
                        ScrollView {
                            if buildings.loading { // skeleton UI
                                ForEach(1..<4) { index in
                                    VStack(alignment: .leading) {
                                        VStack(alignment: .leading) {
                                            Text("Loading...")
                                                .skeleton(with: true,
                                                          size: CGSize(width: 180, height: 16))
                                            Text("Loading...")
                                                .skeleton(with: true,
                                                          size: CGSize(width: 120, height: 14))
                                        }
                                        .frame(width: 320)
                                        .padding([.horizontal], 20)
                                    }
                                    .frame(width: 360, height: 56)
                                }
                            }
                            else {
                                ForEach(buildings.buildings) { building in
                                    NavigationLink(destination:
                                                    SurveyBuildingInfoView(showSurvey: $showSurvey,
                                                                           tabSelection: $tabSelection,
                                                                           buildingId: building.id,
                                                                           buildingName: building.name,
                                                                           buildingFloors: building.floors,
                                                                           singlePointReport: singlePointReport)) {
                                        BuildingItem(id: building.id,
                                                     name: building.name,
                                                     address: building.address,
                                                     distance: building.getDistanceString(from: deviceCoordinate))
                                    }
                                }
                                if buildings.buildings.isEmpty {
                                    Text("No nearby buildings found.")
                                }
                            }
                        }
                        
                        // I'm outdoors
                        NavigationLink(destination: SurveyHazardForm(showSurvey: $showSurvey,
                                                                     hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                                                                     tabSelection: $tabSelection,
                                                                     buildingId: "OUTDOORS",
                                                                     buildingFloor: "",
                                                                     buildingHazardLocation: "",
                                                                     singlePointReport: singlePointReport)) {
                            IconButtonInner(iconName: "mountain.2.fill", buttonText: "I'm outdoors")
                        }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                                     foregroundColor: .black))
                        
                        // Building is not listed
                        NavigationLink(destination: SurveyUnlistedBuilding(showSurvey: $showSurvey,
                                                                           tabSelection: $tabSelection,
                                                                          singlePointReport: singlePointReport)) {
                            Text("Building is not listed")
                                .font(.system(size: 15))
                        }
                        .padding(.top, 4)
                        .padding(.bottom, singlePointReport ? 12 : 24)
                    }
                    .frame(height: 360)
                    
                    
                } // VStack

                
                // loading
                if buildings.loading {
                    Text("Loading...")
                }
            } 
            .navigationBarHidden(true)
        }
        .onAppear {
            buildings.clear()
            FirebaseManager.loadBuildings(loader: buildings)
        }
    }
    
    
    
    /// View for each building
    struct BuildingItem: View {
        let id: String
        let name: String
        let address: String
        let distance: String
        @State var selected: Bool = false
        
        var body: some View {
            ZStack {
                // Text
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(name)
                            .font(.system(size: 16, weight: .bold))
                        Text(distance)
                            .font(.system(size: 13))
                            .offset(y: -1)
                    }
                    .frame(width: 320, alignment: .leading)
                    
                    Text(address)
                        .font(.system(size: 13, weight: .light))
                        .frame(width: 320, alignment: .leading)
                        .opacity(0.7)
                }
                .frame(width: 320)
                .padding([.horizontal], 20)
                .padding([.vertical], 12)
                .foregroundColor(Utilities.isDarkMode() ? .white : .black)

                // > symbol
                Image(systemName: "greaterthan")
                    .resizable()
                    .frame(width: 6, height: 12)
                    .foregroundColor(Color(white: 0.5))
                    .offset(x: 156)
            }
            .frame(width: 360, height: 56)
            .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
            .cornerRadius(12)
            .padding([.horizontal], 16)
        }
    }
    
    /// Marker used inside `MapAnnotation`.
    struct PlaceAnnotationView: View {
        let title: String
        
        var body: some View {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color(.black))
                    .cornerRadius(10)
                    .opacity(0.9)
                
//                ZStack {
//                    Image(systemName: "circle.fill")
//                        .imageScale(.large)
//                        .foregroundColor(.white)
//                        .offset(x: 0, y: 2)
//
//                    Image(systemName: "building.2.crop.circle.fill")
//                        .font(.title)
//                        .foregroundColor(.red)
//                }
//
//                Image(systemName: "arrowtriangle.down.fill")
//                    .font(.caption)
//                    .foregroundColor(.red)
//                    .offset(x: 0, y: -5)
            }
//            .offset(y: -24)
        }
    }

    /// Struct for buildings
    struct BuildingMarker: Identifiable {
        let id = UUID()
        var name: String
        var coordinate: CLLocationCoordinate2D
    }
}

