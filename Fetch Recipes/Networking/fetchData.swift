//
//  fetchData.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/22/24.
//

import Foundation
import SwiftUI

import Foundation

enum URLError: Error {
    case invalidURL
    case invalidResponse
}

class APIClient {
    private let session: URLSession

    // Dependency injection for easier testing
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    // Async function to fetch recipes
    func fetchRecipes() async throws -> RecipeList {
        guard let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") else { throw URLError.invalidURL }
        do {
            let (data, _) = try await session.data(from: url)
            let recipeList = try JSONDecoder().decode(RecipeList.self, from: data)
            return recipeList
        } catch {
            throw URLError.invalidResponse
        }
    }
}
