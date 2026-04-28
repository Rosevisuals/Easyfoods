import Foundation

struct MockData {

    // MARK: - Foods
    static let foods: [FoodItem] = [
        FoodItem(
            id: 1,
            name: "Smoky BBQ Burger",
            subtitle: "Double beef, BBQ sauce",
            imageName: "burger",
            imageURL: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=85",
            price: 28000,
            rating: 4.8,
            deliveryTime: "20–25",
            calories: 520,
            category: .burger,
            tags: ["Bestseller", "Grilled", "Spicy"],
            description: "Double beef patty with smoky BBQ sauce, aged cheddar, crispy onion rings and fresh jalapeños in a toasted brioche bun."
        ),
        FoodItem(
            id: 2,
            name: "Margherita Pizza",
            subtitle: "Stone-baked, fresh mozzarella",
            imageName: "pizza",
            imageURL: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=85",
            price: 35000,
            rating: 4.7,
            deliveryTime: "25–35",
            calories: 680,
            category: .pizza,
            tags: ["Vegetarian", "Stone-baked"],
            description: "Hand-stretched dough, San Marzano tomato sauce, fresh mozzarella and fragrant basil. Baked at 450° in a stone oven."
        ),
        FoodItem(
            id: 3,
            name: "Ugandan Rolex",
            subtitle: "Chapati, eggs & fresh veggies",
            imageName: "rolex",
            imageURL: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=400&q=85",
            price: 8000,
            rating: 4.9,
            deliveryTime: "10–15",
            calories: 310,
            category: .local,
            tags: ["Local Fave", "Quick"],
            description: "The Ugandan classic: chapati rolled with eggs, tomatoes, onions, cabbage and special chilli sauce. Made fresh to order."
        ),
        FoodItem(
            id: 4,
            name: "Matoke Stew",
            subtitle: "Slow-cooked green banana",
            imageName: "matoke",
            imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=85",
            price: 15000,
            rating: 4.6,
            deliveryTime: "20–25",
            calories: 390,
            category: .local,
            tags: ["Local", "Filling"],
            description: "Slow-cooked green bananas in a rich groundnut and beef stew. Served with steamed greens. A Ugandan home classic."
        ),
        FoodItem(
            id: 5,
            name: "Mango Smoothie",
            subtitle: "Cold-pressed, no sugar",
            imageName: "smoothie",
            imageURL: "https://images.unsplash.com/photo-1502741224143-90386d7f8c82?w=400&q=85",
            price: 12000,
            rating: 4.9,
            deliveryTime: "5–10",
            calories: 180,
            category: .drinks,
            tags: ["Fresh", "Cold"],
            description: "Blended East African mangoes with ginger and lime. Cold-pressed and served over crushed ice."
        ),
        FoodItem(
            id: 6,
            name: "Chocolate Lava Cake",
            subtitle: "Molten dark chocolate centre",
            imageName: "lavacake",
            imageURL: "https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&q=85",
            price: 22000,
            rating: 4.8,
            deliveryTime: "15–20",
            calories: 440,
            category: .dessert,
            tags: ["Sweet", "Must-try"],
            description: "Warm chocolate sponge with a molten dark chocolate centre. Served with vanilla ice cream and caramel drizzle."
        ),
    ]

    // MARK: - Restaurants
    static let restaurants: [Restaurant] = [
        Restaurant(
            id: UUID(),
            name: "Kampala Grill House",
            imageURL: "https://images.unsplash.com/photo-1514190051997-0f6f39ca5cde?w=400&q=80",
            rating: 4.8,
            deliveryTime: "20 min",
            categories: ["Burgers", "Grills"]
        ),
        Restaurant(
            id: UUID(),
            name: "The Rooftop Kitchen",
            imageURL: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80",
            rating: 4.7,
            deliveryTime: "15 min",
            categories: ["Local", "Ugandan"]
        ),
        Restaurant(
            id: UUID(),
            name: "Milano Pizza Co.",
            imageURL: "https://images.unsplash.com/photo-1579751626657-72bc17010498?w=400&q=80",
            rating: 4.6,
            deliveryTime: "30 min",
            categories: ["Pizza", "Italian"]
        ),
    ]

    // MARK: - Saved (first 4 foods)
    static var savedFoods: [FoodItem] {
        Array(foods.prefix(4))
    }

    // MARK: - Mock Order
    static func mockOrder(from cartItems: [CartItem]) -> Order {
        Order(
            id: "EF-\(Int.random(in: 1000...9999))",
            items: cartItems,
            status: .onTheWay,
            placedAt: Date(),
            deliveryAddress: "Plot 23, Prince Charles Drive, Kololo",
            paymentMethod: .mobileMoney,
            riderName: "James Kato",
            estimatedMinutes: 32
        )
    }
}
