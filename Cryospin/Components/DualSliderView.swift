import SwiftUI

struct DualSliderView: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var unit: String
    var color: Color // Cette couleur sera injectée depuis le ThemeManager dans ContentView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray.opacity(0.8))
                
                Spacer()
                
                // Affichage de la valeur avec un design arrondi cohérent
                Text(String(format: "%.1f%@", value, unit))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Le Slider utilise la couleur dynamique passée en paramètre
            Slider(value: $value, in: range)
                .accentColor(color)
                .tint(color) // Ajout de tint pour compatibilité iOS 16+
        }
        .padding(.vertical, 4)
    }
}
