import SwiftUI

struct DualSliderView: View {
    var title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var unit: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(String(format: "%.1f%@", value, unit))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Slider(value: $value, in: range)
                .accentColor(color)
        }
    }
}
