//
//  RecipesView.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/26/24.
//

import SwiftUI

struct RecipesView: View {
    @Binding var recipes: [Recipe]
    @Binding var filterConditions: FilterConditions
    
    @ViewBuilder
    var body: some View {
        if recipes.isEmpty {
            Text("No recipes found")
        } else {
            List(recipes.filter({ recipe in
                filterConditions.checkRecipe(recipe)
            })
            ) { recipe in
                RecipeView(recipe: recipe, dataStore: ListItemDataStore(recipe: recipe))
            }
        }
    }
}
