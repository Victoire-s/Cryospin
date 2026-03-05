import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var tempService = TemperatureService()
    
    @State private var startTemp: Double = 38.0
    @State private var endTemp: Double = 36.5
    @State private var autoFanPower: Double = 70.0
    @State private var autoDuration: Double = 5.0 // minutes
    
    @State private var isManualFanOn: Bool = false
    @State private var manualFanPower: Double = 50.0
    
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
                        .padding(.trailing, 20)
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 120)
                            
                            TemperatureGauge(
                                currentTemp: tempService.currentTemp,
                                startTemp: selectedTab == 0 ? startTemp : nil,
                                endTemp: selectedTab == 0 ? endTemp : nil,
                                isFanActive: selectedTab == 1 ? isManualFanOn : tempService.currentTemp >= startTemp
                            )
                            
                            Spacer(minLength: 80)
                            
                            VStack {
                                if selectedTab == 0 {
                                    autoModeControls
                                        .transition(.opacity)
                                } else {
                                    manualModeControls
                                        .transition(.opacity)
                                }
                            }
                            .padding(.bottom, 140)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height - 150)
                }
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
                    Capsule().stroke(Color.white.opacity(0), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0), radius: 20, x: 0, y: 15)
                .padding(.top, 60)
                
                Spacer()
            }
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
                        color: Color(red: 0.106, green: 0.118, blue: 0.894)
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
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                isShowingHistory = true
            }) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Historique des sessions")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.106, green: 0.118, blue: 0.894))
                .cornerRadius(15)
            }
            .padding(.horizontal, 20)
        }
    }
    
    var manualModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Contrôle Direct") {
                VStack(spacing: 40) {
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
                                .fill(isManualFanOn ? Color(red: 0.106, green: 0.118, blue: 0.894) : Color.white.opacity(0.05))
                                .frame(width: 120, height: 120)
                                .shadow(color: isManualFanOn ? Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.6) : .clear, radius: 25, x: 0, y: 10)
                            
                            Image(systemName: "power")
                                .font(.system(size: 45, weight: .bold))
                                .foregroundColor(isManualFanOn ? .white : .gray.opacity(0.5))
                        }
                    }
                    .padding(.top, 10)
                    
                    DualSliderView(
                        title: "Puissance du ventilateur",
                        value: $manualFanPower,
                        range: 0...100,
                        unit: "%",
                        color: Color(red: 0.106, green: 0.118, blue: 0.894)
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
