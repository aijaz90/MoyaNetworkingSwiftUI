//
//  NetworkMonitor.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Services/NetworkMonitor.swift
import Foundation
import Network
import Combine

import Combine

public protocol NetworkMonitorProtocol: AnyObject {
    var isConnected: Bool { get }
    var connectionType: ConnectionType { get }

    /// Emits connection changes (true / false)
    var connectionPublisher: AnyPublisher<Bool, Never> { get }
}


public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
    case disconnected
}


//
//  NetworkMonitor.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

import Foundation
import Network
import Combine

public final class NetworkMonitor: NetworkMonitorProtocol {

    // MARK: - Singleton (Protocol-based)
    public static let shared: NetworkMonitorProtocol = NetworkMonitor()

    // MARK: - Private
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.netmoya.network.monitor")

    private var internetCheckTask: URLSessionDataTask?

    // MARK: - State (Single source of truth)
    @Published private(set) public var isConnected: Bool = true
    @Published private(set) public var connectionType: ConnectionType = .unknown

    // MARK: - Publisher
    public var connectionPublisher: AnyPublisher<Bool, Never> {
        $isConnected
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Init
    private init() {
        startMonitoring()
    }

    // MARK: - Monitoring
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let type = self.resolveConnectionType(from: path)

            // 1️⃣ If no network path → definitely disconnected
            guard path.status == .satisfied else {
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.connectionType = .disconnected
                }
                return
            }

            // 2️⃣ Network available → now verify real internet
            self.checkInternetAvailability { hasInternet in
                DispatchQueue.main.async {
                    self.isConnected = hasInternet
                    self.connectionType = hasInternet ? type : .disconnected

                    #if DEBUG
                    print("📡 NetworkMonitor → path OK, internet:", hasInternet, "type:", type)
                    #endif
                }
            }
        }

        monitor.start(queue: queue)
    }

    // MARK: - Internet Verification
    /// Checks REAL internet access (Wi-Fi may be connected but internet down)
    private func checkInternetAvailability(completion: @escaping (Bool) -> Void) {

        // Cancel previous check to avoid race conditions
        internetCheckTask?.cancel()

        let url = URL(string: "https://clients3.google.com/generate_204")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 6
        request.httpMethod = "GET"

        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        let session = URLSession(configuration: config)

        internetCheckTask = session.dataTask(with: request) { _, response, error in
            print("🛜🛜🛜🛜🛜Internet error \(error)  : response \(response)🛜🛜")
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse
            else {
                completion(false)
                return
            }

            // 204 = internet reachable
            completion(httpResponse.statusCode == 204)
        }

        internetCheckTask?.resume()
    }

    // MARK: - Helpers
    private func resolveConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        }
        if path.usesInterfaceType(.cellular) {
            return .cellular
        }
        if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }
        return .unknown
    }

    deinit {
        monitor.cancel()
        internetCheckTask?.cancel()
    }
}
