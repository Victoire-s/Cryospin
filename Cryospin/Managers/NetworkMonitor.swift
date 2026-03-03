import Foundation
import Network
import SwiftUI
import Combine

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnectedToWiFi = false
    @Published var hasCheckedInitialStatus = false
    
    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnectedToWiFi = path.status == .satisfied && path.usesInterfaceType(.wifi)
                self?.hasCheckedInitialStatus = true
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
