//
//  ThemeManager.swift
//  MileMates
//
//  Created for MileMates
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @AppStorage("animatedGIFThemeEnabled") var animatedGIFThemeEnabled: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    var shouldShowGIF: Bool {
        let reduceMotion = UIAccessibility.isReduceMotionEnabled
        return animatedGIFThemeEnabled && !reduceMotion
    }
}

