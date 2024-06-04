import SwiftUI

/// A textfield that accepts numbers only with a prompt text, displayed side-by-side.
///
/// ### Example
/// ```
/// @State private var ddValue: String = ""
///
/// ```
/// Parse the value into a number as needed.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 12, 2023
///
struct SurveyNumberField: View {
    
    var question: String
    
    /// String that provides a brief hint to the user as to what kind of information is expected in the field.
    /// Example: "Username", "Password", "Number"
    var placeholder: String = ""
    
    /// Binding value: pass by reference. Value of the textfield in string.
    /// Parse into a number as needed. Error checking may be required.
    @Binding var value: String
    
    var unit: String
    
    var totalWidth: CGFloat
    
    
    var body: some View {
        VStack {
            VStack {
                Text(question)
                    .font(.system(size: 15.5))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: totalWidth)
                
                HStack {
                    TextField(placeholder, text: $value)
                        .background {
                            VStack {
                                Spacer()
                                Color(UIColor.systemGray4)
                                    .frame(height: 2)
                            }
                        }
                        .foregroundColor(.accentColor)
                        .keyboardType(.numberPad)
                        .frame(width: 60, alignment: .leading)
                    
                    Text(unit)
                        .frame(alignment: .trailing)
                }
            }
            .padding([.all], 12)
        }
        .background(Utilities.isDarkMode() ? Color(white: 0.15) : Color(white: 0.85))
        .cornerRadius(12)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(width: totalWidth)
        
    }
}
