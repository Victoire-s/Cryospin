import SwiftUI

struct TabButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var namespace: Namespace.ID
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.8))
                            .matchedGeometryEffect(id: "TabPill", in: namespace)
                            .shadow(color: Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
