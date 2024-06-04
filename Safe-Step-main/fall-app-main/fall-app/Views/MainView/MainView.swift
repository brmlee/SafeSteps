import SwiftUI

/// Main view of the application, with the "Start Walking" / "Stop Walking" button
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 31, 2023
///
struct MainView: View
{
    /// Tab selection on `ContentView`.
    @Binding var tabSelection: Int;
    
    /// Show survey popup?
    @State var showSurvey: Bool = false // SurveyBuildingsView
    @State var showSurveySinglePoint: Bool = false // single point report
    
    /// Timer used to read users location every 3 minutes.
    /// Prevents iPhone from suspending the app from background (hopefully)
    @State var timer = Timer.publish(every: 180, on: .main, in: .common).autoconnect()
    
    @AppStorage("enableAutomaticDeviceScanning")
    var enableAutomaticDeviceScanning: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if enableAutomaticDeviceScanning {
                    Text("Sensor Autoconnect Enabled")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(Color(white: 0.5))
                }
                else {
                    Spacer()
                        .frame(height: 8)
                }
                
            
                // Logos
                MainView_Logos()
                
                Spacer()
                
                // Info text
                VStack {
                    Text("SafeSteps")
                        .font(.system(size: 32, weight: .bold))
                    Text("Report environmental slip, trip, and fall hazards and stay informed!")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 350)
                }
                .offset(y: -8)
                
                // Graphic
                GeometryReader { metrics in
                    Image("main_graphic")
                        .resizable()
                        .frame(width: metrics.size.width, height: metrics.size.width  * 800 / 1280,
                               alignment: .center)
                        .offset(y: -16)
                }
                
                Spacer()
                    .frame(maxHeight: 160)
                
                // Interactible (code below)
                MainView_Interact_Manual(showSurvey: $showSurvey,
                                  showSurveySinglePoint: $showSurveySinglePoint,
                                  tabSelection: $tabSelection)
                
                // Sheet - SurveyBuildingsView
                .sheet(isPresented: $showSurvey) {
                    SurveyBuildingsView(showSurvey: $showSurvey,
                                        tabSelection: $tabSelection)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled()
                }
                .sheet(isPresented: $showSurveySinglePoint) {
                    SurveyBuildingsView(showSurvey: $showSurveySinglePoint,
                                        tabSelection: $tabSelection,
                                        singlePointReport: true)
                    .presentationDetents([.large])
                }
            } // VStack
            .onReceive(timer) { input in
                let loc = MetaWearManager.locationManager.getLocation()
            }
        }
    } // main
    
}

struct MainView_Interact_Manual: View {
    
    // used for rotating animation
    @State var animationBool: Bool = false
    
    /// Whether walking is recording or not.
    /// Gets data from`MetaWearManager.connected()` every 1 second.
    @State var isRecording: Bool = false
    
    /// Used to determine sensor connection status.
    @EnvironmentObject var cso: ConnectionStatusObject
    
    @Binding var showSurvey: Bool
    @Binding var showSurveySinglePoint: Bool
    @State var showCancelPopup: Bool = false
    @Binding var tabSelection: Int
    
    // refresh every second
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @AppStorage("switchWaistWrist")
    var switchWaistWrist: Bool = false
    
