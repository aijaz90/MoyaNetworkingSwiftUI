//
//  NetworkService.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// NetworkService.swift (Updated)
import Foundation
import Combine
import Moya
import Alamofire

public enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int, String?)
    case decodingError(Error)
    case moyaError(MoyaError)
    case unknown
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code, let message):
            return message ?? "Server error occurred (Status code: \(code))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .moyaError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return message
        case .unknown:
            return "An unknown error occurred."
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .serverError(let code, _):
            return code
        default:
            return nil
        }
    }
}

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, NetworkError>
    func requestAPIResponse<T: Decodable>(_ target: TargetType) -> AnyPublisher<APIResponse<T>, NetworkError>
    func requestEmpty(_ target: TargetType) -> AnyPublisher<Void, NetworkError>
}


// NetworkService.swift (Updated with Enhanced Logging)
import Foundation
import Combine
import Moya
import Alamofire

public final class NetworkService: NetworkServiceProtocol {
    
    private let provider: MoyaProvider<MultiTarget>
    private let networkMonitor: NetworkMonitorProtocol
    private let logger: NetworkLoggerProtocol
    
    public init(
        provider: MoyaProvider<MultiTarget>? = nil,
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared,
        logger: NetworkLoggerProtocol = NetworkLogger()
    ) {
        self.networkMonitor = networkMonitor
        self.logger = logger
        
        // Create plugins
        let plugins: [PluginType] = [
            NetworkLoggerPlugin1(logger: logger),
            NetworkStatusPlugin(networkMonitor: networkMonitor, logger: logger)
        ]
        
        let session: Session = {
            let configuration = URLSessionConfiguration.default
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            
            // SSL Pinning configuration (optional)
            let serverTrustManager: ServerTrustManager? = {
                let certificates = NetworkService.loadCertificates()
                
                guard !certificates.isEmpty else {
                    return nil
                }
                
                let evaluators = certificates.reduce(into: [String: ServerTrustEvaluating]()) { result, _ in
                    if let host = URL(string: NetworkConfiguration.shared.baseURL.absoluteString)?.host {
                        result[host] = PinnedCertificatesTrustEvaluator(certificates: certificates)
                    }
                }
                
                return ServerTrustManager(evaluators: evaluators)
            }()
            
            return Session(
                configuration: configuration,
                startRequestsImmediately: false,
                serverTrustManager: serverTrustManager
            )
        }()
        
        self.provider = provider ?? MoyaProvider<MultiTarget>(
            session: session,
            plugins: plugins
        )
    }
    
    // MARK: - Network Status Plugin
    
    private class NetworkStatusPlugin: PluginType {
        private let networkMonitor: NetworkMonitorProtocol
        private let logger: NetworkLoggerProtocol
        
        init(networkMonitor: NetworkMonitorProtocol, logger: NetworkLoggerProtocol) {
            self.networkMonitor = networkMonitor
            self.logger = logger
        }
        
        func willSend(_ request: RequestType, target: TargetType) {
            // Log network status before each request
            logger.logNetworkStatus(isConnected: networkMonitor.isConnected)
        }
    }
    
    // MARK: - Request Methods
    
