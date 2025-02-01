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
                    Label("Map", systemImage: "map.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environmentObject(FirebaseService.shared)
}
#endif
