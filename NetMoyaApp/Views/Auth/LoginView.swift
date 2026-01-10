//
//  LoginView.swift
//  NetMoyaApp
//
//  Created by Aijaz on 10/01/2026.
//

// Views/LoginView.swift
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "cube.box.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Product Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func login() {
        // Simulate login
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Save token
            let fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            UserDefaults.standard.set(fakeToken, forKey: "accessToken")
            NetworkConfiguration.shared.setAccessToken(fakeToken)
            
            isLoading = false
            
            // Navigate to product list
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(
                    rootView: ZStack(alignment: .top) {
                        //ProductListView()
                        ContentView()
                    //    NetworkStatusView()
                    }
                )
                window.makeKeyAndVisible()
            }
        }
    }
}