    public func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, NetworkError> {
        guard networkMonitor.isConnected else {
            logger.logNetworkStatus(isConnected: false)
            return Fail(error: NetworkError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        return provider.requestPublisher(MultiTarget(target))
            .tryMap { response -> T in
                // Check for 401 status code
                if response.statusCode == 401 {
                    NotificationCenter.default.post(name: .userShouldLogout, object: nil)
                    throw NetworkError.unauthorized
                }
                
                // Check for other error status codes
                guard (200...299).contains(response.statusCode) else {
                    if let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: response.data) {
                        throw NetworkError.apiError(apiError.message ?? "Unknown error")
                    } else {
                        throw NetworkError.serverError(response.statusCode, nil)
                    }
                }
                
                // Decode response
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: response.data)
                } catch {
                    // Log decoding error
                    self.logger.logError(error, target: target)
                    throw NetworkError.decodingError(error)
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let moyaError = error as? MoyaError {
                    return NetworkError.moyaError(moyaError)
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    // ... rest of your NetworkService implementation
//}
    
    public func requestAPIResponse<T: Decodable>(_ target: TargetType) -> AnyPublisher<APIResponse<T>, NetworkError> {
        guard networkMonitor.isConnected else {
            return Fail(error: NetworkError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        return provider.requestPublisher(MultiTarget(target))
            .tryMap { response -> APIResponse<T> in
                // Check for 401 status code
                if response.statusCode == 401 {
                    NotificationCenter.default.post(name: .userShouldLogout, object: nil)
                    throw NetworkError.unauthorized
                }
                
                // Check for other error status codes
                guard (200...299).contains(response.statusCode) else {
                    if let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: response.data) {
                        throw NetworkError.apiError(apiError.message ?? "Unknown error")
                    } else {
                        throw NetworkError.serverError(response.statusCode, nil)
                    }
                }
                
                // Decode APIResponse wrapper
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let apiResponse = try decoder.decode(APIResponse<T>.self, from: response.data)
                    
                    // Check if API response itself indicates an error
                    if !apiResponse.status {
                        throw NetworkError.apiError(apiResponse.message ?? "API error")
                    }
                    
                    return apiResponse
                } catch {
                    throw NetworkError.decodingError(error)
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let moyaError = error as? MoyaError {
                    return NetworkError.moyaError(moyaError)
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func requestEmpty(_ target: TargetType) -> AnyPublisher<Void, NetworkError> {
        guard networkMonitor.isConnected else {
            return Fail(error: NetworkError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        return provider.requestPublisher(MultiTarget(target))
            .tryMap { response -> Void in
                // Check for 401 status code
                if response.statusCode == 401 {
                    NotificationCenter.default.post(name: .userShouldLogout, object: nil)
                    throw NetworkError.unauthorized
                }
                
                // For delete operations, 204 is common
                guard (200...299).contains(response.statusCode) || response.statusCode == 204 else {
                    if let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: response.data) {
                        throw NetworkError.apiError(apiError.message ?? "Unknown error")
                    } else {
                        throw NetworkError.serverError(response.statusCode, nil)
                    }
                }
                
                // Return void for successful empty response
                return ()
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let moyaError = error as? MoyaError {
                    return NetworkError.moyaError(moyaError)
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Helper function for SSL Pinning
    private static func loadCertificates() -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        // Load .cer files from bundle
        let fileExtensions = ["cer", "CER", "der", "DER"]
        
        for ext in fileExtensions {
            let paths = Bundle.main.paths(forResourcesOfType: ext, inDirectory: nil)
            for path in paths {
                if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    if let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
                        certificates.append(certificate)
                    }
                }
            }
        }
        
        return certificates
    }
}

// NetworkService.swift (Add this method)
extension NetworkServiceProtocol {
    func checkInternetConnectivity() -> AnyPublisher<Bool, NetworkError> {
        let endpoint = HealthEndpoint.check
        
        return request(endpoint)
            .map { (response: HealthResponse) -> Bool in
                return response.status.lowercased() == "ok"
            }
            .catch { error -> AnyPublisher<Bool, NetworkError> in
                // If health endpoint fails, we assume no internet
                return Just(false)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// Notification for logout
extension Notification.Name {
    public static let userShouldLogout = Notification.Name("UserShouldLogout")
}




// MARK: - Seprate without Progress

// NetworkService.swift (Simplified)
import Foundation
import Combine
import Moya
import Alamofire

public enum NetworkError1: Error, LocalizedError {
    case noInternetConnection
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int, String?)
    case decodingError(Error)
    case moyaError(MoyaError)
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError(let code, let message):
            return message ?? "Server error occurred (Status code: \(code))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .moyaError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .unauthorized:
            return 401
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .serverError(let code, _):
            return code
        default:
            return nil
        }
    }
}

public protocol NetworkServiceProtocol1 {
    func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, NetworkError>
}

public final class NetworkService1: NetworkServiceProtocol1 {
    
    private let provider: MoyaProvider<MultiTarget>
    private let networkMonitor: NetworkMonitorProtocol
    
    public init(
        provider: MoyaProvider<MultiTarget>? = nil,
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared
    ) {
        self.networkMonitor = networkMonitor
        
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(
                formatter: .init(),
                logOptions: .verbose
            ))
        ]
        
        let session: Session = {
            let configuration = URLSessionConfiguration.default
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 60
            
            // SSL Pinning configuration (optional)
            let serverTrustManager: ServerTrustManager? = {
                let certificates = NetworkService1.loadCertificates()
                
                guard !certificates.isEmpty else {
                    return nil
                }
                
                let evaluators = certificates.reduce(into: [String: ServerTrustEvaluating]()) { result, _ in
                    if let host = URL(string: NetworkConfiguration.shared.baseURL.absoluteString)?.host {
                        result[host] = PinnedCertificatesTrustEvaluator(certificates: certificates)
                    }
                }
                
                return ServerTrustManager(evaluators: evaluators)
            }()
            
            return Session(
                configuration: configuration,
                startRequestsImmediately: false,
                serverTrustManager: serverTrustManager
            )
        }()
        
        self.provider = provider ?? MoyaProvider<MultiTarget>(
            session: session,
            plugins: plugins
        )
    }
    
    public func request<T: Decodable>(_ target: TargetType) -> AnyPublisher<T, NetworkError> {
        guard networkMonitor.isConnected else {
            return Fail(error: NetworkError.noInternetConnection)
                .eraseToAnyPublisher()
        }
        
        return provider.requestPublisher(MultiTarget(target))
            .tryMap { response -> T in
                // Check for 401 status code
                if response.statusCode == 401 {
                    NotificationCenter.default.post(name: .userShouldLogout, object: nil)
                    throw NetworkError.unauthorized
                }
                
                // Check for other error status codes
                guard (200...299).contains(response.statusCode) else {
                    let errorMessage = try? JSONDecoder().decode(APIErrorResponse.self, from: response.data).message
                    throw NetworkError.serverError(response.statusCode, errorMessage)
                }
                
                // Decode response
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: response.data)
                } catch {
                    throw NetworkError.decodingError(error)
                }
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else if let moyaError = error as? MoyaError {
                    return NetworkError.moyaError(moyaError)
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    // Helper function for SSL Pinning
    private static func loadCertificates() -> [SecCertificate] {
        var certificates: [SecCertificate] = []
        
        // Load .cer files from bundle
        let fileExtensions = ["cer", "CER", "der", "DER"]
        
        for ext in fileExtensions {
            let paths = Bundle.main.paths(forResourcesOfType: ext, inDirectory: nil)
            for path in paths {
                if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    if let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
                        certificates.append(certificate)
                    }
                }
            }
        }
        
        return certificates
    }
}

// Notification for logout
extension Notification.Name {
    public static let userShouldLogout1 = Notification.Name("UserShouldLogout")
}

// MARK: - Update NetworkService to handle different response types:


