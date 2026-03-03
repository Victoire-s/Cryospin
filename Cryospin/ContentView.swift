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
    
    var body: some View {
        ZStack {
            // Elegant Background
            Color(red: 0.1, green: 0.12, blue: 0.15).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("CRYOSPIN")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(4)
                    .padding(.top, 20)
                
                // Custom Tab Selector
                HStack {
                    TabButton(title: "AUTO", isSelected: selectedTab == 0) {
                        withAnimation { selectedTab = 0 }
                    }
                    TabButton(title: "MANUEL", isSelected: selectedTab == 1) {
                        withAnimation { selectedTab = 1 }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Central Gauge
                TemperatureGauge(
                    currentTemp: currentTemp,
                    startTemp: selectedTab == 0 ? startTemp : nil,
                    endTemp: selectedTab == 0 ? endTemp : nil,
                    isFanActive: selectedTab == 1 ? isManualFanOn : currentTemp >= startTemp
                )
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                // Content based on tab
                ScrollView {
                    if selectedTab == 0 {
                        autoModeControls
                            .transition(.opacity)
                    } else {
                        manualModeControls
                            .transition(.opacity)
                    }
                }
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
            .padding(.bottom, 20)
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
