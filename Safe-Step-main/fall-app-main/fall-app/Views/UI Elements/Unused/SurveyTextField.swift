import SwiftUI

/// A textfield with a prompt text of width 320.
///
/// ### Example
/// ```
/// @State private var ddValue: String = ""
/// SurveyTextField(question: "Please select a username",
///                 placeholder: "Letters only",
///                 value: $ddValue)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 9, 2023
///
struct SurveyTextField: View {

    /// Question text to be shown on top of the textfield.
    var question: String
    
    /// String that provides a brief hint to the user as to what kind of information is expected in the field.
    /// Only visible when value = ""
    var placeholder: String
    
    /// Binding value: pass by reference. Value of the textfield.
    /// For empty by default, pass ""
    @Binding var value: String

    /// Width of the textfield. Default: 320
    let width: CGFloat = 320
    
    /// Height of the textfield. Default: 40
    let height: CGFloat = 40
    
    var body: some View {
        VStack {
            HStack {
                Text(question)
                    .padding(.top, 4)
                    .frame(width: width - 20, alignment: .leading)
                Spacer()
            }
            TextField(placeholder, text: $value)
                .frame(width: width, height: height)
                .background {
                    VStack {
                        Spacer()
                        Color(UIColor.systemGray4)
                            .frame(height: 2)
                    }
                }
                .foregroundColor(Color(UIColor.systemGray))
                .padding(.top, -12)
                .keyboardType(.default)
                .padding(.bottom, 8)
        }
        .frame(width: width)
        
    }
}
