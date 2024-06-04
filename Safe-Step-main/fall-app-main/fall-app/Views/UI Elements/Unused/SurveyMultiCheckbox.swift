import SwiftUI

/// Single-select dropdown with prompt text of width 320.
///
/// ### Example
/// ```
/// @State private var hazardTypes: [Bool] = [false, false, false];
/// SurveyMultiCheckbox(question: "Please select all SFT hazards you experienced.",
///         optionTexts: ["Slippery", "Option 2", "Option 3"],
///         value: $hazardTypes)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 12, 2023
///
struct SurveyMultiCheckbox: View {
    
    /// Question text to be shown on top of the checkboxes
    var question: String
    
    /// Array of strings to be shown next to the checkboxes
    var optionTexts: [String]
    
    /// Binding value; pass by reference. 
    @Binding var value: [Bool]
    
    /// Width of dropdown menu box. Default: 320
    let width: CGFloat = 320
    
    /// Height of dropdown menu box. Default: 36
    let height: CGFloat = 36
    
    var body: some View {
        VStack {
            HStack {
                Text(question)
                    .padding(.top, 4)
                    .frame(width: width - 25, alignment: .leading)
                Spacer()
            }
            .padding(.bottom, 0)
            
            VStack {
                ForEach(value.indices) { index in
                    HStack {
                        Text(optionTexts[index])
                            .foregroundColor(.black)
                        Checkbox(selected: $value[index])
                    }
                    .frame(width: width)
                    .padding(.top, index == 0 ? -8 : -16)
                    .padding(.bottom, index == value.count-1 ? -8 : -16)
                }
            }
            .background(Color(white: 0.93))
            .cornerRadius(12)
            
            
        }
        .frame(width: width)
    }
}

struct Checkbox: View {
    
    @Binding var selected: Bool
    
    let width: CGFloat = 64
    let height: CGFloat = 64
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut.speed(4)) {
                selected.toggle()
            }
        }) {
            Image(systemName: selected ? "checkmark.square.fill" : "square")
                .imageScale(.large)
                .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
    }

    
}
