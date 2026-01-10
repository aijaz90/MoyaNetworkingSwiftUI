//
//  MockProductService.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Test/MockProductService.swift
import Foundation
import Combine

#if DEBUG
class MockProductService /*:ProductServiceProtocol*/ {
//    func deleteProduct(id: String) -> AnyPublisher<SuccessResponse, NetworkError> {
//        
//    }
    
    var mockProducts: [Product] = []
    var mockError: NetworkError?
    
    func getProducts(page: Int, limit: Int, category: String?, search: String?) -> AnyPublisher<ProductListResponse, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let response = ProductListResponse(
            products: mockProducts,
            total: mockProducts.count,
            page: page,
            limit: limit,
            totalPages: 1
        )
        
        return Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func getProduct(id: String) -> AnyPublisher<Product, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let product = mockProducts.first(where: { $0.id == id }) {
            return Just(product)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: .notFound)
                .eraseToAnyPublisher()
        }
    }
    
    func createProduct(_ request: CreateProductRequest) -> AnyPublisher<Product, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let product = Product(
            id: UUID().uuidString,
            name: request.name,
            description: request.description,
            price: request.price,
            currency: request.currency,
            imageURL: nil,
            category: request.category,
            stockQuantity: request.stockQuantity,
            sku: request.sku,
            createdAt: Date().ISO8601Format(),
            updatedAt: Date().ISO8601Format()
        )
        
        mockProducts.append(product)
        
        return Just(product)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func updateProduct(id: String, request: UpdateProductRequest) -> AnyPublisher<Product, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        guard let index = mockProducts.firstIndex(where: { $0.id == id }) else {
            return Fail(error: .notFound).eraseToAnyPublisher()
        }
        
        var product = mockProducts[index]
//        if let name = request.name { product.name = name }
//        if let description = request.description { product.description = description }
//        if let price = request.price { product.price = price }
//        if let category = request.category { product.category = category }
//        if let stock = request.stockQuantity { product.stockQuantity = stock }
//        if let sku = request.sku { product.sku = sku }
//        product.updatedAt = Date().ISO8601Format()
//        
        mockProducts[index] = product
        
        return Just(product)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteProduct(id: String) -> AnyPublisher<Void, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        mockProducts.removeAll { $0.id == id }
        
        return Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
#endif
