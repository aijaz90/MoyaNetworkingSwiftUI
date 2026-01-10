//
//  ServiceAssembly.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Assemblies/ServiceAssembly.swift
import Foundation
import Swinject

public final class ServiceAssembly: Assembly {
    public func assemble(container: Container) {
        // Product Service
        container.register(ProductServiceProtocol.self) { resolver in
            ProductService(
                networkService: resolver.resolve(NetworkServiceProtocol.self)!
            )
        }.inObjectScope(.container)
        
        container.register(TodoServiceProtocol.self) { resolver in
            TodoService(
                networkService: resolver.resolve(NetworkServiceProtocol.self)!
            )
        }.inObjectScope(.container)
        
        // If you have more services, add them here:
        // Auth Service
        /*
        container.register(AuthServiceProtocol.self) { resolver in
            AuthService(
                networkService: resolver.resolve(NetworkServiceProtocol.self)!
            )
        }.inObjectScope(.container)
        */
        
        // User Service
        /*
        container.register(UserServiceProtocol.self) { resolver in
            UserService(
                networkService: resolver.resolve(NetworkServiceProtocol.self)!
            )
        }.inObjectScope(.container)
        */
    }
}
