import SwiftUI
import MapKit

struct ChargingStation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let power: Double
    let available: Int
    let total: Int
    let distance: Double
}

struct ChargingMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var selectedStation: ChargingStation?
    @State private var showingStationList = false
    
    let stations: [ChargingStation] = [
        ChargingStation(
            id: "1",
            name: "Beverly Hills Supercharger",
            coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            power: 190,
            available: 1,
            total: 3,
            distance: 5.3
        )
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: stations) { station in
                MapAnnotation(coordinate: station.coordinate) {
                    VStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .onTapGesture {
                        selectedStation = station
                    }
                }
            }
            
            if let station = selectedStation {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(station.name)
                                .font(.headline)
                            Text("\(station.distance, specifier: "%.1f") km")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Send to car") {
                            // Implementation to send to car
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(station.power) kW")
                                .font(.headline)
                            Text("Power")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(station.available)/\(station.total)")
                                .font(.headline)
                            Text("Available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("12 min")
                                .font(.headline)
                            Text("Queue")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
                .transition(.move(edge: .bottom))
            }
            
            VStack {
                HStack {
                    Button(action: { /* Filter action */ }) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: { /* Location action */ }) {
                        Image(systemName: "location")
                            .padding()
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
