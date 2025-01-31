//
//  ContentView.swift
//  VoltFlow
//
//  Created by Kelly Randall on 31/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var carService = CarService()
    @State private var selectedTab = 0
    
    var mockCar = Car(
        id: "1",
        brand: .tesla,
        model: "Roadster",
        batteryLevel: 0.67,
        range: 212,
        location: Location(latitude: 34.0522, longitude: -118.2437, address: "Beverly Hills"),
        isCharging: false,
        temperature: 20.0,
        mileage: 24140,
        engineStarted: false
    )
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CarStatusView(car: mockCar)
                .tabItem {
                    Image(systemName: "car.fill")
                    Text("Car")
                }
                .tag(0)
            
            ChargingMapView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Charging")
                }
                .tag(1)
            
            Text("Settings")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
