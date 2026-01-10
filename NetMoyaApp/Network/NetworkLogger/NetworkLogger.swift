////
////  NetworkLogger.swift
////  NetMoyaApp
////
////  Created by Aijaz on 10/01/2026.
////
//
//// NetworkLogger.swift
//import Foundation
//import Moya
//import Alamofire
//
//public protocol NetworkLoggerProtocol {
//    func logRequest(_ target: TargetType)
//    func logResponse(_ response: Response, target: TargetType)
//    func logNetworkStatus(isConnected: Bool)
//    func logError(_ error: Error, target: TargetType)
//}
//
//public final class NetworkLogger: NetworkLoggerProtocol {
//    
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        return formatter
//    }()
//    
//    private let jsonEncoder: JSONEncoder = {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//        encoder.dateEncodingStrategy = .iso8601
//        return encoder
//    }()
//    
//    public init() {}
//    
//    // MARK: - Request Logging
//    
//    public func logRequest(_ target: TargetType) {
//        #if DEBUG
//        print("\n" + "=".repeating(60))
//        print("🌐 NETWORK REQUEST")
//        print("=".repeating(60))
//        print("📅 Time: \(dateFormatter.string(from: Date()))")
//        print("🎯 Endpoint: \(String(describing: type(of: target)))")
//        
//        // URL & Method
//        let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//        print("🔗 URL: \(url)")
//        print("📝 Method: \(target.method.rawValue)")
//        
//        // Headers in JSON format
//        if let headers = target.headers {
//            print("📋 Headers:")
//            if let headersJSON = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(headers), options: []),
//               let prettyData = try? jsonEncoder.encode(headersJSON),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            } else {
//                print(headers)
//            }
//        }
//        
//        // Parameters/Query Parameters
//        logRequestParameters(target)
//        
//        // Validation Type
//        print("✅ Validation Type: \(target.validationType)")
//        print("=".repeating(60) + "\n")
//        #endif
//    }
//    
//    private func logRequestParameters(_ target: TargetType) {
//        switch target.task {
//        case .requestPlain:
//            print("📦 Body: No parameters")
//            
//        case .requestData(let data):
//            print("📦 Body (Raw Data): \(data.count) bytes")
//            logDataAsJSON(data)
//            
//        case .requestJSONEncodable(let encodable):
//            print("📦 Body (Encodable):")
//            if let data = try? JSONEncoder().encode(encodable) {
//                logDataAsJSON(data)
//            }
//            
//        case .requestParameters(let parameters, let encoding):
//            print("📦 Parameters (Encoding: \(encoding)):")
//            if let prettyData = try? jsonEncoder.encode(parameters),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            } else {
//                print(parameters)
//            }
//            
//        case .requestCompositeData(let bodyData, let urlParameters):
//            print("📦 Composite Request:")
//            print("📦 Body Data: \(bodyData.count) bytes")
//            logDataAsJSON(bodyData)
//            print("📦 URL Parameters:")
//            if let prettyData = try? jsonEncoder.encode(urlParameters),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            }
//            
//        case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
//            print("📦 Composite Parameters:")
//            print("📦 Body Parameters (Encoding: \(bodyEncoding)):")
//            if let prettyData = try? jsonEncoder.encode(bodyParameters),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            }
//            print("📦 URL Parameters:")
//            if let prettyData = try? jsonEncoder.encode(urlParameters),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            }
//            
//        case .uploadFile(let file):
//            print("📦 Upload File: \(file)")
//            
//        case .uploadMultipart(let multipartData):
//            print("📦 Multipart Data: \(multipartData.count) parts")
//            for (index, data) in multipartData.enumerated() {
//                print("  Part \(index + 1): \(data.name) - \(data.fileName ?? "No filename")")
//            }
//            
//        case .uploadCompositeMultipart(let multipartData, let urlParameters):
//            print("📦 Composite Multipart:")
//            print("📦 Multipart Data: \(multipartData.count) parts")
//            print("📦 URL Parameters:")
//            if let prettyData = try? jsonEncoder.encode(urlParameters),
//               let prettyString = String(data: prettyData, encoding: .utf8) {
//                print(prettyString)
//            }
//            
//        @unknown default:
//            print("📦 Body: Unknown task type")
//        }
//    }
//    
//    // MARK: - Response Logging
//    
//    public func logResponse(_ response: Response, target: TargetType) {
//        #if DEBUG
//        let statusEmoji = (200...299).contains(response.statusCode) ? "✅" : "❌"
//        let isSuccess = (200...299).contains(response.statusCode)
//        
//        print("\n" + "=".repeating(60))
//        print("📡 NETWORK RESPONSE")
//        print("=".repeating(60))
//        print("📅 Time: \(dateFormatter.string(from: Date()))")
//        print("🎯 Endpoint: \(String(describing: type(of: target)))")
//        print("🔗 URL: \(response.request?.url?.absoluteString ?? "N/A")")
//        print("\(statusEmoji) Status Code: \(response.statusCode)")
//        print("📊 Status: \(isSuccess ? "SUCCESS" : "FAILED")")
//        
//        // Headers in JSON format
//        print("📋 Headers:")
//        let headersDict = response.response?.allHeaderFields as? [String: Any] ?? [:]
//        if let headersJSON = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(headersDict), options: []),
//           let prettyData = try? jsonEncoder.encode(headersJSON),
//           let prettyString = String(data: prettyData, encoding: .utf8) {
//            print(prettyString)
//        }
//        
//        // Response Data
//        print("📥 Response Data:")
//        logResponseData(response.data, statusCode: response.statusCode)
//        
//        // Timing information (if available)
//        if let request = response.request,
//           let startTime = request.value(forHTTPHeaderField: "X-Request-Start-Time"),
//           let start = Double(startTime) {
//            let duration = Date().timeIntervalSince1970 - start
//            print("⏱️ Duration: \(String(format: "%.3f", duration))s")
//        }
//        
//        print("=".repeating(60) + "\n")
//        #endif
//    }
//    
//    private func logResponseData(_ data: Data, statusCode: Int) {
//        guard !data.isEmpty else {
//            print("📭 Empty response body")
//            return
//        }
//        
//        // Try to decode as JSON first
//        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//           let prettyData = try? jsonEncoder.encode(jsonObject),
//           let jsonString = String(data: prettyData, encoding: .utf8) {
//            print(jsonString)
//            
//            // Additional analysis for arrays
//            if let array = jsonObject as? [Any] {
//                print("📊 Array Count: \(array.count) items")
//            }
//        }
//        // Try as string
//        else if let string = String(data: data, encoding: .utf8) {
//            print(string)
//        }
//        // Binary data
//        else {
//            print("🔢 Binary data: \(data.count) bytes")
//        }
//        
//        // Print size info
//        print("📏 Size: \(formatBytes(data.count))")
//    }
//    
//    // MARK: - Error Logging
//    
//    public func logError(_ error: Error, target: TargetType) {
//        #if DEBUG
//        print("\n" + "=".repeating(60))
//        print("❌ NETWORK ERROR")
//        print("=".repeating(60))
//        print("📅 Time: \(dateFormatter.string(from: Date()))")
//        print("🎯 Endpoint: \(String(describing: type(of: target)))")
//        print("🔗 Path: \(target.path)")
//        
//        if let moyaError = error as? MoyaError {
//            logMoyaError(moyaError)
//        } else if let networkError = error as? NetworkError {
//            logNetworkError(networkError)
//        } else {
//            print("💥 Error Type: \(type(of: error))")
//            print("💥 Description: \(error.localizedDescription)")
//            print("💥 Full Error: \(error)")
//        }
//        
//        // Print request details for debugging
//        print("\n📝 Failed Request Details:")
//        logRequest(target)
//        
//        print("=".repeating(60) + "\n")
//        #endif
//    }
//    
//    private func logMoyaError(_ error: MoyaError) {
//        print("💥 Error Type: MoyaError")
//        
//        switch error {
//        case .imageMapping(let response):
//            print("💥 Cause: Image Mapping Failed")
//            print("📊 Response Code: \(response.statusCode)")
//            
//        case .jsonMapping(let response):
//            print("💥 Cause: JSON Mapping Failed")
//            print("📊 Response Code: \(response.statusCode)")
//            logResponseData(response.data, statusCode: response.statusCode)
//            
//        case .statusCode(let response):
//            print("💥 Cause: Status Code \(response.statusCode)")
//            print("📊 Response: \(response)")
//            logResponseData(response.data, statusCode: response.statusCode)
//            
//        case .stringMapping(let response):
//            print("💥 Cause: String Mapping Failed")
//            print("📊 Response Code: \(response.statusCode)")
//            logResponseData(response.data, statusCode: response.statusCode)
//            
//        case .objectMapping(let error, let response):
//            print("💥 Cause: Object Mapping Failed")
//            print("💥 Mapping Error: \(error)")
//            print("📊 Response Code: \(response.statusCode)")
//            logResponseData(response.data, statusCode: response.statusCode)
//            
//        case .encodableMapping(let error):
//            print("💥 Cause: Encodable Mapping Failed")
//            print("💥 Error: \(error)")
//            
//        case .underlying(let error, let response):
//            print("💥 Cause: Underlying Error")
//            print("💥 Error: \(error)")
//            if let response = response {
//                print("📊 Response Code: \(response.statusCode)")
//                logResponseData(response.data, statusCode: response.statusCode)
//            }
//            
//        case .requestMapping(let message):
//            print("💥 Cause: Request Mapping Failed")
//            print("💥 Message: \(message)")
//            
//        case .parameterEncoding(let error):
//            print("💥 Cause: Parameter Encoding Failed")
//            print("💥 Error: \(error)")
//            
//        case .sslPinningFailed:
//            print("💥 Cause: SSL Pinning Failed")
//            
//        @unknown default:
//            print("💥 Cause: Unknown Moya Error")
//        }
//    }
//    
//    private func logNetworkError(_ error: NetworkError) {
//        print("💥 Error Type: NetworkError")
//        
//        switch error {
//        case .noInternetConnection:
//            print("💥 Cause: No Internet Connection")
//        case .unauthorized:
//            print("💥 Cause: Unauthorized (401)")
//        case .forbidden:
//            print("💥 Cause: Forbidden (403)")
//        case .notFound:
//            print("💥 Cause: Not Found (404)")
//        case .serverError(let code, let message):
//            print("💥 Cause: Server Error (\(code))")
//            print("💥 Message: \(message ?? "No message")")
//        case .decodingError(let underlyingError):
//            print("💥 Cause: Decoding Error")
//            print("💥 Error: \(underlyingError)")
//        case .moyaError(let moyaError):
//            logMoyaError(moyaError)
//        case .unknown:
//            print("💥 Cause: Unknown Error")
//        case .apiError(let message):
//            print("💥 Cause: API Error")
//            print("💥 Message: \(message)")
//        }
//    }
//    
//    // MARK: - Network Status
//    
//    public func logNetworkStatus(isConnected: Bool) {
//        #if DEBUG
//        let status = isConnected ? "✅ CONNECTED" : "❌ DISCONNECTED"
//        print("\n📶 NETWORK STATUS: \(status)\n")
//        #endif
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func logDataAsJSON(_ data: Data) {
//        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
//           let prettyData = try? jsonEncoder.encode(jsonObject),
//           let jsonString = String(data: prettyData, encoding: .utf8) {
//            print(jsonString)
//        } else {
//            print("Cannot display as JSON, raw data: \(data.count) bytes")
//        }
//    }
//    
//    private func formatBytes(_ bytes: Int) -> String {
//        let units = ["B", "KB", "MB", "GB"]
//        var size = Double(bytes)
//        var unitIndex = 0
//        
//        while size >= 1024 && unitIndex < units.count - 1 {
//            size /= 1024
//            unitIndex += 1
//        }
//        
//        return String(format: "%.2f %@", size, units[unitIndex])
//    }
//}
//
//// String extension for repeating
//extension String {
//    func repeating(_ count: Int) -> String {
//        return String(repeating: self, count: count)
//    }
//}
//
//
//// Plugins/NetworkLoggerPlugin.swift
//import Foundation
//import Moya
//
//public final class NetworkLoggerPlugin: PluginType {
//
//    private let logger: NetworkLoggerProtocol
//    
//    public init(logger: NetworkLoggerProtocol = NetworkLogger()) {
//        self.logger = logger
//    }
//    
//    public func willSend(_ request: RequestType, target: TargetType) {
//        // Log the request before sending
//        logger.logRequest(target)
//        
//        // Add timestamp for duration calculation
//        if var urlRequest = request.request {
//            let timestamp = String(Date().timeIntervalSince1970)
//            urlRequest.addValue(timestamp, forHTTPHeaderField: "X-Request-Start-Time")
//        }
//    }
//    
//    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
//        switch result {
//        case .success(let response):
//            logger.logResponse(response, target: target)
//            
//            // Check for 401 and trigger logout
//            if response.statusCode == 401 {
//                NotificationCenter.default.post(name: .userShouldLogout, object: nil)
//            }
//            
//        case .failure(let error):
//            logger.logError(error, target: target)
//            
//            // Check for 401 in error response
//            if let response = error.response, response.statusCode == 401 {
//                NotificationCenter.default.post(name: .userShouldLogout, object: nil)
//            }
//        }
//    }
//    
//    public func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
//        return result
//    }
//}
