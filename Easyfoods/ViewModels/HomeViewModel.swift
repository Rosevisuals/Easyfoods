import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    @Published var selectedCategory: FoodCategory = .all
    @Published var searchText: String = ""
    @Published var savedFoodIDs: Set<Int> = [1, 3]  // pre-saved for demo

    var filteredFoods: [FoodItem] {
        let byCategory = selectedCategory == .all
            ? MockData.foods
            : MockData.foods.filter { $0.category == selectedCategory }

        if searchText.isEmpty { return byCategory }
        return byCategory.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    func toggleSaved(_ food: FoodItem) {
        if savedFoodIDs.contains(food.id) {
            savedFoodIDs.remove(food.id)
        } else {
            savedFoodIDs.insert(food.id)
        }
    }

    func isSaved(_ food: FoodItem) -> Bool {
        savedFoodIDs.contains(food.id)
    }

    var savedFoods: [FoodItem] {
        MockData.foods.filter { savedFoodIDs.contains($0.id) }
    }
}
