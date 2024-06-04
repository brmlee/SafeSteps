import SwiftUI

/// Style used to create a 320x40 button with icon + text.
///
/// ### Description
/// A ButtonStyle for IconButtons of size 320x40. Must be used with IconButtonInner.
/// ### Example
/// ```
/// Button(action: { /* TODO */ }) {
///     IconButtonInner(iconName: "paperplane.fill", buttonText: "Submit")
/// }.buttonStyle(IconButtonStyle(backgroundColor: Color(red: 0, green: 146/255, blue: 12/255),
///                         foregroundColor: .white))
/// ```
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 7, 2023
///
struct IconButtonStyle: ButtonStyle
{
    var width: CGFloat = 320
    
    var backgroundColor: Color
    var foregroundColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: width, height: 40)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            
    }
}
