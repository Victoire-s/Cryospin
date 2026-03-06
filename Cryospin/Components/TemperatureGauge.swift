import SwiftUI

struct TemperatureGauge: View {
    @Binding var isAutoMode: Bool
    @Binding var isManualFanOn: Bool
    var currentTemp: Double
    var startTemp: Double
    var endTemp: Double
    var isFanActive: Bool
    
    // NOUVEAU : Accès au thème pour les couleurs dynamiques
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
                // Background arc
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // Foreground arc (DYNAMIQUE)
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [theme.secondaryColor, theme.primaryColor], // Utilise le bleu et violet du thème
                            startPoint: .bottom, endPoint: .top
                        ),
                        style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // Triangle indicator
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
                
                // Left content
                HStack {
                    VStack(alignment: .leading, spacing: 40) {
                        // Temperature Text
                        VStack(alignment: .leading, spacing: 0) {
                            Text("°C")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(String(format: "%.0f", currentTemp))
                                .font(.system(size: 100, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .contentTransition(.numericText())
                                .padding(.top, -10)
                        }
                        
                        // Buttons
                        VStack(alignment: .leading, spacing: 15) {
                            // Mode Button
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isAutoMode.toggle()
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }) {
                                HStack {
                                    Text(isAutoMode ? "Auto" : "Manuel")
                                        .font(.system(size: 16, weight: .bold)) // Passé en Bold pour l'équilibre
                                        .foregroundColor(.black)
                                        .frame(width: 65, height: 38, alignment: .leading)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 24, height: 24)
                                        Text(isAutoMode ? "A" : "M")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            // Parameter Buttons
                            HStack(spacing: 15) {
                                if isAutoMode {
                                    // Start Temp Badge
                                    TemperatureBadge(value: "\(Int(startTemp))°", icon: "arrow.up", color: theme.primaryColor)
                                    
                                    // End Temp Badge
                                    TemperatureBadge(value: "\(Int(endTemp))°", icon: "arrow.down", color: theme.secondaryColor)
                                    
                                } else {
                                    // Power button (DYNAMIQUE)
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isManualFanOn.toggle()
                                        }
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(isManualFanOn ? theme.secondaryColor : Color.white.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "power")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(isManualFanOn ? .white : .gray)
                                        }
                                    }
                                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                }
                            }
                        }
                    }
                    .padding(.leading, 30)
                    Spacer()
                }
            }
        }
        .frame(height: 420)
    }
}

// Composant réutilisable pour les petits carrés de température
struct TemperatureBadge: View {
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(width: 60, height: 60)
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .padding(.top, 2)
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.8)))
    }
}
