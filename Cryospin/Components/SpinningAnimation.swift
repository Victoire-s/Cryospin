import SwiftUI

// Basic spin animation for the active fan icon
struct SpinningAnimation: ViewModifier {
    @State private var isSpinning = false
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    isSpinning = true
                }
            }
    }
}
