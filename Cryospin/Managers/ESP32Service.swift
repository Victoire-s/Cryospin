import Foundation
import Combine

    let baseURL = "http://192.168.4.1"
    
    @Published var lastRequestStatus: String = ""
    
    func turnOnFan() {
        sendRequest(endpoint: "/api/on")
    }
    
    func turnOffFan() {
        sendRequest(endpoint: "/api/off")
    }
    
    private func sendRequest(endpoint: String) {
        guard let url = URL(string: baseURL + endpoint) else {
            DispatchQueue.main.async {
                self.lastRequestStatus = "URL invalide"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.lastRequestStatus = "Erreur: \(error.localizedDescription)"
                    print("❌ Erreur communication ESP32: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        self?.lastRequestStatus = "Succès (\(httpResponse.statusCode))"
                        print("✅ Requête \(endpoint) envoyée avec succès à l'ESP32")
                    } else {
                        self?.lastRequestStatus = "Erreur serveur (\(httpResponse.statusCode))"
                        print("⚠️ L'ESP32 a répondu avec le code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}
