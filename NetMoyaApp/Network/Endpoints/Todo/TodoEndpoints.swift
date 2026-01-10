//
//  TodoEndpoints.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//


// Endpoints/ProductEndpoint.swift
import Foundation
import Moya
public import Alamofire

public enum TodoEndpoints {
    case getToDoList
}

extension TodoEndpoints: TargetType {
    public var baseURL: URL {
        return NetworkConfiguration.shared.baseURL
    }
    
    public var path: String {
        switch self {
        case .getToDoList:
            return "/todos"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getToDoList:
            return .get
        }
    }
    
    public var task: Task {
        switch self {
        case .getToDoList:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .getToDoList:
            var headers = NetworkConfiguration.shared.defaultHeaders
            return headers
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    public var sampleData: Data {
          switch self {
          case .getToDoList:
              return """
              [
                {
                  "userId": 3,
                  "id": 1,
                  "title": "Buy groceries",
                  "completed": false
                },
                {
                  "userId": 5,
                  "id": 2,
                  "title": "Go for a walk",
                  "completed": true
                }
              ]
              """.data(using: .utf8)!
          }
      }
}
