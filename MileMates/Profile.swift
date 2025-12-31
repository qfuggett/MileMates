//
//  Profile.swift
//  MileMates
//
//  Created for MileMates
//

import SwiftUI

struct Profile: View {
    @StateObject private var themeManager = ThemeManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Animated Background Theme", isOn: $themeManager.animatedGIFThemeEnabled)
                } header: {
                    Text("Visual Theme")
                } footer: {
                    Text("Enable an animated background theme. This setting respects Reduce Motion accessibility preferences.")
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    Profile()
}

