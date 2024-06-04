import SwiftUI
import SkeletonUI

/// History view of the application, showing past walking records
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 2, 2023
///
struct HistoryView: View
{
    @StateObject var records = WalkingRecordsLoader();
    @State var toggleToRefresh: Bool = false
    
    var body: some View {
        GeometryReader { metrics in
            NavigationStack {
                let numRecs = records.generalDataArr.count;
                
                //  Print records
                ScrollView(.vertical) {
                    if records.isDoneFetching() { // done loading
                        // Content
                        VStack {
                            /// TEST ONLY - show all records on database
//                        NavigationLink(destination: MultiRecordsView()) {
//                            HStack {
//                                Text("View records from all trips")
//                                Image(systemName: "arrow.right")
//                                    .imageScale(.small)
//                            }
//                        }
//                        Spacer()
//                            .frame(height: 16)
                            
                            let numRecs = records.generalDataArr.count;
                            Text(String(numRecs) + " record(s) found.")
                                .padding(.bottom, 10)
                                .padding(.top, 8)
                                .frame(width: 320)
                            
                            if(numRecs != 0) { // the boxes
                                ForEach(records.generalDataArr.indices) { index in
                                    RecordItem(generalData: records.generalDataArr[numRecs - index - 1])
                                }
                            }
                        }
                    }
                    else { // still loading
                        // Skeleton UI
                        VStack {
                            Text("Loading...")
                                .padding(.bottom, 10)
                                .padding(.top, 16)
                                .frame(width: 320)
                                .skeleton(with: !records.isDoneFetching(),
                                          size: CGSize(width: 240, height: 16))
                            
                            ForEach(1..<12) { index in
                                VStack(alignment: .leading) {
                                    Text("Loading...")
                                        .skeleton(with: !records.isDoneFetching(),
                                                  size: CGSize(width: 320, height: 16))
                                    Text("Loading...")
                                        .skeleton(with: !records.isDoneFetching(),
                                                  size: CGSize(width: 280, height: 16))
                                }
                                .frame(width: 280, height: 56)
                                
                                
                            }
                        }
                    }
                } // ScrollView
                .navigationTitle(Text("Walking History"))
                .refreshable {
                    toggleToRefresh.toggle()
                    getRecords()
                }
                .padding([.horizontal], 0)
            } // NavigationView
            .onAppear {
                getRecords()
            }
            .padding([.horizontal], 0)
        } // GeometryReader
    }
    
    /// Retrieves records from Firebase and refreshes the screen.
    func getRecords() {
        records.clearArr()
        FirebaseManager.connect()
        FirebaseManager.getRecords(loader: records)
    }
    
    /// Returns a dictionary where key = date (Unix timestamp of start of day) and value = array of data from that date.
//    func splitByDay(records: WalkingRecordsArr) -> [Int: [GeneralWalkingData]] {
//        var dict: [Int: [GeneralWalkingData]] = [:]
//
//        for item in records.generalDataArr {
//            var date = Date(timeIntervalSince1970: item.timestamp).startOfDay.timeIntervalSince1970
//            (dict[Int(date)] ?? []).append(item)
//        }
//
//        return dict
//    }
}

