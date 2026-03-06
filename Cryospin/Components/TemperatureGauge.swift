import SwiftUI

struct TemperatureGauge: View {
    @Binding var isAutoMode: Bool
    @Binding var isManualFanOn: Bool
    var currentTemp: Double
    var startTemp: Double
    var endTemp: Double
    var isFanActive: Bool
    
    @StateObject private var heartRateManager = HeartRateManager()
    @StateObject private var theme = ThemeManager()
    
    let minT: Double = 30.0
    let range: Double = 12.0
    
    func percent(for temp: Double) -> Double {
        return max(0, min(1, (temp - minT) / range))
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let radius = height / 2
            let cx = width
            let cy = height / 2
            
            let tempPercent = percent(for: currentTemp)
            let currentAngle = 90 + (tempPercent * 180)
            let radAngle = currentAngle * .pi / 180
            
            let arcWidth: CGFloat = 40
            let outerRadius = radius + arcWidth / 2
            
            let c = CGFloat(cos(radAngle))
            let s = CGFloat(sin(radAngle))
            
            ZStack {
                // 1. Arrière-plan de l'arc
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // 2. Arc de progression (Couleurs Thème)
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [theme.secondaryColor, theme.primaryColor],
                            startPoint: .bottom, endPoint: .top
                        ),
                        style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // 3. Indicateur Triangle
                let triSize: CGFloat = 12
                Path { path in
                    let tipX = cx + (outerRadius + triSize) * c
                    let tipY = cy + (outerRadius + triSize) * s
                    let base1X = cx + (outerRadius - triSize * 0.5) * c - triSize * s
                    let base1Y = cy + (outerRadius - triSize * 0.5) * s + triSize * c
                    let base2X = cx + (outerRadius - triSize * 0.5) * c + triSize * s
                    let base2Y = cy + (outerRadius - triSize * 0.5) * s - triSize * c
                    path.move(to: CGPoint(x: tipX, y: tipY))
                    path.addLine(to: CGPoint(x: base1X, y: base1Y))
                    path.addLine(to: CGPoint(x: base2X, y: base2Y))
                    path.closeSubpath()
                }
                .fill(Color.white)
                .shadow(color: .black.opacity(0.4), radius: 4)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: radAngle)
                
                // --- POSITIONNEMENT FIXÉ ---
                
                // RYTHME CARDIAQUE (Décalé à gauche du centre de l'arc)
                VStack(spacing: 2) {
                    Text(heartRateManager.bpm == 0 ? "--" : "\(heartRateManager.bpm)")
                        .font(.system(size: 70, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(theme.isHighContrastMode ? theme.secondaryColor : .red)
                        .scaleEffect(heartRateManager.bpm > 0 ? 1.1 : 1.0)
                        .animation(heartRateManager.bpm > 0 ? .easeInOut(duration: 0.5).repeatForever() : .default, value: heartRateManager.bpm)
                }
                .position(x: cx - 85, y: cy) // Positionnement précis vers l'intérieur
                
                // TEMPÉRATURE & BOUTONS (Alignés à gauche de l'écran)
                HStack {
                    VStack(alignment: .leading, spacing: 40) {
                        VStack(alignment: .leading, spacing: -5) {
                            Text("°C")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(String(format: "%.0f", currentTemp))
                                .font(.system(size: 90, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            // Bouton Mode
                            Button(action: { isAutoMode.toggle() }) {
                                HStack {
                                    Text(isAutoMode ? "Auto" : "Manuel")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(theme.isHighContrastMode ? .white : .black)
                                        .frame(width: 65, alignment: .leading)
                                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 24).overlay(Text(isAutoMode ? "A" : "M").font(.caption).bold())
                                }
                                .padding(10)
                                .background(theme.isHighContrastMode ? Color.white.opacity(0.1) : Color.white)
                                .cornerRadius(16)
                            }
                            
                            HStack(spacing: 12) {
                                if isAutoMode {
                                    TemperatureBadge(value: "\(Int(startTemp))°", icon: "arrow.up", color: theme.primaryColor)
                                    TemperatureBadge(value: "\(Int(endTemp))°", icon: "arrow.down", color: theme.secondaryColor)
                                } else {
                                    Button(action: { isManualFanOn.toggle() }) {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(isManualFanOn ? theme.secondaryColor : Color.white.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(Image(systemName: "power").foregroundColor(isManualFanOn ? theme.adaptiveTextColor : .gray))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
            }
        }
        .frame(height: 420)
        
        .onAppear {
            heartRateManager.requestAuthorizationAndStart()
            heartRateManager.startHeartRateQuery()
            // Lance la surveillance en temps réel dès que la jauge apparaît
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    heartRateManager.startHeartRateQuery() // Force un check
                }
        }
    }
}

// COMPOSANT BADGE RECONSTRUIT
struct TemperatureBadge: View {
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color.white).frame(width: 60, height: 60)
            VStack(spacing: 2) {
                Image(systemName: icon).font(.caption).bold().foregroundColor(color)
                Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.black)
            }
        }
    }
}
