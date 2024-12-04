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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Filter by Additional Materials")) {
                    ForEach(FilterConditions.AdditionalMaterials.allCases, id: \.self) { additionalMaterials in
                        FilterRow(
                            title: additionalMaterials.displayName,
                            isSelected: filterConditions.additionalMaterials.contains(additionalMaterials),
                            onTap: {
                                toggleItem(for: additionalMaterials)
                            }
                        )
                    }
                }
                
                Section(header: Text("Filter by Cuisine")) {
                    ForEach(Cuisines.allCases, id: \.self) { cuisine in
                        FilterRow(
                            title: cuisine.rawValue,
                            isSelected: filterConditions.cuisines.contains(cuisine),
                            onTap: {
                                toggleItem(for: cuisine)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Filter Recipes")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
    
    // Helper method to toggle selection
    private func toggleItem<T: Equatable>(for cuisine: T) {
        if let material = cuisine as? FilterConditions.AdditionalMaterials {
            if filterConditions.additionalMaterials.contains(where: { $0 == material}) {
                filterConditions.additionalMaterials.removeAll(where: { $0 == material })
            } else {
                filterConditions.additionalMaterials.append(material)
            }
        } else if let cuisine = cuisine as? Cuisines {
            if filterConditions.cuisines.contains(where: { $0 == cuisine }) {
                filterConditions.cuisines.removeAll { $0 == cuisine }
            } else {
                filterConditions.cuisines.append(cuisine)
            }
        }
    }
}

struct FilterRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
