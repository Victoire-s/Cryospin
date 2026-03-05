import Foundation
import Combine
import WatchKit // Indispensable pour le retour haptique

class WatchESP32Service: ObservableObject {
    let baseURL = "http://192.168.4.1"
    
    @Published var lastRequestStatus: String = ""
    
    // ÉCRAN 1 : ON / OFF
    func turnOn() {
        sendRequest(endpoint: "/api/on")
    }
    
    func turnOff() {
        sendRequest(endpoint: "/api/off")
    }
    
    // ÉCRAN 2 : MANIVELLE (Route non définie pour l'instant)
    // Note : On garde la structure prête pour le futur
    func setIntensity(_ value: Double) {
        print("Log: Intensité modifiée localement : \(Int(value))")
        // sendRequest(endpoint: "/api/speed?value=\(Int(value))")
    }
    
    // ÉCRAN 3 : AUTO (Appelle la route Reset)
    func resetToFactory() {
        sendRequest(endpoint: "/api/reset")
    }
    
    // RÉCUPÉRATION DES DONNÉES (GET /api/data)
    func fetchData() {
        sendRequest(endpoint: "/api/data")
    }
    
    private func sendRequest(endpoint: String) {
        guard let url = URL(string: baseURL + endpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 4.0
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.lastRequestStatus = "Erreur"
                    print("❌ ESP32 Error: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    self?.lastRequestStatus = "OK (\(httpResponse.statusCode))"
                    
                    // Si la requête réussit, on fait vibrer la montre
                    if (200...299).contains(httpResponse.statusCode) {
                        WKInterfaceDevice.current().play(.directionUp)
                    }
                }
            }
        }.resume()
    }
}
