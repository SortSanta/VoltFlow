//
//  ContentView.swift
//  VoltFlow
//
//  Created by Kelly Randall on 31/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var carService = CarService()
    @EnvironmentObject private var firebaseService: FirebaseService
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.95))
        
        // Customize unselected item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        
        // Customize selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.blue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.blue)
        ]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Mock data for development
    let mockCar = Car(
        id: "mock1",
        brand: .tesla,
        model: "Model 3",
        batteryLevel: 0.65,
        range: 350,
        location: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco"),
        isCharging: false,
        temperature: 20.0,
        mileage: 15000,
        engineStarted: false
    )
    
    var body: some View {
        TabView {
            CarStatusView(car: mockCar)
                .tabItem {
                    Label("Status", systemImage: "car.fill")
                }
            
            ChargingMapView()
                .tabItem {
                    Label("Map", systemImage: "bolt.car.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .preferredColorScheme(.dark)
        .tint(.blue) // Set the accent color for selected items
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(FirebaseService.shared)
}
#endif
