//
//  ThemeManager.swift
//  MileMates
//
//  Created for MileMates
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("animatedGIFThemeEnabled") var animatedGIFThemeEnabled: Bool = false
    
    var shouldShowGIF: Bool {
        // Respect Reduce Motion accessibility setting
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        return animatedGIFThemeEnabled && !reduceMotion
    }
}

