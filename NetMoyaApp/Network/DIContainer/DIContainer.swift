//
//  DIContainer.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// DIContainer.swift
import Foundation
import Swinject

public protocol DIContainerProtocol {
    func registerDependencies()
    func resolve<T>(_ type: T.Type) -> T?
    func resolve<T>(_ type: T.Type, name: String?) -> T?
}

public final class DIContainer: DIContainerProtocol {
    public static let shared = DIContainer()
    
    private let container: Container
    private let assembler: Assembler
    
    private init() {
        container = Container()
        assembler = Assembler(container: container)
        registerDependencies()
    }
    
    public func registerDependencies() {
        // Register all assemblies
        assembler.apply(assemblies: [
            NetworkAssembly(),
            ServiceAssembly(),
            ViewModelAssembly()
        ])
    }
    
    public func resolve<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
    
    public func resolve<T>(_ type: T.Type, name: String?) -> T? {
        return container.resolve(type, name: name)
    }
    
    // Helper method for ViewModels (since they need to be created fresh each time)
    public func resolveViewModel<T>(_ type: T.Type) -> T? {
        return container.resolve(type)
    }
}
