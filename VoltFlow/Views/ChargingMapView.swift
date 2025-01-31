import SwiftUI
import MapKit
import CoreLocation

struct ChargingMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let tomTomApiKey = "B6C9i7TKpiPfszZA24uraI2mgsUSzpl2"
    @State private var stations: [ChargingStation] = []
    @State private var selectedStation: ChargingStation?
    @State private var showingFilters = false
    @State private var isListView = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.6761, longitude: 12.5683), // Copenhagen coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    // Filter states
    @State private var selectedTypes: Set<ChargingStation.StationType> = Set(ChargingStation.StationType.allCases)
    @State private var minPower: Double = 0
    @State private var maxPower: Double = 350
    @State private var maxPrice: Double = 1.0
    @State private var availableOnly = false
    
    var filteredStations: [ChargingStation] {
        stations.filter { station in
            let typeMatch = selectedTypes.contains(station.type)
            let powerMatch = station.powerOutput >= minPower && station.powerOutput <= maxPower
            let priceMatch = station.price <= maxPrice
            let availabilityMatch = !availableOnly || station.available > 0
            let searchMatch = searchText.isEmpty ||
                station.name.localizedCaseInsensitiveContains(searchText)
            
            return typeMatch && powerMatch && priceMatch && availabilityMatch && searchMatch
        }.sorted { $0.distance < $1.distance }
    }
    
    private func fetchNearbyStations() {
        print("Fetching nearby stations...")
        guard let location = locationManager.location else {
            print("❌ Location not available")
            return
        }
        
        print("📍 Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // TomTom API endpoint for EV charging stations
        let urlString = "https://api.tomtom.com/search/2/categorySearch/electric%20vehicle%20station.json"
        var components = URLComponents(string: urlString)!
        
        // Add query parameters
        components.queryItems = [
            URLQueryItem(name: "key", value: tomTomApiKey),
            URLQueryItem(name: "lat", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "radius", value: "10000"), // 10km radius
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "categorySet", value: "7309"), // EV charging station category
            URLQueryItem(name: "view", value: "Unified") // Include extended POI data
        ]
        
        guard let url = components.url else {
            print("❌ Invalid URL")
            return
        }
        
        print("🌐 Fetching from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                return
            }
            
            print("📡 Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TomTomResponse.self, from: data)
                print("✅ Successfully decoded \(response.results.count) stations")
                
                DispatchQueue.main.async {
                    self.stations = response.results.map { result in
                        ChargingStation(
                            id: result.id,
                            name: result.poi.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: result.position.lat,
                                longitude: result.position.lon
                            ),
                            type: .type2, // Default to Type 2 since TomTom doesn't specify connector types
                            powerOutput: 0, // TomTom doesn't provide power output
                            price: 0.0, // TomTom doesn't provide pricing
                            distance: result.dist ?? 0,
                            address: result.address.freeformAddress,
                            operatorInfo: nil,
                            usageType: result.poi.classifications?.first?.code ?? "Unknown",
                            connectionTypes: [],
                            available: 0,
                            total: 0
                        )
                    }
                    print("🔌 Found \(self.stations.count) charging stations")
                }
            } catch {
                print("❌ Decoding error: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📄 Raw response: \(dataString)")
                }
            }
        }.resume()
    }
    
    private func calculateBoundingBox(center: CLLocationCoordinate2D, radiusKm: Double) -> (minLat: Double, minLon: Double, maxLat: Double, maxLon: Double) {
        let earthRadiusKm: Double = 6371
        let latRadian = center.latitude * .pi / 180
        
        let deltaLat = (radiusKm / earthRadiusKm) * (180 / .pi)
        let deltaLon = asin(sin(radiusKm / earthRadiusKm) / cos(latRadian)) * (180 / .pi)
        
        return (
            minLat: center.latitude - deltaLat,
            minLon: center.longitude - deltaLon,
            maxLat: center.latitude + deltaLat,
            maxLon: center.longitude + deltaLon
        )
    }
    
    private func searchStations(query: String) -> [ChargingStation] {
        if query.isEmpty {
            return []
        }
        return stations.filter { station in
            station.name.localizedCaseInsensitiveContains(query) ||
            station.address.localizedCaseInsensitiveContains(query) ||
            station.connectionTypes.contains(where: { $0.localizedCaseInsensitiveContains(query) })
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
                        maxPower: $maxPower,
                        maxPrice: $maxPrice,
                        availableOnly: $availableOnly
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                // Map View with glass effect border
                VStack(spacing: 0) {
                    if let error = locationManager.locationError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    Map(coordinateRegion: $region,
                        showsUserLocation: true,
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
                    .overlay(alignment: .trailing) {
                        VStack {
                            Spacer()
                            Button(action: {
                                if let location = locationManager.location {
                                    withAnimation {
                                        region = MKCoordinateRegion(
                                            center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        )
                                    }
                                    fetchNearbyStations()
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(.trailing, 16)
                            .padding(.bottom, 32)
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
                }
                
                // List View
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredStations) { station in
                            StationRow(station: station)
                                .onTapGesture {
                                    selectedStation = station
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
        .onAppear {
            print("ChargingMapView appeared")
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                print("Location changed, updating map region")
                withAnimation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                print("Fetching nearby stations...")
                fetchNearbyStations()
            }
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
    @Binding var maxPower: Double
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
                    
                    Slider(value: $minPower, in: 0...maxPower, step: 50)
                        .accentColor(.blue)
                }
                
                // Power slider
                VStack(alignment: .leading) {
                    HStack {
                        Text("Max Power")
                        Spacer()
                        Text("\(Int(maxPower))kW")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                    Slider(value: $maxPower, in: minPower...350, step: 50)
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
            Image(systemName: station.type.imageName)
                .font(.system(size: 24))
                .foregroundColor(station.type.color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(station.type.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(station.address)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f km", station.distance / 1000))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                if station.available > 0 {
                    Text("\(station.available) available")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                } else {
                    Text("No spots")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SearchResultButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.1) : Color.clear)
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
