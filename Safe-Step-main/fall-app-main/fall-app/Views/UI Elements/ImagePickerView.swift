import SwiftUI
import UIKit

/// UIKit view to take photos.
///
/// ### Usage
/// In SwiftUI view:
/// ```
/// ImagePickerView() { image in
///   // handle image (UIImage)
/// }
/// ```
/// Example:
/// ```
/// var myImage: UIImage
/// ImagePickerView() { image in
///     myImage = image
/// }
/// ```
/// See `SurveyHazardForm` and `HazardImageView` for examples.
/// 
/// ### Author & Version
/// From Stack Overflow (https://stackoverflow.com/q/75230875/) , retrieved Jun 9, 2023
/// Modified by Seung-Gu Lee
///
struct ImagePickerView: UIViewControllerRepresentable {
    
    let sourceType: UIImagePickerController.SourceType = .camera
    let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(onImagePicked: @escaping (UIImage) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
    
}

