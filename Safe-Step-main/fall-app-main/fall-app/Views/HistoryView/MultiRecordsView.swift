import SwiftUI

/// Shows multiple walking records on a map.
/// Shown when pressing "View records from all trips" FOR TESTING ONLY.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 22, 2023
///
struct MultiRecordsView: View {
    
    @ObservedObject var multiDataLoader: MultiWalkingLoader = MultiWalkingLoader()
    static var numLoaded: Int = 0
    
    init() {
        FirebaseManager.getAllRecords(loader: multiDataLoader)
    }
    
    var body: some View {
        ZStack {
            let polylines = multiDataLoader.getEncodedPolylines()
            let hazardEncountered = multiDataLoader.hazardEncountered()
            let finalLocation = multiDataLoader.getFinalLocation()
            MapPolylineView(polylines,
                    hazardEncountered: hazardEncountered,
                    hazardLocation: finalLocation)
            
            /// BROKEN
            if multiDataLoader.isLoading {
                Text("Loading...")
            }
        }
        .onAppear {
            if MultiRecordsView.numLoaded == 0 {
                multiDataLoader.isLoading = true
            }
            
            MultiRecordsView.numLoaded += 1
        }
        
    }
}

struct MultiRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        MultiRecordsView()
    }
}
