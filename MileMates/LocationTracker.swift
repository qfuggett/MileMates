import CoreLocation
import Combine

class LocationTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var totalDistance: CLLocationDistance = 0 // in meters
    @Published var isTracking = false
    @Published var isPaused = false
    
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        totalDistance = 0
        lastLocation = nil
        isTracking = true
        isPaused = false
        manager.startUpdatingLocation()
    }
    
    func pauseTracking() {
        isPaused.toggle()
    }
    
    func stopTracking() {
        isTracking = false
        isPaused = false
        manager.stopUpdatingLocation()
        lastLocation = nil
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking, !isPaused else { return }
        
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        if let last = lastLocation {
            let delta = newLocation.distance(from: last) // meters between updates
            totalDistance += delta
        }
        lastLocation = newLocation
    }
}
//
//  LocationTracker.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/9/25.
//

