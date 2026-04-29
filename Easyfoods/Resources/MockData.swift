import Foundation

struct MockData {

    // MARK: - Rider
    static let rider = RiderProfile(
        id: UUID(),
        name: "James Kato",
        rating: 4.9,
        deliveries: 847,
        avatarURL: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=85",
        phone: "+256 701 234567",
        bio: "Kampala native. 3 years delivering smiles across the city. Fast, friendly, reliable.",
        joinedYear: 2022
    )

    // MARK: - Foods
    static let foods: [FoodItem] = [
        FoodItem(
            id: 1, name: "Smoky BBQ Burger", subtitle: "Double beef, BBQ sauce",
            imageName: "burger",
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=85",
            price: 28000, rating: 4.8, ratingCount: 320,
            deliveryTime: "20–25", calories: 520, category: .burger,
            tags: ["Bestseller", "Grilled", "Spicy"],
            description: "Double beef patty with smoky BBQ sauce, aged cheddar, crispy onion rings and fresh jalapeños in a toasted brioche bun.",
            addons: [
                FoodAddon(id: UUID(), name: "Add Chips", price: 3000, emoji: "🍟"),
                FoodAddon(id: UUID(), name: "Extra Cheese", price: 2000, emoji: "🧀"),
                FoodAddon(id: UUID(), name: "Extra Patty", price: 5000, emoji: "🥩"),
                FoodAddon(id: UUID(), name: "Add Egg", price: 1500, emoji: "🍳"),
                FoodAddon(id: UUID(), name: "No Onions", price: 0, emoji: "🚫"),
            ]
        ),
        FoodItem(
            id: 2, name: "Margherita Pizza", subtitle: "Stone-baked, fresh mozzarella",
            imageName: "pizza",
            imageURL: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=85",
            price: 35000, rating: 4.7, ratingCount: 214,
            deliveryTime: "25–35", calories: 680, category: .pizza,
            tags: ["Vegetarian", "Stone-baked"],
            description: "Hand-stretched dough, San Marzano tomato sauce, fresh mozzarella and fragrant basil. Baked at 450° in a stone oven.",
            addons: [
                FoodAddon(id: UUID(), name: "Extra Mozzarella", price: 3000, emoji: "🧀"),
                FoodAddon(id: UUID(), name: "Add Pepperoni", price: 4000, emoji: "🍕"),
                FoodAddon(id: UUID(), name: "Add Mushrooms", price: 2000, emoji: "🍄"),
                FoodAddon(id: UUID(), name: "Stuffed Crust", price: 3500, emoji: "✨"),
                FoodAddon(id: UUID(), name: "Gluten Free Base", price: 2500, emoji: "🌾"),
            ]
        ),
        FoodItem(
            id: 3, name: "Ugandan Rolex", subtitle: "Chapati, eggs & fresh veggies",
            imageName: "rolex",
            imageURL: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&q=85",
            price: 8000, rating: 4.9, ratingCount: 612,
            deliveryTime: "10–15", calories: 310, category: .local,
            tags: ["Local Fave", "Quick"],
            description: "The Ugandan classic: chapati rolled with eggs, tomatoes, onions, cabbage and special chilli sauce. Made fresh to order.",
            addons: [
                FoodAddon(id: UUID(), name: "Add Chips", price: 2000, emoji: "🍟"),
                FoodAddon(id: UUID(), name: "Extra Chapati", price: 1500, emoji: "🫓"),
                FoodAddon(id: UUID(), name: "Extra Egg", price: 1000, emoji: "🍳"),
                FoodAddon(id: UUID(), name: "Add Avocado", price: 2000, emoji: "🥑"),
                FoodAddon(id: UUID(), name: "Extra Chilli", price: 0, emoji: "🌶️"),
            ]
        ),
        FoodItem(
            id: 4, name: "Matoke Stew", subtitle: "Slow-cooked green banana",
            imageName: "matoke",
            imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=85",
            price: 15000, rating: 4.6, ratingCount: 178,
            deliveryTime: "20–25", calories: 390, category: .local,
            tags: ["Local", "Filling"],
            description: "Slow-cooked green bananas in a rich groundnut and beef stew. Served with steamed greens. A Ugandan home classic.",
            addons: [
                FoodAddon(id: UUID(), name: "Add Rice", price: 2000, emoji: "🍚"),
                FoodAddon(id: UUID(), name: "Extra Beef", price: 4000, emoji: "🥩"),
                FoodAddon(id: UUID(), name: "Add Posho", price: 1500, emoji: "🫓"),
                FoodAddon(id: UUID(), name: "Extra Groundnut Sauce", price: 1000, emoji: "🥜"),
            ]
        ),
        FoodItem(
            id: 5, name: "Mango Smoothie", subtitle: "Cold-pressed, no sugar",
            imageName: "smoothie",
            imageURL: "https://images.unsplash.com/photo-1502741224143-90386d7f8c82?w=400&q=85",
            price: 12000, rating: 4.9, ratingCount: 403,
            deliveryTime: "5–10", calories: 180, category: .drinks,
            tags: ["Fresh", "Cold"],
            description: "Blended East African mangoes with ginger and lime. Cold-pressed and served over crushed ice. Ask for a flavour below.",
            addons: [
                FoodAddon(id: UUID(), name: "Mango Flavour", price: 0, emoji: "🥭"),
                FoodAddon(id: UUID(), name: "Strawberry Flavour", price: 500, emoji: "🍓"),
                FoodAddon(id: UUID(), name: "Passion Fruit", price: 500, emoji: "🟡"),
                FoodAddon(id: UUID(), name: "Add Yoghurt", price: 1500, emoji: "🥛"),
                FoodAddon(id: UUID(), name: "No Ice", price: 0, emoji: "🌡️"),
            ]
        ),
        FoodItem(
            id: 6, name: "Chocolate Lava Cake", subtitle: "Molten dark chocolate",
            imageName: "lavacake",
            imageURL: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&q=85",
            price: 22000, rating: 4.8, ratingCount: 267,
            deliveryTime: "15–20", calories: 440, category: .dessert,
            tags: ["Sweet", "Must-try"],
            description: "Warm chocolate sponge with a molten dark chocolate centre. Served with vanilla ice cream and caramel drizzle.",
            addons: [
                FoodAddon(id: UUID(), name: "Extra Ice Cream", price: 3000, emoji: "🍨"),
                FoodAddon(id: UUID(), name: "Strawberry Sauce", price: 1500, emoji: "🍓"),
                FoodAddon(id: UUID(), name: "Caramel Drizzle", price: 1000, emoji: "🍯"),
                FoodAddon(id: UUID(), name: "Sprinkles", price: 500, emoji: "🎉"),
            ]
        ),
    ]

