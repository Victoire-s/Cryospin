import Foundation
import Combine

final class ESP32Service: ObservableObject {
    let baseURL: String

    // Nouvelles variables depuis l'API complète
    @Published var hotTemperature: Double = 37.2
    @Published var bodyTemperature: Double = 22.7
    @Published var targetTemperature: Double = 20.0
    
    @Published var isPeltierPower: String = "OFF"
    @Published var isFanPower: String = "OFF"
    @Published var isActive: Bool = false
    @Published var isOverheating: Bool = false

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

    func turnOn() {
        // Optimistic UI update
        DispatchQueue.main.async {
            self.isActive = true
        }
        
        sender.sendPowerState(isOn: true) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.lastRequestStatus = "Système activé"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de l'activation du système: \(error.localizedDescription)")
                    // Rollback on failure could go here
                }
            }
        }
    }

    func turnOff() {
        // Optimistic UI update
        DispatchQueue.main.async {
            self.isActive = false
        }
        
        sender.sendPowerState(isOn: false) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success:
                    self.lastRequestStatus = "Système désactivé"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de la désactivation du système: \(error.localizedDescription)")
                    // Rollback on failure could go here
                }
            }
        }
    }

    func setTargetTemperature(_ temp: Double) {
        // Optimistic UI update
        DispatchQueue.main.async {
            self.targetTemperature = temp
            self.isActive = true // Assuming setting temp activates it based on API doc
        }
        
        sender.sendTargetTemp(temp: temp) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success:
                    self.lastRequestStatus = "Nouvelle consigne envoyée (\(temp)°C)"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de l'envoi de la consigne: \(error.localizedDescription)")
                }
            }
        }
    }

    func resetTargetTemperature() {
        // Optimistic UI update
        DispatchQueue.main.async {
            self.targetTemperature = 20.0
            self.isActive = true // API implies resetting activates system
        }
        
        sender.sendReset() { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success:
                    self.lastRequestStatus = "Réinitialisation effectuée"
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = error.localizedDescription
                    print("Erreur lors de la réinitialisation: \(error.localizedDescription)")
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
                    self.hotTemperature = deviceState.tempHot
                    self.bodyTemperature = deviceState.tempBody
                    self.targetTemperature = deviceState.targetTemp
                    self.isPeltierPower = deviceState.peltierState
                    self.isFanPower = deviceState.fanState
                    self.isActive = deviceState.isActive
                    self.isOverheating = deviceState.isOverheating
                    
                    self.lastReadStatus = "Etat recu"
                case .failure(let error):
                    self.lastReadStatus = error.localizedDescription
                    print("Erreur lors de la lecture de l'etat ESP32: \(error.localizedDescription)")
                }
            }
        }
    }
    // Dans ESP32Service.swift

    func setIntensity(_ level: Double) {
        // 1. On lance l'appel via le sender que tu viens de mettre à jour
        sender.sendIntensity(level: level) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.lastRequestStatus = "Intensité envoyée : \(Int(level))%"
                    // Optionnel : on force un rafraîchissement pour confirmer l'état
                    self.refreshStatus()
                case .failure(let error):
                    self.lastRequestStatus = "Erreur intensité : \(error.localizedDescription)"
                    print("Erreur API Intensity: \(error)")
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
