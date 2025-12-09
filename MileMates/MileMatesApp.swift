//
//  MileMatesApp.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/9/25.
//

import SwiftUI
import CoreData

@main
struct MileMatesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
