import SwiftUI

/// Popup view that asks users details about a building if user selected a building on list
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jul 5, 2023
///
struct SurveyBuildingInfoView: View {
    
    @Binding var showSurvey: Bool
    @Binding var tabSelection: Int
    @State var selectedFloor: String = ""
    @State var buildingId: String
    @State var buildingName: String
    @State var buildingFloors: [String]
    @State var hazardLocation: String = ""
    @State var hazardRemarks: String = ""
    var singlePointReport: Bool
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Hazard Location"),
                        footer: Text("Please specify where you encountered the hazard.")) {
                    Text(buildingName)
                    Picker("Floor", selection: $selectedFloor) {
                        ForEach(buildingFloors.indices) { index in
                            Text(buildingFloors[index]).tag(buildingFloors[index])
                        }
                    }
                    TextField("Hazard Location", text: $hazardLocation)
                    TextField("Remarks/Comments (optional)", text: $hazardRemarks)
                }
            }
            
            if hazardLocation != "" {
                NavigationLink(destination: SurveyHazardForm(showSurvey: $showSurvey,
                                                             hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                                                             tabSelection: $tabSelection,
                                                             buildingId: buildingId,
                                                             buildingFloor: selectedFloor,
                                                             buildingRemarks: hazardRemarks,
                                                             buildingHazardLocation: hazardLocation,
                                                             singlePointReport: singlePointReport)) {
                    IconButtonInner(iconName: "arrow.right", buttonText: "Continue")
                }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                             foregroundColor: .black))
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            selectedFloor = buildingFloors[0]
        }
    }
}


