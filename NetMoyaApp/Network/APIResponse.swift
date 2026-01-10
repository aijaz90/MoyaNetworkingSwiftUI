//
//  APIResponse.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//


// Models/APIResponse.swift
import Foundation

// Generic API response wrapper
public struct APIResponse<T: Decodable>: Decodable {
    public let status: Bool
    public let message: String?
    public let data: T?
    public let errors: [String]?
    public let code: Int?
    
    public enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
        case errors
        case code
    }
}

// For empty response (delete, update without data return)
public struct EmptyResponse: Decodable {
    // Empty response for endpoints that don't return data
}

// For simple success messages
public struct SuccessResponse: Decodable {
    public let success: Bool
    public let message: String?
    
    public enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}

// For error responses
public struct ErrorResponse: Decodable {
    public let message: String?
    public let errors: [String: [String]]?
    public let code: Int?
    
    public enum CodingKeys: String, CodingKey {
        case message
        case errors
        case code
    }
}