    var body: some View {
        // Status
        HStack {
            if switchWaistWrist {
                StatusItem(active: $cso.conn2,
                           activeText: "Waist",
                           inactiveText: "Waist")
                    .padding(.trailing, 8)
                StatusItem(active: $cso.conn1,
                           activeText: "Wrist",
                           inactiveText: "Wrist")
            }
            else {
                StatusItem(active: $cso.conn1,
                           activeText: "Waist",
                           inactiveText: "Waist")
                    .padding(.trailing, 8)
                StatusItem(active: $cso.conn2,
                           activeText: "Wrist",
                           inactiveText: "Wrist")
            }
            
        }
        
        // Interact
        VStack {
            Spacer()
                .frame(height: 12)
            
            // walking indicator
            HStack {
                let circleSize: CGFloat = 16
                let circleLineWidth: CGFloat = 3
                
                ZStack {
                    let wheelColor = Utilities.isDarkMode() ? Color(white: 0.3) : Color(white: 0.7)
                    Circle()
                        .stroke(wheelColor, lineWidth: circleLineWidth)
                        .frame(width: circleSize, height: circleSize)
                        .zIndex(-999)
                    
                    if isRecording && cso.conn1 && cso.conn2 {
                        Circle() // animation
                            .trim(from: 0, to: 0.25)
                            .stroke(.cyan, lineWidth: circleLineWidth)
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(Angle(degrees: animationBool ? 360 : 0))
                            .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                            .onAppear {
                                animationBool = true
                            }
                            .onChange(of: isRecording) { _ in
                                animationBool = false
                                animationBool = true
                            }
                    }
                    else if !cso.conn1 || !cso.conn2 { // disconnected
                        Image("xmark_red")
                            .resizable()
                            .frame(width: circleSize + (circleLineWidth * 2),
                                   height: circleSize + (circleLineWidth * 2))
                    }
                    
                }
                .frame(width: circleSize, height: circleSize)
                
                let statusText = isRecording ? (cso.conn1 && cso.conn2 ? "Recording" : "Suspended") : "Not Recording"
                Text(statusText)
                    .padding(.leading, 4)
                    .font(.system(size: 16, weight: .semibold))
            } // HStack
            
            // text or button
            if isRecording { // recording
                
                if !cso.conn1 || !cso.conn2 { // sensor disconnected
                    Text("Please reconnect to the sensor.")
                        .font(.system(size: 14))
                        .frame(maxWidth: 330)
                        .multilineTextAlignment(.center)
                }
                
                // end, report hazard
                Button(action: {
                    showSurvey = true
                    MetaWearManager().stopRecording()
                    WalkingDetectionManager.enableDetection(false)
                    isRecording = false
                    animationBool = false
                    WalkingDetectionManager.reset()
                }) {
                    IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Report Hazard")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                             foregroundColor: .black))
                
                // end, no hazard
                Button(action: {
                    MetaWearManager().stopRecording()
                    isRecording = false
                    animationBool = false
                    MetaWearManager.sendHazardReport(hazards: AppConstants.hazards,
                                                     intensity: AppConstants.defaultHazardIntensity,
                                                     imageId: "")
                    Toast.showToast("Submitted. Thank you!")
                    tabSelection = 2;
                }) {
                    IconButtonInner(iconName: "stop.circle.fill", buttonText: "End Session (no hazard)")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: Color(white: 0.4),
                                             foregroundColor: .white))
                
                // cancel
                Button(action: {
                    showCancelPopup = true
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .imageScale(.small)
                        Text("Cancel Session")
                            .font(.system(size: 14))
                    }
                    .padding(.top, 2)
                }
            }
            else if !cso.conn1 || !cso.conn2 { // sensor disconnected & not recording
                
                Text("Please connect the sensors to enable walking detection.")
                .font(.system(size: 14))
                .frame(maxWidth: 330)
                .multilineTextAlignment(.center)
                
                //                // Report Hazard (not recording)
                Button(action: {
                    showSurveySinglePoint = true
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .offset(y: -1)
                        Text("Report Hazard")
                            .font(.system(size: 13))
                            .padding(.top, -2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            else if !isRecording { // not recording
                
                Button(action: {
                    MetaWearManager().startRecording();
                    isRecording = true;
                }) {
                    IconButtonInner(iconName: "record.circle", buttonText: "Start Recording")
                }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 155/255, green: 255/255, blue: 249/255),
                                              foregroundColor: .black))
                .padding(.bottom, 2)
                
                Button(action: {
                    showSurveySinglePoint = true
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .offset(y: -1)
                        Text("Report Hazard")
                            .font(.system(size: 13))
                            .padding(.top, -2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            Spacer()
                .frame(height: 12)
        } // VStack
        .frame(width: 350)
        .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
        .cornerRadius(12)
        .padding(.bottom, 4).padding(.top, -2)
        .onAppear {
            MetaWearManager.connected(cso)
            WalkingDetectionManager.initialize()
            NotificationManager.requestPermissions()
            MetaWearManager.locationManager.requestPermissions()
        }
        // Refresh every 0.5 sec
        .onReceive(timer) { _ in
            isRecording = MetaWearManager.recording
//            MetaWearManager.connected(cso)
            
//            if cso.status == .notConnected
//                && UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
//                MetaWearManager.scanBoard1(cso: cso)
//            }
//            if cso.wristStatus == .notConnected && UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
//                MetaWearManager.scanBoard2(cso: cso)
//            }
        }
        // Handles animation
        .onChange(of: isRecording) { _ in
            if isRecording == false {
                animationBool = false
            }
        }
        // Popup when user
        .alert("Cancel?", isPresented: $showCancelPopup, actions: {
            Button("Cancel Session", role: .destructive, action: {
                MetaWearManager().stopRecording()
                isRecording = false
                animationBool = false
                MetaWearManager.cancelSession()
                WalkingDetectionManager.reset()
                showCancelPopup = false
                Toast.showToast("Successfully cancelled.")
            })
            Button("Back", role: .cancel, action: {
                showCancelPopup = false
            })
        }, message: {
            Text("Are you sure you want to cancel the ongoing walking session?")
        })
        
        Spacer()
            .frame(maxHeight: 32)
    }
}


/// Walking detection
struct MainView_Interact_Auto: View {
    
    // used for rotating animation
    @State var animationBool: Bool = false
    
    /// Whether walking is recording or not.
    /// Gets data from`MetaWearManager.connected()` every 1 second.
    @State var isRecording: Bool = false
    
    /// Used to determine sensor connection status.
    @EnvironmentObject var cso: ConnectionStatusObject
    
    @Binding var showSurvey: Bool
    @Binding var showSurveySinglePoint: Bool
    @State var showCancelPopup: Bool = false
    @Binding var tabSelection: Int
    
    // refresh every second
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        // Status
        HStack {
            StatusItem(active: $cso.conn1,
                       activeText: "Waist",
                       inactiveText: "Waist")
            StatusItem(active: $cso.conn2,
                       activeText: "Wrist",
                       inactiveText: "Wrist")
        }
        
        
        // Interact
        VStack {
            Spacer()
                .frame(height: 12)
            
            // walking indicator
            HStack {
                let circleSize: CGFloat = 16
                let circleLineWidth: CGFloat = 3
                
                ZStack {
                    let wheelColor = Utilities.isDarkMode() ? Color(white: 0.3) : Color(white: 0.7)
                    Circle()
                        .stroke(wheelColor, lineWidth: circleLineWidth)
                        .frame(width: circleSize, height: circleSize)
                        .zIndex(-999)
                    
                    if isRecording && cso.conn1 && cso.conn2 {
                        Circle() // animation
                            .trim(from: 0, to: 0.25)
                            .stroke(.cyan, lineWidth: circleLineWidth)
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(Angle(degrees: animationBool ? 360 : 0))
                            .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                            .onAppear {
                                animationBool = true
                            }
                            .onChange(of: isRecording) { _ in
                                animationBool = false
                                animationBool = true
                            }
                    }
                    else if !cso.conn1 || !cso.conn2 { // disconnected
                        Image("xmark_red")
                            .resizable()
                            .frame(width: circleSize + (circleLineWidth * 2),
                                   height: circleSize + (circleLineWidth * 2))
                    }
                    
                }
                .frame(width: circleSize, height: circleSize)
                
                let statusText = isRecording ? (cso.conn1 && cso.conn2 ? "Recording" : "Suspended") : "Not Recording"
                Text(statusText)
                    .padding(.leading, 4)
                    .font(.system(size: 16, weight: .semibold))
            } // HStack
            
            // text or button
            if isRecording { // recording
                
                if !cso.conn1 || !cso.conn2 { // sensor disconnected
                    Text("Please reconnect to the sensor.")
                        .font(.system(size: 14))
                        .frame(maxWidth: 330)
                        .multilineTextAlignment(.center)
                }
                
                // end, report hazard
                Button(action: {
                    showSurvey = true
                    MetaWearManager().stopRecording()
                    WalkingDetectionManager.enableDetection(false)
                    isRecording = false
                    animationBool = false
                    WalkingDetectionManager.reset()
                }) {
                    IconButtonInner(iconName: "exclamationmark.triangle", buttonText: "Report Hazard")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: .yellow,
                                             foregroundColor: .black))
                
                // end, no hazard
                Button(action: {
                    MetaWearManager().stopRecording()
                    isRecording = false
                    animationBool = false
                    MetaWearManager.sendHazardReport(hazards: AppConstants.hazards,
                                                     intensity: AppConstants.defaultHazardIntensity,
                                                     imageId: "")
                    Toast.showToast("Submitted. Thank you!")
                    tabSelection = 2;
                }) {
                    IconButtonInner(iconName: "stop.circle.fill", buttonText: "End Session (no hazard)")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: Color(white: 0.4),
                                             foregroundColor: .white))
                
                // cancel
                Button(action: {
                    showCancelPopup = true
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .imageScale(.small)
                        Text("Cancel Session")
                            .font(.system(size: 14))
                    }
                    .padding(.top, 2)
                }
            }
            else if !cso.conn1 || !cso.conn2 { // sensor disconnected & not recording
                
                Text("Please connect the sensors to enable walking detection.")
                    .font(.system(size: 14))
                    .frame(maxWidth: 330)
                    .multilineTextAlignment(.center)
                
//                // Report Hazard (not recording)
                Button(action: {
                    showSurveySinglePoint = true
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .offset(y: -1)
                        Text("Report Hazard")
                            .font(.system(size: 13))
                            .padding(.top, -2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            else if !isRecording { // not recording
                Text("Start walking to automatically start recording.\nFeel free to leave the app.")
                    .font(.system(size: 14))
                    .frame(maxWidth: 330)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    showSurveySinglePoint = true
                }) {
                    HStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .offset(y: -1)
                        Text("Report Hazard")
                            .font(.system(size: 13))
                            .padding(.top, -2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            Spacer()
                .frame(height: 12)
        } // VStack
        .frame(width: 350)
        .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
        .cornerRadius(12)
        .padding(.bottom, 4).padding(.top, -2)
        .onAppear {
            MetaWearManager.connected(cso)
            WalkingDetectionManager.initialize()
            NotificationManager.requestPermissions()
            MetaWearManager.locationManager.requestPermissions()
        }
        // Refresh every 0.5 sec
        .onReceive(timer) { _ in
            isRecording = MetaWearManager.recording
            WalkingDetectionManager.initialize()
//            M etaWearManager.connected(cso)
            
//            if cso.status == .notConnected
//                && UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
//                MetaWearManager.scanBoard1(cso: cso)
//            }
        }
        // Handles animation
        .onChange(of: isRecording) { _ in
            if isRecording == false {
                animationBool = false
            }
        }
        // Popup when user
        .alert("Cancel?", isPresented: $showCancelPopup, actions: {
            Button("Cancel Session", role: .destructive, action: {
                MetaWearManager().stopRecording()
                isRecording = false
                animationBool = false
                MetaWearManager.cancelSession()
                WalkingDetectionManager.reset()
                showCancelPopup = false
                Toast.showToast("Successfully cancelled.")
            })
            Button("Back", role: .cancel, action: {
                showCancelPopup = false
            })
        }, message: {
            Text("Are you sure you want to cancel the ongoing walking session?")
        })
        
        
        Spacer()
            .frame(maxHeight: 32)
    } // body
}



/// Logos used in `MainView`
struct MainView_Logos: View {
    var body: some View {
        GeometryReader { metrics in
            HStack(alignment: .center) {
                // DPM
                HStack {
                    Image("block_m_logo")
                        .resizable()
                        .frame(width: metrics.size.width * 0.12,
                               height: metrics.size.width * 0.12 * 830 / 1162,
                               alignment: .center)
                        .padding(.trailing, -4)
                    VStack {
                        Text("DYNAMIC")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                            .padding(.bottom, -10)
                        Text("PROJECT")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                            .padding(.bottom, -10)
                        Text("MANAGEMENT")
                            .frame(width: metrics.size.width * 0.22,
                                   alignment: .leading)
                            .font(Font.custom("NunitoSans-12ptExtraLight_Regular", size: 11))
                    }
                    .frame(width: metrics.size.width * 0.25)
                }
                // Liberty Mutual
//                VStack {
//                    Image("liberty_mutual_logo_tb")
//                        .resizable()
//                        .frame(width: metrics.size.width * 0.45,
//                               height: metrics.size.width * 0.45 * 317 / 1140,
//                               alignment: .center)
//                    Spacer()
//                        .frame(height: 8)
//                }
//                .background(.white)
//                .cornerRadius(8)
                
            }
            .frame(width: metrics.size.width)
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView_Preview()
    }
}

/// For preview
struct MainView_Preview: View {
    @State var tabSelection: Int = 0
    
    var body: some View {
        MainView(tabSelection: $tabSelection)
    }
}
