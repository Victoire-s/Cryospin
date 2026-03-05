import SwiftUI

struct ControlCard<Content: View>: View {
    var title: String
    var content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            content
        }
        .padding(20)
        .background(Rectangle().fill(.ultraThinMaterial))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color(red: 0.106, green: 0.118, blue: 0.894).opacity(0.15), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
