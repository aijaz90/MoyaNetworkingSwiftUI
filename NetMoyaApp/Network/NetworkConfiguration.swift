//
//  NetworkConfiguration.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// NetworkConfiguration.swift
import Foundation
import UIKit

public enum Environment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dummy-json.mock.beeceptor.com/"
        case .staging:
            return "https://dummy-json.mock.beeceptor.com/"
        case .production:
            return "https://dummy-json.mock.beeceptor.com/"
        }
    }
}

public class NetworkConfiguration {
    public static let shared = NetworkConfiguration()
    
    private(set) var currentEnvironment: Environment = .development
    private(set) var accessToken: String?
    
    private init() {}
    
    public func setEnvironment(_ environment: Environment) {
        self.currentEnvironment = environment
    }
    
    public func setAccessToken(_ token: String?) {
        self.accessToken = token
    }
    
    public func clearAccessToken() {
        self.accessToken = nil
    }
    
    public var baseURL: URL {
        guard let url = URL(string: currentEnvironment.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }
    
    public var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Language": Locale.current.language.languageCode?.identifier ?? "en",
            "X-App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            "X-Device-Platform": "iOS",
            "X-Device-Model": UIDevice.current.model,
            "X-OS-Version": UIDevice.current.systemVersion
        ]
        
        if let accessToken = accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
}
