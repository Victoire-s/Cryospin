import Foundation
import Combine

final class ESP32Service: ObservableObject {
    let baseURL: String

    @Published var isFanOn: Bool = false
    @Published var bodyTemperature: Double = 37.2
    @Published var lastRequestStatus: String = ""
    @Published var lastReadStatus: String = ""

    private let sender: ESP32Sender
    private let receiver: ESP32Receiver
    private let pollingInterval: TimeInterval

    private var pollingCancellable: AnyCancellable?
    private var isFetchingStatus = false

    init(
        baseURL: String = "http://192.168.4.1",
        session: URLSession = .shared,
        pollingInterval: TimeInterval = 2.0
    ) {
        self.baseURL = baseURL
        self.sender = ESP32Sender(baseURL: baseURL, session: session)
        self.receiver = ESP32Receiver(baseURL: baseURL, session: session)
        self.pollingInterval = pollingInterval
    }

    func turnOnFan() {
        sender.sendPowerState(isOn: true) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.isFanOn = true
                    self.lastRequestStatus = "Ventilateur active"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de l'activation du ventilateur: \(error.localizedDescription)")
                }
            }
        }
    }

    func turnOffFan() {
        sender.sendPowerState(isOn: false) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.isFanOn = false
                    self.lastRequestStatus = "Ventilateur desactive"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de la desactivation du ventilateur: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateConfiguration(
        minTemp: Double,
        maxTemp: Double,
        fanPower: Double,
        durationMinutes: Double
    ) {
        guard minTemp <= maxTemp else {
            lastRequestStatus = "La temperature minimale doit etre inferieure ou egale a la temperature maximale"
            return
        }

        guard durationMinutes >= 0 else {
            lastRequestStatus = "La duree d'activation doit etre positive ou nulle"
            return
        }

        let configuration = ESP32FanConfiguration(
            minTemperature: minTemp,
            maxTemperature: maxTemp,
            fanPower: min(max(fanPower, 0), 100),
            activationDurationMinutes: durationMinutes
        )

        sender.sendConfiguration(configuration) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.lastRequestStatus = "Configuration envoyee"
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de l'envoi de la configuration: \(error.localizedDescription)")
                }
            }
        }
    }

    func refreshStatus() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.refreshStatus()
            }
            return
        }

        guard !isFetchingStatus else { return }
        isFetchingStatus = true

        receiver.fetchDeviceState { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                defer { self.isFetchingStatus = false }

                switch result {
                case .success(let deviceState):
                    self.isFanOn = deviceState.isOn
                    self.bodyTemperature = deviceState.bodyTemperature
                    self.lastReadStatus = "Etat recu"
                case .failure(let error):
                    self.lastReadStatus = error.localizedDescription
                    print("Erreur lors de la lecture de l'etat ESP32: \(error.localizedDescription)")
                }
            }
        }
    }

    func startPolling() {
        guard pollingCancellable == nil else { return }

        refreshStatus()

        pollingCancellable = Timer.publish(every: pollingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshStatus()
            }
    }

    func stopPolling() {
        pollingCancellable?.cancel()
        pollingCancellable = nil
    }
}
