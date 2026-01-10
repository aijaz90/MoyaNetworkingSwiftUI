//
//  NetworkAssembly.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Assemblies/NetworkAssembly.swift
import Foundation
import Swinject

public final class NetworkAssembly: Assembly {
    public func assemble(container: Container) {
        // Network Configuration
        container.register(NetworkConfiguration.self) { _ in
            NetworkConfiguration.shared
        }.inObjectScope(.container)
        
        // Network Monitor
        container.register(NetworkMonitorProtocol.self) { _ in
            NetworkMonitor.shared
        }.inObjectScope(.container)
        
        // Network Service
        container.register(NetworkServiceProtocol.self) { resolver in
            NetworkService(
                networkMonitor: resolver.resolve(NetworkMonitorProtocol.self)!
            )
        }.inObjectScope(.container)
        
        // SSL Pinning (optional)
//        container.register(SSLPinningManagerProtocol.self) { _ in
//            SSLPinningManager.shared
//        }.inObjectScope(.container)
    }
}
