import Foundation

/// Class that stores battery icon and percentage
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 9, 2023
///
class BatteryStatusObject: ObservableObject {
    @Published var battery_percentage: String = "-"
    @Published var battery_icon: String = "battery.0"
}
