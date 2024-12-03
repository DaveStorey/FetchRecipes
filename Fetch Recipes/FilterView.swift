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
        NavigationView {
            Form {
                // Your existing filter sections go here
                Section(header: Text("Filter by Additional Materials")) {
                    ForEach(FilterConditions.AdditionalMaterials.allCases, id: \.self) { additionalMaterials in
                        FilterRow(
                            title: additionalMaterials.displayName,
                            isSelected: filterConditions.additionalMaterials.contains(additionalMaterials),
                            onTap: {
                                toggleSelection(for: additionalMaterials, in: &filterConditions.additionalMaterials)
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
                                toggleSelection(for: cuisine, in: &filterConditions.cuisines)
                            }
                        )
                    }
                }
                
                Section {
                    HStack {
                        Button("Done") {
                            filterPop.toggle() // Close the filter view
                        }
                        .frame(width: 100, height: 45)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Clear All") {
                            filterConditions.cuisines.removeAll()
                            filterConditions.additionalMaterials.removeAll()
                        }
                        .frame(width: 100, height: 45)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Filter Recipes")
            .navigationBarItems(trailing: Button("Close") {
                filterPop.toggle()
            })
        }
    }
    
    // Helper method to toggle selection in a list
    private func toggleSelection<T: Equatable>(for item: T, in list: inout [T]) {
        if list.contains(item) {
            list.removeAll { $0 == item }
        } else {
            list.append(item)
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
        .contentShape(Rectangle()) // Make the entire row tappable
        .onTapGesture {
            onTap()
        }
    }
}
