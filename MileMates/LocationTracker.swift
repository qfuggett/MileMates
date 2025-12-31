import CoreLocation
import Combine

class LocationTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var totalDistance: CLLocationDistance = 0 // in meters
    @Published var isTracking = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private var lastLocation: CLLocation?
    private var startTime: Date?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        totalDistance = 0
        lastLocation = nil
        startTime = Date()
        isTracking = true
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func stopTracking() -> TimeInterval? {
        isTracking = false
        manager.stopUpdatingLocation()
        let duration = startTime.map { Date().timeIntervalSince($0) }
        lastLocation = nil
        startTime = nil
        return duration
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        // Filter out inaccurate locations
        if newLocation.horizontalAccuracy > 50 { return }
        
        if let last = lastLocation {
            let delta = newLocation.distance(from: last) // meters between updates
            totalDistance += delta
        }
        lastLocation = newLocation
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location tracking error: \(error.localizedDescription)")
    }
}
//
//  LocationTracker.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/9/25.
//

