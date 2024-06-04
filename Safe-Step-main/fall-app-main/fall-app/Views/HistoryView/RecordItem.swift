import SwiftUI

/// Box for individual history records.
///
/// ### Usage
/// ```
/// RecordItem(generalData: ...)
/// ```
/// Used in `HistoryView`.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 21 2023
///
struct RecordItem: View {
    
    var generalData: GeneralWalkingData

    var body: some View {
        NavigationLink(destination: WalkingRecordView(generalData: generalData)) {
            HStack {
                Spacer()
                    .frame(width: 24);
                
                HStack {
                    
                    // Text
                    let textWidth: CGFloat = 285
                    VStack {
                        Spacer()
                            .frame(height: 8);
                        
                        HStack {
                            Text(generalData.timestampToStringRelative())
                                .font(.system(size: 16, weight: .semibold))
                                .frame(alignment: .leading)
                                
                            if generalData.hazardEncountered() {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .imageScale(.small)
                                    .foregroundColor(Utilities.isDarkMode() ? .yellow : .orange)
                                    .frame(alignment: .leading)
                                    .padding(.trailing, -2)
                            }
//                            else {
//                                Image(systemName: "checkmark.diamond.fill")
//                                    .imageScale(.small)
//                                    .foregroundColor(.green)
//                                    .frame(alignment: .leading)
//                                    .padding(.trailing, -2)
//                            }
                            
                            if generalData.photoAvailable() {
                                Image(systemName: "photo")
                                    .imageScale(.small)
                                    .foregroundColor(.cyan)
                                    .frame(alignment: .leading)
                                    .padding(.trailing, -2)
                            }
                        }
                        .frame(width: textWidth, alignment: .leading)
                        .padding(.bottom, -7.5)
                        
                        // No hazard
                        if !generalData.hazardEncountered() {
                            HStack {
                                Text("No hazard reported.")
                                    .frame(alignment: .leading)
                                    .padding(.leading, 0)
                            }
                            .frame(width: textWidth, alignment: .leading)
                        }
                        // Reported hazard
                        else {
                            let hazardsArr = generalData.hazardsToStringArr();
                            ForEach(hazardsArr.indices) { index in
                                Text("• " + hazardsArr[index])
                                    .frame(width: textWidth, alignment: .leading)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 8);
                    }
                    
                    // > symbol
                    Image(systemName: "greaterthan")
                        .resizable()
                        .frame(width: 6, height: 12)
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(width: 340)
                .background(Utilities.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
                .cornerRadius(12)
                .padding(.bottom, 8)
                
                Spacer()
                    .frame(width: 24);
            }
            
        }
        .foregroundColor(Utilities.isDarkMode() ? .white : .black)
        
        
    }
}
