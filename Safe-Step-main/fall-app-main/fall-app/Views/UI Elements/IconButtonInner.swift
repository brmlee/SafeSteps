import SwiftUI

/// Inner elements for a 320x40 button with icon + text.
///
/// ### Description
/// Inner elements for IconButtons of size 320x40. Includes an icon image and a text. Must be used with IconButtonStyle.
/// ### Example
/// ```
/// Button(action: { /* TODO */ }) {
/// IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
/// }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
///                         foregroundColor: .white))
/// ```
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 7, 2023
///
struct IconButtonInner: View
{
    var iconName: String
    var buttonText: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .imageScale(.medium)
            Text(buttonText)
        }
        .frame(width: 320, height: 40)
    }
}
