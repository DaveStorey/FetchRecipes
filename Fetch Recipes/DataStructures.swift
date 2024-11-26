//
//  Recipe.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/22/24.
//



struct Recipe: Codable, Identifiable, Equatable {
    let cuisine: String
    let name: String
    let photo_url_large: String?
    let photo_url_small: String?
    let uuid: String
    let source_url: String?
    let youtube_url: String?
    var id: String { self.uuid }
    var hasSourceWebsite: Bool { self.source_url != nil }
    var hasYoutubeVideo: Bool { self.youtube_url != nil }
}

struct RecipeList: Codable {
    let recipes: [Recipe]
}

enum Cuisines: String, CaseIterable, Identifiable {
    case American
    case British
    case Canadian
    case Croatian
    case French
    case Greek
    case Italian
    case Malaysian
    case Russian
    case Tunisian
    
    var id: String { self.rawValue }
}

struct FilterConditions {
    var cuisines: [Cuisines] = []
    var additionalMaterials: [AdditionalMaterials] = []
    
    enum AdditionalMaterials: String, CaseIterable, Identifiable {
        case hideWithoutWebsite
        case hideWithoutVideo
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .hideWithoutWebsite: return "Hide without website"
            case .hideWithoutVideo: return "Hide without video"
            }
        }
    }
    
    func checkRecipe(_ recipe: Recipe) -> Bool {
        if cuisines.isEmpty || cuisines.contains(where: { $0.rawValue == recipe.cuisine }) {
            if additionalMaterials.isEmpty {
                return true
            }
            if additionalMaterials.contains(.hideWithoutVideo), !recipe.hasYoutubeVideo {
                return false
            }
            if additionalMaterials.contains(.hideWithoutWebsite), !recipe.hasSourceWebsite {
                return false
            }
            return true
        }
        return false
    }
}
