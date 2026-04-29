import Foundation
import SwiftUI

// MARK: - Food Item
struct FoodItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let subtitle: String
    let imageName: String
    let imageURL: String
    let price: Int              // UGX
    let rating: Double
    let ratingCount: Int
    let deliveryTime: String
    let calories: Int
    let category: FoodCategory
    let tags: [String]
    let description: String
    let addons: [FoodAddon]     // toppings / flavours / sides
}

// MARK: - Food Addon (toppings, flavours, sides)
struct FoodAddon: Identifiable, Hashable {
    let id: UUID
    let name: String
    let price: Int              // 0 = free
    let emoji: String
}

// MARK: - Food Category
enum FoodCategory: String, CaseIterable, Identifiable {
    case all = "All", burger = "Burger", pizza = "Pizza",
         local = "Local", drinks = "Drinks", dessert = "Dessert"
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .all: return "🍽️"; case .burger: return "🍔"
        case .pizza: return "🍕"; case .local: return "🍲"
        case .drinks: return "🥤"; case .dessert: return "🧁"
        }
    }
}

// MARK: - Cart Item
struct CartItem: Identifiable {
    let id: UUID
    let food: FoodItem
    var quantity: Int
    var selectedAddons: [FoodAddon]

    init(food: FoodItem, quantity: Int = 1, addons: [FoodAddon] = []) {
        self.id = UUID(); self.food = food
        self.quantity = quantity; self.selectedAddons = addons
    }
    var addonTotal: Int { selectedAddons.reduce(0) { $0 + $1.price } }
    var unitPrice: Int { food.price + addonTotal }
    var subtotal: Int { unitPrice * quantity }
}

// MARK: - Order
struct Order: Identifiable {
    let id: String
    let items: [CartItem]
    var status: OrderStatus
    let placedAt: Date
    let deliveryAddress: String
    let paymentMethod: PaymentMethod
    let rider: RiderProfile
    let estimatedMinutes: Int

    var subtotal: Int { items.reduce(0) { $0 + $1.subtotal } }
    var deliveryFee: Int { 3500 }
    var serviceFee: Int  { 1000 }
    var total: Int { subtotal + deliveryFee + serviceFee }

    var statusLabel: String { status.rawValue }
    var statusColor: Color {
        switch status {
        case .confirmed: return .blue
        case .preparing: return Color(hex: "#FF8533")
        case .onTheWay:  return Color(hex: "#FF6200")
        case .delivered: return Color(hex: "#22C55E")
        }
    }
}

enum OrderStatus: String, CaseIterable {
    case confirmed = "Confirmed"
    case preparing = "Preparing"
    case onTheWay  = "On the Way"
    case delivered = "Delivered"
}

// MARK: - Rider Profile
struct RiderProfile: Identifiable {
    let id: UUID
    let name: String
    let rating: Double
    let deliveries: Int
    let avatarURL: String
    let phone: String
    let bio: String
    let joinedYear: Int
}

// MARK: - Chat Message
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date

    init(text: String, isFromUser: Bool) {
        self.id = UUID(); self.text = text
        self.isFromUser = isFromUser; self.timestamp = Date()
    }
}

// MARK: - Payment Method
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

