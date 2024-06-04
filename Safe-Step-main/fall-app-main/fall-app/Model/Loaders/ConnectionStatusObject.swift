import Foundation

/// Status of the connection between the sensor and the iPhone.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 23, 2023
///
class ConnectionStatusObject: ObservableObject {
    
    @Published var status1: ConnectionStatus = ConnectionStatus.notConnected;
    @Published var status2: ConnectionStatus = ConnectionStatus.notConnected;
    @Published var conn1: Bool = false // connected
    //@Published var waistConn: Bool = false
    @Published var conn2: Bool = false
    
    

    func setStatus1(status: ConnectionStatus) {
        self.status1 = status
        conn1 = connected1()
    }
    func setStatus2(status: ConnectionStatus) {
        self.status2 = status
        conn2 = connected2()
    }
    
    func getStatus1() -> ConnectionStatus {
        return self.status1
    }
    func getStatus2() -> ConnectionStatus {
        return self.status2
    }
    
    func showModal() -> Bool {
        return self.status1 == .scanning || self.status1 == ConnectionStatus.found || self.status2 == .scanning || self.status2 == .found
    }
    
    func connected1() -> Bool {
        return self.status1 == ConnectionStatus.connected
    }
    func connected2() -> Bool {
        return self.status2 == ConnectionStatus.connected
    }
}

/// Enum indicating connection status between the sensor and the iPhone.
enum ConnectionStatus {
    case notConnected, scanning, found, disconnecting, connected
}
