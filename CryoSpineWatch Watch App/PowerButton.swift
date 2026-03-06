import SwiftUI

struct PowerButton: View {
    @Binding var isOn: Bool
    
    // Ajout des actions pour lier directement le service ESP32
    var actionOn: () -> Void
    var actionOff: () -> Void
    
    var body: some View {
        Button(action: {
            // Haptique spécifique à la Watch pour confirmer le toucher
            WKInterfaceDevice.current().play(.click)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
                
                // Déclenchement immédiat de la route réseau correspondante
                if isOn {
                    actionOn()
                } else {
                    actionOff()
                }
            }
        }) {
            ZStack {
                // Fond du bouton
                Circle()
                    .fill(isOn ? Color.cyan : Color.white.opacity(0.2))
                    .frame(width: 85, height: 85) // Taille légèrement augmentée pour le confort
                    .shadow(color: isOn ? Color.cyan.opacity(0.5) : .clear, radius: 15)
                
                // Icône Power
                Image(systemName: "power")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(isOn ? .white : .white.opacity(0.6))
                
                // Halo lumineux si activé
                if isOn {
                    Circle()
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 4)
                        .scaleEffect(1.1)
                }
            }
        }
        .buttonStyle(.plain) // Supprime le style gris par défaut watchOS
    }
}
