import SwiftUI

struct LiquidGlassButton: View {
    var title: String
    var systemImage: String
    var isActive: Bool
    var activeColor: Color // Nouvelle propriété pour la couleur du glow
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            WKInterfaceDevice.current().play(.click)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isActive ? activeColor.opacity(0.7) : Color.white.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isActive ? activeColor : Color.white.opacity(0.2), lineWidth: 1.5)
            )
            // Aura lumineuse personnalisée
            .shadow(color: isActive ? activeColor.opacity(0.6) : .clear, radius: 12, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}
