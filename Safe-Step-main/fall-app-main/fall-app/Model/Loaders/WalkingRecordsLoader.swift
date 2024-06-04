import Foundation

/// A class that contains an array of general data objects.
///
/// Create a `@StateObject` of this type, and pass it by reference to the `FirestoreHandler`.
///
class WalkingRecordsLoader: ObservableObject {
    
    var generalDataArr: [GeneralWalkingData] = [];
    
    @Published var done: Bool = false;
    
    /// Add item to `generalDataArr`.
    func append(item: GeneralWalkingData) {
        generalDataArr.append(item);
    }

    /// Return `generalDataArr`
    func getGeneralDataArr() -> [GeneralWalkingData] {
        return generalDataArr;
    }
    
    /// Clear both arrays
    func clearArr() {
        generalDataArr = [];
    }
    
    /// Call this when starting to fetch data from database.
    /// Used to display loading skeleton UI.
    func startFetching() {
        done = false;
        print("Started fetching data from database")
    }
    
    /// Call this when data fetching is complete.
    /// Used to stop displaying skeleton UI.
    func doneFetching() {
        done = true;
        print("Done fetching data from database")
    }
    
    /// Return `done`, i.e. whether database access has been complete
    func isDoneFetching() -> Bool {
        return done;
    }
}
