//
//  ProductDetailViewModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ProductDetailViewModel.swift
import Foundation
import Combine
import UIKit

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false
    @Published var showImagePicker = false
    @Published var selectedImage: UIImage?
    
    private let productService: ProductServiceProtocol
    private let productId: String
    private var cancellables = Set<AnyCancellable>()
    
    // Using dependency injection
    init(productId: String, productService: ProductServiceProtocol) {
        self.productId = productId
        self.productService = productService
        loadProduct()
    }
    
    func loadProduct() {
        isLoading = true
        errorMessage = nil
        
        productService.getProduct(id: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] product in
                self?.product = product
            }
            .store(in: &cancellables)
    }
    
    func updateProduct(name: String, description: String, price: String, category: String, stock: String) {
        guard let product = product else { return }
        
        let updateRequest = UpdateProductRequest(
            name: name,
            description: description,
            price: Double(price) ?? 0,
            category: category,
            stockQuantity: Int(stock) ?? 0,
            sku: product.sku
        )
        
        isLoading = true
        
        productService.updateProduct(id: productId, request: updateRequest)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedProduct in
                self?.product = updatedProduct
                self?.isEditing = false
                self?.errorMessage = "Product updated successfully"
            }
            .store(in: &cancellables)
    }
    
    func deleteProduct() {
        isLoading = true
        
        productService.deleteProduct(id: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.errorMessage = "Product deleted successfully"
            }
            .store(in: &cancellables)
    }
}
