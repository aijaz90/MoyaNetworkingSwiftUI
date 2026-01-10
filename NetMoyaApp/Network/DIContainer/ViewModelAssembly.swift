//
//  ViewModelAssembly.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Assemblies/ViewModelAssembly.swift
import Foundation
import Swinject

public final class ViewModelAssembly: Assembly {
    public func assemble(container: Container) {
        // ProductListViewModel
        container.register(ProductListViewModel.self) { resolver in
            ProductListViewModel(
                productService: resolver.resolve(ProductServiceProtocol.self)!
            )
        }.inObjectScope(.transient) // Transient scope - new instance each time
        
        // ProductDetailViewModel
        container.register(ProductDetailViewModel.self) { (resolver, productId: String) in
            ProductDetailViewModel(
                productId: productId,
                productService: resolver.resolve(ProductServiceProtocol.self)!
            )
        }.inObjectScope(.transient)
        
        container.register(TodoListViewModel.self) { (resolver) in
            TodoListViewModel(
                todoService: resolver.resolve(TodoServiceProtocol.self)!
            )
        }.inObjectScope(.transient)
        
        
        
        // CreateProductViewModel
//        container.register(CreateProductViewModel.self) { resolver in
//            CreateProductViewModel(
//                productService: resolver.resolve(ProductServiceProtocol.self)!
//            )
//        }.inObjectScope(.transient)
        
        // NetworkStatusViewModel
//                container.register(NetworkStatusViewModel.self) { resolver in
//                    NetworkStatusViewModel(
//                        networkMonitor: resolver.resolve(NetworkMonitorProtocol.self)!,
//                        networkService: resolver.resolve(NetworkServiceProtocol.self)!
//                    )
//                }.inObjectScope(.container) // Singleton as it monitors global network status
    }
}
