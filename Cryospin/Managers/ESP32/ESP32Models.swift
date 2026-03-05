import Foundation

struct ESP32DeviceState: Decodable {
    let tempHot: Double
    let tempBody: Double
    let targetTemp: Double
    let peltierState: String
    let fanState: String
    let isActive: Bool
    let isOverheating: Bool

    // Map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case tempHot = "temp_hot"
        case tempBody = "temp_body"
        case targetTemp = "cible"
        case peltierState = "peltier"
        case fanState = "fans"
        case isActive = "actif"
        case isOverheating = "en_surchauffe"
    }
}

enum ESP32ServiceError: LocalizedError {
    case invalidURL
    case network(Error)
    case invalidResponse
    case httpError(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .network(let error):
            return "Erreur reseau: \(error.localizedDescription)"
        case .invalidResponse:
            return "Reponse invalide de l'ESP32"
        case .httpError(let statusCode):
            return "Erreur serveur (\(statusCode))"
        case .decoding(let error):
            return "Erreur de decodage: \(error.localizedDescription)"
        }
    }
}
