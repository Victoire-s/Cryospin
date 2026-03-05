import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // --- PERSISTANCE & PARAMÈTRES ---
    @AppStorage("isVideoPlaying") private var isVideoPlaying: Bool = true // État sauvegardé de l'animation
    @AppStorage("emergencyName") private var emergencyName: String = ""
    @AppStorage("emergencyPhone") private var emergencyPhone: String = ""
    @State private var isShowingSettings = false
    
    // --- AUTO MODE STATE ---
    @State private var startTemp: Double = 38.0
    @State private var endTemp: Double = 36.5
    @State private var autoFanPower: Double = 70.0
    @State private var autoDuration: Double = 5.0 // minutes
    
    @State private var isManualFanOn: Bool = false
    // --- MANUAL MODE STATE ---
    @State private var manualFanPower: Double = 50.0
    
    @State private var isAutoMode: Bool = true
    
    // --- SERVICES ---
    @StateObject private var tempService = TemperatureService()
    @StateObject private var esp32 = ESP32Service()
    
    @State private var isShowingHistory: Bool = false
    @Namespace private var menuAnimation
    
    var body: some View {
        ZStack {
            // FOND VIDÉO (Écoute l'état persisté)
            VideoBackgroundView(videoName: "background", videoExtension: "mov", isPlaying: $isVideoPlaying)
                .ignoresSafeArea()
            
            // FILTRE SOMBRE (S'active si la vidéo est en pause pour le look LiquidGlass)
            Color.black
                .ignoresSafeArea()
                .opacity(isVideoPlaying ? 0 : 0.85)
                .animation(.easeInOut(duration: 0.6), value: isVideoPlaying)
            
            VStack(spacing: 0) {
                // HEADER ÉPURÉ
                HStack {
                    // Bouton Paramètres (Ouvre la NavigationStack)
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Text("CRYOSPIN")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(4)
                    
                    Spacer()
                    
                    // Bouton Historique Graphique
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
                        
                        // JAUGE THERMIQUE
                        TemperatureGauge(
                            isAutoMode: $isAutoMode,
                            isManualFanOn: $isManualFanOn,
                            currentTemp: esp32.hotTemperature,
                            startTemp: startTemp,
                            endTemp: endTemp,
                            isFanActive: isAutoMode ? (esp32.hotTemperature >= startTemp) : esp32.isActive
                        )
                        
                        Spacer(minLength: 80)
                        
                        VStack(spacing: 25) {
                            // SÉLECTEUR DE MODE
                            if isAutoMode {
                                autoModeControls
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            } else {
                                manualModeControls
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            }
                            
                            // --- BOUTON APPEL D'URGENCE (Fixé en bas de liste) ---
                            if !emergencyPhone.isEmpty {
                                Button(action: triggerEmergencyCall) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "phone.fill")
                                        Text("Urgence : \(emergencyName)")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.red.opacity(0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .red.opacity(0.3), radius: 10)
                                }
                                .padding(.top, 20)
                                .transition(.opacity.animation(.easeInOut))
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAutoMode)
                        .padding(.horizontal, 20)
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
        
        // --- MODALES (SHEETS) ---
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .presentationBackground(.clear) // Permet de voir la vidéo derrière la modale
        }
        .sheet(isPresented: $isShowingHistory) {
            SessionHistoryView(history: tempService.dailyHistory)
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(.clear)
        }
    }
    
    // --- LOGIQUE D'APPEL ---
    private func triggerEmergencyCall() {
        let cleanedPhone = emergencyPhone.filter { "0123456789+".contains($0) }
        if let url = URL(string: "tel://\(cleanedPhone)") {
            UIApplication.shared.open(url)
        }
    }
    
    // --- SECTIONS DE CONTRÔLES (Logique conservée) ---
    var autoModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Seuils de déclenchement") {
                VStack(spacing: 20) {
                    DualSliderView(title: "Température de début", value: $startTemp, range: 35...42, unit: "°C", color: Color(red: 0.235, green: 0.0, blue: 0.490))
                    DualSliderView(title: "Température de fin", value: $endTemp, range: 34...40, unit: "°C", color: Color(red: 0.0, green: 0.180, blue: 0.710))
                }
            }
            ControlCard(title: "Paramètres de ventilation") {
                VStack(spacing: 20) {
                    DualSliderView(title: "Puissance", value: $autoFanPower, range: 0...100, unit: "%", color: Color(red: 0.0, green: 0.180, blue: 0.710))
                    DualSliderView(title: "Optionnel: Durée fixe", value: $autoDuration, range: 0...60, unit: " min", color: .white)
                }
            }
            ControlCard(title: "Actions API") {
                HStack(spacing: 20) {
                    Button(action: { esp32.setTargetTemperature(endTemp) }) {
                        Text("Appliquer consigne").font(.subheadline).foregroundColor(.white).padding().background(Color(red: 0.0, green: 0.180, blue: 0.710)).cornerRadius(10)
                    }
                    Button(action: { esp32.resetTargetTemperature() }) {
                        Text("Reset (20°C)").font(.subheadline).foregroundColor(.white).padding().background(Color.white.opacity(0.2)).cornerRadius(10)
                    }
                }
            }
        }
    }
    
    var manualModeControls: some View {
        VStack(spacing: 25) {
            ControlCard(title: "Contrôle manuel") {
                VStack(spacing: 20) {
                    DualSliderView(title: "Puissance", value: $manualFanPower, range: 0...100, unit: "%", color: Color(red: 0.0, green: 0.180, blue: 0.710))
                }
                .blur(radius: esp32.isActive ? 0 : 6)
                .disabled(!esp32.isActive)
                .animation(.easeInOut(duration: 0.3), value: esp32.isActive)
            }
        }
        .onChange(of: isManualFanOn) { newValue in
            if newValue { esp32.turnOn() }
            else { esp32.turnOff() }
        }
        .onChange(of: esp32.isActive) { newValue in
            if isManualFanOn != newValue { isManualFanOn = newValue }
        }
    }
}
