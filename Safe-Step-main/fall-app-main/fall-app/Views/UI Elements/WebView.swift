import Foundation
import SwiftUI
import UIKit
import WebKit

/// Web view that shows website in-app. Uses WebKit.
///
/// ### Usage
/// `WebView(url: URL(string: "https://google.com"))`
///
/// ### Author & Version
/// AppCoda (https://www.appcoda.com/swiftui-wkwebview/), retrieved Jun 13, 2023
///
struct WebView: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        return WKWebView(frame: .zero,
                         configuration: config)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let myURL = url else { return }
        let request = URLRequest(url: myURL)
        uiView.load(request)
    }
}

