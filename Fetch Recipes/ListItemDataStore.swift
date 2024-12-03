//
//  ListItemDataStore.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/26/24.
//

import Foundation
import Combine
import SwiftUI

/// Using a class-based data store allows for better async functionality and local data storage of the images that persists after the views themselves would have been recycled.
class ListItemDataStore: ObservableObject {
    @Published public var recipe: Recipe
    @Published public var smallImage: Image
    @Published public var largeImage: Image
    
    init(recipe: Recipe, smallImage: Image? = nil, largeImage: Image? = nil) {
        self.recipe = recipe
        self.smallImage = smallImage ?? Image(systemName: "photo")
        self.largeImage = largeImage ?? Image(systemName: "photo")
        
        if smallImage == nil {
            Task { await fetchSmallImage() }
        }
    }
        
    @MainActor
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
    
    @MainActor
    func fetchLargeImage() async {
        guard largeImage == Image(systemName: "photo"), let urlString = recipe.photo_url_large, let url = URL(string: urlString) else {
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
