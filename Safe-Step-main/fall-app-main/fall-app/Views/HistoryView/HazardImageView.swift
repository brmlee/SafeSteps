import SwiftUI

/// View to see hazard images and retake them if needed.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Jun 12,  2023
///
struct HazardImageView: View {
    var imageId: String
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @State var showPhotoPicker: Bool = false
    
    init(imageId: String) {
        self.imageId = imageId
        // load image
        FirebaseManager.loadHazardImage(uuid: imageId, loader: imageLoader)
    }
    
    var body: some View {
        VStack {
            // loading
            if imageLoader.loading {
                Text("Loading...")
            }
            else {
                // failed - image may be deleted by admin, network issue, etc.
                if imageLoader.failed {
                    Text("Failed to load image.\nPlease try again later.")
                        .multilineTextAlignment(.center)
                }
                // success
                else {
                    Image(uiImage: imageLoader.image)
                        .resizable()
                        .scaledToFit()
                }
                
                Button(action: {
                    showPhotoPicker = true
                }) {
                    IconButtonInner(iconName: "camera.fill", buttonText: "Retake Photo")
                }
                .buttonStyle(IconButtonStyle(backgroundColor: .cyan,
                                             foregroundColor: .black))
                // Photo Picker
                .sheet(isPresented: $showPhotoPicker) {
                    ImagePickerView() { image in
                        FirebaseManager.uploadHazardImage(uuid: imageId, image: image)
                        imageLoader.image = image
                        Toast.showToast("Success!")
                    }.presentationDetents([.large])
                }
            }
        }
    }
}
