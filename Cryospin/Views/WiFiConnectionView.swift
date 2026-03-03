import SwiftUI

struct WiFiConnectionView: View {
    @State private var isPulsing = false
    
    // Gestionnaire de connexion au Collier The Cryospin
    @StateObject private var wifiManager = WiFiManager()
    
    var body: some View {
        ZStack {
            // Vidéo en arrière-plan
            VideoBackgroundView(videoName: "background", videoExtension: "mov")
                .ignoresSafeArea()
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                    
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(.orange)
                }
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)
                .onAppear {
                    isPulsing = true
                }
                
                VStack(spacing: 15) {
                    Text("Connexion Requise")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("L'application doit se connecter au réseau Wi-Fi local généré par votre collier pour pouvoir communiquer avec ce dernier.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                if !wifiManager.connectionStatus.isEmpty {
                    Text(wifiManager.connectionStatus)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(wifiManager.connectionStatus.contains("Erreur") ? .red : .green)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .animation(.easeInOut, value: wifiManager.connectionStatus)
                }
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    // Lancement de la demande de configuration
                    wifiManager.connectToESP32()
                }) {
                    HStack {
                        if wifiManager.isConnecting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 8)
                        }
                        
                        Text(wifiManager.isConnecting ? "Connexion en cours..." : "Rejoindre le collier")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(wifiManager.isConnecting ? Color.gray.opacity(0.5) : Color.orange)
                    .clipShape(Capsule())
                    .padding(.horizontal, 40)
                }
                .disabled(wifiManager.isConnecting)
                
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Je préfère me connecter manuellement")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .underline()
                }
                .padding(.bottom, 40)
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    WiFiConnectionView()
}
