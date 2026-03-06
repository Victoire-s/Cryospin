import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isVideoPlaying") private var isVideoPlaying: Bool = true
    @StateObject private var theme = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                List {
                    // --- SECTION PERSONNALISATION (SOUS-PAGE) ---
                    Section {
                        NavigationLink {
                            ThemeCustomizationView(theme: theme)
                        } label: {
                            Label("Modifier les couleurs", systemImage: "paintbrush.fill")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial).opacity(0.8)
                        )
                    } header: {
                        Text("Apparence").foregroundColor(.white.opacity(0.6))
                    }

                    // --- SECTION AFFICHAGE ---
                    Section {
                        Toggle(isOn: $isVideoPlaying) {
                            Label("Animation d'arrière-plan", systemImage: "video.fill")
                                .foregroundColor(.white)
                        }
                        .tint(.blue)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial).opacity(0.8)
                        )
                    } header: {
                        Text("Vidéo").foregroundColor(.white.opacity(0.6))
                    }

                    // --- SECTION SÉCURITÉ ---
                    Section {
                        NavigationLink {
                            EmergencyContactForm()
                        } label: {
                            Label("Numéro d'urgence", systemImage: "phone.circle.fill")
                                .foregroundColor(.white)
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial).opacity(0.8)
                        )
                    } header: {
                        Text("Sécurité").foregroundColor(.white.opacity(0.6))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Paramètres")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ThemeCustomizationView: View {
    @ObservedObject var theme: ThemeManager
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            List {
                // SECTION PRESETS
                Section {
                    Picker("Mode d'affichage", selection: $theme.selectedPreset) {
                        ForEach(AccessibilityPreset.allCases, id: \.self) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .onChange(of: theme.selectedPreset) { newValue in
                        withAnimation {
                            theme.applyPreset(newValue)
                        }
                    }
                } header: {
                    Text("Accessibilité").foregroundColor(.white.opacity(0.6))
                } footer: {
                    Text("Les modes Daltonisme adaptent les contrastes pour une meilleure distinction des seuils.")
                }
                .listRowBackground(Color.white.opacity(0.1))

                // SECTION MANUELLE (Ton code existant)
                Section {
                    ColorPicker("Couleur Primaire", selection: $theme.primaryColor)
                    ColorPicker("Couleur Secondaire", selection: $theme.secondaryColor)
                } header: {
                    Text("Personnalisation manuelle").foregroundColor(.white.opacity(0.6))
                }
                .listRowBackground(Color.white.opacity(0.1))
                
                Section {
                    Button(action: { theme.resetToDefault() }) {
                        HStack {
                            Spacer()
                            Text("Rétablir les couleurs par défaut").foregroundColor(.red).bold()
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Couleurs")
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
