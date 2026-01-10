//
//  AppDelegate.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// AppDelegate.swift
import UIKit
import SwiftUI
import Swinject


class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    private let diContainer = DIContainer.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup DI
                diContainer.registerDependencies()
        
        // Create window
//                window = UIWindow(frame: UIScreen.main.bounds)
//                window?.backgroundColor = .white
//        // Setup root view controller
//              setupRootViewController()
//        window?.makeKeyAndVisible()
//        
        setupNetworkConfiguration()
        setupLogoutObserver()
        return true
    }
    
//    private func setupRootViewController() {
//         // You can set up your initial view controller here
//         // For example, if you have a tab bar controller:
//         let tabBarController = UITabBarController()
//         
//         // Create Product List View with DI
//         let productListView = ProductListView()
//             .environmentObject(diContainer.resolve(ProductListViewModel.self)!)
//         
//         let productListHost = UIHostingController(rootView: productListView)
//         productListHost.tabBarItem = UITabBarItem(
//             title: "Products",
//             image: UIImage(systemName: "cube.box"),
//             selectedImage: UIImage(systemName: "cube.box.fill")
//         )
//         
//         tabBarController.viewControllers = [productListHost]
//         
//         window?.rootViewController = tabBarController
//     }
    
    private func setupNetworkConfiguration() {
        // Set environment
        #if DEBUG
        NetworkConfiguration.shared.setEnvironment(.development)
        #else
        NetworkConfiguration.shared.setEnvironment(.production)
        #endif
        
        // Load saved access token
        if let savedToken = UserDefaults.standard.string(forKey: "accessToken") {
            NetworkConfiguration.shared.setAccessToken(savedToken)
        }
    }
    
    private func setupLogoutObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .userShouldLogout,
            object: nil
        )
    }
    
    @objc private func handleLogout() {
        // Clear saved token
        UserDefaults.standard.removeObject(forKey: "accessToken")
        NetworkConfiguration.shared.clearAccessToken()
        
        // Navigate to login screen
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: ContentView())
                window.makeKeyAndVisible()
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
           // Clean up if needed
       }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
