//
//  Toast.swift
//  fall-app
//
//  Created by Seung-Gu Lee on 4/8/23.
//

import SwiftUI

/// Displays a short, temporary toast message at the bottom of the screen.
///
/// Simple implementation for single-line text only. May not work on long text.
///
/// ### Example
/// Display for the default duration of 2.0 seconds:
/// ```
/// Toast.showToast("Message")
/// ```
///
/// Display for a custom duration:
/// ```
/// Toast.showToast(text: "Message", delay: 2.5)
/// ```
///
/// ### Author & Version
/// Originally by Vergiliy on StackOverflow: https://stackoverflow.com/questions/31540375/how-to-create-a-toast-message-in-swift
///
/// Modified by Seung-Gu Lee, last modified Apr 9, 2023
///
class Toast {
    static let DELAY_SHORT = 2.0
    static let DELAY_LONG = 3.0

    static func showToast(_ text: String, delay: TimeInterval = DELAY_SHORT) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        let label = UILabel()
        label.backgroundColor = UIColor(white: 0.2, alpha: 0.9)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.alpha = 0
        label.text = text
        label.numberOfLines = 0

        var vertical: CGFloat = 0
        var size = label.intrinsicContentSize
        var width = min(size.width, window.frame.width - 60) + 32
        if width != size.width {
            vertical = 10
//            label.textAlignment = .justified
        }
//        label.textInsets = UIEdgeInsets(top: vertical, left: 15, bottom: vertical, right: 15)

        size = label.intrinsicContentSize
        width = min(size.width, window.frame.width - 60) + 30

        label.frame = CGRect(x: 20, y: window.frame.height - 90, width: width, height: size.height + 20)
        label.center.x = window.center.x
        label.layer.cornerRadius = min(label.frame.height/2, 25)
        label.layer.masksToBounds = true
        window.addSubview(label)

        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
                label.alpha = 0
            }, completion: {_ in
                label.removeFromSuperview()
            })
        })
    }
}
