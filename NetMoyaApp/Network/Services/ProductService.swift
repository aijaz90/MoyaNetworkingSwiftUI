//
//  ProductService.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ProductService.swift (Updated)
import Foundation
import Combine
import Moya

public protocol ProductServiceProtocol1 {
    func getProducts(
        page: Int,
        limit: Int,
        category: String?,
        search: String?
    ) -> AnyPublisher<ProductListResponse, NetworkError>
    
    func getProduct(id: String) -> AnyPublisher<Product, NetworkError>
    
    func createProduct(_ request: CreateProductRequest) -> AnyPublisher<Product, NetworkError>
    
    func updateProduct(id: String, request: UpdateProductRequest) -> AnyPublisher<Product, NetworkError>
    
    func deleteProduct(id: String) -> AnyPublisher<Void, NetworkError>
}

public final class ProductService1: ProductServiceProtocol1 {
    
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    public func getProducts(
        page: Int = 1,
        limit: Int = 20,
        category: String? = nil,
        search: String? = nil
    ) -> AnyPublisher<ProductListResponse, NetworkError> {
        let endpoint = ProductEndpoint.getProducts(
            page: page,
            limit: limit,
            category: category,
            search: search
        )
        
        // Method 1: Direct request (if API returns ProductListResponse directly)
       // return networkService.request(endpoint)
        
        // OR Method 2: Using APIResponse wrapper (if API wraps in {status, message, data})
         return networkService.requestAPIResponse(endpoint)
             .compactMap { $0.data }
             .eraseToAnyPublisher()
    }
    
    public func getProduct(id: String) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.getProduct(id: id)
        //return networkService.request(endpoint)
        
        // If using APIResponse wrapper:
         return networkService.requestAPIResponse(endpoint)
             .compactMap { $0.data }
             .eraseToAnyPublisher()
    }
    
    public func createProduct(_ request: CreateProductRequest) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.createProduct(request)
       // return networkService.request(endpoint)
        
        // If using APIResponse wrapper:
         return networkService.requestAPIResponse(endpoint)
             .compactMap { $0.data }
             .eraseToAnyPublisher()
    }
    
    public func updateProduct(id: String, request: UpdateProductRequest) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.updateProduct(id: id, request: request)
        return networkService.request(endpoint)
        
        // If using APIResponse wrapper:
        // return networkService.requestAPIResponse(endpoint)
        //     .compactMap { $0.data }
        //     .eraseToAnyPublisher()
    }
    
    public func deleteProduct(id: String) -> AnyPublisher<Void, NetworkError> {
        let endpoint = ProductEndpoint.deleteProduct(id: id)
        // Use requestEmpty for endpoints that don't return data
        return networkService.requestEmpty(endpoint)
    }
}










































// MARK: - ProductService.swift (Using APIResponse consistently)

// ProductService.swift (Fixed)
import Foundation
import Combine
import Moya

public protocol ProductServiceProtocol {
    func getProducts(
        page: Int,
        limit: Int,
        category: String?,
        search: String?
    ) -> AnyPublisher<ProductListResponse, NetworkError>
    
    func getProduct(id: String) -> AnyPublisher<Product, NetworkError>
    
    func createProduct(_ request: CreateProductRequest) -> AnyPublisher<Product, NetworkError>
    
    func updateProduct(id: String, request: UpdateProductRequest) -> AnyPublisher<Product, NetworkError>
    
    func deleteProduct(id: String) -> AnyPublisher<SuccessResponse, NetworkError>
}

public final class ProductService: ProductServiceProtocol {
    
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    public func getProducts(
        page: Int = 1,
        limit: Int = 20,
        category: String? = nil,
        search: String? = nil
    ) -> AnyPublisher<ProductListResponse, NetworkError> {
        let endpoint = ProductEndpoint.getProducts(
            page: page,
            limit: limit,
            category: category,
            search: search
        )
        
        // Explicitly specify the type for requestAPIResponse
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<ProductListResponse>) -> ProductListResponse in
                guard let data = apiResponse.data else {
                    throw NetworkError.apiError(apiResponse.message ?? "No data received")
                }
                return data
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func getProduct(id: String) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.getProduct(id: id)
        
        // Explicitly specify the type for requestAPIResponse
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<Product>) -> Product in
                guard let data = apiResponse.data else {
                    throw NetworkError.apiError(apiResponse.message ?? "No data received")
                }
                return data
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func createProduct(_ request: CreateProductRequest) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.createProduct(request)
        
        // Explicitly specify the type for requestAPIResponse
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<Product>) -> Product in
                guard let data = apiResponse.data else {
                    throw NetworkError.apiError(apiResponse.message ?? "No data received")
                }
                return data
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func updateProduct(id: String, request: UpdateProductRequest) -> AnyPublisher<Product, NetworkError> {
        let endpoint = ProductEndpoint.updateProduct(id: id, request: request)
        
        // Explicitly specify the type for requestAPIResponse
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<Product>) -> Product in
                guard let data = apiResponse.data else {
                    throw NetworkError.apiError(apiResponse.message ?? "No data received")
                }
                return data
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func deleteProduct(id: String) -> AnyPublisher<SuccessResponse, NetworkError> {
        let endpoint = ProductEndpoint.deleteProduct(id: id)
        
        // For delete, we need to specify what type of APIResponse we expect
        // If your API returns a wrapped response for delete, use APIResponse<EmptyResponse>
        // If it returns just a success message, use APIResponse<SuccessResponse>
        
        // Option 1: If API returns {status: true, message: "Deleted", data: null}
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<EmptyResponse>) -> SuccessResponse in
                if apiResponse.status {
                    return SuccessResponse(success: true, message: apiResponse.message ?? "Deleted successfully")
                } else {
                    throw NetworkError.apiError(apiResponse.message ?? "Delete failed")
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
        
        // Option 2: If API returns {status: true, message: "Deleted", data: {success: true}}
        /*
        return networkService.requestAPIResponse(endpoint)
            .tryMap { (apiResponse: APIResponse<SuccessResponse>) -> SuccessResponse in
                guard let data = apiResponse.data else {
                    throw NetworkError.apiError(apiResponse.message ?? "No data received")
                }
                return data
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
        */
    }
}
