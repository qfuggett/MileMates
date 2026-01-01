//
//  TipsAndTricks.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct TipsAndTricks: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var imageData: Data? = nil
    @State private var currentTip: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Background - GIF theme or system background
                if themeManager.shouldShowGIF, let data = imageData, !data.isEmpty {
                    GIFImage(data: data)
                        .ignoresSafeArea()
                } else {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    // Header area with decorative elements
                    VStack(spacing: 16) {
                        HStack {
                            Image("bigCloud")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            Spacer()
                            Image("smallCloud")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        HStack(spacing: 12) {
                            Text("Tips")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("&")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Tricks")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    Spacer()
                    
                    // Tip card
                    VStack(spacing: 12) {
                        Text("Did you know?")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text(currentTip.isEmpty ? "Loading tip..." : currentTip)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .padding(24)
                    .frame(maxWidth: 320)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    
                    Spacer()
                    
                    // Home button
                    NavigationLink(destination: Welcome()) {
                        Label("Home", systemImage: "house.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
            .onAppear {
                // Load today's tip
                currentTip = TipsData.getTipForToday()
                // Load GIF only if theme is enabled
                if themeManager.shouldShowGIF && imageData == nil {
                    if let gifData = NSDataAsset(name: "poleposition")?.data {
                        imageData = gifData
                    }
                }
            }
            .onChange(of: themeManager.animatedGIFThemeEnabled) { _, enabled in
                // Load or unload GIF based on theme preference
                if themeManager.shouldShowGIF && imageData == nil {
                    if let gifData = NSDataAsset(name: "poleposition")?.data {
                        imageData = gifData
                    }
                } else if !themeManager.shouldShowGIF {
                    imageData = nil
                }
            }
        }
    }
}

#Preview {
    TipsAndTricks()
}
