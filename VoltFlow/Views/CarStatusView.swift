import SwiftUI
import MapKit

struct CarStatusView: View {
    let car: Car
    @State private var selectedTab = "Status"
    @Environment(\.colorScheme) var colorScheme
    @State private var isClimateOn = false
    @State private var targetTemperature = 20.0
    @State private var selectedClimateMode = "Auto"
    @State private var scheduledTime = Date()
    @State private var showingSchedulePicker = false
    @State private var isSentryMode = true
    @State private var isPinToDrive = false
    @State private var isChildLock = true
    
    let tabs = ["Status", "Climate", "Battery", "Safety", "Location"]
    let climateModes = ["Auto", "Cool", "Heat", "Fan", "Off"]
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
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
                                Text(car.location.address ?? "Parked")
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
                                    value: Double(car.range),
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
                    
                    // Tab Bar and Content
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(tabs, id: \.self) { tab in
                                VStack(spacing: 8) {
                                    Text(tab)
                                        .foregroundColor(selectedTab == tab ? .white : .gray)
                                        .font(.system(size: 17, weight: selectedTab == tab ? .semibold : .regular))
                                    
                                    Circle()
                                        .fill(selectedTab == tab ? Color.white : Color.clear)
                                        .frame(width: 4, height: 4)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedTab = tab
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tab Content
                    switch selectedTab {
                    case "Status":
                        // Status Cards
                        VStack(spacing: 16) {
                            // Battery Card
                            StatusCard {
                                batteryCardContent
                            }
                            
                            // Climate Card
                            StatusCard {
                                climateCardContent
                            }
                            
                            // Media Player Card
                            StatusCard {
                                mediaCardContent
                            }
                        }
                        .padding(.horizontal)
                        
                    case "Climate":
                        VStack(spacing: 16) {
                            // Main Climate Control Card
                            StatusCard {
                                VStack(spacing: 24) {
                                    temperatureRingView
                                    currentTemperatureView
                                    climateModeButtons
                                }
                            }
                            
                            // Schedule Card
                            StatusCard {
                                scheduleView
                            }
                        }
                        .padding(.horizontal)
                        
                    case "Battery":
                        VStack(spacing: 16) {
                            StatusCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Current Charge")
                                                .foregroundColor(.gray)
                                            Text("\(Int(car.batteryLevel * 100))%")
                                                .font(.system(size: 42, weight: .medium))
                                        }
                                        Spacer()
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                    }
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Range")
                                                .foregroundColor(.gray)
                                            Text("\(Int(car.range)) km")
                                                .font(.headline)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Time to Full")
                                                .foregroundColor(.gray)
                                            Text("2h 15m")
                                                .font(.headline)
                                        }
                                    }
                                }
                            }
                            
                            StatusCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Nearby Chargers")
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {}) {
                                        HStack {
                                            Image(systemName: "bolt.car.fill")
                                            Text("Find Charging Stations")
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    case "Safety":
                        VStack(spacing: 16) {
                            // Security Features Card
                            StatusCard {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Vehicle Security")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    VStack(spacing: 16) {
                                        securityToggle(title: "Sentry Mode",
                                                     icon: "shield.fill",
                                                     color: .blue,
                                                     isOn: $isSentryMode,
                                                     description: "Monitor vehicle surroundings")
                                        
                                        Divider()
                                            .background(Color.white.opacity(0.1))
                                        
                                        securityToggle(title: "PIN to Drive",
                                                     icon: "lock.shield.fill",
                                                     color: .green,
                                                     isOn: $isPinToDrive,
                                                     description: "Require PIN before driving")
                                        
                                        Divider()
                                            .background(Color.white.opacity(0.1))
                                        
                                        securityToggle(title: "Child Lock",
                                                     icon: "figure.child.circle.fill",
                                                     color: .orange,
                                                     isOn: $isChildLock,
                                                     description: "Lock rear door controls")
                                    }
                                }
                            }
                            
                            // Recent Activity Card
                            StatusCard {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recent Activity")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ForEach(recentActivityItems, id: \.time) { item in
                                        HStack(spacing: 12) {
                                            Image(systemName: item.icon)
                                                .foregroundColor(item.color)
                                                .font(.title3)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.title)
                                                    .foregroundColor(.white)
                                                Text(item.time)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    case "Location":
                        VStack(spacing: 16) {
                            StatusCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Current Location")
                                        .foregroundColor(.gray)
                                    
                                    Text(car.location.address ?? "Unknown Location")
                                        .font(.headline)
                                    
                                    Button(action: {}) {
                                        Label("Navigate to Car", systemImage: "location.fill")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                    default:
                        EmptyView()
                    }
                }
                .padding(.top)
            }
        }
        .foregroundColor(.white)
    }
    
    // MARK: - Climate Control Components
    
    private var temperatureRingView: some View {
        ZStack {
            // Background Ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 30)
                .frame(width: 220, height: 220)
            
            // Temperature Progress
            Circle()
                .trim(from: 0, to: min(CGFloat(targetTemperature) / 30.0, 1.0))
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 30, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
            
            // Center Temperature Display
            VStack(spacing: 8) {
                Text("\(targetTemperature, specifier: "%.1f")°")
                    .font(.system(size: 54, weight: .medium))
                    .foregroundColor(.white)
                
                Text("TARGET")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            temperatureControlButtons
        }
        .padding(.top, 20)
    }
    
    private var temperatureControlButtons: some View {
        HStack {
            Button(action: { targetTemperature = max(16, targetTemperature - 0.5) }) {
                Image(systemName: "minus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(temperatureButtonGradient)
                    .clipShape(Circle())
            }
            .offset(x: -140)
            
            Button(action: { targetTemperature = min(30, targetTemperature + 0.5) }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(temperatureButtonGradient)
                    .clipShape(Circle())
            }
            .offset(x: 140)
        }
    }
    
    private var temperatureButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var currentTemperatureView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CURRENT")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(Int(car.temperature))°")
                    .font(.title)
                    .foregroundColor(.white)
            }
            Spacer()
            Toggle("", isOn: $isClimateOn)
                .tint(.blue)
        }
        .padding(.horizontal)
    }
    
    private struct ClimateButton: View {
        let mode: String
        let isSelected: Bool
        let action: () -> Void
        let iconName: String
        
        private var buttonGradient: LinearGradient {
            isSelected ?
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.title2)
                    Text(mode)
                        .font(.caption)
                }
                .frame(width: 70, height: 70)
                .background(buttonGradient)
                .foregroundColor(isSelected ? .white : .gray)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    private var climateModeButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(climateModes, id: \.self) { mode in
                    ClimateButton(
                        mode: mode,
                        isSelected: selectedClimateMode == mode,
                        action: { selectedClimateMode = mode },
                        iconName: modeIcon(for: mode)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var scheduleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Schedule")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showingSchedulePicker.toggle() }) {
                    Text(showingSchedulePicker ? "Done" : "Edit")
                        .foregroundColor(.blue)
                }
            }
            
            if showingSchedulePicker {
                DatePicker("Select Time", selection: $scheduledTime, displayedComponents: [.hourAndMinute, .date])
                    .datePickerStyle(.graphical)
                    .colorScheme(.dark)
                    .accentColor(.blue)
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NEXT SCHEDULE")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(scheduledTime, style: .time)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Toggle("", isOn: .constant(true))
                        .tint(.blue)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Card Content Views
    
    private var batteryCardContent: some View {
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
    
    private var climateCardContent: some View {
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
    
    private var mediaCardContent: some View {
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

// MARK: - Helper Functions

extension CarStatusView {
    private func modeIcon(for mode: String) -> String {
        switch mode {
        case "Auto": return "a.circle.fill"
        case "Cool": return "snowflake"
        case "Heat": return "flame.fill"
        case "Fan": return "wind"
        default: return "power.circle.fill"
        }
    }
    
    private func securityToggle(title: String, icon: String, color: Color, isOn: Binding<Bool>, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: isOn)
                    .tint(color)
            }
        }
    }
    
    private var recentActivityItems: [(icon: String, color: Color, title: String, time: String)] {
        [
            ("shield.fill", .blue, "Sentry Mode Activated", "2 hours ago"),
            ("figure.walk", .orange, "Door Opened", "Yesterday at 9:30 PM"),
            ("key.fill", .green, "Vehicle Unlocked", "Yesterday at 9:29 PM")
        ]
    }
}
