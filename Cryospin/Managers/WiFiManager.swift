import Foundation
import NetworkExtension
import Combine

class WiFiManager: ObservableObject {
    @Published var connectionStatus: String = ""
    @Published var isConnecting: Bool = false
    
    let esp32SSID = "Collier_Connecte_Setup"
    let esp32Password = ""
    
    func connectToESP32() {
        self.isConnecting = true
        self.connectionStatus = "Tentative de connexion à \(esp32SSID)..."
        
        let configuration: NEHotspotConfiguration
        
        if esp32Password.isEmpty {
            configuration = NEHotspotConfiguration(ssid: esp32SSID)
        } else {
            configuration = NEHotspotConfiguration(ssid: esp32SSID, passphrase: esp32Password, isWEP: false)
        }
        
        configuration.joinOnce = true
        
        NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] error in
            DispatchQueue.main.async {
                self?.isConnecting = false
                if let error = error {
                    self?.connectionStatus = "Erreur: \(error.localizedDescription)"
                    print("Erreur de connexion WiFi: \(error)")
                } else {
                    self?.connectionStatus = "Connecté avec succès à \(self!.esp32SSID)"
                    print("Connexion au Hotspot réussie !")
                }
            }
        }
    }
    
    func disconnectFromESP32() {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: esp32SSID)
        self.connectionStatus = "Déconnecté de \(esp32SSID)"
    }
}
