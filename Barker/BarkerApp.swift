//
//  BarkerApp.swift
//  Barker
//
//  Created by Matt Leirdahl on 11/26/21.
//

import SwiftUI

@main
struct BarkerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
