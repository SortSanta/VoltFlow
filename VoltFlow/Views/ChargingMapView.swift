import SwiftUI
import MapKit

struct ChargingStation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: StationType
    let available: Int
    let total: Int
    let powerOutput: Int
    let price: Double
    var distance: Double
    
    enum StationType: String, CaseIterable {
        case supercharger = "Supercharger"
        case ccs = "CCS"
        case chademo = "CHAdeMO"
        
        var color: Color {
            switch self {
            case .supercharger: return .red
            case .ccs: return Color(red: 0.2, green: 0.5, blue: 1.0)
            case .chademo: return Color(red: 0.3, green: 0.8, blue: 0.4)
            }
        }
    }
}

struct ChargingMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedStation: ChargingStation?
    @State private var showingFilters = false
    @State private var searchText = ""
    @State private var isListView = false
    
    // Filter states
    @State private var selectedTypes: Set<ChargingStation.StationType> = Set(ChargingStation.StationType.allCases)
    @State private var minPower: Double = 0
    @State private var maxPrice: Double = 1.0
    @State private var availableOnly = false
    
    // Mock data
    let stations = [
        ChargingStation(
            name: "Beverly Hills Supercharger",
            coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            type: .supercharger,
            available: 6,
            total: 8,
            powerOutput: 250,
            price: 0.40,
            distance: 0.5
        ),
        ChargingStation(
            name: "Santa Monica CCS",
            coordinate: CLLocationCoordinate2D(latitude: 34.0195, longitude: -118.4912),
            type: .ccs,
            available: 2,
            total: 4,
            powerOutput: 150,
            price: 0.35,
            distance: 2.3
        ),
        ChargingStation(
            name: "Downtown Fast Charge",
            coordinate: CLLocationCoordinate2D(latitude: 34.0407, longitude: -118.2468),
            type: .chademo,
            available: 1,
            total: 2,
            powerOutput: 100,
            price: 0.45,
            distance: 1.8
        )
    ]
    
    var filteredStations: [ChargingStation] {
        stations.filter { station in
            let typeMatch = selectedTypes.contains(station.type)
            let powerMatch = station.powerOutput >= Int(minPower)
            let priceMatch = station.price <= maxPrice
            let availabilityMatch = !availableOnly || station.available > 0
            let searchMatch = searchText.isEmpty || 
                station.name.localizedCaseInsensitiveContains(searchText)
            return typeMatch && powerMatch && priceMatch && availabilityMatch && searchMatch
        }.sorted { $0.distance < $1.distance }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.15, blue: 0.25),
                    Color(red: 0.2, green: 0.2, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Accent gradients
            ZStack {
                // Blue accent
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.clear
                    ]),
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                // Purple accent
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.2),
                        Color.clear
                    ]),
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Text("Charging")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    // Search and filter
                    HStack(spacing: 12) {
                        // Search container
                        VStack(spacing: 0) {
                            // Search field
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                                
                                TextField("", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                                    .autocorrectionDisabled()
                                    .placeholder(when: searchText.isEmpty) {
                                        Text("Search charging stations")
                                            .foregroundColor(.white.opacity(0.7))
                                            .font(.system(size: 16))
                                    }
                                
                                if !searchText.isEmpty {
                                    Button(action: { 
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            searchText = "" 
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(!searchText.isEmpty ? 0.15 : 0.1))
                                    .animation(.easeInOut(duration: 0.2), value: searchText)
                            )
                            
                            // Search results
                            if !searchText.isEmpty {
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.horizontal, 16)
                                
                                VStack(spacing: 0) {
                                    if filteredStations.isEmpty {
                                        VStack(spacing: 8) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white.opacity(0.6))
                                            Text("No stations found")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 20)
                                    } else {
                                        ForEach(filteredStations.prefix(5)) { station in
                                            Button(action: {
                                                withAnimation(.spring()) {
                                                    selectedStation = station
                                                    region.center = station.coordinate
                                                    searchText = ""
                                                }
                                            }) {
                                                SearchResultRow(station: station)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(SearchResultButtonStyle())
                                            
                                            if station.id != filteredStations.prefix(5).last?.id {
                                                Divider()
                                                    .background(Color.white.opacity(0.1))
                                                    .padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        
                        Button(action: { showingFilters.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(showingFilters ? .blue : .white)
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .zIndex(1) // Ensure dropdown appears above other content
                
                if showingFilters {
                    FilterView(
                        selectedTypes: $selectedTypes,
                        minPower: $minPower,
                        maxPrice: $maxPrice,
                        availableOnly: $availableOnly
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Map View with glass effect border
                VStack(spacing: 0) {
                    Map(coordinateRegion: $region,
                        annotationItems: filteredStations) { station in
                        MapAnnotation(coordinate: station.coordinate) {
                            ChargingStationMarker(
                                station: station,
                                isSelected: selectedStation?.id == station.id
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedStation = station
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Divider with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                }
                
                // List View
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredStations) { station in
                            StationRow(station: station)
                                .onTapGesture {
                                    selectedStation = station
                                    region.center = station.coordinate
                                }
                                .background(
                                    Group {
                                        if selectedStation?.id == station.id {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.08))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                                )
                                        } else {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.03))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                                )
                                        }
                                    }
                                )
                                .animation(.easeInOut, value: selectedStation?.id)
                        }
                    }
                    .padding()
                }
            }
            .foregroundColor(.white)
        }
    }
}

struct StationListView: View {
    let stations: [ChargingStation]
    @Binding var selectedStation: ChargingStation?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(stations) { station in
                    StationRow(station: station)
                        .onTapGesture {
                            selectedStation = station
                        }
                }
            }
            .padding()
        }
    }
}

