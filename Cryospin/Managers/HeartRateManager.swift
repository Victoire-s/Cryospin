import HealthKit
import SwiftUI
import Combine

class HeartRateManager: ObservableObject {
    private var healthStore = HKHealthStore()
    @Published var bpm: Int = 0
    
    // On garde une trace de la requête pour pouvoir l'arrêter si besoin
    private var anchor: HKQueryAnchor?

    func startHeartRateQuery() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        // Cette requête "écoute" les nouveaux échantillons
        let query = HKAnchoredObjectQuery(type: sampleType,
                                          predicate: nil,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            self?.anchor = newAnchor
            self?.updateHeartRate(samples)
        }

        // C'EST ICI QUE LA MAGIE OPÈRE :
        // L'updateHandler est appelé à chaque fois qu'une nouvelle mesure arrive
        query.updateHandler = { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            self?.anchor = newAnchor
            self?.updateHeartRate(samples)
        }

        healthStore.execute(query)
    }

    private func updateHeartRate(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample], let lastSample = samples.last else { return }
        
        let unit = HKUnit(from: "count/min")
        let value = Int(lastSample.quantity.doubleValue(for: unit))
        print("💓 Nouveau BPM reçu : \(value)") // Ajoute ceci pour monitorer le flux
        
        DispatchQueue.main.async {
            withAnimation(.smooth) {
                self.bpm = value
            }
        }
    }
    
    // Dans HeartRateManager.swift
    func requestAuthorizationAndStart() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let healthStore = HKHealthStore()
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { success, error in
            if success {
                // Une fois autorisé, on lance la requête
                self.startHeartRateQuery()
            }
        }
    }
}
