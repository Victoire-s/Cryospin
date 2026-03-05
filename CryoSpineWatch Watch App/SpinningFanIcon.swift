import SwiftUI

struct SpinningFanIcon: View {
    var intensity: Double
    
    // Date de référence fixe
    @State private var startDate = Date()
    
    var body: some View {
        // TimelineView est le secret pour une animation fluide sur Watch
        // Elle rafraîchit la vue à chaque image (60fps)
        TimelineView(.animation) { context in
            let timeElapsed = context.date.timeIntervalSince(startDate)
            
            // Calcul de la vitesse :
            // 0% -> 0° par seconde
            // 100% -> 720° par seconde (2 tours/sec)
            let degreesPerSecond = (intensity / 100.0) * 720.0
            let currentRotation = timeElapsed * degreesPerSecond
            
            Image(systemName: "fanblades.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
                .foregroundColor(.white)
                // On applique la rotation calculée mathématiquement
                .rotationEffect(.degrees(currentRotation))
        }
    }
}
