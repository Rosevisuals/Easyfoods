import SwiftUI

struct ContentView: View {
    @StateObject private var cart    = CartViewModel()
    @StateObject private var home    = HomeViewModel()
    @StateObject private var history = OrderHistoryViewModel()

    @State private var showSplash  = true
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack {
            if showSplash {
                SplashView().transition(.opacity).zIndex(2)
            } else {
                mainApp.transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
            }
        }
    }

    private var mainApp: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                        .transition(.opacity)
                case .cart:
                    CartView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)))
                case .orders:
                    OrderHistoryView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)))
                case .profile:
                    ProfileView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)))
                }
            }
            .environmentObject(cart)
            .environmentObject(home)
            .environmentObject(history)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.32, dampingFraction: 0.78), value: selectedTab)

            FloatingTabBar(selected: $selectedTab, cartCount: cart.itemCount)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview { ContentView() }

