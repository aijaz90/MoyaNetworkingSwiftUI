//
//  HealthEndpoint.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Endpoints/HealthEndpoint.swift
import Foundation
import Moya
import Alamofire

public enum HealthEndpoint {
    case check
}

extension HealthEndpoint: TargetType {
    public var baseURL: URL {
        return NetworkConfiguration.shared.baseURL
    }
    
    public var path: String {
        return "/api/v1/health"
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    public var sampleData: Data {
        return """
        {
            "status": "ok",
            "timestamp": "2024-01-01T00:00:00Z",
            "version": "1.0.0"
        }
        """.data(using: .utf8)!
    }
}

// Response model
public struct HealthResponse: Decodable {
    public let status: String
    public let timestamp: String?
    public let version: String?
}
