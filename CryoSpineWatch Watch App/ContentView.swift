import SwiftUI

struct ContentView: View {
    @StateObject var esp32 = WatchESP32Service()
    @State private var intensity: Double = 50.0
    @State private var isFanOn: Bool = false
    
    @State private var isAutoMode: Bool = false
    @State private var isCustomMode: Bool = false
    
    var body: some View {
        ZStack {
            ChromeWatchFace()
                .ignoresSafeArea()
            
            TabView {
                // ÉCRAN 1 : Bouton Power (MANUEL)
                VStack {
                    Spacer()
                    // Dans ta ContentView.swift (Watch)
                    PowerButton(
                        isOn: $isFanOn,
                        actionOn: { esp32.turnOn() },  // Appelle /api/on
                        actionOff: { esp32.turnOff() } // Appelle /api/off
                    )
                    Spacer()
                }
                .tag(0)
                
                // ÉCRAN 2 : MANIVELLE
                VStack {
                    Spacer()
                    CrankSlider(value: $intensity)
                        .frame(width: 140, height: 140)
                        .padding()
                        // Verrouillé si le collier est éteint OU en mode Auto
                        .opacity(isFanOn && !isAutoMode ? 1.0 : 0.3)
                        .disabled(!isFanOn || isAutoMode)
                    Spacer()
                }
                .tag(1)
                
                // ÉCRAN 3 : MODES AUTOMATIQUES
                VStack(spacing: 15) {
                    Spacer()
                    Text("CONTROL MODES")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.4))
                    
                    HStack(spacing: 10) {
                        // BOUTON AUTO
                        LiquidGlassButton(
                            title: "Auto",
                            systemImage: isAutoMode ? "thermometer.snowflake" : "snowflake",
                            isActive: isAutoMode,
                            activeColor: Color(hex: "00F2FF")
                        ) {
                            isAutoMode.toggle()
                            
                            if isAutoMode {
                                // On désactive le visuel Manuel sans envoyer de turnOff
                                isFanOn = false
                                // Aucune requête envoyée (route auto non définie)
                            } else {
                                // Si on rappuie sur Auto pour l'éteindre, on éteint l'ESP32
                                isCustomMode = false
                                esp32.turnOff()
                            }
                        }
                        
                        // BOUTON PRESET (Décoratif)
                        LiquidGlassButton(
                            title: isCustomMode ? "Custom" : "Default",
                            systemImage: isCustomMode ? "person.and.arrow.left.and.arrow.right" : "gearshape.2.fill",
                            isActive: isCustomMode,
                            activeColor: Color(hex: "73C2FB")
                        ) {
                            isCustomMode.toggle()
                        }
                        .opacity(isAutoMode ? 1.0 : 0.3)
                        .disabled(!isAutoMode)
                    }
                    .padding(.horizontal, 10)
                    Spacer()
                }
                .tag(2)
            }
            .tabViewStyle(.page)
        }
    }
}
