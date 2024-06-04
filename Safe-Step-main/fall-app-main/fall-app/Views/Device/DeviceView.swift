import SwiftUI

/// View to connect to MetaWear devices.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct DeviceView: View {
    /// Connection status object
    @EnvironmentObject var connectionStatus: ConnectionStatusObject
    
    @ObservedObject var bso: BatteryStatusObject = BatteryStatusObject()
    @ObservedObject var wristbso: BatteryStatusObject = BatteryStatusObject()
    
    // refresh every second
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var showAutoconnectDisablePopup: Bool = false
    
    @AppStorage("switchWaistWrist")
    var switchWaistWrist: Bool = false
    

    
   
    
    var body: some View {
        ZStack {
            VStack {
                Text("MetaWear Sensors")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.bottom, 4)
                    .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                VStack(spacing: 10) {
                    Text("Please keep the sensor within 4 feet of your iPhone and do not disable Bluetooth.")
                        .font(.system(size: 12))
                        .frame(width: 320)
                        .padding(.horizontal, 30) // Add horizontal padding on both sides
                        .multilineTextAlignment(.center) // Center-align the text on the next line
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                    if UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
                        Text("Sensors will automatically reconnect when disconnected.")
                            .font(.system(size: 12))
                            .frame(maxWidth: 320)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                    }
                }
                .padding(.bottom, 12)
                
                HStack {
                    // === LEFT SENSOR: START ===
                    VStack {
                        Text("Waist")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                        
                        if switchWaistWrist {
                            Sensor2(bso: bso, wristbso: wristbso)
                        }
                        else {
                            Sensor1(bso: bso, wristbso: wristbso)
                        }
                        
                    } //VStack
                    // === LEFT SENSOR: END ===
                    
                    Button(action: {
                        switchWaistWrist.toggle()
                    }) {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                    .padding([.horizontal], -4)
                    
                    // === RIGHT SENSOR: START ===
                    VStack {
                        Text("Wrist")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                        
                        if switchWaistWrist {
                            Sensor1(bso: bso, wristbso: wristbso)
                        }
                        else {
                            Sensor2(bso: bso, wristbso: wristbso)
                        }
                        
                    } //Vstack
                    // === RIGHT SENSOR: END ===
                    
                } //HStack
                
                
                // Manual
                Link(destination: URL(string: "https://mbientlab.com/tutorials/MetaMotionS.html")!) {
                    HStack {
                        Image(systemName: "book.fill")
                            .imageScale(.medium)
                        Text("User Manual")
                    }
                }
                .padding(.top, 16)
            } // VStack
            .onAppear {
                MetaWearManager.getWristBattery(bso: wristbso)
                MetaWearManager.getBattery(bso: bso)
            }
            
            
            
            
            
            // Modal: scanning
            if(connectionStatus.showModal()) {
                Spacer()
                    .frame(width: 2000, height: 2000) // TODO FIX invalid frame dimension?
                    .background(Color(white: 0).opacity(0.65))
                
                VStack {
                    // Sensor detected
                    if(connectionStatus.getStatus1() == ConnectionStatus.found || connectionStatus.getStatus2 () == .found) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                            Text("Detected!")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding(.bottom, -2)
                        
                        Text("Sensor detected. Please wait...")
                    }
                    // Still scanning...
                    else {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .imageScale(.large)
                            Text("Scanning...")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding(.bottom, -2)
                        
                        Text("Place the IMU sensor near your iPhone.")
                            .padding(.bottom, -2)
                        
                        Button("Cancel") {
                            MetaWearManager.stopScan(cso: connectionStatus)
                        }
                        .foregroundColor(Color(white: 0.7))
                    }
                }
                .frame(width: 350, height: 112)
                .background(Color(white: 0.13).opacity(0.98))
                .foregroundColor(Color(white: 0.95))
                .cornerRadius(12)
                .onDisappear {
                    MetaWearManager.getBattery(bso: bso)
                    MetaWearManager.getWristBattery(bso: wristbso)
                }
            } // if (scanning)
        } // ZStack
        // Refresh every 1 sec
        .onReceive(timer) { _ in
            MetaWearManager.connected(connectionStatus)
        }
        .alert("Disable autoconnect?", isPresented: $showAutoconnectDisablePopup, actions: {
            Button("Cancel", role: .cancel, action: {
                showAutoconnectDisablePopup = false
            })
            Button("Continue", role: nil, action: {
                MetaWearManager.disconnectBoard(cso: connectionStatus,
                                                bso: bso)
                UserDefaults.standard.setValue(false, forKey: "enableAutomaticDeviceScanning")
                showAutoconnectDisablePopup = false
            })
        }, message: {
            Text("Sensor autoconnect will be disabled. You can reenable this later in settings.")
        })
    } // body
    
    struct Sensor1: View {
        @EnvironmentObject var connectionStatus: ConnectionStatusObject
        @ObservedObject var bso: BatteryStatusObject
        @ObservedObject var wristbso: BatteryStatusObject
        
        var body: some View {
            Text(connectionStatus.connected1() ? "\(MetaWearManager.device1.mac ?? "Connected")" : " ")
                .font(.system(size: 11))
                .foregroundColor(Utilities.isDarkMode() ? Color(white: 0.65) : Color(white: 0.35))
            
            // Sensor image
            Image("metamotions")
                .resizable()
                .frame(width: 160, height: 160)
                .offset(y: 70)
                .padding(.top, -70)
            
            // Sensor status icon
            Image(connectionStatus.connected1() ? "checkmark_green" : "xmark_red")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, -30)
                .offset(x: 35, y: 40)
                .background(.white)
            
            // Gray box with text
            VStack {
                Spacer()
                    .frame(height: 28)
                Spacer()
                    .frame(height: 8)
                
            }//VStack
            .frame(width: 120, height: 30)
            .background(Color(white: 0.9))
            .cornerRadius(12)
            .zIndex(-10)
            
            VStack {
                Text(connectionStatus.connected1() ?  "Connected" : "Disconnected")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(connectionStatus.connected1() ? .green : (Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0)))
                    .padding([.vertical], 2)
                HStack {
                    
                    Image(systemName: connectionStatus.connected1() ? bso.battery_icon : "battery.0")
                        .imageScale(.small)
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                    Text(connectionStatus.connected1() ? bso.battery_percentage : "-")
                        .font(.system(size: 13))
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                }//HStack
            }
            .padding([.vertical], 8)
            .onAppear {
//                MetaWearManager.getWristBattery(bso: wristbso)
            }
            
            VStack{
                // Buttons
                if(connectionStatus.connected1()) { // when connected
                    // Disconnect
                    Button(action: {
                        if UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
                            UserDefaults.standard.set(false, forKey: "enableAutomaticDeviceScanning")
                        }
                        MetaWearManager.disconnectBoard(cso: connectionStatus, bso: bso)
                        
                    }) {
                        IconButtonInner(iconName: "xmark.square", buttonText: "Disconnect")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(white: 0.15),  foregroundColor: .white))
                    
                    // Ping
                    Button(action: {
                        MetaWearManager.pingBoard1()
                    }) {
                        IconButtonInner(iconName: "wave.3.right", buttonText: "Ping")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(red: 69/255, green: 104/255, blue: 218/255), foregroundColor: .white))
                }
                else {
                    // Connect
                    Button(action: {
                        MetaWearManager.scanBoard1(cso: connectionStatus)
                        UserDefaults.standard.set(true, forKey: "enableAutomaticDeviceScanning")
                    }) {
                        IconButtonInner(iconName: "link", buttonText: "Connect")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(red: 0, green: 146/255, blue: 12/255), foregroundColor: .white))
                }
            } // VStack
        }
    }
    
    struct Sensor2: View {
        @EnvironmentObject var connectionStatus: ConnectionStatusObject
        @ObservedObject var bso: BatteryStatusObject
        @ObservedObject var wristbso: BatteryStatusObject
        
        var body: some View {
            Text(connectionStatus.connected2() ? "\(MetaWearManager.device2.mac ?? "Connected")" : " ")
                .font(.system(size: 11))
                .foregroundColor(Utilities.isDarkMode() ? Color(white: 0.65) : Color(white: 0.35))
            // Sensor image
            Image("metamotions")
                .resizable()
                .frame(width: 160, height: 160)
                .offset(y: 70)
                .padding(.top, -70)
            
            // Sensor status icon
            Image(connectionStatus.connected2() ? "checkmark_green" : "xmark_red")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, -30)
                .offset(x: 35, y: 40)
                .background(.white)
            
            // Gray box with text
            VStack {
                Spacer()
                    .frame(height: 28)
                Spacer()
                    .frame(height: 8)
            }//VStack
            .frame(width: 120, height: 30)
            .background(Color(white: 0.9))
            .cornerRadius(12)
            .zIndex(-10)
            
            //
            VStack {
                Text(connectionStatus.connected2() ?  "Connected" : "Disconnected")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(connectionStatus.connected2() ? .green : (Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0)))
                    .padding([.vertical], 2)
                HStack {
                    Image(systemName: connectionStatus.connected2() ? wristbso.battery_icon : "battery.0")
                        .imageScale(.small)
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                    Text(connectionStatus.connected2() ? wristbso.battery_percentage : "-")
                        .font(.system(size: 13))
                        .foregroundColor(Utilities.isDarkMode() ? Color(white: 1) : Color(white: 0))
                }//HStack
            }
            .padding([.vertical], 8)
            .onAppear {
//                MetaWearManager.getBattery(bso: bso)
            }
            
            // Buttons
            VStack {
                if(connectionStatus.connected2()) { // when connected
                    // Disconnect
                    Button(action: {
                        if UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
                            UserDefaults.standard.set(false, forKey: "enableAutomaticDeviceScanning")
                        }
                        MetaWearManager.disconnectBoardWrist(wristcso: connectionStatus, wristbso: wristbso)
                        
                    }) {
                        IconButtonInner(iconName: "xmark.square", buttonText: "Disconnect")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(white: 0.15),
                                                  foregroundColor: .white))
                    
                    // Ping
                    Button(action: {
                        MetaWearManager.pingBoard2()
                    }) {
                        IconButtonInner(iconName: "wave.3.right", buttonText: "Ping")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(red: 69/255, green: 104/255, blue: 218/255),
                                                  foregroundColor: .white))
                    
                }
                else {
                    // Connect
                    Button(action: {
                        MetaWearManager.scanBoard2(cso: connectionStatus)
                        UserDefaults.standard.set(true, forKey: "enableAutomaticDeviceScanning")
                    }) {
                        IconButtonInner(iconName: "link", buttonText: "Connect")
                    }.buttonStyle(IconButtonStyle(width: 160, backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
                                                  foregroundColor: .white))
                }
            }
        }
    }
}

