import SwiftUI
import Charts

struct SessionHistoryView: View {
    @Environment(\.dismiss) var dismiss
    
    var history: [TemperatureDataPoint] = []
    
    let mockSessions: [UserSession] = [
        UserSession(date: "Aujourd'hui, 08:30", duration: "12 min", startTemp: "38.5°C", endTemp: "36.5°C"),
        UserSession(date: "Hier, 21:15", duration: "8 min", startTemp: "38.2°C", endTemp: "36.8°C"),
        UserSession(date: "2 Mars, 18:00", duration: "15 min", startTemp: "39.0°C", endTemp: "36.5°C"),
        UserSession(date: "1 Mars, 07:45", duration: "10 min", startTemp: "38.0°C", endTemp: "36.7°C")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 10)
                    
                    HStack {
                        Text("Historique des sessions")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                }
                .background(Color.black.opacity(0.2))
                
                // Content list
                ScrollView {
                    VStack(spacing: 15) {
                        if !history.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Aujourd'hui")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Chart {
                                    ForEach(history) { point in
                                        LineMark(
                                            x: .value("Heure", point.time),
                                            y: .value("Température", point.temperature)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(Color(red: 0.106, green: 0.118, blue: 0.894))
                                        
                                        AreaMark(
                                            x: .value("Heure", point.time),
                                            y: .value("Température", point.temperature)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.3),
                                                    Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.0)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                }
                                .chartYScale(domain: .automatic(includesZero: false))
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .hour, count: 2)) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .foregroundStyle(Color.white.opacity(0.1))
                                        AxisTick(stroke: StrokeStyle(lineWidth: 0))
                                        AxisValueLabel(format: .dateTime.hour(), collisionResolution: .greedy)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                                            .foregroundStyle(Color.white.opacity(0.1))
                                        AxisTick(stroke: StrokeStyle(lineWidth: 0))
                                        if let temp = value.as(Double.self) {
                                            AxisValueLabel {
                                                Text(String(format: "%.1f°", temp))
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                        }
                                    }
                                }
                                .frame(height: 180)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }

                        ForEach(mockSessions, id: \.date) { session in
                            HStack(spacing: 15) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "thermometer.snow")
                                        .foregroundColor(Color(red: 0.106, green: 0.118, blue: 0.894))
                                        .font(.system(size: 20))
                                }
                                
                                // Details
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(session.date)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("\(session.startTemp) → \(session.endTemp)")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                // Duration
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text(session.duration)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("Durée")
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

struct UserSession {
    let date: String
    let duration: String
    let startTemp: String
    let endTemp: String
}

#Preview {
    SessionHistoryView(history: TemperatureService().dailyHistory)
}
