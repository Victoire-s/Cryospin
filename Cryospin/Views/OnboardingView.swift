import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    let features = [
        FeatureInfo(
            title: "Bienvenue sur Cryospin",
            description: "Le collier intelligent qui s'adapte à votre température corporelle en temps réel.",
            icon: nil,
            color: Color(red: 0.106, green: 0.118, blue: 0.894)
        ),
        FeatureInfo(
            title: "Mode Automatique",
            description: "Définissez vos seuils, et le collier se déclenche et s'arrête tout seul selon vos besoins.",
            icon: "thermometer.sun.fill",
            color: .orange
        ),
        FeatureInfo(
            title: "Contrôle Manuel",
            description: "Prenez le relais à tout moment avec une puissance ajustable d'un simple geste.",
            icon: "hand.tap.fill",
            color: .blue
        ),
        FeatureInfo(
            title: "Connexion Requise",
            description: "L'application fonctionne en tandem avec le collier grâce à une communication par réseau Wi-Fi local dédié.",
            icon: "wifi",
            color: .white
        )
    ]
    
    var body: some View {
        ZStack {
            VideoBackgroundView(videoName: "background", videoExtension: "mov", isPlaying: .constant(true))
                .ignoresSafeArea()
            Color.black.opacity(0.6).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<features.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            if let iconName = features[index].icon {
                                Image(systemName: iconName)
                                    .font(.system(size: 80, weight: .light))
                                    .foregroundColor(features[index].color)
                                    .shadow(color: features[index].color.opacity(0.5), radius: 20)
                            }
                            
                            Text(features[index].title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(features[index].description)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineSpacing(5)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                Button(action: {
                    if currentPage < features.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        withAnimation { hasSeenOnboarding = true }
                    }
                }) {
                    Text(currentPage < features.count - 1 ? "Suivant" : "Commencer")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct FeatureInfo {
    var title: String
    var description: String
    var icon: String?
    var color: Color
}