    // MARK: - Restaurants
    static let restaurants: [Restaurant] = [
        Restaurant(id: UUID(), name: "Kampala Grill House",
                   imageURL: "https://images.unsplash.com/photo-1514190051997-0f6f39ca5cde?w=400&q=80",
                   rating: 4.8, deliveryTime: "20 min", categories: ["Burgers", "Grills"]),
        Restaurant(id: UUID(), name: "The Rooftop Kitchen",
                   imageURL: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80",
                   rating: 4.7, deliveryTime: "15 min", categories: ["Local", "Ugandan"]),
        Restaurant(id: UUID(), name: "Milano Pizza Co.",
                   imageURL: "https://images.unsplash.com/photo-1579751626657-72bc17010498?w=400&q=80",
                   rating: 4.6, deliveryTime: "30 min", categories: ["Pizza", "Italian"]),
    ]

    // MARK: - Order History
    static func orderHistory() -> [Order] {
        let past1 = Order(
            id: "EF-2841", items: [CartItem(food: foods[0], quantity: 1), CartItem(food: foods[2], quantity: 2)],
            status: .delivered, placedAt: Date().addingTimeInterval(-86400 * 2),
            deliveryAddress: "Plot 23, Prince Charles Drive, Kololo",
            paymentMethod: .mobileMoney, rider: rider, estimatedMinutes: 28
        )
        let past2 = Order(
            id: "EF-2835", items: [CartItem(food: foods[1], quantity: 1)],
            status: .delivered, placedAt: Date().addingTimeInterval(-86400 * 5),
            deliveryAddress: "Plot 23, Prince Charles Drive, Kololo",
            paymentMethod: .cash, rider: rider, estimatedMinutes: 32
        )
        let past3 = Order(
            id: "EF-2819", items: [CartItem(food: foods[4], quantity: 2), CartItem(food: foods[5], quantity: 1)],
            status: .delivered, placedAt: Date().addingTimeInterval(-86400 * 12),
            deliveryAddress: "Plot 23, Prince Charles Drive, Kololo",
            paymentMethod: .card, rider: rider, estimatedMinutes: 22
        )
        return [past1, past2, past3]
    }

    // MARK: - Rider auto-replies
    static let riderReplies = [
        "I'm on my way! 🛵",
        "About 10 minutes away now.",
        "Just passed Wandegeya, nearly there!",
        "Traffic is light today, coming fast 😄",
        "I'll call you when I'm at the gate.",
        "Yes, noted! See you soon.",
        "No problem at all 👍",
    ]

    // MARK: - Mock Order
    static func mockOrder(from cartItems: [CartItem]) -> Order {
        Order(
            id: "EF-\(Int.random(in: 1000...9999))",
            items: cartItems, status: .onTheWay,
            placedAt: Date(),
            deliveryAddress: "Plot 23, Prince Charles Drive, Kololo",
            paymentMethod: .mobileMoney, rider: rider, estimatedMinutes: 32
        )
    }
}

