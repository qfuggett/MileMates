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
    
    init(name: String, miles: Double) {
        self.name = name
        self.miles = miles
    }
}
