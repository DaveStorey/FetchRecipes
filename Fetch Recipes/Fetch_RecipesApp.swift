//
//  Fetch_RecipesApp.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/22/24.
//

import SwiftUI

@main
struct Fetch_RecipesApp: App {
    // No persistence is used in the app, but I am reluctant to remove it from anything, since it can be a pain to add
    // later, and is essentially invisible in every way.
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
