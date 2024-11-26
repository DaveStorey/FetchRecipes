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
    @Environment(\.managedObjectContext) private var viewContext
    @State private var recipes: [Recipe] = []
    @State private var filterConditions = FilterConditions()
    @State private var filterPopup = false
    @State private var errorPopup: Bool = false
    @State private var errorMessage: String? = nil
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
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
            FilterView(
                filterConditions: $filterConditions,
                filterPop: $filterPopup)
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

struct RecipesView: View {
    @Binding var recipes: [Recipe]
    @Binding var filterConditions: FilterConditions
    
    @ViewBuilder
    var body: some View {
        if recipes.isEmpty {
            Text("No recipes found")
        } else {
            List(recipes.filter({ recipe in filterConditions.checkRecipe(recipe) })
            ) { recipe in
                RecipeView(recipe: recipe)
            }
        }
    }
}

// Popover view for filtering recipes by cuisine. Could be expanded to include filtering by ingredients or availability of recipe source.
struct FilterView: View {
    @Binding var filterConditions: FilterConditions
    @Binding var filterPop: Bool
    
    var body: some View {
        List() {
            Section(header: Text("Filter by Additional Materials")) {
                ForEach(FilterConditions.AdditionalMaterials.allCases) { additionalMaterials in
                    LazyHStack {
                        Text(additionalMaterials.displayName)
                        if filterConditions.additionalMaterials.contains(additionalMaterials) {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }.onTapGesture {
                        if filterConditions.additionalMaterials.contains(additionalMaterials) {
                            filterConditions.additionalMaterials.removeAll(where: { $0 == additionalMaterials })
                        } else {
                            filterConditions.additionalMaterials.append(additionalMaterials)
                        }
                    }
                }
            }
        }
        .frame(height: 200)
        
        List() {
            Section(header: Text("Filter by Cuisine")) {
                ForEach(Cuisines.allCases) { cuisine in
                    LazyHStack {
                        Text(cuisine.rawValue)
                        if filterConditions.cuisines.contains(cuisine) {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }.onTapGesture {
                        if filterConditions.cuisines.contains(cuisine) {
                            filterConditions.cuisines.removeAll(where: { $0 == cuisine })
                        } else {
                            filterConditions.cuisines.append(cuisine)
                        }
                    }
                }
            }
        }
            
        LazyHStack {
            Button("Done", action: { filterPop.toggle() })
                .frame(width: 100, height: 45)
                .cornerRadius(2.5)
            Button("Clear all", action: {
                filterConditions.cuisines.removeAll()
                filterConditions.additionalMaterials.removeAll()
            })
                .frame(width: 100, height: 45)
                .cornerRadius(2.5)
        }
        .frame(height: 50)
    }
}

struct RecipeView: View {
    let recipe: Recipe
    @State var isExpanded: Bool = false
    @ObservedObject var dataStore: ListItemDataStore
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.dataStore = ListItemDataStore(recipe: recipe)
    }
    
    @ViewBuilder
    var body: some View {
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

class ListItemDataStore: ObservableObject {
    @Published fileprivate var recipe: Recipe
    @Published fileprivate var smallImage: Image
    @Published fileprivate var largeImage: Image
    
    init(recipe: Recipe, smallImage: Image? = nil, largeImage: Image? = nil) {
        self.recipe = recipe
        self.smallImage = smallImage ?? Image(systemName: "photo")
        self.largeImage = largeImage ?? Image(systemName: "photo")
        
        if smallImage == nil {
            Task { await fetchSmallImage() }
        }
    }
        
    func fetchSmallImage() async {
        guard let urlString = recipe.photo_url_small, let url = URL(string: urlString) else {
             return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data, let self else {
                return }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.smallImage = Image(uiImage: image)
                }
            }
        }
        task.resume()
    }
    
    func fetchLargeImage() async {
        guard let urlString = recipe.photo_url_large, let url = URL(string: urlString) else {
             return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data, let self else { return }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.largeImage = (Image(uiImage: image))
                }
            }
        }
        task.resume()
    }
}
