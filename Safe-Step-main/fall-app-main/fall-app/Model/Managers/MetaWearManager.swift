import CoreLocation
import MetaWear
import MetaWearCpp

/// Handles all MetaWear API-related actions.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21, 2023
///
class MetaWearManager
{
    /// MetaWear device variable
    static var device1: MetaWear!
    static var device2: MetaWear!
    
    /// LocationManager object
    static var locationManager = LocationManager()
    
    /// Whether walking recording or not
    static var recording: Bool = false
    
    /// Start location of a session.
    static var startLocation: [Double] = []
    
    /// Start time of a session.
    static var startTime: Double = 0
    
    /// RealtimeWalkingData object
    static var realtimeData: RealtimeWalkingData = RealtimeWalkingData()
    
    /// List of document names of realtime (gyroscope and location) data
    static var realtimeDataDocNames: [String] = []

    
    /// Scans the board and updates the status on`cso`.
    static func scanBoard1(cso: ConnectionStatusObject) {
        // Set status
        print("Scanning...")
        cso.setStatus1(status: ConnectionStatus.scanning)
        
        // Scan
        let signalThreshold = -90
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (d) in
            // Close sensor found?
            if d.rssi > signalThreshold {
                MetaWearScanner.shared.stopScan()
                cso.setStatus1(status: ConnectionStatus.found)
                
                d.connectAndSetup().continueWith { t in
                    if let error = t.error { // failed to connect
                        print("ERROR!!")
                        print(error)
                        cso.setStatus1(status: ConnectionStatus.notConnected)
                    }
                    else { // success
                        print("Device connected")
                        cso.setStatus1(status: ConnectionStatus.connected)
                        MetaWearManager.device1.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                        WalkingDetectionManager.initialize()
                    }
                    
                    // On disconnected
                    t.result?.continueWith { t in
                        if UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
                            scanBoard1(cso: cso)
                        }
                        
                        print("Device disconnected, unexpectedly")
                        cso.setStatus1(status: ConnectionStatus.notConnected)
                        
                        // notifications
                        if (UserDefaults.standard.bool(forKey: "receiveErrorNotifications")) {
                            let body = recording ? "Ongoing walking session temporarily suspended. Please reconnect to your IMU sensor on the app." :
                            "Walking detection is not available while disconnected. Please reconnect to your IMU sensor on the app."
                            NotificationManager.sendNotificationNow(title: "Sensor Disconnected",
                                                                    body: body,
                                                                    rateLimit: 60,
                                                                    rateLimitId: "sensorDisconnectAlert")
                        }
                    }
            }
                
                // Set device on complete
                MetaWearManager.device1 = d
                MetaWearManager.device1.remember()
            }
        }
            
    }
    
    static func scanBoard2(cso: ConnectionStatusObject){
        print("Scanning...")
        cso.setStatus2(status: ConnectionStatus.scanning)
        
        // Scan
        let signalThreshold = -999
        
        MetaWearScanner.shared.startScan(allowDuplicates: true) { (w) in
            // Close sensor found?
            
            if w.rssi > signalThreshold {
                MetaWearScanner.shared.stopScan()
                cso.setStatus2(status: ConnectionStatus.found)
                
                w.connectAndSetup().continueWith { t in
                    if let error = t.error { // failed to connect
                        print("ERROR!!")
                        print(error)
                        cso.setStatus1(status: ConnectionStatus.notConnected)
                    }
                    else { // success
                        print("Device connected")
                        cso.setStatus2(status: ConnectionStatus.connected)
                        MetaWearManager.device2.flashLED(color: .green, intensity: 1.0, _repeat: 3)
                        WalkingDetectionManager.initialize()
                    }
                    
                    // On disconnected
                    t.result?.continueWith { t in
                        if UserDefaults.standard.bool(forKey: "enableAutomaticDeviceScanning") {
                            scanBoard2(cso: cso)
                        }
                        print("Device disconnected, unexpectedly")
                        cso.setStatus2(status: ConnectionStatus.notConnected)
                        
                        // notifications
                        if (UserDefaults.standard.bool(forKey: "receiveErrorNotifications")) {
                            let body = recording ? "Ongoing walking session temporarily suspended. Please reconnect to your IMU sensor on the app." :
                            "Walking detection is not available while disconnected. Please reconnect to your IMU sensor on the app."
                            NotificationManager.sendNotificationNow(title: "Sensor Disconnected",
                                                                    body: body,
                                                                    rateLimit: 60,
                                                                    rateLimitId: "sensorDisconnectAlert")
                        }
                    }
                }
                
                // Set device on complete
                MetaWearManager.device2 = w
                MetaWearManager.device2.remember()
            }
        }
    
    }
    
    
    /// Flashes blue LED on board, to identify boards.
    static func pingBoard1() {
        MetaWearManager.device1.flashLED(color: .blue, intensity: 1.0, _repeat: 3)
    }
    static func pingBoard2() {
        MetaWearManager.device2.flashLED(color: .blue, intensity: 1.0, _repeat: 3)
    }
    
    /// Stops scanning for the board and updates the status on `cso`.
    /// Called when user cancels scanning.
    static func stopScan(cso: ConnectionStatusObject) {
        print("Stopping scan")
        MetaWearScanner.shared.stopScan()
        cso.setStatus1(status: ConnectionStatus.notConnected)
    }
    
    /// Returns whether a device is connected or not.
    static func connected() -> Bool {
        if device1 == nil {
            return false;
        }
        return device1.isConnectedAndSetup
    }
    static func wristConnected() -> Bool {
        if device2 == nil {
            return false;
        }
        return device2.isConnectedAndSetup
    }
    
     

    /// Returns whether a device is connected or not.
    static func connected(_ cso: ConnectionStatusObject) {
        if device1 == nil {
            cso.conn1 = false;
        }
        else {
            cso.conn1 = device1.isConnectedAndSetup
        }
    }

    static func wristConnected(_ cso: ConnectionStatusObject) {
      if device2 == nil {
         cso.conn2 = false
      } else {
         cso.conn2 = device2.isConnectedAndSetup
      }
    }
    
    
    /// Disconnects (and resets) the board.
    static func disconnectBoard(cso: ConnectionStatusObject,
                                bso: BatteryStatusObject) {
        device1.connectAndSetup().continueWith { t in
            cso.setStatus1(status: ConnectionStatus.disconnecting)
            MetaWearManager.device1.flashLED(color: .red, intensity: 1.0, _repeat: 1)
            
            device1.clearAndReset()
            cso.setStatus1(status: ConnectionStatus.notConnected)
            getBattery(bso: bso)
            print("Disconnected")
        }
    }
    static func disconnectBoardWrist(wristcso: ConnectionStatusObject,
                                     wristbso: BatteryStatusObject) {
         device2.connectAndSetup().continueWith { t in
             wristcso.setStatus2(status: ConnectionStatus.disconnecting)
             MetaWearManager.device2.flashLED(color: .red, intensity: 1.0, _repeat: 1)
             
             device2.clearAndReset()
             wristcso.setStatus2(status: ConnectionStatus.notConnected)
             getBattery(bso: wristbso)
             print("Disconnected")
         }
     }
    
    /// Starts recording the gyroscope and location data.
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    func startRecording() {
        // Reset
        MetaWearManager.realtimeData.resetData()
        MetaWearManager.locationManager.startRecording()
        MetaWearManager.realtimeDataDocNames = []
        MetaWearManager.recording = true
        
        FirebaseManager.connect()
        
        // Config
        let board1 = MetaWearManager.device1.board
        let gyroSignal1 = mbl_mw_gyro_bmi160_get_rotation_data_signal(board1)!
        let accSignal1 = mbl_mw_acc_bosch_get_acceleration_data_signal(board1)!
        
        let board2 = MetaWearManager.device2.board
        let gyroSignal2 = mbl_mw_gyro_bmi160_get_rotation_data_signal(board2)!
        let accSignal2 = mbl_mw_acc_bosch_get_acceleration_data_signal(board2)!
        
        mbl_mw_gyro_bmi160_set_odr(board1, MBL_MW_GYRO_BOSCH_ODR_50Hz);
        mbl_mw_gyro_bmi160_write_config(board1);
        mbl_mw_gyro_bmi160_set_odr(board2, MBL_MW_GYRO_BOSCH_ODR_50Hz);
        mbl_mw_gyro_bmi160_write_config(board2);
        
        mbl_mw_acc_set_odr(board1, 50);
        mbl_mw_acc_write_acceleration_config(board1);
        mbl_mw_acc_set_odr(board2, 50);
        mbl_mw_acc_write_acceleration_config(board2);
        
        // Increase signal strength
        mbl_mw_settings_set_tx_power(board1, 4)
        mbl_mw_settings_set_tx_power(board2, 4)
        mbl_mw_settings_set_connection_parameters(board1, 7.5, 7.5, 0, 16000)
        mbl_mw_settings_set_connection_parameters(board2, 7.5, 7.5, 0, 16000)
        
        // Record start time and location
        MetaWearManager.startLocation = MetaWearManager.locationManager.getLocation()
        MetaWearManager.startTime = Date().timeIntervalSince1970
        
        // Sensor 1 - Gyroscope
        mbl_mw_datasignal_subscribe(gyroSignal1, bridge(obj: self)) { (context, data) in
            // Get and add data
            let gyroscope: MblMwCartesianFloat = data!.pointee.valueAs()
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(data: gyroscope, dataType: "gyroscope",
                                                                          location: location, sensorId: UserDefaults.standard.bool(forKey: "switchWaistWrist") ? 2 : 1))
            
            // Split it by 3000 data points (30 sec @ 50 Hz * 2 sensors)
            if MetaWearManager.realtimeData.size() > 3000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(MetaWearManager.device1.board)
        mbl_mw_gyro_bmi160_start(board1)
        
        
        // Sensor 1 - Accelerometer
        mbl_mw_datasignal_subscribe(accSignal1, bridge(obj: self)) { (context, data) in
            let acc: MblMwCartesianFloat = data!.pointee.valueAs()
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(data: acc, dataType: "acceleration",
                                                                          location: location, sensorId: UserDefaults.standard.bool(forKey: "switchWaistWrist") ? 2 : 1))
            
            
            // Split it by 3000 data points (30 sec @ 50 Hz * 2 sensors)
            if MetaWearManager.realtimeData.size() > 3000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_acc_bosch_enable_acceleration_sampling(board1)
        mbl_mw_acc_bosch_start(board1)
        
        // Sensor 2 - Gyroscope
        mbl_mw_datasignal_subscribe(gyroSignal2, bridge(obj: self)) { (context, data) in
            // Get and add data
            let gyroscope: MblMwCartesianFloat = data!.pointee.valueAs()
            let timestamp = data!.pointee.timestamp.timeIntervalSince1970;
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(data: gyroscope, dataType: "gyroscope", location: location, timestamp: timestamp, sensorId: UserDefaults.standard.bool(forKey: "switchWaistWrist") ? 1 : 2))
            
            // Split it by 3000 data points (30 sec @ 50 Hz * 2 sensors)
            if MetaWearManager.realtimeData.size() > 3000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_gyro_bmi160_enable_rotation_sampling(MetaWearManager.device2.board)
        mbl_mw_gyro_bmi160_start(board2)
        
        // Sensor 2 - Accelerometer
        mbl_mw_datasignal_subscribe(accSignal2, bridge(obj: self)) { (context, data) in
            let acc: MblMwCartesianFloat = data!.pointee.valueAs()
            let location = MetaWearManager.locationManager.getLocation()
            MetaWearManager.realtimeData.addData(RealtimeWalkingDataPoint(data: acc, dataType: "acceleration",
                                                                          location: location, sensorId: UserDefaults.standard.bool(forKey: "switchWaistWrist") ? 1 : 2))
            
            
            // Split it by 3000 data points (30 sec @ 50 Hz * 2 sensors)
            if MetaWearManager.realtimeData.size() > 3000 {
                let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
                let documentUuid = UUID().uuidString
                FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
                MetaWearManager.realtimeDataDocNames.append(documentUuid)
                MetaWearManager.realtimeData.resetData()
            }
        }
        mbl_mw_acc_bosch_enable_acceleration_sampling(board2)
        mbl_mw_acc_bosch_start(board2)
    }

    /// Sends hazard report to Firebase.
    /// Called when user presses "No, close" or submits a hazard report.
    static func sendHazardReport(hazards: [String],
                                 intensity: [Int],
                                 imageId: String,
                                 buildingId: String = "",
                                 buildingFloor: String = "",
                                 buildingRemarks: String = "",
                                 buildingHazardLocation: String = "",
                                 singlePointReport: Bool = false // report hazard without recording
    ) {
        // Single point report (reporting without recording)
        if singlePointReport {
            let currentLocation = locationManager.getLocation()
            
            // Upload realtime data with 1 data point
            let documentUuid = UUID().uuidString
            var rt = RealtimeWalkingData()
            rt.addData(RealtimeWalkingDataPoint(data: MblMwCartesianFloat(x: 0, y: 0, z: 0), dataType: "null", location: currentLocation))
            FirebaseManager.addRealtimeData(realtimeData: rt, docNameUuid: documentUuid)
            
            // Upload
            let currentLocationDict: [String: Double] = ["latitude": currentLocation[0],
                                                         "longitude": currentLocation[1],
                                                         "altitude": currentLocation[2]]
            FirebaseManager.connect()
            FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                      realtimeDataDocNames: [documentUuid],
                                      imageId: imageId,
                                      lastLocation: currentLocationDict,
                                      startLocation: currentLocationDict,
                                      startTime: Date().timeIntervalSince1970,
                                      buildingId: buildingId,
                                      buildingFloor: buildingFloor,
                                      buildingRemarks: buildingRemarks,
                                      buildingHazardLocation: buildingHazardLocation)
        }
        // Regular report
        else {
            // Upload remaining realtime data
            let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
            let documentUuid = UUID().uuidString
            FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
            MetaWearManager.realtimeDataDocNames.append(documentUuid)
            
            // last location
            let lastLocation = MetaWearManager.realtimeData.data.last?.location ?? [0, 0, 0]
            let lastLocationDict: [String: Double] = ["latitude": lastLocation[0],
                                                      "longitude": lastLocation[1],
                                                      "altitude": lastLocation[2]]
            let startLocationDict: [String: Double] = ["latitude": startLocation[0],
                                                      "longitude": startLocation[1],
                                                      "altitude": startLocation[2]]
            MetaWearManager.realtimeData.resetData()
            
            // Upload general data
            FirebaseManager.connect()
            FirebaseManager.addRecord(rec: GeneralWalkingData.toRecord(type: hazards, intensity: intensity),
                                      realtimeDataDocNames: MetaWearManager.realtimeDataDocNames,
                                      imageId: imageId,
                                      lastLocation: lastLocationDict,
                                      startLocation: startLocationDict,
                                      startTime: startTime,
                                      buildingId: buildingId,
                                      buildingFloor: buildingFloor,
                                      buildingRemarks: buildingRemarks,
                                      buildingHazardLocation: buildingHazardLocation)
        }
        
    }
    

    
    /// Cancels current walking recording session.
    static func cancelSession() {
        // Upload remaining realtime data
        let copiedObj = RealtimeWalkingData(copyFrom: MetaWearManager.realtimeData)
        let documentUuid = UUID().uuidString
        FirebaseManager.addRealtimeData(realtimeData: copiedObj, docNameUuid: documentUuid)
        MetaWearManager.realtimeDataDocNames.append(documentUuid)
        MetaWearManager.realtimeData.resetData()
    }
    
    /// Stops recording the gyroscope and location data. Called when user presses "Stop Recording".
    /// Note: This does not upload any data to the database; `sendHazardReport` must be called separately.
    ///
    /// Non-static function. Usage: `MetaWearManager().startRecording()`
    ///
    func stopRecording() {
        let board1 = MetaWearManager.device1.board
        let gyroSignal1 = mbl_mw_gyro_bmi160_get_rotation_data_signal(board1)!
        let accSignal1 = mbl_mw_acc_bosch_get_acceleration_data_signal(board1)!
        
        let board2 = MetaWearManager.device2.board
        let gyroSignal2 = mbl_mw_gyro_bmi160_get_rotation_data_signal(board2)!
        let accSignal2 = mbl_mw_acc_bosch_get_acceleration_data_signal(board2)!
        
        mbl_mw_gyro_bmi160_stop(board1)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(board1)
        mbl_mw_datasignal_unsubscribe(gyroSignal1)
        mbl_mw_acc_bosch_disable_acceleration_sampling(board1)
        mbl_mw_datasignal_unsubscribe(accSignal1)
        
        mbl_mw_gyro_bmi160_stop(board2)
        mbl_mw_gyro_bmi160_disable_rotation_sampling(board2)
        mbl_mw_datasignal_unsubscribe(gyroSignal2)
        mbl_mw_acc_bosch_disable_acceleration_sampling(board2)
        mbl_mw_datasignal_unsubscribe(accSignal2)
        
        
        MetaWearManager.recording = false
        
        // If we are not using walking detection
        if !UserDefaults.standard.bool(forKey: "receiveWalkingDetectionNotifications") {
            MetaWearManager.locationManager.stopRecording()
        }
        
    }
    
    /// Gets battery data from sensor and updates `bso`
    static func getBattery(bso: BatteryStatusObject) {
        if(MetaWearManager.connected()) {
            mbl_mw_settings_get_battery_state_data_signal(MetaWearManager.device1.board).read().continueWith(.mainThread) {
                    let battery: MblMwBatteryState = $0.result!.valueAs()
                    bso.battery_percentage = String(battery.charge) + "%"

                    let battery_fill: UInt8 = min(battery.charge / 20, 4) * 25
                    bso.battery_icon = "battery." + String(battery_fill)
                }
        }
    }
    
    /// Gets battery data from sensor and updates `bso`
    static func getWristBattery(bso: BatteryStatusObject) {
        if(MetaWearManager.wristConnected()) {
            mbl_mw_settings_get_battery_state_data_signal(MetaWearManager.device2.board).read().continueWith(.mainThread) {
                    let battery: MblMwBatteryState = $0.result!.valueAs()
                    bso.battery_percentage = String(battery.charge) + "%"

                    let battery_fill: UInt8 = min(battery.charge / 20, 4) * 25
                    bso.battery_icon = "battery." + String(battery_fill)
                }
        }
    }
}



