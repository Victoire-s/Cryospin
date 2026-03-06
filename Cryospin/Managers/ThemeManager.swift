import SwiftUI
import Combine

// enum des preset
enum AccessibilityPreset: String, CaseIterable {
    case standard = "Standard"
    case protanopia = "Protanopie (Rouge)"
    case deuteranopia = "Deuteranopie (Vert)"
    case tritanopia = "Tritanopie (Bleu-Jaune)" // Ajout Tritanopie
    case highContrast = "Contraste Élevé"
}

final class ThemeManager: ObservableObject {
    @AppStorage("primaryColorHex") var primaryColorHex: String = "#3C007D"
    @AppStorage("secondaryColorHex") var secondaryColorHex: String = "#002EB5"
    @AppStorage("selectedPreset") var selectedPreset: AccessibilityPreset = .standard
    @AppStorage("isVideoPlaying") var isVideoPlaying: Bool = true
    @AppStorage("isHighContrastMode") var isHighContrastMode: Bool = false
    @AppStorage("userPrimaryHex") var userPrimaryHex: String = "#3C007D"
    @AppStorage("userSecondaryHex") var userSecondaryHex: String = "#002EB5"

    var primaryColor: Color {
            get { Color(hex: primaryColorHex) }
            set {
                primaryColorHex = newValue.toHex()
                // Si on change manuellement, on met à jour ton "Standard" perso
                if selectedPreset == .standard { userPrimaryHex = primaryColorHex }
            }
        }

    var secondaryColor: Color {
            get { Color(hex: secondaryColorHex) }
            set {
                secondaryColorHex = newValue.toHex()
                if selectedPreset == .standard { userSecondaryHex = secondaryColorHex }
            }
        }
    
    var adaptiveTextColor: Color {
            // En mode contraste élevé, le fond devient Cyan/Blanc très clair, donc texte NOIR
            // Sinon, sur les fonds sombres habituels (Violet/Bleu), texte BLANC
            isHighContrastMode ? .black : .white
        }

    func applyPreset(_ preset: AccessibilityPreset) {
        isHighContrastMode = false
        selectedPreset = preset
        switch preset {
        case .standard:
            primaryColorHex = userPrimaryHex
            secondaryColorHex = userSecondaryHex
        case .protanopia:
            primaryColorHex = "#F5793A"
            secondaryColorHex = "#85C1E9"
            isVideoPlaying = true
        case .deuteranopia:
            primaryColorHex = "#E69F00"
            secondaryColorHex = "#0072B2"
            isVideoPlaying = true
        case .tritanopia:
            // Couleurs spécifiques Tritanopie
            primaryColorHex = "#D55E00" // Vermillon / Rouge orangé
            secondaryColorHex = "#009E73" // Vert Bleuté / Cyan foncé
            isVideoPlaying = true
        case .highContrast:
            primaryColorHex = "#FFFFFF"
            secondaryColorHex = "#00FFFF"
            isVideoPlaying = false // Désactive la vidéo pour un fond noir pur
            isHighContrastMode = true
        }
    }

    func resetToDefault() {
        primaryColorHex = "#3C007D"
        secondaryColorHex = "#002EB5"
        selectedPreset = .standard
        isVideoPlaying = true
    }
}

// L'extension Color reste en dehors de la classe
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
