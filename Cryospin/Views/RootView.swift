import SwiftUI

struct RootView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Namespace var animation
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if !networkMonitor.hasCheckedInitialStatus {
                ProgressView()
                    .tint(.white)
            } else {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } 
                else if !networkMonitor.isConnectedToWiFi {
                    WiFiConnectionView()
                        .transition(.opacity.combined(with: .scale))
                } 
                else {
                    ContentView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasSeenOnboarding)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: networkMonitor.isConnectedToWiFi)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: networkMonitor.hasCheckedInitialStatus)
        .environmentObject(networkMonitor)
    }
}

#Preview {
    RootView()
}
