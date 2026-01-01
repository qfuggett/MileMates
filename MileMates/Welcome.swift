//
//  Welcome.swift
//  MileMates
//
//  Created by the 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF
import SwiftData
internal import CoreLocation

struct Welcome: View {
    @StateObject private var locationTracker = LocationTracker()
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    
    @State private var imageData: Data? = nil
    @State private var showActivityNameAlert = false
    @State private var activityName = ""
    @State private var showLocationPermissionAlert = false
    @State private var lastTripDistance: Double = 0
    
    private var currentDistanceInMiles: Double {
        locationTracker.totalDistance / 1609.34 // Convert meters to miles
    }
    
    private var displayDistance: Double {
        if locationTracker.isTracking {
            return currentDistanceInMiles
        } else {
            return lastTripDistance
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background - GIF theme or system background
                if themeManager.shouldShowGIF, let data = imageData, !data.isEmpty {
                    GIFImage(data: data)
                        .id(data.hashValue)
                        .ignoresSafeArea()
                } else {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Start/Stop buttons
                    HStack(spacing: 20) {
                        Button {
                            handleStartButton()
                        } label: {
                            Image("start")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                        }
                        .buttonStyle(.plain)
                        .disabled(locationTracker.isTracking)
                        .accessibilityLabel("Start tracking")
                        
                        Button {
                            handleStopButton()
                        } label: {
                            Image("stop")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                        }
                        .buttonStyle(.plain)
                        .disabled(!locationTracker.isTracking)
                        .accessibilityLabel("Stop tracking")
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Last Trip display
                    VStack(spacing: 8) {
                        Text("Last Trip")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("\(String(format: "%.2f", displayDistance)) miles")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: 200)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            }
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Bottom navigation buttons
                    HStack(spacing: 16) {
                        NavigationLink(destination: Activities()) {
                            Label("All Activities", systemImage: "list.bullet")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        
                        NavigationLink(destination: Profile()) {
                            Label("Profile", systemImage: "person.circle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
                }
            }
            .onAppear {
                // Load GIF only if theme is enabled
                if themeManager.shouldShowGIF && imageData == nil {
                    if let gifData = NSDataAsset(name: "poleposition")?.data {
                        imageData = gifData
                    }
                }
                // Update last trip distance from most recent activity
                if let lastActivity = activities.first {
                    lastTripDistance = lastActivity.miles
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
            .alert("Enter Activity Name", isPresented: $showActivityNameAlert) {
                TextField("Activity name", text: $activityName)
                Button("Cancel", role: .cancel) {
                    activityName = ""
                }
                Button("Start") {
                    startTracking()
                }
            } message: {
                Text("Please enter a name for this activity.")
            }
            .alert("Location Permission Required", isPresented: $showLocationPermissionAlert) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location services in Settings to track your mileage.")
            }
            .onChange(of: locationTracker.authorizationStatus) { oldValue, newValue in
                // Handle authorization status changes event-driven
                if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
                    // User granted permission - show activity name prompt
                    if oldValue == .notDetermined {
                        showActivityNameAlert = true
                    }
                } else if newValue == .denied || newValue == .restricted {
                    // User denied permission - show Settings alert
                    if oldValue == .notDetermined {
                        showLocationPermissionAlert = true
                    }
                }
            }
        }
    }
    
    private func handleStartButton() {
        let currentStatus = locationTracker.authorizationStatus
        
        if currentStatus == .notDetermined {
            // Request authorization - system will show dialog
            // Response will be handled by onChange listener
            locationTracker.requestWhenInUseAuthorization()
            return
        } else if currentStatus == .denied || currentStatus == .restricted {
            // Permission was previously denied - show Settings alert
            showLocationPermissionAlert = true
        } else if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
            // Permission already granted - show activity name prompt
            showActivityNameAlert = true
        }
    }
    
    private func startTracking() {
        guard !activityName.isEmpty else { return }
        locationTracker.startTracking()
    }
    
    private func handleStopButton() {
        guard locationTracker.isTracking else { return }
        
        // Get distance before stopping
        let distanceInMiles = currentDistanceInMiles
        let duration = locationTracker.stopTracking()
        
        // Save the activity
        let activity = Activity(
            name: activityName,
            miles: distanceInMiles,
            duration: duration ?? 0,
            date: Date()
        )
        modelContext.insert(activity)
        
        do {
            try modelContext.save()
            lastTripDistance = distanceInMiles
            activityName = ""
        } catch {
            print("Failed to save activity: \(error)")
        }
    }
}

#Preview {
    Welcome()
}
