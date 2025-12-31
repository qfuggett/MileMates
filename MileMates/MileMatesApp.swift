//
//  MileMatesApp.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftData

@main
struct MileMatesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                Welcome()
            }
        }
        .modelContainer(for: Activity.self)
    }
}
