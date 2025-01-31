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
                                AnimatedGauge(
                                    value: car.batteryLevel * 100,
                                    maxValue: 100,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [.green, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    label: "Battery",
                                    unit: "%"
                                )
                                
                                // Range indicator
                                AnimatedGauge(
                                    value: car.range,
                                    maxValue: 500,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    label: "Range",
                                    unit: "km"
                                )
                                
                                // Temperature
                                AnimatedGauge(
                                    value: car.temperature,
                                    maxValue: 40,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    label: "Temp",
                                    unit: "°C"
                                )
                            }
                            
                            // Quick actions
                            HStack(spacing: 30) {
                                QuickActionButton(
                                    icon: "lock.fill",
                                    label: "Lock"
                                ) {
                                    // Lock action
                                }
                                
                                QuickActionButton(
                                    icon: "fanblades",
                                    label: "Climate"
                                ) {
                                    // Climate action
                                }
                                
                                QuickActionButton(
                                    icon: "bolt.fill",
                                    label: "Charge"
                                ) {
                                    // Charge action
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

struct AnimatedGauge: View {
    let value: Double
    let maxValue: Double
    let gradient: LinearGradient
    let label: String
    let unit: String
    
    @State private var animatedValue: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                // Animated progress
                Circle()
                    .trim(from: 0, to: animatedValue)
                    .stroke(
                        gradient,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1, dampingFraction: 0.8), value: animatedValue)
                
                // Value display
                VStack(spacing: 2) {
                    Text("\(Int(value))")
                        .font(.system(size: 16, weight: .medium))
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .onAppear {
            // Animate from 0 to the actual value
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animatedValue = value / maxValue
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.spring(response: 1, dampingFraction: 0.8)) {
                animatedValue = newValue / maxValue
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}
