//
//  ProductListView.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ProductListView.swift
import SwiftUI
import Swinject

struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel
    @State private var showingCreateProduct = false
    
    // Using DI Container
    init() {
        let viewModel = DIContainer.shared.resolve(ProductListViewModel.self)!
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // Alternative: Direct injection for testing
    init(viewModel: ProductListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.products.isEmpty {
                    ProgressView("Loading products...")
                } else if viewModel.products.isEmpty {
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "cube.box",
                        description: Text("No products found. Try a different search or category.")
                    )
                } else {
//                    List {
//                        ForEach(viewModel.products) { product in
//                            NavigationLink(
//                                destination: ProductDetailView(productId: product.id)
//                            ) {
//                                ProductRowView(product: product)
//                            }
//                        }
//                        
//                        if viewModel.hasMoreProducts && !viewModel.products.isEmpty {
//                            ProgressView()
//                                .frame(maxWidth: .infinity)
//                                .onAppear {
//                                    viewModel.loadMoreProducts()
//                                }
//                        }
//                    }
//                    .refreshable {
//                        viewModel.refreshProducts()
//                    }
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateProduct = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Button(category) {
                                viewModel.selectCategory(category)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search products")
            .sheet(isPresented: $showingCreateProduct) {
             //   CreateProductView()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

#Preview {
    ProductListView()
}
