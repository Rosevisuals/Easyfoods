//
//  ViewModels.swift
//  Easyfoods
//
//  Created by Rose Visuals on 29/04/2026.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Cart ViewModel
@MainActor
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var selectedPayment: PaymentMethod = .mobileMoney
    @Published var currentOrder: Order? = nil
    @Published var isProcessing = false

    var itemCount: Int   { items.reduce(0) { $0 + $1.quantity } }
    var subtotal: Int    { items.reduce(0) { $0 + $1.subtotal } }
    var deliveryFee: Int { 3500 }
    var serviceFee: Int  { 1000 }
    var total: Int       { subtotal + deliveryFee + serviceFee }
    var isEmpty: Bool    { items.isEmpty }

    func add(_ food: FoodItem, quantity: Int = 1, addons: [FoodAddon] = []) {
        if let idx = items.firstIndex(where: { $0.food.id == food.id && $0.selectedAddons == addons }) {
            items[idx].quantity += quantity
        } else {
            items.append(CartItem(food: food, quantity: quantity, addons: addons))
        }
    }
    func increment(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].quantity += 1
    }
    func decrement(_ item: CartItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        if items[idx].quantity > 1 { items[idx].quantity -= 1 }
        else { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { items.remove(at: idx) } }
    }
    func remove(_ item: CartItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { items.removeAll { $0.id == item.id } }
    }
    func clear() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { items.removeAll() }
    }
    func placeOrder() async {
        isProcessing = true
        try? await Task.sleep(nanoseconds: 2_200_000_000)
        currentOrder = MockData.mockOrder(from: items)
        clear()
        isProcessing = false
    }
}

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var selectedCategory: FoodCategory = .all
    @Published var searchText: String = ""
    @Published var savedFoodIDs: Set<Int> = [1, 3]

    var filteredFoods: [FoodItem] {
        let base = selectedCategory == .all ? MockData.foods : MockData.foods.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return base }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    func toggleSaved(_ food: FoodItem) {
        if savedFoodIDs.contains(food.id) { savedFoodIDs.remove(food.id) }
        else { savedFoodIDs.insert(food.id) }
    }
    func isSaved(_ food: FoodItem) -> Bool { savedFoodIDs.contains(food.id) }
    var savedFoods: [FoodItem] { MockData.foods.filter { savedFoodIDs.contains($0.id) } }
}

// MARK: - Order History ViewModel
@MainActor
class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [Order] = MockData.orderHistory()

    func addOrder(_ order: Order) {
        orders.insert(order, at: 0)
    }
}

// MARK: - Chat ViewModel
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isRiderTyping = false
    private let riderName: String

    init(riderName: String) {
        self.riderName = riderName
        // Greeting from rider
        messages.append(ChatMessage(text: "Hi! I'm \(riderName), your delivery rider. I've picked up your order and I'm on the way 🛵", isFromUser: false))
    }

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, isFromUser: true))
        inputText = ""
        simulateReply()
    }

    private func simulateReply() {
        isRiderTyping = true
        let delay = Double.random(in: 1.2...2.6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.isRiderTyping = false
            let reply = MockData.riderReplies.randomElement() ?? "On my way!"
            self.messages.append(ChatMessage(text: reply, isFromUser: false))
        }
    }
}

