import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Auto Mode State
    @State private var startTemp: Double = 38.0
    @State private var endTemp: Double = 36.5
    @State private var autoFanPower: Double = 70.0
    @State private var autoDuration: Double = 5.0 // minutes
    
    @State private var isManualFanOn: Bool = false
    // Manual Mode State
    @State private var manualFanPower: Double = 50.0
    
    @State private var isAutoMode: Bool = true
    
    @StateObject private var tempService = TemperatureService()
    @StateObject private var esp32 = ESP32Service()
    
    @State private var isVideoPlaying: Bool = true
    @State private var isShowingHistory: Bool = false
    
    @Namespace private var menuAnimation
    
    var body: some View {
        ZStack {
            VideoBackgroundView(videoName: "background", videoExtension: "mov", isPlaying: $isVideoPlaying)
                .ignoresSafeArea()
            
            Color.black
                .ignoresSafeArea()
                .opacity(isVideoPlaying ? 0 : 0.85)
                .animation(.easeInOut(duration: 0.6), value: isVideoPlaying)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
                            isVideoPlaying.toggle()
                        }
                    }) {
                        Image(systemName: isVideoPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Text("CRYOSPIN")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(4)
                    
                    Spacer()
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        isShowingHistory = true
                    }) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 120)
                            
                            TemperatureGauge(
                                isAutoMode: $isAutoMode,
                                isManualFanOn: $isManualFanOn,
                                currentTemp: esp32.hotTemperature,
                                startTemp: startTemp,
                                endTemp: endTemp,
                                isFanActive: isAutoMode ? (esp32.hotTemperature >= startTemp) : esp32.isActive
                            )
                            
                            Spacer(minLength: 80)
                            
                            VStack {
                                if isAutoMode {
                                    autoModeControls
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                } else {
                                    manualModeControls
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAutoMode)
                            .padding(.bottom, 140)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height - 150)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            esp32.startPolling()
        }
        .onDisappear {
            esp32.stopPolling()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingHistory) {
            SessionHistoryView(history: tempService.dailyHistory)
                .presentationDetents([.fraction(0.8)]) // Takes up exactly 80% screen
                .presentationDragIndicator(.hidden) // We have custom drag indicator in SessionHistoryView
                .presentationCornerRadius(30)
                .presentationBackground(.clear) // To let our own glassmorphism background shine
        }
    }
    
    var autoModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Seuils de déclenchement") {
                VStack(spacing: 20) {
                    DualSliderView(
                        title: "Température de début",
                        value: $startTemp,
                        range: 35...42,
                        unit: "°C",
                        color: Color(red: 0.235, green: 0.0, blue: 0.490)  // #3C007D chaud
                    )
                    
                    DualSliderView(
                        title: "Température de fin",
                        value: $endTemp,
                        range: 34...40,
                        unit: "°C",
                        color: Color(red: 0.0, green: 0.180, blue: 0.710)  // #002EB5 froid
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
                        color: Color(red: 0.0, green: 0.180, blue: 0.710)  // #002EB5
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
            ControlCard(title: "Actions API") {
                HStack(spacing: 20) {
                    Button(action: {
                        esp32.setTargetTemperature(endTemp)
                    }) {
                        Text("Appliquer consigne")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.0, green: 0.180, blue: 0.710)) // blue froid
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        esp32.resetTargetTemperature()
                    }) {
                        Text("Reset (20°C)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    var manualModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Contrôle manuel") {
                VStack(spacing: 20) {
                    DualSliderView(
                        title: "Puissance",
                        value: $manualFanPower,
                        range: 0...100,
                        unit: "%",
                        color: Color(red: 0.0, green: 0.180, blue: 0.710)  // #002EB5
                    )
                }
                .blur(radius: esp32.isActive ? 0 : 6)
                .disabled(!esp32.isActive)
                .animation(.easeInOut(duration: 0.3), value: esp32.isActive)
            }
        }
        .onChange(of: isManualFanOn) { newValue in
            if newValue {
                esp32.turnOn()
            } else {
                esp32.turnOff()
            }
        }
        .onChange(of: esp32.isActive) { newValue in
            if isManualFanOn != newValue {
                isManualFanOn = newValue
            }
        }
    }
}

#Preview {
    ContentView()
}
