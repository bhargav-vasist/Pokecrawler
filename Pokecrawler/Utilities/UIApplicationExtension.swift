//
//  UIApplicationExtension.swift
//  Pokecrawler
//
//  Created by Bhargav Vasist on 26/03/23.
//

import UIKit

extension UIApplication {
    
    /// The recommended way to get key window iOS 15.0+
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
