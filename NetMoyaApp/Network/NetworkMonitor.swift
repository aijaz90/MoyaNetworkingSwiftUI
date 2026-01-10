//
//  NetworkMonitor.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Services/NetworkMonitor.swift
import Foundation
import Network
import Combine

public protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    var connectionType: ConnectionType { get }
    var connectionPublisher: AnyPublisher<Bool, Never> { get }
}

public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
    case disconnected
}

public final class NetworkMonitor: NetworkMonitorProtocol {
    public static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let connectionSubject = PassthroughSubject<Bool, Never>()
    
    @Published public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    public var connectionPublisher: AnyPublisher<Bool, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isConnected = path.status == .satisfied
            let connectionType = self.getConnectionType(path)
            
            DispatchQueue.main.async {
                self.isConnected = isConnected
                self.connectionType = connectionType
                self.connectionSubject.send(isConnected)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func getConnectionType(_ path: NWPath) -> ConnectionType {
        guard path.status == .satisfied else {
            return .disconnected
        }
        
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
