import Foundation
import SwiftUI
import UIKit

/// Object used to load an image asynchronously from Firebase.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 12, 2023
///
class ImageLoader: ObservableObject {
    
    @Published var image: UIImage = UIImage()
    
    @Published var loading: Bool = false
    
    @Published var failed: Bool = false
}
