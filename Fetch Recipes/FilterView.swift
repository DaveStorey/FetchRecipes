//
//  FilterView.swift
//  Fetch Recipes
//
//  Created by David Storey on 11/26/24.
//

import SwiftUI

/// Popover view for filtering recipes by cuisine and availability of additional materials. Could be expanded to include filtering by ingredients or taste profiles.
struct FilterView: View {
    @Binding var filterConditions: FilterConditions
    @Binding var filterPop: Bool
    
    var body: some View {
        
        // Experimented with the multi-select functionality for List here, but the edit mode seems to have some bugs
        // so I went homebrew.
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
