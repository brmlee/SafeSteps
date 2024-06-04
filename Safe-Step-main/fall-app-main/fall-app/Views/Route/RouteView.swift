import SwiftUI

/// View that displays a route in a map and relevant information, and a button that triggers popup to change routes
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Oct 27, 2023
///
struct RouteView: View {
    var route: Route
    @AppStorage("userDismissedPitchHintView") var userDismissedPitchHintView: Bool = false

    
    var body: some View {
        ZStack {
            MapPolylineView(route.getEncodedPolyline(),
                            destinationPosition: route.getDestinationPosition())
            
            VStack {
                VStack {
                    VStack {
                        Text("\(route.name)")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.top, 1)
                        Text("to \(route.end_location)")
                            .font(.system(size: 15))
                    }
                    
                    .padding([.vertical], 8)
                    .padding([.horizontal], 12)
                }
                .background(Utilities.isDarkMode() ? .black : .white)
                .cornerRadius(16)
                .padding([.horizontal], 16)
                .padding(.top, 8)
                .frame(maxWidth: 340)
                
                Spacer()
                
                if !userDismissedPitchHintView {
                    VStack {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Drag the screen up/down with two fingers to adjust the vertical 3D tilt.")
                                .font(.system(size: 15))
                                .padding([.horizontal], 8)
                            Button(action: {
                                userDismissedPitchHintView = true
                            }) {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding([.horizontal], 20)
                        .padding([.vertical], 6)
                        
                    }
                    .background(Color(white: 0, opacity: 0.85))
                    .cornerRadius(12)
                    .padding([.horizontal], 12)
                }
                
                RouteDistanceView(route: route)
            }
            .opacity(0.9)

        }
    }
    
        
    struct RouteDistanceView: View {
        var route: Route
        @State var distanceRemaining: Int = -1
        @State var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
        
        var body: some View {
            VStack {
                if distanceRemaining > 100000 || distanceRemaining < 0 {
                    Text("Calculating distance...")
                        .font(.system(size: 15))
                        .padding([.horizontal], 12)
                        .padding([.vertical], 5)
                }
                else if distanceRemaining > 25 {
                    Text("\(distanceRemaining) ft (\(distanceRemaining/240) min) remaining")
                        .font(.system(size: 15))
                        .padding([.horizontal], 12)
                        .padding([.vertical], 5)
                }
                else {
                    Text("Arrived!")
                        .font(.system(size: 15))
                        .padding([.horizontal], 12)
                        .padding([.vertical], 5)
                }
            }
            .background(Utilities.isDarkMode() ? .black : .white)
            .cornerRadius(12)
            .padding([.all], 8)
            .onReceive(timer) { _ in
                distanceRemaining = route.distanceRemaining()
            }
        }
        
    }
}
