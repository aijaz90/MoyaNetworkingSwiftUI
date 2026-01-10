//
//  SSLPinningManager.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// SSLPinningManager.swift
//import Foundation
//import Security
//
//public protocol SSLPinningManagerProtocol {
//    var isEnabled: Bool { get }
//    func validate(challenge: URLAuthenticationChallenge) -> Bool
//}
//
//public final class SSLPinningManager: SSLPinningManagerProtocol {
//    public static let shared = SSLPinningManager()
//    
//    private let pinningCertificates: [SecCertificate]
//    public let isEnabled: Bool
//    
//    private init() {
//        // Load certificates from bundle
//        self.pinningCertificates = SSLPinningManager.loadCertificates()
//        self.isEnabled = !pinningCertificates.isEmpty
//    }
//    
//    private static func loadCertificates() -> [SecCertificate] {
//        var certificates: [SecCertificate] = []
//        
//        // Load .cer files from bundle
//        let fileExtensions = ["cer", "CER", "der", "DER"]
//        
//        for ext in fileExtensions {
//            let paths = Bundle.main.paths(forResourcesOfType: ext, inDirectory: nil)
//            for path in paths {
//                if let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
//                    if let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
//                        certificates.append(certificate)
//                    }
//                }
//            }
//        }
//        
//        return certificates
//    }
//    
//    public func validate(challenge: URLAuthenticationChallenge) -> Bool {
//        guard isEnabled,
//              let serverTrust = challenge.protectionSpace.serverTrust else {
//            return true // Skip validation if no certificates or trust
//        }
//        
//        // Set SSL policy for domain name check
//        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
//        SecTrustSetPolicies(serverTrust, policy)
//        
//        // Evaluate server trust
//        var error: CFError?
//        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, &error)
//        
//        guard isServerTrusted else {
//            print("SSL Pinning: Server trust evaluation failed: \(error?.localizedDescription ?? "Unknown error")")
//            return false
//        }
//        
//        // Compare certificates
//        let serverCertificates = getCertificates(from: serverTrust)
//        
//        for serverCertificate in serverCertificates {
//            for pinnedCertificate in pinningCertificates {
//                if SecCertificateEqual(serverCertificate, pinnedCertificate) {
//                    print("SSL Pinning: Certificate matched successfully")
//                    return true
//                }
//            }
//        }
//        
//        print("SSL Pinning: No matching certificate found")
//        return false
//    }
//    
//    private func getCertificates(from trust: SecTrust) -> [SecCertificate] {
//        let certificateCount = SecTrustGetCertificateCount(trust)
//        var certificates: [SecCertificate] = []
//        
//        for index in 0..<certificateCount {
//            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
//                certificates.append(certificate)
//            }
//        }
//        
//        return certificates
//    }
//}
