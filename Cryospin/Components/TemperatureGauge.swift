import SwiftUI

struct TemperatureGauge: View {
    @Binding var isAutoMode: Bool
    @Binding var isManualFanOn: Bool
    var currentTemp: Double
    var startTemp: Double
    var endTemp: Double
    var isFanActive: Bool
    
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
            let currentTrim = 0.25 + (tempPercent * 0.5)
            
            // Calculate indicator position
            let currentAngle = 90 + (tempPercent * 180)
            let radAngle = currentAngle * .pi / 180
            
            // White oval indicator on outer edge of the arc
            let arcWidth: CGFloat = 40
            let outerRadius = radius + arcWidth / 2  // outer edge of the arc
            
            let c = CGFloat(cos(radAngle))
            let s = CGFloat(sin(radAngle))
            
            let dotX = cx + outerRadius * c
            let dotY = cy + outerRadius * s
            let dotW: CGFloat = 14   // slightly oval
            let dotH: CGFloat = 20
            
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.25, to: 0.75)
                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // Foreground arc (gradient)
                Circle()
                    .trim(from: 0.25, to: 0.75) // Always fully drawn
                    .stroke(
                        LinearGradient(colors: [Color.cyan, Color(red: 0.106, green: 0.118, blue: 0.894)], startPoint: .bottom, endPoint: .top),
                        style: StrokeStyle(lineWidth: arcWidth, lineCap: .butt)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: cx, y: cy)
                
                // Triangle indicator on the outer edge of the arc
                let triSize: CGFloat = 12
                Path { path in
                    // Triangle pointing outward (radially away from center)
                    // Base is perpendicular to the radial direction, tip points outward
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
                            // Mode Pill Button
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isAutoMode.toggle()
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }) {
                                HStack {
                                    Text(isAutoMode ? "Auto" : "Manuel")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .contentTransition(.interpolate)
                                        .frame(width: 55, alignment: .leading)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 24, height: 24)
                                        Text(isAutoMode ? "A" : "M")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .contentTransition(.interpolate)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .clipShape(Capsule())
                            }
                            
                            // Parameter Buttons
                            HStack(spacing: 15) {
                                if isAutoMode {
                                    // First square — start temp
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .frame(width: 60, height: 60)
                                        VStack(spacing: 2) {
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.red)
                                                .padding(.top, 2)
                                            Text("\(Int(startTemp))°")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                    }
                                    
                                    // Second square — end temp
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .frame(width: 60, height: 60)
                                        VStack(spacing: 2) {
                                            Image(systemName: "arrow.down")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.blue)
                                                .padding(.top, 2)
                                            Text("\(Int(endTemp))°")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                    }
                                } else {
                                    // Power button — toggles fan & blur
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isManualFanOn.toggle()
                                        }
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(isManualFanOn ? Color(red: 0.106, green: 0.118, blue: 0.894) : Color.white.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                                .animation(.easeInOut(duration: 0.3), value: isManualFanOn)
                                            Image(systemName: "power")
                                                .font(.system(size: 24))
                                                .foregroundColor(isManualFanOn ? .white : .gray)
                                                .animation(.easeInOut(duration: 0.3), value: isManualFanOn)
                                        }
                                    }
                                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                                }
                            }
                        }
                    }
                    .padding(.leading, 30) // Offset from the left edge of screen
                    
                    Spacer()
                }
            }
        }
        .frame(height: 420)
    }
}
