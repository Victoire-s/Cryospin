//
//  PowerButton.swift
//  Cryospin
//
//  Created by Alan Diot on 04/03/2026.
//


import SwiftUI

struct PowerButton: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            // Haptique spécifique à la Watch
            WKInterfaceDevice.current().play(.click)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
            }
            
            // Ici tu peux appeler tes fonctions ESP32 comme dans ton code iOS
        }) {
            ZStack {
                Circle()
                    .fill(isOn ? Color.cyan : Color.white.opacity(0.5))
                    .frame(width: 75, height: 75) // Taille optimisée pour Watch
                    .shadow(color: isOn ? Color.cyan.opacity(0.5) : .clear, radius: 15)
                
                Image(systemName: "power")
                    .font(.system(size: 30, weight: .bold)) // Taille icône réduite
                    .foregroundColor(isOn ? .white : .gray.opacity(0.8))
            }
        }
        .buttonStyle(.plain) // Supprime le style gris par défaut de la Watch
    }
}
