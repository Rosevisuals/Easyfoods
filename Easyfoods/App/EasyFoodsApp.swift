import SwiftUI

@main
struct EasyFoodsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // Force light mode — our design is light-only
        }
    }
}
