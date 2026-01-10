//
//  ProductListViewModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ProductListViewModel.swift
import Foundation
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var hasMoreProducts = true
    
    private let productService: ProductServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let pageLimit = 20
    
    var categories: [String] = ["All", "Electronics", "Clothing", "Books", "Home"]
    
    // Using dependency injection
    init(productService: ProductServiceProtocol) {
        self.productService = productService
        setupSearchDebounce()
        loadProducts()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.refreshProducts()
            }
            .store(in: &cancellables)
    }
    
    func loadProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        let category = selectedCategory == "All" ? nil : selectedCategory
        
        productService.getProducts(
            page: currentPage,
            limit: pageLimit,
            category: category,
            search: searchText.isEmpty ? nil : searchText
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            if self.currentPage == 1 {
                self.products = response.products
            } else {
                self.products.append(contentsOf: response.products)
            }
            
            self.hasMoreProducts = self.currentPage < response.totalPages
        }
        .store(in: &cancellables)
    }
    
    func refreshProducts() {
        currentPage = 1
        loadProducts()
    }
    
    func loadMoreProducts() {
        guard hasMoreProducts, !isLoading else { return }
        currentPage += 1
        loadProducts()
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        refreshProducts()
    }
    
    func deleteProduct(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let product = products[index]
        
        productService.deleteProduct(id: product.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.products.remove(at: index)
            }
            .store(in: &cancellables)
    }
}
