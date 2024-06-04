import Foundation

/// Class that stores global variables of the app as static variables, used in multiple files.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21 2023
///
class AppConstants {
    /// Types of hazards to be shown
    static let hazards: [String] = ["Change in Floor Levels", "Uneven Surface", "Debris or Obstacles", "Slippery", "Slope", "Poor Lighting"]
    
    /// Icons of hazards to be shown. Size must match that of `hazards`.
    static let hazardIcons: [String] = ["changes_in_floor_levels", "uneven_surface", "debris_obstacles", "slippery", "slope", "poor_lighting"]
    
    /// Default hazard intensities (0 = none)
    static let defaultHazardIntensity: [Int] = [0, 0, 0, 0, 0, 0]
    
    /// Hazard intensity options.
    static let optionTexts: [String] = ["None (0)", "Low (1)", "Medium (2)", "High (3)"]
    
    /// Values of hazard intensities. Size must match that of `optionTexts`.
    static let optionValues: [Int] = [0, 1, 2, 3]
    
    /// Node.js server
    static let serverProtocol: String = "http"
    static let serverAddress: String = "34.136.54.25"
    static let serverPort: Int = 3000
    static let serverPath: String = "safesteps"
    
    /// Get the URL used to send a request to the server.
    ///
    /// ### Usage ###
    /// `"\(AppConstants.getUrl())/calculate/15"`
    ///
    static func getUrl() -> String {
        return "\(serverProtocol)://\(serverAddress):\(serverPort)/\(serverPath)"
    }
}
