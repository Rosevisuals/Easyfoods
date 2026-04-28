import Foundation
import SwiftUI

// MARK: - Food Item
struct FoodItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let subtitle: String
    let imageName: String       // SF Symbol or asset name
    let imageURL: String        // Remote URL for AsyncImage
    let price: Int              // UGX
    let rating: Double
    let deliveryTime: String    // e.g. "20–25"
    let calories: Int
    let category: FoodCategory
    let tags: [String]
    let description: String
}

enum FoodCategory: String, CaseIterable, Identifiable {
    case all      = "All"
    case burger   = "Burger"
    case pizza    = "Pizza"
    case local    = "Local"
    case drinks   = "Drinks"
    case dessert  = "Dessert"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .all:     return "🍽️"
        case .burger:  return "🍔"
        case .pizza:   return "🍕"
        case .local:   return "🍲"
        case .drinks:  return "🥤"
        case .dessert: return "🧁"
        }
    }
}

// MARK: - Cart Item
struct CartItem: Identifiable {
    let id: UUID
    let food: FoodItem
    var quantity: Int

    init(food: FoodItem, quantity: Int = 1) {
        self.id = UUID()
        self.food = food
        self.quantity = quantity
    }

    var subtotal: Int { food.price * quantity }
}

// MARK: - Order
struct Order: Identifiable {
    let id: String
    let items: [CartItem]
    let status: OrderStatus
    let placedAt: Date
    let deliveryAddress: String
    let paymentMethod: PaymentMethod
    let riderName: String
    let estimatedMinutes: Int

    var subtotal: Int { items.reduce(0) { $0 + $1.subtotal } }
    var deliveryFee: Int { 3500 }
    var serviceFee: Int { 1000 }
    var total: Int { subtotal + deliveryFee + serviceFee }
}

enum OrderStatus: String {
    case confirmed  = "Order Confirmed"
    case preparing  = "Preparing"
    case onTheWay   = "On the Way"
    case delivered  = "Delivered"
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    case mobileMoney = "Mobile Money"
    case card        = "Visa / Mastercard"
    case cash        = "Cash on Delivery"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .mobileMoney: return "📱"
        case .card:        return "💳"
        case .cash:        return "💵"
        }
    }
}

// MARK: - Restaurant
struct Restaurant: Identifiable {
    let id: UUID
    let name: String
    let imageURL: String
    let rating: Double
    let deliveryTime: String
    let categories: [String]
}
