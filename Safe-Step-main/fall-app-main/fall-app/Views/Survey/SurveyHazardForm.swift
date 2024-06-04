import SwiftUI
import PhotosUI

/// Popup view that asks users the details about the fall risk after user selected building & floor.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
struct SurveyHazardForm: View {
    @Binding var showSurvey: Bool
 
    /// Types of hazards to be shown
    var hazards: [String]
    var hazardIcons: [String]
    
    /// Intensity of hazards
    @State var intensity: [Int] = [0, 0, 0, 0, 0, 0]
    
    @State var hazardImageId: String = ""
    
    /// Show photo picker / camera?
    @State var showPhotoPicker: Bool = false
    
    /// Show "no hazard selected" alert?
    @State var showAlert: Bool = false;
    
    /// Show "no photo uploaded" alert?
    @State var showAlert2: Bool = false;
    
    /// Tab selection number on `ContentView`
    @Binding var tabSelection: Int
    
    var buildingId: String
    var buildingFloor: String
    var buildingRemarks: String = ""
    var buildingHazardLocation: String
    
    var singlePointReport: Bool = false
    
    var body: some View {
        VStack {
            // Scroll view
            ScrollView(.vertical, showsIndicators: false)
            {
                HStack {
                    Text("Please report all hazards you experienced\nand their intensities:")
                        .font(.system(size: 16))
                        .padding(.top, 24)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                }
                
                // Hazards form
                ForEach(hazards.indices) { index in
                    SurveyDropdown(label: hazards[index],
                                   icon: hazardIcons[index],
                                   optionTexts: AppConstants.optionTexts,
                                   optionValues: AppConstants.optionValues,
                                    value: $intensity[index])
                }
                
                // Disclaimer text
                Text("To help us identify and analyze the fall risk,\nplease take a photo of the hazard.")
                    .font(.system(size: 14))
                    .padding(.top, 12)
                    .multilineTextAlignment(.center)
                
                // Take Photo
                Button(action: {
                    showPhotoPicker = true
                }) {
                    if hazardImageId == "" {
                        IconButtonInner(iconName: "camera.fill", buttonText: "Take Photo")
                    }
                    else {
                        IconButtonInner(iconName: "checkmark.circle.fill", buttonText: "Photo Selected")
                    }
                }
                .buttonStyle(IconButtonStyle(backgroundColor: hazardImageId == "" ? .cyan : .gray,
                                             foregroundColor: hazardImageId == "" ? .black : .white))
                
                // Disclaimer text
                Text("This form is not monitored. If you need medical assistance,\nplease call 911 or your local healthcare provider.")
                    .font(.system(size: 10))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
                
                // Submit Button
                Button(action: {
                    sendHazardReport(mustSelect: true)
                }) {
                    IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
                }.buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            
            // Alert
            .alert("No Hazard Selected", isPresented: $showAlert, actions: {
                Button("Submit",  role: .destructive, action: {
                    sendHazardReport(mustSelect: false,
                                     mustUploadPhoto: false)
                    showAlert = false;
                })
                Button("Cancel",  role: .cancel, action: { showAlert = false; })
            }, message: {
                Text("You have not selected any hazards to report. Are you sure you want to report no hazard?")
            })
            .alert("No Photo Uploaded", isPresented: $showAlert2, actions: {
                Button("Submit",  role: .destructive, action: {
                    sendHazardReport(mustSelect: false,
                                     mustUploadPhoto: false)
                    showAlert2 = false;
                })
                Button("Cancel",  role: .cancel, action: { showAlert2 = false; })
            }, message: {
                Text("You have not uploaded a photo of the hazard. Photos help us identify and analyze the fall risk. Are you sure you want to submit a report without a photo?")
            })
            .navigationTitle(Text("Report Fall Risk"))
        }
        // Photo Picker
        .sheet(isPresented: $showPhotoPicker) {
            ImagePickerView() { image in
                hazardImageId = UUID().uuidString
                FirebaseManager.uploadHazardImage(uuid: hazardImageId,
                                             image: image)
                showPhotoPicker = false
            }.presentationDetents([.large])
        }
    }
                      
    
    /// Sends hazard report to Firebase and closes the survey.
    func sendHazardReport(mustSelect: Bool = true,
                          mustUploadPhoto: Bool = true) {
        // Hazard not selected?
        if noHazardSelected() && mustSelect {
            showAlert = true;
            return;
        }
        if hazardImageId == "" && mustUploadPhoto {
            showAlert2 = true;
            return;
        }
        
        WalkingDetectionManager.enableDetection(true)
        MetaWearManager.sendHazardReport(hazards: hazards,
                                         intensity: intensity,
                                         imageId: hazardImageId,
                                         buildingId: buildingId,
                                         buildingFloor: buildingFloor,
                                         buildingRemarks: buildingRemarks,
                                         buildingHazardLocation: buildingHazardLocation,
                                         singlePointReport: singlePointReport)

        showSurvey = false;
        Toast.showToast("Submitted. Thank you!")
        tabSelection = 2; // switch to HistoryView
    }

    /// Returns true if user did not select any hazard to report, false otherwise.
    func noHazardSelected() -> Bool {
        for i in intensity {
            if(i != 0) {
                return false;
            }
        }
        return true;
    }
    
    /// Clears intensities to 0 when pressing "Back".
    func clearIntensities() {
        for index in intensity.indices {
            intensity[index] = 0;
        }
    }
}


/// OBSOLETE
/// Popup view that asks users if they experienced fall risk.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
//struct Survey1: View {
//
//    @Binding var showPopup1: Bool
//    @State var showPopup2: Bool = false
//    @Binding var tabSelection: Int
//
//    /// Intensity for each hazards. Default value = 0. Size must match that of `hazards`.
//    @State private var intensity: [Int] = [0, 0, 0, 0, 0, 0];
//
//
//    var body: some View {
//        VStack {
//            // Header
//            Text("Recording Complete!")
//                .fontWeight(.bold)
//                .font(.system(size: 24))
//                .padding(.bottom, -6)
//            Text("Did you experience fall risk?")
//                .font(.system(size: 20))
//
//            // Report Hazard
//            Button(action: {
//                showPopup2 = true
//            }) {
//                IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Yes, report")
//            }.buttonStyle(IconButtonStyle(backgroundColor: .yellow,
//                                         foregroundColor: .black))
//
//            // Don't report
//            Button(action: sendReport) {
//                IconButtonInner(iconName: "xmark", buttonText: "No, close")
//            }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0.2, green: 0.2, blue: 0.2),
//                                         foregroundColor: .white))
//
//            // Bottom
//            Text("Your response will be recorded. Thank you!")
//                .font(.system(size: 10))
//                .padding(.top, 0)
//        }
//        .sheet(isPresented: $showPopup2) {
//            SurveyHazardForm(showPopup1: $showPopup1, showPopup2: $showPopup2,
//                    hazards: AppConstants.hazards, hazardIcons: AppConstants.hazardIcons,
//                    tabSelection: $tabSelection)
//                .presentationDetents([.large])
//        }
//
//    }
//
//    /// Sends hazard report (with no hazards) to Firebase and closes the popup.
//    func sendReport() {
//        // Firebase
//        MetaWearManager.sendHazardReport(hazards: AppConstants.hazards,
//                                         intensity: intensity,
//                                         imageId: "")
//        showPopup1 = false;
//        tabSelection = 2; // switch to HistoryView
//        Toast.showToast("Submitted. Thank you!")
//    }
//}
