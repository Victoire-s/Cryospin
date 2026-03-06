import Foundation

final class ESP32Sender {
    private let baseURL: String
    private let session: URLSession
    private let timeoutInterval: TimeInterval = 5.0

    init(baseURL: String = "http://192.168.4.1", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func sendPowerState(
        isOn: Bool,
        completion: @escaping (Result<Void, ESP32ServiceError>) -> Void
    ) {
        let endpoint = isOn ? "/api/on" : "/api/off"
        sendRequest(path: endpoint, queryItems: [], completion: completion)
    }

    func sendTargetTemp(
        temp: Double,
        completion: @escaping (Result<Void, ESP32ServiceError>) -> Void
    ) {
        let queryItems = [
            URLQueryItem(name: "temp", value: String(format: "%.1f", temp))
        ]
        sendRequest(path: "/api/set", queryItems: queryItems, completion: completion)
    }
    
    // Ajoute cette fonction juste après sendTargetTemp
    func sendIntensity(
        level: Double,
        completion: @escaping (Result<Void, ESP32ServiceError>) -> Void
    ) {
        // On prépare le paramètre "value" (ou "level" selon ton API ESP32)
        let queryItems = [
            URLQueryItem(name: "intensity", value: String(format: "%.0f", level))
        ]
        
        // On utilise la route /api/intensity
        sendRequest(path: "/api/intensity", queryItems: queryItems, completion: completion)
    }

    func sendReset(
        completion: @escaping (Result<Void, ESP32ServiceError>) -> Void
    ) {
        sendRequest(path: "/api/reset", queryItems: [], completion: completion)
    }

    private func sendRequest(
        path: String,
        queryItems: [URLQueryItem],
        completion: @escaping (Result<Void, ESP32ServiceError>) -> Void
    ) {
        guard var components = URLComponents(string: baseURL + path) else {
            completion(.failure(.invalidURL))
            return
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeoutInterval

        session.dataTask(with: request) { _, response, error in
            if let error {
                completion(.failure(.network(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }

            completion(.success(()))
        }.resume()
    }
}
