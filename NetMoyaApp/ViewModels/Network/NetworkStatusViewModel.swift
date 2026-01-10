//
//  NetworkStatusViewModel.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// ViewModels/NetworkStatusViewModel.swift
//import Foundation
//import Combine
//import Network
//import Moya
//
//@MainActor
//final class NetworkStatusViewModel: ObservableObject {
//    @Published var isConnected: Bool = true
//    @Published var showAlert: Bool = false
//    @Published var isCheckingConnection: Bool = false
//    @Published var connectionType: NetworkConnectionType = .unknown
//    @Published var lastChecked: Date?
//    
//    private let networkMonitor: NetworkMonitorProtocol
//    private let networkService: NetworkServiceProtocol
//    private var cancellables = Set<AnyCancellable>()
//    
//    private let checkInterval: TimeInterval = 30 // Check every 30 seconds
//    private var lastCheckTimer: Timer?
//    
//    // Renamed to avoid conflict with NetworkMonitor.ConnectionType
//    enum NetworkConnectionType: String {
//        case wifi = "Wi-Fi"
//        case cellular = "Cellular"
//        case ethernet = "Ethernet"
//        case unknown = "Unknown"
//        case disconnected = "Disconnected"
//    }
//    
//    // MARK: - Initialization with Dependency Injection
//    
//    init(
//        networkMonitor: NetworkMonitorProtocol,
//        networkService: NetworkServiceProtocol
//    ) {
//        self.networkMonitor = networkMonitor
//        self.networkService = networkService
//        setupObservers()
//        startPeriodicChecks()
//    }
//    
//    deinit {
//        lastCheckTimer?.invalidate()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupObservers() {
//        // Monitor network status changes
//        networkMonitor.connectionPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isConnected in
//                guard let self = self else { return }
//                
//                // Update connection type
//                self.connectionType = self.mapToConnectionType(self.networkMonitor.connectionType)
//                
//                // Only trigger check if status changed from connected to disconnected
//                if !isConnected && self.isConnected {
//                    self.isConnected = false
//                    self.showAlert = true
//                    self.stopPeriodicChecks()
//                } else if isConnected && !self.isConnected {
//                    // When reconnecting, perform a quick check
//                    self.isConnected = true
//                    self.performConnectionCheck()
//                    self.startPeriodicChecks()
//                } else {
//                    self.isConnected = isConnected
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func mapToConnectionType(_ type: NetworkMonitor.ConnectionType) -> NetworkConnectionType {
//        switch type {
//        case .wifi:
//            return .wifi
//        case .cellular:
//            return .cellular
//        case .ethernet:
//            return .ethernet
//        case .disconnected:
//            return .disconnected
//        case .unknown:
//            return .unknown
//        }
//    }
//    
//    // MARK: - Public Methods
//    
//    func performConnectionCheck() {
//        guard !isCheckingConnection else { return }
//        
//        isCheckingConnection = true
//        
//        // Use async task
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            
//            Task {
//                await self.performConnectionCheckAsync()
//            }
//        }
//    }
//    
//    private func performConnectionCheckAsync() async {
//        do {
//            // First check if we have network interface connectivity
//            if !networkMonitor.isConnected {
//                await MainActor.run {
//                    self.isConnected = false
//                    self.showAlert = true
//                    self.isCheckingConnection = false
//                }
//                return
//            }
//            
//            // Then perform API ping to check if internet is actually working
//            let isInternetWorking = try await self.checkInternetConnection()
//            
//            await MainActor.run {
//                if !isInternetWorking {
//                    // Network interface says connected but API fails
//                    self.isConnected = false
//                    self.showAlert = true
//                    self.connectionType = .disconnected
//                } else {
//                    self.isConnected = true
//                    self.showAlert = false
//                    self.lastChecked = Date()
//                }
//                
//                self.isCheckingConnection = false
//            }
//            
//        } catch {
//            await MainActor.run {
//                self.isConnected = false
//                self.showAlert = true
//                self.connectionType = .disconnected
//                self.isCheckingConnection = false
//            }
//        }
//    }
//    
//    func retryConnection() {
//        performConnectionCheck()
//    }
//    
//    func dismissAlert() {
//        showAlert = false
//    }
//    
//    // MARK: - Private Methods
//    
//    private func checkInternetConnection() async throws -> Bool {
//        // Create a simple health check endpoint
//        struct HealthCheckEndpoint: Moya.TargetType {
//            var baseURL: URL {
//                return NetworkConfiguration.shared.baseURL
//            }
//            
//            var path: String {
//                return "/api/v1/health"
//            }
//            
//            var method: Moya.Method {
//                return .get
//            }
//            
//            var task: Moya.Task {
//                return .requestPlain
//            }
//            
//            var headers: [String: String]? {
//                return NetworkConfiguration.shared.defaultHeaders
//            }
//            
//            var validationType: ValidationType {
//                return .successCodes
//            }
//            
//            var sampleData: Data {
//                return Data()
//            }
//        }
//        
//        // Try to reach the health endpoint with timeout
//        return try await withTimeout(seconds: 5) {
//            do {
//                // Simple response model for health check
//                struct HealthResponse: Decodable {
//                    let status: String
//                    let timestamp: String?
//                }
//                
//                // Try to make the request
//                return try await withCheckedThrowingContinuation { continuation in
//                    self.networkService.request(HealthCheckEndpoint())
//                        .sink(receiveCompletion: { completion in
//                            switch completion {
//                            case .finished:
//                                continuation.resume(returning: true)
//                            case .failure(let error):
//                                continuation.resume(throwing: error)
//                            }
//                        }, receiveValue: { (_: HealthResponse) in
//                            // We don't need the actual response, just success
//                            continuation.resume(returning: true)
//                        })
//                        .store(in: &self.cancellables)
//                }
//            } catch {
//                // If health endpoint fails, try a more basic check
//                return try await performBasicInternetCheck()
//            }
//        }
//    }
//    
//    private func performBasicInternetCheck() async throws -> Bool {
//        // Alternative: Try to connect to a known reliable server
//        // Using URLSession directly for this basic check
//        
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 3
//        configuration.timeoutIntervalForResource = 3
//        
//        let session = URLSession(configuration: configuration)
//        
//        // Try common endpoints
//        let testURLs = [
//            URL(string: "https://www.google.com/generate_204")!, // Google's 204 endpoint
//            URL(string: "https://connectivitycheck.gstatic.com/generate_204")!,
//            URL(string: "https://captive.apple.com/hotspot-detect.html")! // Apple's captive portal check
//        ]
//        
//        for url in testURLs {
//            do {
//                let (_, response) = try await session.data(from: url)
//                if let httpResponse = response as? HTTPURLResponse {
//                    // Accept 200, 204, or any successful status
//                    if (200...299).contains(httpResponse.statusCode) || httpResponse.statusCode == 204 {
//                        return true
//                    }
//                }
//            } catch {
//                continue // Try next URL
//            }
//        }
//        
//        return false
//    }
//    
//    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
//        // Use Task for timeout
//        try await withThrowingTaskGroup(of: T.self) { group in
//            group.addTask {
//                return try await operation()
//            }
//            
//            group.addTask {
//                // Use Task.sleep with do-catch
//                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
//                throw TimeoutError()
//            }
//            
//            guard let result = try await group.next() else {
//                throw TimeoutError()
//            }
//            
//            group.cancelAll()
//            return result
//        }
//    }
//    
//    private func startPeriodicChecks() {
//        // Invalidate any existing timer
//        lastCheckTimer?.invalidate()
//        
//        // Create new timer
//        lastCheckTimer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            
//            // Only check if we think we're connected
//            if self.isConnected {
//                self.performConnectionCheck()
//            }
//        }
//    }
//    
//    private func stopPeriodicChecks() {
//        lastCheckTimer?.invalidate()
//        lastCheckTimer = nil
//    }
//    
//    // MARK: - Connection Status Info
//    
//    var connectionStatusText: String {
//        if isCheckingConnection {
//            return "Checking connection..."
//        }
//        
//        if !isConnected {
//            return "No Internet Connection"
//        }
//        
//        return "Connected via \(connectionType.rawValue)"
//    }
//    
//    var connectionStatusColor: String {
//        if isCheckingConnection {
//            return "orange"
//        }
//        
//        return isConnected ? "green" : "red"
//    }
//    
//    var lastCheckedText: String {
//        guard let lastChecked = lastChecked else {
//            return "Never checked"
//        }
//        
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .short
//        return "Last checked \(formatter.localizedString(for: lastChecked, relativeTo: Date()))"
//    }
//}
//
//// MARK: - Error Types
//
//struct TimeoutError: Error, LocalizedError {
//    var errorDescription: String? {
//        return "Connection check timed out"
//    }
//}

// MARK: - Mock for Preview

    //#if DEBUG
//extension NetworkStatusViewModel {
//    static var mock: NetworkStatusViewModel {
//        let mockNetworkMonitor = MockNetworkMonitor()
//        let mockNetworkService = MockNetworkService()
//        
//        return NetworkStatusViewModel(
//            networkMonitor: mockNetworkMonitor,
//            networkService: mockNetworkService
//        )
//    }
//}
//#endif

//class MockNetworkMonitor: NetworkMonitorProtocol {
//    var isConnected: Bool = true
//    var connectionType: NetworkMonitor.ConnectionType = .wifi
//    var connectionPublisher: AnyPublisher<Bool, Never> {
//        Just(isConnected).eraseToAnyPublisher()
//    }
//}
//
//class MockNetworkService: NetworkServiceProtocol {
//    func request<T>(_ target: Moya.TargetType) -> AnyPublisher<T, NetworkError> where T : Decodable {
//        // Simulate successful response for health check
//        if target.path.contains("health") {
//            let response = ["status": "ok", "timestamp": "2024-01-01T00:00:00Z"] as [String: Any]
//            let data = try! JSONSerialization.data(withJSONObject: response)
//            let decoder = JSONDecoder()
//            let decoded = try! decoder.decode(T.self, from: data)
//            return Just(decoded)
//                .setFailureType(to: NetworkError.self)
//                .eraseToAnyPublisher()
//        }
//        
//        return Fail(error: NetworkError.unknown)
//            .eraseToAnyPublisher()
//    }
//    
//    func requestAPIResponse<T>(_ target: Moya.TargetType) -> AnyPublisher<APIResponse<T>, NetworkError> where T : Decodable {
//        return Fail(error: NetworkError.unknown)
//            .eraseToAnyPublisher()
//    }
//    
//    func requestEmpty(_ target: Moya.TargetType) -> AnyPublisher<Void, NetworkError> {
//        return Just(())
//            .setFailureType(to: NetworkError.self)
//            .eraseToAnyPublisher()
//    }
//}
//#endif
