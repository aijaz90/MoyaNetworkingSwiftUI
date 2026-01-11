//
//  NetMoyaAppApp.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// YourApp.swift
import SwiftUI

@main
struct NetMoyaAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  //  @StateObject private var networkStatusViewModel: NetworkStatusViewModel
    
    init() {
           // Resolve from DI container
          // let viewModel = DIContainer.shared.resolve(NetworkStatusViewModel.self)!
        //   _networkStatusViewModel = StateObject(wrappedValue: viewModel)
       }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                ContentView()
                NetworkStatusView()
              //  NetworkStatusView(viewModel: networkStatusViewModel)
            } .onAppear {
                // Initial connectivity check
              // networkStatusViewModel.performConnectionCheck()
            }.onReceive(NetworkMonitor.shared.connectionPublisher) { connected in
                print("Connected:", connected)
              
            }
        }
    }
}
