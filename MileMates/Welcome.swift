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
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    
    @State private var imageData: Data? = nil
    @State private var isDone = false
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
            ZStack{
                ZStack {
                    if let data = imageData {
                        GIFImage(data: data) {
                            isDone = true
                        }
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Color.black.ignoresSafeArea()
                        Text("Loading...")
                            .foregroundColor(.white)
                    }
                }
                .onAppear {
                    // Load GIF from Asset Catalog
                    if let gifData = NSDataAsset(name: "poleposition")?.data {
                        imageData = gifData
                    }
                    // Update last trip distance from most recent activity
                    if let lastActivity = activities.first {
                        lastTripDistance = lastActivity.miles
                    }
                }
                HStack{
                    Button{
                        handleStartButton()
                    }label: {
                        Image("start")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .offset(x: -20, y: -250)
                    }
                    .buttonStyle(.plain)
                    .disabled(locationTracker.isTracking)
                    Button{
                        handleStopButton()
                    }label: {
                        Image("stop")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .offset(x: 20, y: -250)
                    }
                    .buttonStyle(.plain)
                    .disabled(!locationTracker.isTracking)
                }
                Rectangle()
                    .border(Color.white, width: 2)
                    .frame(width: 200, height: 60)
                    .offset(y:-40)
                Text("Last Trip: \(String(format: "%.2f", displayDistance)) miles")
                    .font(.system(size: 20, weight: .semibold))
                    .offset(y: -40)
                    .foregroundStyle(Color.white)
                VStack {
                    Spacer()

                    NavigationLink(destination: Activities()) {
                        Label("All Activities", systemImage: "list")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 33)
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
                // When authorization status changes, check if we should show the activity name alert
                if newValue == .authorizedWhenInUse || newValue == .authorizedAlways {
                    // Only show if we were waiting for authorization
                    if oldValue == .notDetermined {
                        showActivityNameAlert = true
                    }
                } else if newValue == .denied || newValue == .restricted {
                    if oldValue == .notDetermined {
                        showLocationPermissionAlert = true
                    }
                }
            }
        }
    }
    
    private func handleStartButton() {
        // Check location authorization
        let currentStatus = locationTracker.authorizationStatus
        
        if currentStatus == .notDetermined {
            // Request authorization and wait for the delegate callback
            locationTracker.requestAuthorization()
            // The authorization status will be updated via the delegate callback
            // We'll check it after a short delay to allow the system dialog to appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Check again after the system might have updated the status
                if locationTracker.authorizationStatus == .authorizedWhenInUse || locationTracker.authorizationStatus == .authorizedAlways {
                    showActivityNameAlert = true
                } else if locationTracker.authorizationStatus == .denied || locationTracker.authorizationStatus == .restricted {
                    showLocationPermissionAlert = true
                } else {
                    // Still not determined, wait a bit more for the system dialog
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if locationTracker.authorizationStatus == .authorizedWhenInUse || locationTracker.authorizationStatus == .authorizedAlways {
                            showActivityNameAlert = true
                        } else if locationTracker.authorizationStatus == .denied || locationTracker.authorizationStatus == .restricted {
                            showLocationPermissionAlert = true
                        }
                    }
                }
            }
        } else if currentStatus == .denied || currentStatus == .restricted {
            showLocationPermissionAlert = true
        } else if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
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
