//
//  Product.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Models/Product.swift
import Foundation

public struct Product: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String?
    public let price: Double
    public let currency: String
    public let imageURL: String?
    public let category: String
    public let stockQuantity: Int
    public let sku: String?
    public let createdAt: String?
    public let updatedAt: String?
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case currency
        case imageURL = "image_url"
        case category
        case stockQuantity = "stock_quantity"
        case sku
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(
        id: String,
        name: String,
        description: String? = nil,
        price: Double,
        currency: String = "USD",
        imageURL: String? = nil,
        category: String,
        stockQuantity: Int,
        sku: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.currency = currency
        self.imageURL = imageURL
        self.category = category
        self.stockQuantity = stockQuantity
        self.sku = sku
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct ProductListResponse: Codable {
    public let products: [Product]
    public let total: Int
    public let page: Int
    public let limit: Int
    public let totalPages: Int
    
    public enum CodingKeys: String, CodingKey {
        case products
        case total
        case page
        case limit
        case totalPages = "total_pages"
    }
}

public struct CreateProductRequest: Codable {
    public let name: String
    public let description: String?
    public let price: Double
    public let currency: String
    public let category: String
    public let stockQuantity: Int
    public let sku: String?
    
    public enum CodingKeys: String, CodingKey {
        case name
        case description
        case price
        case currency
        case category
        case stockQuantity = "stock_quantity"
        case sku
    }
}

public struct UpdateProductRequest: Codable {
    public let name: String?
    public let description: String?
    public let price: Double?
    public let category: String?
    public let stockQuantity: Int?
    public let sku: String?
    
    public enum CodingKeys: String, CodingKey {
        case name
        case description
        case price
        case category
        case stockQuantity = "stock_quantity"
        case sku
    }
}

public struct APIErrorResponse: Codable {
    public let message: String?
    public let code: String?
    public let errors: [String: [String]]?
    public let statusCode: Int?
    
    public enum CodingKeys: String, CodingKey {
        case message
        case code
        case errors
        case statusCode = "status_code"
    }
}
