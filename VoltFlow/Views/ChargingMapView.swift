import SwiftUI
import MapKit
import CoreLocation

struct ChargingMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var stations: [ChargingStation] = []
    @State private var selectedStation: ChargingStation?
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Map
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: stations) { station in
                    MapAnnotation(coordinate: station.coordinate) {
                        StationAnnotation(station: station, isSelected: selectedStation?.id == station.id)
                            .onTapGesture {
                                selectedStation = station
                                withAnimation {
                                    region = MKCoordinateRegion(
                                        center: station.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                
                // Floating cards
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(stations) { station in
                            StationCard(station: station)
                                .onTapGesture {
                                    selectedStation = station
                                    withAnimation {
                                        region = MKCoordinateRegion(
                                            center: station.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .frame(height: 140)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.bottom, 49) // Height of tab bar
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                withAnimation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                fetchNearbyStations()
            }
        }
    }
    
    private func fetchNearbyStations() {
        guard let location = locationManager.location else {
            errorMessage = "Location not available"
            showError = true
            return
        }
        
        // Mock data for testing
        stations = [
            ChargingStation(
                id: "1",
                name: "Tesla Supercharger",
                coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude + 0.01,
                    longitude: location.coordinate.longitude + 0.01
                ),
                type: .supercharger,
                powerOutput: 250,
                price: 0.35,
                distance: 1500,
                address: "123 Main St",
                operatorInfo: "Tesla",
                usageType: "Public",
                connectionTypes: ["Type 2", "CCS"],
                available: 4,
                total: 8
            ),
            ChargingStation(
                id: "2",
                name: "City Charging Station",
                coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude - 0.01,
                    longitude: location.coordinate.longitude - 0.01
                ),
                type: .type2,
                powerOutput: 50,
                price: 0.40,
                distance: 2000,
                address: "456 Oak St",
                operatorInfo: "City Power",
                usageType: "Public",
                connectionTypes: ["Type 2"],
                available: 2,
                total: 4
            )
        ]
    }
}

struct StationAnnotation: View {
    let station: ChargingStation
    let isSelected: Bool
    
    private var markerColor: Color {
        station.available > 0 ? .green : Color(red: 0.2, green: 0.2, blue: 0.2)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(markerColor)
                .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
            
            // Lightning bolt
            Image(systemName: "bolt.fill")
                .font(.system(size: isSelected ? 20 : 16))
                .foregroundColor(.white)
            
            // Selected state indicator
            if isSelected {
                // Distance pill
                Text("\(Int(station.distance))m")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.3))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .offset(y: -40)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct StationCard: View {
    let station: ChargingStation
    
    private var priceInDKK: Double {
        station.price * 6.8 // Convert USD to DKK
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with name and distance
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(station.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(station.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(String(format: "%.1f km", station.distance / 1000))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Charging info
            HStack(spacing: 16) {
                // Power output
                VStack(alignment: .leading, spacing: 2) {
                    Label("\(Int(station.powerOutput)) kW", systemImage: "bolt.fill")
                        .foregroundColor(.yellow)
                    Text("Max Power")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                // Price
                VStack(alignment: .leading, spacing: 2) {
                    Label("\(String(format: "%.2f", priceInDKK)) DKK", systemImage: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("per kWh")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Availability
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(station.available > 0 ? .green : Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(width: 8, height: 8)
                        Text("\(station.available)/\(station.total)")
                            .foregroundColor(.white)
                    }
                    Text("Available")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .font(.subheadline)
            
            // Connector types
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(station.connectionTypes, id: \.self) { type in
                        Text(type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 300)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
