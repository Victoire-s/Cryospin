import SwiftUI

@main
struct CryospinApp: App {
    var body: some Scene {
        WindowGroup {
            RootView() // Le routeur prend la place du ContentView direct
        }
    }
}
