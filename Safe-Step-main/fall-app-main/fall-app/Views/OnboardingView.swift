import SwiftUI

/// Onboarding screen asking for user information.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 12, 2023
///
struct OnboardingView: View {
    
    @State var name: String = ""
    @State var age: Int = 15
    @State var sex: String = "male"
    
    @State var q1: String = ""
    @State var q2: String = ""
    @State var q3: String = ""
    @State var q4: String = ""
    @State var q5: String = ""
    @State var q6: String = ""
    @State var q7: String = ""
    
    @Binding var userOnboarded: Bool
    
    
    @State var page: Int = 0
    
    var body: some View {
        // page 1
        if page == 0 {
            VStack {
                Text("Welcome!")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.bottom, -2)
                    .padding(.top, 54)
                Text("Please tell us about yourself.")
                    .padding(.bottom, 2)
                
                // personal info
                VStack {
                    Form {
                        // name
                        TextField("Full Name", text: $name)
                        
                        // age
                        Picker(selection: $age,
                               label: Text("Age")) {
                            ForEach(15..<70) { index in
                                Text("\(index)").tag(index)
                            }
                        }

                        // assigned sex at birth
                        Picker(selection: $sex,
                               label: Text("Sex Assigned at Birth")) {
                            Text("Male").tag("male")
                            Text("Female").tag("female")
                            Text("Intersex/Other").tag("intersex/other")
                        }
                    }
                }
                
                // continue button
                if !name.isEmpty && age > 14 {
                    VStack {
                        
                        Button(action: { page += 1 }) {
                            IconButtonInner(iconName: "arrow.right", buttonText: "Continue")
                        }
                        .buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                                      foregroundColor: .black))
                        .padding(.bottom, 12)
                        
                        VStack {
                            HStack {
                                Text("By continuing, you agree to the")
                                    .padding(.trailing, -5)
                                Link(destination: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/tnc.html")!) {
                                    Text("Terms and Conditions")
                                        .bold()
                                }
                            }
                            HStack {
                                Text("and the")
                                    .padding(.trailing, -5)
                                Link(destination: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/privacy-policy.html")!) {
                                    Text("Privacy Policy.")
                                        .bold()
                                }
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.5))
                        .padding(.bottom, 16)
                    }
                }
            } // VStack
        }
        // page 2
        else if page == 1 {
            let padding: CGFloat = 20
            questionnaire(padding) // VStack
        }
        // page 3
        else if page == 2 {
            VStack {
                WebView(url: URL(string: "http://\(AppConstants.serverAddress)/\(AppConstants.serverPath)/onboarding.html")!)
                Button(action: {
                    continueOnboarding()
                }) {
                    IconButtonInner(iconName: "checkmark", buttonText: "Finish")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
    }
    
    func continueOnboarding() {
        // upload
        FirebaseManager.connect()
        var user = User(name: name,
                        device_id: UIDevice.current.identifierForVendor?.uuidString ?? "",
                        age: Int(age),
                        sex: sex,
                        survey_responses: [
                            "1_vigorous_days_per_wk" : Int(q1) ?? 0,
                            "2_vigorous_mins_per_day" : Int(q2) ?? 0,
                            "3_moderate_days_per_wk" : Int(q3) ?? 0,
                            "4_moderate_mins_per_day" : Int(q4) ?? 0,
                            "5_walking_days_per_wk" : Int(q5) ?? 0,
                            "6_walking_mins_per_day" : Int(q6) ?? 0,
                            "7_sitting_hrs_per_day" : Int(q7) ?? 0
                        ])
        FirebaseManager.addUserInfo(user)
        
        // Set default values
        UserDefaults.standard.setValue(name, forKey: "userName")
        UserDefaults.standard.setValue(45, forKey: "walkingDetectionSensitivity")
        UserDefaults.standard.setValue(true, forKey: "receiveWalkingDetectionNotifications")
        UserDefaults.standard.setValue(true, forKey: "receiveErrorNotifications")
        UserDefaults.standard.setValue(true, forKey: "enableAutomaticDeviceScanning")
        
        // Permissions
        WalkingDetectionManager.initialize()
        NotificationManager.requestPermissions()
        MetaWearManager.locationManager.requestPermissions()
        
        // mark complete
        userOnboarded = true
        Toast.showToast("Welcome!")
    }
    
    fileprivate func questionnaire(_ padding: CGFloat) -> VStack<some View> {
        return VStack {
            GeometryReader { metrics in
                ScrollView(.vertical, showsIndicators: false) {
                    Text("Questionnaire")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, -2)
                        .padding(.top, 54)
                    Text("Now, please respond to the following brief questionnaire. Please read the questions carefully.")
                        .padding(.bottom, 16)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    
                    // Q 1-2
                    VStack {
                        VStack {
                            Text("Vigorous Activities")
                                .font(.system(size: 18, weight: .bold))
                                .padding([.vertical], 2)
                            
                            Text("Think about all the **vigorous** activities that you did in the **last 7 days**. Vigorous physical activities refer to activities that take hard physical effort and make you breathe much harder than normal. Think only about those physical activities that you did for at least 10 minutes at a time.")
                                .font(.system(size: 15.5))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 8)
                            
                            SurveyNumberField(question: "During the last 7 days, on how many days did you do vigorous physical activities like heavy lifting, digging, aerobics, or fast bicycling?",
                                              value: $q1,
                                              unit: "days per week",
                                              totalWidth: metrics.size.width - (padding * 2))
                            
                            if q1 != "" && q1 != "0" {
                                SurveyNumberField(question: "How much time did you usually spend doing vigorous physical activities on one of those days?",
                                                  value: $q2,
                                                  unit: "minutes per day",
                                                  totalWidth: metrics.size.width - (padding * 2))
                            }
                        }
                        .padding([.all], 12)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.08) : Color(white: 0.92))
                    .cornerRadius(16)
                    
                    // Q 3-4
                    VStack {
                        VStack {
                            Text("Moderate Activities")
                                .font(.system(size: 18, weight: .bold))
                                .padding([.vertical], 2)
                            
                            Text("Think about all the **moderate** activities that you did in the **last 7 days**. Moderate activities refer to activities that take moderate physical effort and make you breathe somewhat harder than normal.  Think only about those physical activities that you did for at least 10 minutes at a time.")
                                .font(.system(size: 15.5))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 8)
                            
                            SurveyNumberField(question: "During the last 7 days, on how many days did you do moderate physical activities like carrying light loads, bicycling at a regular pace, or doubles tennis? Do not include walking.",
                                              value: $q3,
                                              unit: "days per week",
                                              totalWidth: metrics.size.width - (padding * 2))
                            
                            if q3 != "" && q3 != "0" {
                                SurveyNumberField(question: "How much time did you usually spend doing moderate physical activities on one of those days?",
                                                  value: $q4,
                                                  unit: "minutes per day",
                                                  totalWidth: metrics.size.width - (padding * 2))
                            }
                        }
                        .padding([.all], 12)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.08) : Color(white: 0.92))
                    .cornerRadius(16)
                    
                    // Q 5-6
                    VStack {
                        VStack {
                            Text("Walking")
                                .font(.system(size: 18, weight: .bold))
                                .padding([.vertical], 2)
                            
                            Text("Think about the time you spent **walking** in the **last 7 days**. This includes at work and at home, walking to travel from place to place, and any other walking that you have done solely for recreation, sport, exercise, or leisure.")
                                .font(.system(size: 15.5))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 8)
                            
                            SurveyNumberField(question: "During the last 7 days, on how many days did you walk for at least 10 minutes at a time?",
                                              value: $q5,
                                              unit: "days per week",
                                              totalWidth: metrics.size.width - (padding * 2))
                            
                            if q5 != "" && q5 != "0" {
                                SurveyNumberField(question: "How much time did you usually spend walking on one of those days?",
                                                  value: $q6,
                                                  unit: "minutes per day",
                                                  totalWidth: metrics.size.width - (padding * 2))
                            }
                        }
                        .padding([.all], 12)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.08) : Color(white: 0.92))
                    .cornerRadius(16)
                    
                    // Q 7
                    VStack {
                        VStack {
                            Text("Sitting")
                                .font(.system(size: 18, weight: .bold))
                                .padding([.vertical], 2)
                            
                            Text("The last question is about the time you spent **sitting** on **weekdays** during the **last 7 days**. Include time spent at work, at home, while doing course work and during leisure time. This may include time spent sitting at a desk, visiting friends, reading, or sitting or lying down to watch television.")
                                .font(.system(size: 15.5))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 8)
                            
                            SurveyNumberField(question: "During the last 7 days, how much time did you spend sitting on a week day?",
                                              value: $q7,
                                              unit: "hours per day",
                                              totalWidth: metrics.size.width - (padding * 2))
                        }
                        .padding([.all], 12)
                    }
                    .background(Utilities.isDarkMode() ? Color(white: 0.08) : Color(white: 0.92))
                    .cornerRadius(16)
                    
                    // continue button
                    if !q1.isEmpty && !q3.isEmpty && !q5.isEmpty && !q7.isEmpty {
                        Text("This is the end of the questionnaire, thank you for participating! Almost there!")
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.bottom, -2)
                            .frame(maxWidth: 360)
                        
                        Button(action: {
                            page += 1
                        }) {
                            IconButtonInner(iconName: "arrow.right", buttonText: "Continue")
                        }
                        .buttonStyle(IconButtonStyle(backgroundColor: .yellow, foregroundColor: .black))
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                    }
                    else {
                        Text("Please respond to all questions above.")
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                } // GeometryReader
            } // ScrollView
            .padding([.horizontal], padding)
            
            
        }
    }
}


