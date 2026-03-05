import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isVideoPlaying") private var isVideoPlaying: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. On retire Color.black pour laisser voir la vidéo du ContentView
                // On utilise une fine couche sombre pour garder la lisibilité du texte
                Color.black.opacity(0.4).ignoresSafeArea()
                
                List {
                    Section {
                        Toggle(isOn: $isVideoPlaying) {
                            Label("Animation d'arrière-plan", systemImage: "video.fill")
                                .foregroundColor(.white)
                        }
                        .tint(.blue)
                        // 2. L'effet verre dépoli (Liquid Glass)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial) // C'est ici que l'effet se crée
                                .opacity(0.8)
                        )
                    } header: {
                        Text("Affichage").foregroundColor(.white.opacity(0.6))
                    }

                    Section {
                        NavigationLink {
                            EmergencyContactForm()
                        } label: {
                            Label("Numéro d'urgence", systemImage: "phone.circle.fill")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .opacity(0.8)
                        )
                    } header: {
                        Text("Sécurité").foregroundColor(.white.opacity(0.6))
                    }
                }
                .scrollContentBackground(.hidden) // Très important pour la transparence
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// --- SOUS-VUE : FORMULAIRE D'URGENCE ---
struct EmergencyContactForm: View {
    @AppStorage("emergencyName") private var emergencyName: String = ""
    @AppStorage("emergencyPhone") private var emergencyPhone: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRÉNOM DU CONTACT")
                            .font(.caption2).bold().foregroundColor(.gray)
                        TextField("Ex: Jean", text: $emergencyName)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NUMÉRO")
                            .font(.caption2).bold().foregroundColor(.gray)
                        TextField("Ex: 0601020304", text: $emergencyPhone)
                            .keyboardType(.phonePad)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                } header: {
                    Text("Informations")
                } footer: {
                    Text("Ce contact apparaîtra en bas de votre écran de contrôle.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Numéro d'urgence")
    }
}
