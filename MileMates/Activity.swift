//
//  Activity.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/11/25.
//
import Foundation
import SwiftData

@Model
class Activity {
    var name: String
    var miles: Double
    var duration: TimeInterval // in seconds
    var date: Date
    
    init(name: String, miles: Double, duration: TimeInterval, date: Date) {
        self.name = name
        self.miles = miles
        self.duration = duration
        self.date = date
    }
}
