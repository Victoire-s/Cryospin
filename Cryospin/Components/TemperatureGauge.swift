import SwiftUI

struct TemperatureGauge: View {
    var currentTemp: Double
    var startTemp: Double?
    var endTemp: Double?
    var isFanActive: Bool
    
    // Scale 30°C to 42°C
    let minT: Double = 30.0
    let range: Double = 12.0
    
    func percent(for temp: Double) -> Double {
        return max(0, min(1, (temp - minT) / range))
    }
    
    var body: some View {
        ZStack {
            // Background track (3/4 of a circle)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white.opacity(0.04), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(135))
                .frame(width: 250, height: 250)
            
            // Active fan glow effect behind
            if isFanActive {
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.cyan.opacity(0.4), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .rotationEffect(.degrees(135))
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isFanActive)
            }
            
            // Full gradient track
            let gradient = AngularGradient(
                gradient: Gradient(colors: [Color.blue, Color.cyan, Color.orange, Color.red]),
                center: .center,
                startAngle: .degrees(135),
                endAngle: .degrees(135 + 270)
            )
            
            Circle()
                .trim(from: 0, to: 0.75) // Remplit tout le track visible
                .stroke(gradient, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(135))
                .frame(width: 250, height: 250)
            
            // Current temperature marker/progress overlay
            let tempPercent = percent(for: currentTemp)
            
            // Curseur pour la température actuelle (Gros point blanc par exemple)
            let currentAngle = 135 + (tempPercent * 270)
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .shadow(color: .black.opacity(0.3), radius: 5)
                .offset(x: 125)
                .rotationEffect(.degrees(currentAngle))
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentTemp)
            
            // Markers
            if let end = endTemp {
                let endAngle = 135 + (percent(for: end) * 270)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.4), radius: 4)
                    .offset(x: 125)
                    .rotationEffect(.degrees(endAngle))
                    .animation(.spring(), value: end)
            }
            
            if let start = startTemp {
                let startAngle = 135 + (percent(for: start) * 270)
                Circle()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: .black.opacity(0.4), radius: 4)
                    .offset(x: 125)
                    .rotationEffect(.degrees(startAngle))
                    .animation(.spring(), value: start)
            }
            
            // Inner Content
            VStack(spacing: 4) {
                if isFanActive {
                    Image(systemName: "wind")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.cyan)
                        .modifier(SpinningAnimation())
                } else {
                    Image(systemName: "wind")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                HStack(alignment: .top, spacing: 2) {
                    Text(String(format: "%.1f", currentTemp))
                        .font(.system(size: 68, weight: .thin, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText()) // smooth numeric transition when currentTemp changes
                    Text("°C")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.top, 14)
                }
                
                if let start = startTemp, let end = endTemp {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("Fin".uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 10, weight: .bold))
                                Text(String(format: "%.1f", end))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Début".uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 10, weight: .bold))
                                Text(String(format: "%.1f", start))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 5)
                } else {
                    // Manual mode
                    Text("MODE MANUEL")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.2))
                        .tracking(2)
                        .padding(.top, 10)
                }
            }
        }
    }
}
