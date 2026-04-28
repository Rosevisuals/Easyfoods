import SwiftUI

struct ContentView: View {
    @StateObject private var cart = CartViewModel()
    @StateObject private var home = HomeViewModel()

    @State private var showSplash = true
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            } else {
                mainApp
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
            }
        }
    }

    // MARK: - Main App Shell
    // KEY FIX: Use VStack not ZStack so tab bar doesn't overlap scroll content
    private var mainApp: some View {
        VStack(spacing: 0) {
            // Content — fills all available space above tab bar
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity))
                case .cart:
                    CartView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .saved:
                    SavedView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .profile:
                    ProfileView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
            .environmentObject(cart)
            .environmentObject(home)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: selectedTab)

            // Tab bar — pinned at bottom, NEVER overlaps content
            FloatingTabBar(selected: $selectedTab, cartCount: cart.itemCount)
        }
        .ignoresSafeArea(edges: .bottom) // let tab bar sit right on home indicator area
    }
}

#Preview { ContentView() }
