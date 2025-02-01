//
//  VoltFlowApp.swift
//  VoltFlow
//
//  Created by Kelly Randall on 31/01/2025.
//

import SwiftUI
import Firebase

@main
struct VoltFlowApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var firebaseService = FirebaseService.shared
    @State private var showLaunchScreen = true
    
    init() {
        // Only configure Firebase if it hasn't been configured yet
        if FirebaseApp.app() == nil {
            print("VoltFlowApp: Configuring Firebase...")
            FirebaseApp.configure()
            print("VoltFlowApp: Firebase configured successfully")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        // Show launch screen for 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                Group {
                    if firebaseService.isAuthenticated {
                        ContentView()
                    } else {
                        AuthenticationView()
                    }
                }
                .environmentObject(firebaseService)
            }
        }
    }
}
