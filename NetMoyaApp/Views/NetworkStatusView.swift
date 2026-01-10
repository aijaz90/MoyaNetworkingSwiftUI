//
//  NetworkStatusView.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Views/NetworkStatusView.swift
import SwiftUI
import Swinject

//struct NetworkStatusView: View {
//    @StateObject private var viewModel: NetworkStatusViewModel
//    @State private var showDetailedInfo = false
//    
//    // Using DI Container
//    init() {
//        let viewModel = DIContainer.shared.resolve(NetworkStatusViewModel.self)!
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    // Alternative: Direct injection for testing
//    init(viewModel: NetworkStatusViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    var body: some View {
//        VStack {
//            if !viewModel.isConnected {
//                connectionStatusBanner
//            }
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isConnected)
//        .zIndex(999)
//        .onAppear {
//            // Perform initial check when view appears
//            viewModel.performConnectionCheck()
//        }
//    }
//    
//    private var connectionStatusBanner: some View {
//        VStack(spacing: 0) {
//            // Main banner
//            HStack(spacing: 12) {
//                statusIcon
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(viewModel.connectionStatusText)
//                        .font(.subheadline)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                    
//                    if viewModel.isCheckingConnection {
//                        Text("Verifying internet connection...")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.8))
//                    } else {
//                        Text("Some features may be unavailable")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.8))
//                    }
//                }
//                
//                Spacer()
//                
//                // Action buttons
//                HStack(spacing: 8) {
//                    if !viewModel.isCheckingConnection {
//                        Button(action: {
//                            viewModel.retryConnection()
//                        }) {
//                            Image(systemName: "arrow.clockwise")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .frame(width: 30, height: 30)
//                                .background(Color.white.opacity(0.2))
//                                .clipShape(Circle())
//                        }
//                        
//                        Button(action: {
//                            showDetailedInfo.toggle()
//                        }) {
//                            Image(systemName: "info.circle")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .frame(width: 30, height: 30)
//                                .background(Color.white.opacity(0.2))
//                                .clipShape(Circle())
//                        }
//                    } else {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(0.8)
//                    }
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//            .background(connectionStatusBackground)
//            
//            // Detailed info panel (expandable)
//            if showDetailedInfo {
//                detailedInfoPanel
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }
//        }
//        .background(connectionStatusBackground)
//        .cornerRadius(showDetailedInfo ? 0 : 8)
//        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
//        .padding(.horizontal, 8)
//        .padding(.top, 8)
//    }
//    
//    private var statusIcon: some View {
//        ZStack {
//            Circle()
//                .fill(Color.white.opacity(0.2))
//                .frame(width: 36, height: 36)
//            
//            if viewModel.isCheckingConnection {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .scaleEffect(0.8)
//            } else {
//                Image(systemName: viewModel.isConnected ? "wifi" : "wifi.slash")
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(.white)
//            }
//        }
//    }
//    
//    private var connectionStatusBackground: some View {
//        LinearGradient(
//            gradient: Gradient(colors: [
//                Color.red,
//                Color.red.opacity(0.9)
//            ]),
//            startPoint: .leading,
//            endPoint: .trailing
//        )
//    }
//    
//    private var detailedInfoPanel: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Divider()
//                .background(Color.white.opacity(0.3))
//                .padding(.horizontal, 16)
//            
//            VStack(alignment: .leading, spacing: 6) {
//                infoRow(icon: "network", title: "Connection Type", value: viewModel.connectionType.rawValue)
//                infoRow(icon: "clock", title: "Last Check", value: viewModel.lastCheckedText)
//                infoRow(icon: "exclamationmark.triangle", title: "Status", value: viewModel.isConnected ? "Online" : "Offline")
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//        }
//        .background(Color.red.opacity(0.8))
//    }
//    
//    private func infoRow(icon: String, title: String, value: String) -> some View {
//        HStack(spacing: 10) {
//            Image(systemName: icon)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.8))
//                .frame(width: 20)
//            
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.8))
//            
//            Spacer()
//            
//            Text(value)
//                .font(.caption)
//                .fontWeight(.medium)
//                .foregroundColor(.white)
//        }
//    }
//}
//
//// MARK: - Preview
//
//#if DEBUG
//struct NetworkStatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            // Connected state
//            NetworkStatusView(viewModel: {
//                let vm = NetworkStatusViewModel.mock
//                vm.isConnected = true
//                vm.connectionType = .wifi
//                return vm
//            }())
//            .previewDisplayName("Connected")
//            
//            // Disconnected state
//            NetworkStatusView(viewModel: {
//                let vm = NetworkStatusViewModel.mock
//                vm.isConnected = false
//                vm.connectionType = .disconnected
//                return vm
//            }())
//            .previewDisplayName("Disconnected")
//            
//            // Checking state
//            NetworkStatusView(viewModel: {
//                let vm = NetworkStatusViewModel.mock
//                vm.isConnected = false
//                vm.isCheckingConnection = true
//                return vm
//            }())
//            .previewDisplayName("Checking")
//        }
//        .previewLayout(.sizeThatFits)
//        .padding()
//        .background(Color.gray.opacity(0.1))
//    }
//}
//#endif
