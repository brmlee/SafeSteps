import SwiftUI

/// Single-select dropdown with in-line prompt text of width 320.
///
/// ### Example
/// ```
/// @State private var ddValue: Int = 1
/// SurveyDropdown(label: "Item 1",
///                 icon: "my-image",
///                 optionTexts: ["No", "Yes"],
///                 optionValues: [0, 1],
///                 value: $ddValue)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct SurveyDropdown: View {

    /// Label text to be shown on top of the dropdown menu.
    var label: String
    
    /// Name of the icon file to be displayed next to the label
    var icon: String
    
    /// Array of strings to be shown in the dropdown menu.
    var optionTexts: [String]
    
    /// Array of integers representing the value of each option
    var optionValues: [Int]
    
    /// Binding value; pass by reference. Default value must be between 1 (inclusive) and the number of items in `optionText` (inclusive).
    /// First element in optionTexts corresponds to `value = 1`, second element in `value = 2`, and so on.
    @Binding var value: Int

    /// Width of dropdown menu box. Default: 320
    let width: CGFloat = 320
    
    /// Height of dropdown menu box. Default: 80
    let height: CGFloat = 80
    
    /// Height of hazard icons. Default: 40
    let iconHeight: CGFloat = 48
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 22)
            
            Image(icon)
                .resizable()
                .frame(width: iconHeight, height: iconHeight)
            
            Spacer()
                .frame(width: 10)
            
            Text(label)
                .frame(width: 100, alignment: .leading)
                .foregroundColor(.black)
            
            
            Picker(label, selection: $value) {
                ForEach(optionTexts.indices) { index in
                    Text(optionTexts[index]).tag(optionValues[index])
                }
            }
            .frame(width: 130, alignment: .trailing)
            
            Spacer()
                .frame(width: 10)
            
        }
        .frame(width: width, height: height)
        .background(Color(white: 0.93))
        .cornerRadius(12)
        .padding(.top, -4)
        .padding(.bottom, 4)
        
    }
}

