import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var currentTemp: Double = 37.2
    
    // Auto Mode State
    @State private var startTemp: Double = 38.0
    @State private var endTemp: Double = 36.5
    @State private var autoFanPower: Double = 70.0
    @State private var autoDuration: Double = 5.0 // minutes
    
    // Manual Mode State
    @State private var isManualFanOn: Bool = false
    @State private var manualFanPower: Double = 50.0
    // Service réseau ESP32
    @StateObject private var esp32 = ESP32Service()
    
    @Namespace private var menuAnimation
    
    var body: some View {
        ZStack {
            VideoBackgroundView(videoName: "background", videoExtension: "mov")
                .ignoresSafeArea()
            
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("CRYOSPIN")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(4)
                    .padding(.top, 10)
                
                Spacer()
                
                TemperatureGauge(
                    currentTemp: currentTemp,
                    startTemp: selectedTab == 0 ? startTemp : nil,
                    endTemp: selectedTab == 0 ? endTemp : nil,
                    isFanActive: selectedTab == 1 ? isManualFanOn : currentTemp >= startTemp
                )
                .padding(.top, 40)
                
                Spacer()
                
                ScrollView(showsIndicators: false) {
                    VStack {
                        if selectedTab == 0 {
                            autoModeControls
                                .transition(.opacity)
                        } else {
                            manualModeControls
                                .transition(.opacity)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .frame(maxHeight: 280)
            }
            .ignoresSafeArea(edges: .bottom)
            
            VStack {
                HStack(spacing: 0) {
                    TabButton(
                        title: "AUTO",
                        icon: "thermometer.sun.fill",
                        isSelected: selectedTab == 0,
                        namespace: menuAnimation
                    ) {
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.5)) { 
                            selectedTab = 0 
                        }
                    }
                    
                    TabButton(
                        title: "MANUEL",
                        icon: "hand.tap.fill",
                        isSelected: selectedTab == 1,
                        namespace: menuAnimation
                    ) {
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.5)) { 
                            selectedTab = 1 
                        }
                    }
                }
                .padding(6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                .padding(.top, 60)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Auto Mode Controls
    var autoModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Seuils de déclenchement") {
                VStack(spacing: 20) {
                    DualSliderView(
                        title: "Température de début",
                        value: $startTemp,
                        range: 35...42,
                        unit: "°C",
                        color: .red
                    )
                    
                    DualSliderView(
                        title: "Température de fin",
                        value: $endTemp,
                        range: 34...40,
                        unit: "°C",
                        color: .blue
                    )
                }
            }
            
            ControlCard(title: "Paramètres de ventilation") {
                VStack(spacing: 20) {
                    DualSliderView(
                        title: "Puissance",
                        value: $autoFanPower,
                        range: 0...100,
                        unit: "%",
                        color: .cyan
                    )
                    
                    DualSliderView(
                        title: "Optionnel: Durée fixe",
                        value: $autoDuration,
                        range: 0...60,
                        unit: " min",
                        color: .white
                    )
                }
            }
            
            // Future feature placeholder
            Button(action: {}) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Historique des sessions")
                }
                .font(.headline)
                .foregroundColor(.cyan)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cyan.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Manual Mode Controls
    var manualModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Contrôle Direct") {
                VStack(spacing: 40) {
                    // Big Toggle Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isManualFanOn.toggle()
                        }
                        
                        if isManualFanOn {
                            esp32.turnOnFan()
                        } else {
                            esp32.turnOffFan()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isManualFanOn ? Color.cyan : Color.white.opacity(0.05))
                                .frame(width: 120, height: 120)
                                .shadow(color: isManualFanOn ? Color.cyan.opacity(0.6) : .clear, radius: 25, x: 0, y: 10)
                            
                            Image(systemName: "power")
                                .font(.system(size: 45, weight: .bold))
                                .foregroundColor(isManualFanOn ? .white : .gray.opacity(0.5))
                        }
                    }
                    .padding(.top, 10)
                    
                    // Power Slider
                    DualSliderView(
                        title: "Puissance du ventilateur",
                        value: $manualFanPower,
                        range: 0...100,
                        unit: "%",
                        color: .cyan
                    )
                    .opacity(isManualFanOn ? 1.0 : 0.4)
                    .disabled(!isManualFanOn)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
