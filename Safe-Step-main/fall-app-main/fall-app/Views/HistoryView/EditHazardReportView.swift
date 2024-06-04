import SwiftUI

/// View to edit existing hazard reports.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modifiedJun 21, 2023
///
struct EditHazardReportView: View {
    
    var generalData: GeneralWalkingData
    
    /// Call `self.presentationMode.wrappedValue.dismiss()` to close this view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Refresh parent view (`WalkingRecordView`)
    @Binding var toggleToRefresh: Bool
    
    @State var intensity: [Int]
    
    @State var showSubmittedAlert: Bool = false
    
    /// Constructor
    init(generalData:
         GeneralWalkingData,
         toggleToRefresh: Binding<Bool>) {
        self.generalData = generalData
        self._toggleToRefresh = toggleToRefresh
        
        // copy hazards intensity
        var dict: [String: Int] = [:]
        var tempIntensity: [Int] = []
        for i in generalData.hazards_intensity.indices {
            dict[generalData.hazards_type[i]] = generalData.hazards_intensity[i]
        }
        for i in AppConstants.hazards.indices {
            let hazard = AppConstants.hazards[i]
            tempIntensity.append(dict[hazard] ?? 0)
        }
        _intensity = State<[Int]>(initialValue: tempIntensity)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Hazards form
                ForEach(AppConstants.hazards.indices) { index in
                    SurveyDropdown(label: AppConstants.hazards[index],
                                   icon: AppConstants.hazardIcons[index],
                                   optionTexts: AppConstants.optionTexts,
                                   optionValues: AppConstants.optionValues,
                                    value: $intensity[index])
                }
                
                // Edit button
                Button(action: {
                    // update data
                    var rec = generalData // copy
                    rec.hazards_type = AppConstants.hazards
                    rec.hazards_intensity = intensity
                    FirebaseManager.editHazardReport(rec: rec)
                    showSubmittedAlert = true
                }) {
                    IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit Changes")
                }.buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
                .padding(.top, 4)
                .padding(.bottom, 16)
            } // VStack
        } // NavigationView
        .alert("Submitted", isPresented: $showSubmittedAlert, actions: {
            Button("Close", role: nil, action: {
                // close and refresh
//                toggleToRefresh.toggle()
                showSubmittedAlert = false
                self.presentationMode.wrappedValue.dismiss()
            })
        }, message: {
            Text("Hazard reported updated! Please note that it may take a few minutes for changes to be reflected on the app.")
        })
    }
    
}
