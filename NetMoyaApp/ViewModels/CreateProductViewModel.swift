//
//  CreateProductViewModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ViewModels/CreateProductViewModel.swift
//import Foundation
//import Combine
//import UIKit
//
//@MainActor
//final class CreateProductViewModel: ObservableObject {
//    @Published var name = ""
//    @Published var description = ""
//    @Published var price = ""
//    @Published var category = ""
//    @Published var stock = ""
//    @Published var sku = ""
//    @Published var selectedImage: UIImage?
//    @Published var showImagePicker = false
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published var isSuccess = false
//    
//    private let productService: ProductServiceProtocol
//    private var cancellables = Set<AnyCancellable>()
//    
//    var categories = ["Electronics", "Clothing", "Books", "Home", "Sports", "Toys"]
//    
//    // Designated initializer without default argument to avoid nonisolated default evaluation.
//    init(productService: ProductServiceProtocol) {
//        self.productService = productService
//    }
//    
//    // Convenience initializer that constructs the default dependency inside the MainActor-isolated body.
//    convenience init() {
//        self.init(productService: ProductService())
//    }
//    
//    var isValidForm: Bool {
//        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
//        !price.isEmpty &&
//        Double(price) != nil &&
//        !category.isEmpty &&
//        !stock.isEmpty &&
//        Int(stock) != nil
//    }
//    
//    func createProduct() {
//        guard isValidForm else {
//            errorMessage = "Please fill all required fields correctly"
//            return
//        }
//        
//        let createRequest = CreateProductRequest(
//            name: name.trimmingCharacters(in: .whitespaces),
//            description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
//            price: Double(price)!,
//            currency: "USD",
//            category: category,
//            stockQuantity: Int(stock)!,
//            sku: sku.trimmingCharacters(in: .whitespaces).isEmpty ? nil : sku
//        )
//        
//        isLoading = true
//        errorMessage = nil
//        
//        productService.createProduct(createRequest)
//            .receive(on: DispatchQueue.main)
//            .flatMap { [weak self] product -> AnyPublisher<Product, NetworkError> in
//                guard let self = self,
//                      let image = self.selectedImage,
//                      let imageData = image.jpegData(compressionQuality: 0.8) else {
//                    return Just(product)
//                        .setFailureType(to: NetworkError.self)
//                        .eraseToAnyPublisher()
//                }
//                
//                return self.productService.uploadProductImage(id: product.id, imageData: imageData)
//            }
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                if case .failure(let error) = completion {
//                    self?.errorMessage = error.localizedDescription
//                }
//            } receiveValue: { [weak self] _ in
//                self?.isSuccess = true
//                self?.resetForm()
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func resetForm() {
//        name = ""
//        description = ""
//        price = ""
//        category = ""
//        stock = ""
//        sku = ""
//        selectedImage = nil
//    }
//}
