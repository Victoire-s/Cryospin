import Foundation

final class ESP32Receiver {
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let timeoutInterval: TimeInterval = 5.0

    init(baseURL: String = "http://192.168.4.1", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchDeviceState(
        completion: @escaping (Result<ESP32DeviceState, ESP32ServiceError>) -> Void
    ) {
        guard let url = URL(string: baseURL + "/api/status") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeoutInterval

        session.dataTask(with: request) { [decoder] data, response, error in
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

            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let deviceState = try decoder.decode(ESP32DeviceState.self, from: data)
                completion(.success(deviceState))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }.resume()
    }
}
