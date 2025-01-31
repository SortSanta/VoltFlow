import SwiftUI

struct CarStatusView: View {
    let car: Car
    @State private var selectedTab = "Status"
    @Environment(\.colorScheme) var colorScheme
    
    let tabs = ["Status", "Climate", "Battery", "Safety", "Location"]
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(car.model)
                                .font(.title)
                                .fontWeight(.semibold)
                            HStack(spacing: 4) {
                                Image(systemName: "battery.75")
                                Text("\(Int(car.range)) km")
                                Text("•")
                                Text("Parked")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        }
                        Spacer()
                        HStack(spacing: 16) {
                            Text("\(Int(car.temperature))°")
                                .font(.title3)
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Abstract Vehicle Status Visualization
                    ZStack {
                        // Background gradient
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.1, green: 0.1, blue: 0.2),
                                        Color(red: 0.05, green: 0.05, blue: 0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        VStack(spacing: 20) {
                            // Status indicators
                            HStack(spacing: 40) {
                                // Battery status
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: car.batteryLevel)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.green, .blue]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                            )
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                        
                                        VStack(spacing: 2) {
                                            Text("\(Int(car.batteryLevel * 100))")
                                                .font(.system(size: 16, weight: .medium))
                                            Text("%")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Text("Battery")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                // Range indicator
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: min(car.range / 500, 1.0))
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.purple, .blue]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                            )
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                        
                                        VStack(spacing: 2) {
                                            Text("\(Int(car.range))")
                                                .font(.system(size: 16, weight: .medium))
                                            Text("km")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Text("Range")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                // Temperature
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .trim(from: 0, to: (car.temperature + 20) / 60)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.orange, .red]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                            )
                                            .frame(width: 60, height: 60)
                                            .rotationEffect(.degrees(-90))
                                        
                                        VStack(spacing: 2) {
                                            Text("\(Int(car.temperature))")
                                                .font(.system(size: 16, weight: .medium))
                                            Text("°C")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Text("Temp")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Quick actions
                            HStack(spacing: 30) {
                                Button(action: {}) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 20))
                                            .frame(width: 50, height: 50)
                                            .background(Color.white.opacity(0.05))
                                            .clipShape(Circle())
                                        Text("Lock")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {}) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "fanblades")
                                            .font(.system(size: 20))
                                            .frame(width: 50, height: 50)
                                            .background(Color.white.opacity(0.05))
                                            .clipShape(Circle())
                                        Text("Climate")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {}) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 20))
                                            .frame(width: 50, height: 50)
                                            .background(Color.white.opacity(0.05))
                                            .clipShape(Circle())
                                        Text("Charge")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    // Tab Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(tabs, id: \.self) { tab in
                                VStack(spacing: 8) {
                                    Text(tab)
                                        .foregroundColor(selectedTab == tab ? .white : .gray)
                                    
                                    Circle()
                                        .fill(selectedTab == tab ? Color.white : Color.clear)
                                        .frame(width: 4, height: 4)
                                }
                                .onTapGesture {
                                    selectedTab = tab
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Status Cards
                    VStack(spacing: 16) {
                        // Battery Card
                        StatusCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Battery")
                                            .foregroundColor(.gray)
                                        Text("Last charge 2w ago")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                
                                HStack(alignment: .bottom, spacing: 8) {
                                    Text("\(Int(car.range))")
                                        .font(.system(size: 32, weight: .medium))
                                    Text("km")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 4)
                                }
                                
                                HStack(alignment: .center) {
                                    // Battery Icon
                                    BatteryView(level: car.batteryLevel)
                                        .frame(width: 40, height: 20)
                                    
                                    Text("\(Int(car.batteryLevel * 100))%")
                                        .font(.system(size: 15, weight: .medium))
                                    Text("\(Int(car.batteryLevel * 117))kW")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // Climate Card
                        StatusCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Climate")
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Button(action: { }) {
                                        Image(systemName: "minus")
                                            .font(.title2)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(car.temperature))°")
                                        .font(.system(size: 32, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Button(action: { }) {
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "snowflake")
                                    Text("Cooling")
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Text("A")
                                        .font(.system(size: 18, weight: .medium))
                                        .frame(width: 32, height: 32)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        // Media Player Card
                        StatusCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Playing now")
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.purple)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "music.note")
                                                .foregroundColor(.white)
                                        )
                                    
                                    VStack(alignment: .leading) {
                                        Text("Seamless")
                                            .font(.headline)
                                        Text("feat. Kelis")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { }) {
                                        Image(systemName: "play.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 44, height: 44)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .foregroundColor(.white)
    }
}

struct StatusCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
    }
}

struct BatteryView: View {
    let level: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 1)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(level > 0.2 ? Color.green : Color.red)
                    .frame(width: geometry.size.width * level)
                    .padding(2)
            }
        }
    }
}
