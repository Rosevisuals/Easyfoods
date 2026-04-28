import Foundation
import Combine
import SwiftUI

@MainActor
class CartViewModel: ObservableObject {

    @Published var items: [CartItem] = []
    @Published var selectedPayment: PaymentMethod = .mobileMoney
    @Published var currentOrder: Order? = nil
    @Published var isProcessing = false

    // MARK: - Computed
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Int {
        items.reduce(0) { $0 + $1.subtotal }
    }

    var deliveryFee: Int { 3500 }
    var serviceFee: Int  { 1000 }

    var total: Int {
        subtotal + deliveryFee + serviceFee
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Actions
    func add(_ food: FoodItem, quantity: Int = 1) {
        if let idx = items.firstIndex(where: { $0.food.id == food.id }) {
            items[idx].quantity += quantity
        } else {
            items.append(CartItem(food: food, quantity: quantity))
        }
    }

    func increment(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].quantity += 1
    }

    func decrement(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[idx].quantity > 1 {
            items[idx].quantity -= 1
        } else {
            withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
                items.remove(at: idx)
            }
        }
    }

    func remove(_ item: CartItem) {
        withAnimation(Animation.spring(response: 0.3, dampingFraction: 0.7)) {
            items.removeAll { $0.id == item.id }
        }
    }

    func clear() {
        withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.75)) {
            items.removeAll()
        }
    }

    func quantity(for food: FoodItem) -> Int {
        items.first(where: { $0.food.id == food.id })?.quantity ?? 0
    }

    // MARK: - Order placement
    func placeOrder() async {
        isProcessing = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_400_000_000)
        currentOrder = MockData.mockOrder(from: items)
        clear()
        isProcessing = false
    }
}

