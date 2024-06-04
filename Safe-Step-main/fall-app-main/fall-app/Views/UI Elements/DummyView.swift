import SwiftUI
import MetaWear
import MetaWearCpp

/// Dummy view of the application, contains nothing but a single text
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct DummyView: View {
    var mwm = MetaWearManager()
    
    
    var body: some View {
        VStack {
            Text("Hello world!")
        }
    }
}
