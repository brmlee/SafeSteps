import SwiftUI

/// Popup view that shows the users the floor plan and allows users to select specific location on the floor plan
/// OBSOLETE - NO LONGER USED.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
//struct SurveyFloorPlanView__OBSOLETE: View {
//
//    @Binding var showSurvey: Bool
//    var building: Building
//    @Binding var tabSelection: Int
//    @State var selectedFloor: String = ""
//    @State var buildingRemarks: String = ""
//    @State var showBuildingRemarkAlert: Bool = false
//
//    @State var tappedLocation: [Double] = [-1, -1]
//
//    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
//
//
//    var body: some View {
//        VStack {
//
//            // Image
//            if imageLoader.loading {
//                Text("Loading floor plan...")
//                    .frame(height: 450)
//            }
//            else if imageLoader.failed {
//                Text("Could not load floor plan.")
//                    .multilineTextAlignment(.center)
//            }
//            else {
//                if imageLoader.image.size.width > 0 {
//                    GeometryReader { metrics in
//                        ZStack {
//                            // Image
//                            Image(uiImage: imageLoader.image)
//                                .resizable()
//                                .frame(width: metrics.size.width,
//                                       height: metrics.size.width / imageLoader.image.size.width * imageLoader.image.size.height)
//                                .onTapGesture { location in
//                                    tappedLocation[0] = location.x / metrics.size.width
//                                    tappedLocation[1] = location.y / metrics.size.width * imageLoader.image.size.width / imageLoader.image.size.height
//                                }
//
//                            // Tap marker
//                            let heightPercentage = metrics.size.width * imageLoader.image.size.height / imageLoader.image.size.width / metrics.size.height
//                            Image(systemName: "exclamationmark.triangle.fill")
//                                .imageScale(.small)
//                                .foregroundColor(.red)
//                                .offset(x: (tappedLocation[0] - 0.5) * metrics.size.width,
//                                        y: (tappedLocation[1] - 0.5) * heightPercentage * metrics.size.height)
//
//                        } // ZStack
//                        .frame(width: metrics.size.width,
//                               height: metrics.size.width / imageLoader.image.size.width * imageLoader.image.size.height)
//                    } // GeometryReader
//                }
//
//
//            }
//
//            // Info
//            if tappedLocation[0] < 0 && tappedLocation[1] < 0 {
//                Text("Please mark the hazard location by tapping the floor plan above.")
//                    .multilineTextAlignment(.center)
//            }
//
//            // Floor Picker
//            Picker("Floor", selection: $selectedFloor) {
//                ForEach(building.floorPlans.sorted(by: <), id: \.key) { floor, plan in
//                    Text("\(floor) floor").tag(floor)
//                }
//            }
//            .pickerStyle(.wheel)
//            .frame(height: 100)
//            .onChange(of: selectedFloor) { newValue in
//                FirebaseManager.loadFloorPlanImage(buildingId: building.id,
//                                                   image: building.floorPlans[newValue] ?? "",
//                                                   loader: imageLoader)
//                tappedLocation = [-1, -1]
//            }
//
//
//            // Button
//            if tappedLocation[0] >= 0 && tappedLocation[1] >= 0 {
//                VStack {
//                    HStack {
//                        // Reset
//                        Button(action: {
//                            tappedLocation = [-1, -1]
//                        }) {
//                            Image(systemName: "xmark.app.fill")
//                                .resizable()
//                                .frame(width: 32, height: 32)
//                                .foregroundColor(Color(white: 0.5))
//                        }
//
//                        NavigationLink(destination: SurveyHazardForm(showSurvey: $showSurvey,
//                                                                     hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
//                                                                     tabSelection: $tabSelection,
//                                                                     buildingId: building.id,
//                                                                     buildingFloor: selectedFloor,
//                                                                     buildingRemarks: buildingRemarks,
//                                                                     buildingHazardLocation: "(\(tappedLocation[0]), \(tappedLocation[1]))")) {
//                            IconButtonInner(iconName: "arrow.right", buttonText: "Continue")
//                        }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
//                                                     foregroundColor: .black))
//                    }
//
//                    Button(action: {
//                        showBuildingRemarkAlert = true
//                    }) {
//                        Text("Add remarks")
//                            .font(.system(size: 15))
//                    }
//                    .padding(.top, 4)
//                    .padding(.bottom, 24)
//                }
//            } // if
//            Spacer()
//        } // VStack
//        .navigationTitle(Text(building.name))
//        .onAppear {
//            let randomFloor = building.floorPlans.sorted(by: <)[0]
//            selectedFloor = randomFloor.key
//
//            FirebaseManager.loadFloorPlanImage(buildingId: building.id,
//                                               image: building.floorPlans[selectedFloor] ?? "",
//                                               loader: imageLoader)
//        } // VStack
//        .alert("Remarks", isPresented: $showBuildingRemarkAlert) {
//            TextField("Type here", text: $buildingRemarks)
//            Button("Save", action: {
//                showBuildingRemarkAlert = false
//            })
//        } message: {
//            Text("Add any remarks/comments to help us locate the hazard.")
//        }
//
//
//    }
//}
