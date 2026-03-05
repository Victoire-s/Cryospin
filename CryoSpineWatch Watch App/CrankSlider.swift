//
//  CrankSlider.swift
//  Cryospin
//
//  Created by Alan Diot on 05/03/2026.
//


import SwiftUI

struct CrankSlider: View {
    @Binding var value: Double
    @State private var previousAngle: Double? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // 1. L'ANNEAU AVEC DÉGRADÉ ET AURA
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1B1EE4"), Color(hex: "04CDFF")]),
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: 15
                    )
                    .shadow(color: Color(hex: "04CDFF").opacity(0.8), radius: 15) // Effet d'aura
                
                // 2. L'ICÔNE ET LA VALEUR AU CENTRE
                VStack(spacing: 5) {
                    SpinningFanIcon(intensity: value)
                    
                    Text("\(Int(value))%")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .contentShape(Circle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(with: gesture.location, in: center)
                    }
                    .onEnded { _ in previousAngle = nil }
            )
        }
    }
    
    private func updateValue(with location: CGPoint, in center: CGPoint) {
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let currentAngle = atan2(vector.y, vector.x) * (180 / .pi)
        
        guard let prevAngle = previousAngle else {
            previousAngle = currentAngle
            return
        }
        
        var angleDiff = currentAngle - prevAngle
        if angleDiff > 180 { angleDiff -= 360 }
        if angleDiff < -180 { angleDiff += 360 }
        
        // Sensibilité de la "manivelle"
        let valueChange = (angleDiff / 360) * 100 * 0.5
        self.value = max(0, min(100, self.value + valueChange))
        previousAngle = currentAngle
    }
}

// Extension pratique pour utiliser les codes Hexa
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
