import Foundation
import Combine

struct TemperatureDataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let temperature: Double
}

class TemperatureService: ObservableObject {
    @Published var currentTemp: Double = 39.2
    @Published var dailyHistory: [TemperatureDataPoint] = []
    
    private var timer: Timer?
    
    init() {
        generateBaseSet()
        startRealTimeUpdates()
    }
    
    private func generateBaseSet() {
        var points: [TemperatureDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        let startOfDay = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        // Generate a mock history from 8:00 AM to now
        let startHour = 8
        let endHour = max(startHour, currentHour)
        
        for hour in startHour...endHour {
            for minute in stride(from: 0, to: 60, by: 10) {
                if hour == currentHour && minute > currentMinute { break }
                
                guard let pointTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: startOfDay) else { continue }
                
                // Base temperature around 37°C with some slight fluctuations (fake cooling/heating events)
                let base = 37.0
                let variance = Double.random(in: -0.5...1.5)
                points.append(TemperatureDataPoint(time: pointTime, temperature: base + variance))
            }
        }
        
        self.dailyHistory = points
        if let last = points.last {
            self.currentTemp = last.temperature
        }
    }
    
    private func startRealTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Fluctuate temperature slightly
            let change = Double.random(in: -0.2...0.2)
            let newTemp = max(30.0, min(42.0, self.currentTemp + change))
            
            DispatchQueue.main.async {
                self.currentTemp = newTemp
                
                // Add new point to history every minute approximately, or just update graph
                let lastPoint = self.dailyHistory.last?.time ?? Date()
                if Date().timeIntervalSince(lastPoint) > 60 { // fake every 60 seconds
                    self.dailyHistory.append(TemperatureDataPoint(time: Date(), temperature: newTemp))
                    
                    // Keep history to last 24h
                    let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    self.dailyHistory.removeAll { $0.time < dayAgo }
                }
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
