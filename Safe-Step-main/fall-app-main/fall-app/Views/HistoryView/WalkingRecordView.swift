import SwiftUI
import MapKit

/// Shows a single walking record with a map.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 15, 2023
///
struct WalkingRecordView: View {
    
    @State var generalData: GeneralWalkingData
    @ObservedObject var realtimeData: RealtimeWalkingDataLoader = RealtimeWalkingDataLoader()
    @State var toggleToRefresh: Bool = false
    
    @State var showSubmittedAlert: Bool = false
    @State var showPhotoPicker: Bool = false
    
    var body: some View {

        ZStack {
            VStack {
                
                /// Map
                MapPolylineView(realtimeData.data.getEncodedPolyline(),
                        hazardEncountered: generalData.hazardEncountered(),
                        hazardLocation: realtimeData.data.getFinalLocation())
                
                /// Info
                VStack {
                    Spacer()
                        .frame(height: 16)
                    
                    // General data
                    HStack {
                        Spacer()
                            .frame(width: 16)
                        
                        Image(systemName: "figure.walk.circle")
                            .resizable()
                            .frame(width:56, height: 56)
                        
                        Spacer()
                            .frame(width: 24)
                        
                        VStack {
                            Spacer()
                                .frame(height: 10)
                            Text(generalData.getDate())
                                .frame(width: 180, alignment: .leading)
                            Text(realtimeData.data.getStartTime() + " - " + realtimeData.data.getEndTime())
                                .frame(width: 180, alignment: .leading)
                            Text(String(format: "%.2f mi", realtimeData.data.getDistanceTravelled()/5280))
                                .frame(width: 180, alignment: .leading)
                            Spacer()
                                .frame(height: 10)
                        }
                        
                        Spacer()
                            .frame(width: 16)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                    .cornerRadius(12)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text("Reported Hazards")
                        .font(.system(size: 16))
                    
                    ScrollView(.vertical) {
                        let hazardsArr = generalData.hazardsToStringArr()
                        ForEach(hazardsArr.indices) { index in
                            Text("• " + hazardsArr[index])
                                .frame(width: 300, alignment: .leading)
                        }
                        NavigationLink(destination: EditHazardReportView(generalData: generalData,
                                                                         toggleToRefresh: $toggleToRefresh)) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }.padding(.top, 8)
                        }
                    }
                    .frame(maxHeight: 160)
                    
                    /// Hazard photo (button)
                    if generalData.image_id != "" {
                        NavigationLink(destination: HazardImageView(imageId: generalData.image_id)) {
                                IconButtonInner(iconName: "photo", buttonText: "View Hazard Photo")
                        }
                        .buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
                        .padding(.bottom, 8)
                    }
                    else {
                        Button(action: {
                            showPhotoPicker = true
                        }) {
                                IconButtonInner(iconName: "camera.fill", buttonText: "Add Photo")
                        }
                        .buttonStyle(IconButtonStyle(backgroundColor: .cyan, foregroundColor: .black))
                        .padding(.bottom, 8)
                    }
                    
                }
                .frame(height: 320, alignment: .center)
                
                    
            }
            .onAppear {
                FirebaseManager.loadRealtimeData(loader: realtimeData,
                                                  docNames: generalData.realtimeDocNames)
            }
            .alert("Submitted", isPresented: $showSubmittedAlert, actions: {
                Button("Close", role: nil, action: {
                    showSubmittedAlert = false
                })
            }, message: {
                Text("Hazard reported updated! Please note that it may take a few minutes for changes to be reflected on the app.")
            })
            .sheet(isPresented: $showPhotoPicker) {
                ImagePickerView() { image in
                    let uuid = UUID().uuidString
                    generalData.image_id = uuid
                    FirebaseManager.editHazardReport(rec: generalData)
                    FirebaseManager.uploadHazardImage(uuid: uuid, image: image)
                    showSubmittedAlert = true
                }.presentationDetents([.large])
            }
            
            if realtimeData.isLoading {
                Text("Loading...")
            }
        } // ZStack
        .navigationBarTitleDisplayMode(.inline)
    } // body
}


