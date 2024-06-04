import Foundation

/// Object used to load realtime (gyroscope/location) walking data from the database.
///
/// ### Usage
/// Let the object be named `loader`. Firebase should directly access `loader.tempData` to
/// add partial `RealtimeWalkingData` entries to the dictionary. To make sure that the document
/// order doesn't get mixed up, store the order of the document as an index of the dictionary.
///
/// Then, after all documents have been read, call `loader.combineTempData(docs.count)`
/// and access the full data through `loader.data`.
///
/// ### Why?
/// Firebase limits each document size to ~1 MiB, which can only hold around 3 minutes of
/// realtime data. To bypass this, we split the realtime data into multiple documents of
/// 3,000 data points (~60 seconds) each. This loader object helps us combine these splitted
/// data back in one piece.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 18, 2023
///
class RealtimeWalkingDataLoader: ObservableObject {
    @Published var data: RealtimeWalkingData = RealtimeWalkingData()
    @Published var isLoading: Bool = false
    var tempData: [Int: RealtimeWalkingData] = [:]
    
    /// Combines `tempData` to a single object `data`.
    func combineTempData(numDocs: Int) {
        var index: Int = 0;
        while(index < numDocs) {
            data.append(arr: tempData[index]?.toArrDict() ?? [[:]])
            index += 1
        }
        tempData = [:] // clear after combining
    }
    
    /// Resets the object.
    func clear() {
        data = RealtimeWalkingData()
        tempData = [:]
    }
}