struct StationRow: View {
    let station: ChargingStation
    
    var body: some View {
        HStack(spacing: 16) {
            // Station type indicator
            ZStack {
                Circle()
                    .fill(station.type.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Circle()
                    .fill(station.type.color)
                    .frame(width: 12, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.headline)
                HStack {
                    Text("\(station.powerOutput)kW")
                    Text("•")
                    Text("$\(String(format: "%.2f", station.price))/kWh")
                    Text("•")
                    Text("\(String(format: "%.1f", station.distance))mi")
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Availability indicator
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(station.available)/\(station.total)")
                    .font(.headline)
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
    }
}

struct StationCard: View {
    let station: ChargingStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(station.name)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(station.type.color)
                    .frame(width: 8, height: 8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(station.powerOutput)kW")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Max Power")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(station.available)/\(station.total)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Available")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text("$\(String(format: "%.2f", station.price))/kWh")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 250)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct FilterView: View {
    @Binding var selectedTypes: Set<ChargingStation.StationType>
    @Binding var minPower: Double
    @Binding var maxPrice: Double
    @Binding var availableOnly: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Charger types
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChargingStation.StationType.allCases, id: \.self) { type in
                        Button(action: {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }) {
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 8, height: 8)
                                Text(type.rawValue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedTypes.contains(type) ? Color.white.opacity(0.1) : Color.clear)
                            .cornerRadius(20)
                        }
                        .foregroundColor(selectedTypes.contains(type) ? .white : .gray)
                    }
                }
                .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                // Power slider
                VStack(alignment: .leading) {
                    HStack {
                        Text("Min Power")
                        Spacer()
                        Text("\(Int(minPower))kW")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                    Slider(value: $minPower, in: 0...350, step: 50)
                        .accentColor(.blue)
                }
                
                // Price slider
                VStack(alignment: .leading) {
                    HStack {
                        Text("Max Price")
                        Spacer()
                        Text("$\(String(format: "%.2f", maxPrice))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                    Slider(value: $maxPrice, in: 0...2, step: 0.05)
                        .accentColor(.blue)
                }
                
                Toggle("Available Only", isOn: $availableOnly)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.black.opacity(0.3))
    }
}

struct ChargingStationMarker: View {
    let station: ChargingStation
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(station.type.color.opacity(0.2))
                    .frame(width: isSelected ? 44 : 40, height: isSelected ? 44 : 40)
                    .shadow(color: station.type.color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: isSelected ? 20 : 18))
                    .foregroundColor(.white)
            }
            
            if isSelected {
                Text(station.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
        .animation(.spring(), value: isSelected)
    }
}

struct SearchResultRow: View {
    let station: ChargingStation
    
    var body: some View {
        HStack(spacing: 16) {
            // Station type indicator
            ZStack {
                Circle()
                    .fill(station.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(station.type.color)
            }
            
            // Station details
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    Label("\(station.powerOutput)kW", systemImage: "bolt.fill")
                    Label("$\(String(format: "%.2f", station.price))", systemImage: "dollarsign")
                    Label("\(String(format: "%.1f", station.distance))mi", systemImage: "location.fill")
                }
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Availability indicator
            Text("\(station.available)/\(station.total)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
        }
    }
}

struct SearchResultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color.white.opacity(configuration.isPressed ? 0.15 : 0.05)
                    .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            )
            .contentShape(Rectangle())
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
