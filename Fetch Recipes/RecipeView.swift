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
    @StateObject var dataStore: ListItemDataStore
    @State private var isExpanded: Bool = false
    
    var body: some View {
        LazyVStack(alignment: .leading) {
                // The expandable cell header (the part that shows when collapsed)
                HStack {
                    dataStore.smallImage
                        .resizable()
                        .frame(width: 45, height: 45)
                        .cornerRadius(5)
                    Text(recipe.name)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                }
                .padding()
                .cornerRadius(8)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle() // Toggle the expanded state when tapped
                    }
                    if isExpanded {
                        Task { await dataStore.fetchLargeImage() }
                    }
                }
                
                // The expanded content
                if isExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack {
                            dataStore.largeImage.resizable().opacity(0.4)
                                .frame(minHeight: 60, idealHeight: 150, maxHeight: 200)
                                .cornerRadius(8)
                        }
                        
                        Text(recipe.name)
                            .font(.title)
                        Text(recipe.cuisine)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Source URL (if exists)
                        if let source = recipe.source_url, let sourceUrl = URL(string: source) {
                            Link("Recipe Source", destination: sourceUrl)
                                .padding(.vertical, 5)
                                .foregroundColor(.blue)
                        }
                        
                        // YouTube video URL (if exists)
                        if let youtube = recipe.youtube_url, let videoUrl = URL(string: youtube) {
                            Link("Instructional Video", destination: videoUrl)
                                .padding(.vertical, 5)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
    }
