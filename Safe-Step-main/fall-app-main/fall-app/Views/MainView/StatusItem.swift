import SwiftUI

/// Shows status
///
/// ### Usage
/// ```
/// StatusItem(active: true, activeText: "Sensor Connected", inactiveText: "Sensor Disconnected")
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 10, 2023
///
struct StatusItem: View {
    
    @Binding var active: Bool
    var activeText: String
    var inactiveText: String
    
    var body: some View {
        
        HStack {
            Image(active ? "checkmark_green" : "xmark_red")
                .resizable()
                .frame(width: 14, height: 14)
            Text(active ? activeText : inactiveText)
                .foregroundColor(Utilities.isDarkMode() ? Color(white: 0.8) : Color(white: 0.2))
                .font(.system(size: 14))
        }
    }
}

