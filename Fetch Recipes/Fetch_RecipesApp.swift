//
//  Fetch_RecipesApp.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/22/24.
//

import SwiftUI

@main
struct Fetch_RecipesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
