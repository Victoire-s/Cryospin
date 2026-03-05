import Foundation

struct ESP32FanConfiguration {
    let minTemperature: Double
    let maxTemperature: Double
    let fanPower: Double
    let activationDurationMinutes: Double
}

struct ESP32DeviceState: Decodable {
    let isOn: Bool
    let bodyTemperature: Double
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
