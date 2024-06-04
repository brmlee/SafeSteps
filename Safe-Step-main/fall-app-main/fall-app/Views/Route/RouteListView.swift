import SwiftUI
import MapKit
/// Shows the list of nearby routes.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Oct 27, 2023
///
struct RouteListView: View {
    @ObservedObject var routesLoader = RoutesLoader()
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                HStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .imageScale(.large)
                            .padding(.trailing, 4)
                        VStack(alignment: .leading) {
                            Text("Pay attention to your surroundings.")
                                .font(.system(size: 15.5, weight: .semibold))
                            Text("Phone use while walking can be dangerous.")
                                .font(.system(size: 13.5))
                        }
                    }
                    .padding([.vertical], 6)
                    .padding([.horizontal], 12)
                    .frame(width: 360)
                }
                .foregroundColor(.black)
                .background(.yellow)
                .cornerRadius(12)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                if(routesLoader.loading) {
                    Text("Loading...")
                }
                if(!routesLoader.loading && routesLoader.routes.isEmpty) {
                    Text("No routes found near your location.")
                }
                
                ForEach(routesLoader.routes) { route in
                    NavigationLink(destination: RouteView(route: route).navigationBarTitleDisplayMode(.inline)) {
                
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(route.name)")
                                        .font(.system(size: 16, weight: .bold))
                                    Spacer()
                                }
                                HStack {
                                    Text("From")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(width: 60, alignment: .leading)
                                    Text("\(route.start_location)")
                                        .font(.system(size: 15))
                                }
                                HStack {
                                    Text("To")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(width: 60, alignment: .leading)
                                    Text("\(route.end_location)")
                                        .font(.system(size: 15))
                                }
                                HStack(alignment: .top) {
                                    Text("Details")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(width: 60, alignment: .leading)
                                    Text("\(route.description)")
                                        .font(.system(size: 15))
                                }
                            }
                            .padding(.leading, 8)
                            .padding([.vertical], 8)
                            .frame(width: 320)
                            
                            Image(systemName: "greaterthan")
                                .resizable()
                                .frame(width: 6, height: 12)
                                .foregroundColor(Color(white: 0.5))
                                .padding(.trailing, 8)
                        } // HStack
                        .frame(width: 360)
                        .foregroundColor(Utilities.isDarkMode() ? .white : .black)
                        .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                        .cornerRadius(12)
                        .padding(.bottom, 4)
                    } // NavigationLink
                } // ForEach
            } // ScrollView
            .navigationTitle(Text("Routes"))
            .refreshable {
                FirebaseManager.loadRoutes(loader: routesLoader)
            }
        }
        .onAppear {
            FirebaseManager.connect()
            FirebaseManager.loadRoutes(loader: routesLoader)
        }
    }
}

#Preview {
    RouteListView()
}
