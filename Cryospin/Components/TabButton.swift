import SwiftUI

struct TabButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .cyan : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.cyan : Color.clear)
                    .frame(height: 3)
                    .shadow(color: isSelected ? .cyan : .clear, radius: 4)
                    .animation(.spring(), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
