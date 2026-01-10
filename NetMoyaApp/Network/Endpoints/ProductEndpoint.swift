//
//  ProductEndpoint.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Endpoints/ProductEndpoint.swift
import Foundation
import Moya
public import Alamofire

public enum ProductEndpoint {
    case getProducts(page: Int, limit: Int, category: String?, search: String?)
    case getProduct(id: String)
    case createProduct(CreateProductRequest)
    case updateProduct(id: String, request: UpdateProductRequest)
    case deleteProduct(id: String)
    case uploadProductImage(id: String, imageData: Data)
}

extension ProductEndpoint: TargetType {
    public var baseURL: URL {
        return NetworkConfiguration.shared.baseURL
    }
    
    public var path: String {
        switch self {
        case .getProducts, .createProduct:
            return "/api/v1/products"
        case .getProduct(let id), .updateProduct(let id, _), .deleteProduct(let id):
            return "/api/v1/products/\(id)"
        case .uploadProductImage(let id, _):
            return "/api/v1/products/\(id)/image"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProducts, .getProduct:
            return .get
        case .createProduct, .uploadProductImage:
            return .post
        case .updateProduct:
            return .put
        case .deleteProduct:
            return .delete
        }
    }
    
    public var task: Task {
        switch self {
        case .getProducts(let page, let limit, let category, let search):
            var parameters: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            
            if let category = category, !category.isEmpty {
                parameters["category"] = category
            }
            
            if let search = search, !search.isEmpty {
                parameters["search"] = search
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .getProduct:
            return .requestPlain
            
        case .createProduct(let request):
            return .requestJSONEncodable(request)
            
        case .updateProduct(_, let request):
            return .requestJSONEncodable(request)
            
        case .deleteProduct:
            return .requestPlain
            
        case .uploadProductImage(_, let imageData):
            let formData = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: "product_image.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([formData])
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .uploadProductImage:
            var headers = NetworkConfiguration.shared.defaultHeaders
            headers.removeValue(forKey: "Content-Type")
            return headers
        default:
            return NetworkConfiguration.shared.defaultHeaders
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    public var sampleData: Data {
        switch self {
        case .getProducts:
            return """
            {
                "products": [
                    {
                        "id": "1",
                        "name": "Sample Product",
                        "description": "Sample Description",
                        "price": 99.99,
                        "currency": "USD",
                        "image_url": "https://example.com/image.jpg",
                        "category": "Electronics",
                        "stock_quantity": 10,
                        "sku": "SKU123",
                        "created_at": "2024-01-01T00:00:00Z",
                        "updated_at": "2024-01-01T00:00:00Z"
                    }
                ],
                "total": 1,
                "page": 1,
                "limit": 10,
                "total_pages": 1
            }
            """.data(using: .utf8)!
        default:
            return Data()
        }
    }
}

// MARK: - 4. Updated ProductEndpoint for image upload (without progress):

// ProductEndpoint.swift (updated)
import Foundation
import Moya

public enum ProductEndpoint1 {
    case getProducts(page: Int, limit: Int, category: String?, search: String?)
    case getProduct(id: String)
    case createProduct(CreateProductRequest)
    case updateProduct(id: String, request: UpdateProductRequest)
    case deleteProduct(id: String)
    case uploadProductImage(id: String, imageData: Data, fileName: String, mimeType: String)
}

extension ProductEndpoint1: TargetType {
    public var baseURL: URL {
        return NetworkConfiguration.shared.baseURL
    }
    
    public var path: String {
        switch self {
        case .getProducts, .createProduct:
            return "/api/v1/products"
        case .getProduct(let id), .updateProduct(let id, _), .deleteProduct(let id):
            return "/api/v1/products/\(id)"
        case .uploadProductImage(let id, _, _, _):
            return "/api/v1/products/\(id)/image"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProducts, .getProduct:
            return .get
        case .createProduct, .uploadProductImage:
            return .post
        case .updateProduct:
            return .put
        case .deleteProduct:
            return .delete
        }
    }
    
    public var task: Task {
        switch self {
        case .getProducts(let page, let limit, let category, let search):
            var parameters: [String: Any] = [
                "page": page,
                "limit": limit
            ]
            
            if let category = category, !category.isEmpty {
                parameters["category"] = category
            }
            
            if let search = search, !search.isEmpty {
                parameters["search"] = search
            }
            
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .getProduct:
            return .requestPlain
            
        case .createProduct(let request):
            return .requestJSONEncodable(request)
            
        case .updateProduct(_, let request):
            return .requestJSONEncodable(request)
            
        case .deleteProduct:
            return .requestPlain
            
        case .uploadProductImage(_, let imageData, let fileName, let mimeType):
            let formData = MultipartFormData(
                provider: .data(imageData),
                name: "image",
                fileName: fileName,
                mimeType: mimeType
            )
            return .uploadMultipart([formData])
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .uploadProductImage:
            var headers = NetworkConfiguration.shared.defaultHeaders
            // Remove Content-Type for multipart form data
            headers.removeValue(forKey: "Content-Type")
            return headers
        default:
            return NetworkConfiguration.shared.defaultHeaders
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    public var sampleData: Data {
        switch self {
        case .getProducts:
            return """
            {
                "products": [
                    {
                        "id": "1",
                        "name": "Sample Product",
                        "description": "Sample Description",
                        "price": 99.99,
                        "currency": "USD",
                        "image_url": "https://example.com/image.jpg",
                        "category": "Electronics",
                        "stock_quantity": 10,
                        "sku": "SKU123",
                        "created_at": "2024-01-01T00:00:00Z",
                        "updated_at": "2024-01-01T00:00:00Z"
                    }
                ],
                "total": 1,
                "page": 1,
                "limit": 10,
                "total_pages": 1
            }
            """.data(using: .utf8)!
        default:
            return Data()
        }
    }
}
