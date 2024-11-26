//
//  RecipeView.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/26/24.
//

import SwiftUI

/// The meat of the main view
struct RecipeView: View {
    let recipe: Recipe
    @State var isExpanded: Bool = false
    /* Interesting SwiftUI wrinkle here: the @State wrapper doesn't update the view when the images are pulled down.
    Good example of some of the issues with Apple's rollout strategies on SwiftUI. I've run into this a number
    of times, particularly in MVVM architecture. */
    @ObservedObject var dataStore: ListItemDataStore
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.dataStore = ListItemDataStore(recipe: recipe)
    }
    
    @ViewBuilder
    var body: some View {
        
        /* Again some constraints of working with SwiftUI. Expanding the cells programmatically with animation
        interfered with the link gesture recognizers. This could be worked around with UIKit (I did a similar expandable
        custom cell a few years ago), but I figured that a mixed UIKit/SwiftUI app didn't make sense here, and the
        DisclosureGroup functionality works quite well. */
        DisclosureGroup(isExpanded: $isExpanded, content: {
            ZStack {
                dataStore.largeImage.resizable(resizingMode: .stretch)
                    .cornerRadius(2.5)
                    .opacity(0.4)
                    .frame(minHeight: 60, idealHeight: 150, maxHeight: 200)
                LazyVStack {
                    Text(recipe.name)
                        .font(.title)
                    Text(recipe.cuisine)
                    if let source = recipe.source_url, let sourceUrl = URL(string: source) {
                        Link("Recipe Source", destination: sourceUrl)
                            .padding(.vertical, 10)
                    }
                    if let youtube = recipe.youtube_url, let videoUrl = URL(string: youtube) {
                        Link("Instructional Video", destination: videoUrl)
                            .padding(.vertical, 10)
                    }
                }
                
            }
            .onAppear {
                Task { await dataStore.fetchLargeImage() }
            }
        }, label: {
            LazyHStack {
                dataStore.smallImage.resizable().frame(width:45, height: 45).cornerRadius(2.5)
                Text(recipe.name)
            }
        })
    }
}
