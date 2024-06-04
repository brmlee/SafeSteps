import SwiftUI

/// View shown when you select "View records from all trips"
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Aug 14, 2023
///
struct MultiRecordsInfoView: View {
    var body: some View {
        VStack {
            Text("Hello world!")
            NavigationLink(destination: MultiRecordsView()) {
                HStack {
                    Text("View records from all trips")
                    Image(systemName: "arrow.right")
                        .imageScale(.small)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

