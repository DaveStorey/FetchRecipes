//
//  ContentView.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/22/24.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @State private var recipes: [Recipe] = []
    @State var filterConditions = FilterConditions()
    @State private var filterPopup = false
    @State private var errorPopup: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            RecipesView(recipes: $recipes,
                        filterConditions: $filterConditions)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Sort", action: {
                        sort()
                    })
                    Button(action: addItem) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    Button(action: { filterPopup.toggle() }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                addItem()
            }
        }
        .popover(isPresented: $filterPopup, content: {
            FilterView(filterConditions: $filterConditions)
        })
        .alert(
            "Error",
            isPresented: $errorPopup,
            presenting: errorMessage) { message in
                Text(message)
                    .font(.subheadline)
                Button("Retry") {
                    errorPopup = false
                    addItem()
                }
                
            }
        .onAppear(perform: addItem)
    }
    
    private func addItem() {
        withAnimation {
            let client = APIClient()
            Task {
                do {
                    self.recipes = try await client.fetchRecipes().recipes
                } catch(let error) {
                    self.recipes = []
                    errorPopup = true
                    /* Sampling since errors are relatively controlled here. In a real production app there would be
                     a more robust system developed in consultation with business and customer support reps*/
                    errorMessage = {
                        switch error {
                        case URLError.invalidURL: return "Invalid URL, please contact our support with error code 1"
                        case URLError.invalidResponse: return "Invalid Response, please contact our support with error code 2"
                        case DecodingError.valueNotFound: return "Decoding Error, please contact our support with error code 3"
                        case DecodingError.dataCorrupted: return "Decoding Error, please contact our support with error code 4"
                        case DecodingError.typeMismatch: return "Decoding Error, please contact our support with error code 5"
                        case DecodingError.keyNotFound: return "Decoding Error, please contact our support with error code 6"
                        default: return "Unknown Error, please contact our support with error code 7"
                        }
                    }()
                }
            }
        }
    }
    
    private func sort() {
        withAnimation {
            recipes.sort(by: { recipes.first?.name.first == "A" ? $1.name < $0.name : $0.name < $1.name })
        }
    }
}
