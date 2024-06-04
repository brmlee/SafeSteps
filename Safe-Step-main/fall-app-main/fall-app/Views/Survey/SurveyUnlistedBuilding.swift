import SwiftUI

/// Popup view that asks users details about a building if user selected  "Building is unlisted"
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct SurveyUnlistedBuilding: View {
    
    @Binding var showSurvey: Bool
    @Binding var tabSelection: Int
    @State var selectedFloor: String = ""
    @State var buildingName: String = ""
    @State var hazardLocation: String = ""
    @State var hazardRemarks: String = ""
    var singlePointReport: Bool
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Hazard Location"),
                        footer: Text("Please specify where you encountered the hazard.")) {
                    TextField("Building Name", text: $buildingName)
                    TextField("Floor", text: $selectedFloor)
                    TextField("Hazard Location", text: $hazardLocation)
                    TextField("Remarks/Comments (optional)", text: $hazardRemarks)
                }
            }
            
            if buildingName != "" && selectedFloor != "" && hazardLocation != "" {
                NavigationLink(destination: SurveyHazardForm(showSurvey: $showSurvey,
                                                             hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
                                                             tabSelection: $tabSelection,
                                                             buildingId: "UNLISTED__\(buildingName)",
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
    }
}


