import SwiftUI
import MapKit

// MARK: - Smart Energy Models
struct DrivingSession: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let averageSpeed: Double
    let energyUsed: Double
    let distance: Double
}

struct EfficiencyScore {
    let overall: Double // 0-100
    let acceleration: Double // 0-100
    let braking: Double // 0-100
    let energyUsage: Double // kWh/100km
    
    static var preview: EfficiencyScore {
        EfficiencyScore(
            overall: 85,
            acceleration: 90,
            braking: 82,
            energyUsage: 16.8
        )
    }
}

struct DrivingTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let potentialSaving: Double // kWh
    let category: TipCategory
    
    enum TipCategory {
        case acceleration
        case braking
        case climate
        case route
        case charging
    }
}

// MARK: - Smart Energy ViewModel
class SmartEnergyViewModel: ObservableObject {
    @Published var efficiencyScore: EfficiencyScore
    @Published var drivingTips: [DrivingTip]
    @Published var recentSessions: [DrivingSession]
    
    init() {
        // TODO: Replace with real data
        self.efficiencyScore = EfficiencyScore.preview
        self.drivingTips = [
            DrivingTip(
                title: "Smooth Acceleration",
                description: "Gradual acceleration can improve your efficiency by up to 10%",
                potentialSaving: 0.8,
                category: .acceleration
            ),
            DrivingTip(
                title: "Optimal Climate",
                description: "Using seat heaters instead of cabin heat can extend your range",
                potentialSaving: 1.2,
                category: .climate
            )
        ]
        self.recentSessions = []
    }
}

// MARK: - Smart Energy Views
struct EfficiencyScoreCard: View {
    let score: EfficiencyScore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Efficiency Score")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(score.overall))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(scoreColor)
            }
            
            HStack(spacing: 20) {
                ScoreMetric(
                    title: "Acceleration",
                    value: score.acceleration,
                    icon: "speedometer"
                )
                
                ScoreMetric(
                    title: "Braking",
                    value: score.braking,
                    icon: "brake"
                )
                
                ScoreMetric(
                    title: "Energy",
                    value: score.energyUsage,
                    unit: "kWh/100km",
                    icon: "bolt.circle"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    private var scoreColor: Color {
        switch score.overall {
        case 90...: return .green
        case 70...: return .yellow
        default: return .orange
        }
    }
}

struct ScoreMetric: View {
    let title: String
    let value: Double
    var unit: String = ""
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(Int(value))\(unit)")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct DrivingTipsView: View {
    let tips: [DrivingTip]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Tips")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(tips) { tip in
                TipCard(tip: tip)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
}

struct TipCard: View {
    let tip: DrivingTip
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if tip.potentialSaving > 0 {
                    Text("Potential saving: \(String(format: "%.1f", tip.potentialSaving)) kWh")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var iconName: String {
        switch tip.category {
        case .acceleration: return "speedometer"
        case .braking: return "brake"
        case .climate: return "thermometer"
        case .route: return "map"
        case .charging: return "bolt.circle"
        }
    }
    
    private var iconColor: Color {
        switch tip.category {
        case .acceleration: return .blue
        case .braking: return .purple
        case .climate: return .orange
        case .route: return .green
        case .charging: return .yellow
        }
    }
}

// MARK: - Main View
struct CarStatusView: View {
    let car: Car
    @StateObject private var smartEnergy = SmartEnergyViewModel()
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
    @State private var isDragging = false
    @State private var dragAngle: Double = 0
    @State private var previousDragAngle: Double = 0
    
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
                            StatusCard {
                                climateCardContent
                            }
                            
                            // Media Player Card
                            StatusCard {
                                mediaCardContent
                            }
                        }
                        .padding(.horizontal)
                        
                    case "Status":
                        // Status Cards
                        VStack(spacing: 16) {
                            // Battery Card
                            StatusCard {
                                batteryCardContent
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
                        .padding([.horizontal, .bottom])
                        
                    case "Battery":
                        VStack(spacing: 20) {
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
                                EfficiencyScoreCard(score: smartEnergy.efficiencyScore)
                            }
                            
                            StatusCard {
                                DrivingTipsView(tips: smartEnergy.drivingTips)
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
                        .padding([.horizontal, .bottom])
                        
                    case "Safety":
                        VStack(spacing: 20) {
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
                        .padding([.horizontal, .bottom])
                        
                    case "Location":
                        VStack(spacing: 20) {
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
                        .padding([.horizontal, .bottom])
                        
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
        
        func progressRing() -> some View{
        ZStack {
            Circle()
                .trim(from: 0, to: min(CGFloat(targetTemperature - 16) / 14.0, 1.0))
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 30, lineCap: .round)
                )
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .position(handlePosition(for: targetTemperature))
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
    
    private struct TemperatureMarkersView: View {
        var body: some View {
            ZStack {
                ForEach([16, 20, 24, 28], id: \.self) { temp in
                    TemperatureMarker(temperature: temp)
                }
            }
        }
        
        struct TemperatureMarker: View {
            let temperature: Int
            
            var body: some View {
                let pos = position(for: temperature)
                Text("\(temperature)°")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .position(x: pos.x, y: pos.y)
            }
            private func position(for temperature: Int) -> CGPoint {
                let radius: CGFloat = 115
                let angle = (Double(temperature - 16) / 14.0 * 2 * .pi) - .pi/2
                return CGPoint(
                    x: 100 + radius * cos(angle),
                    y: 100 + radius * sin(angle)
                )
            }
        }
    }
    
    private var centerDisplay: some View {
            VStack(spacing: 4) {
                Text("\(targetTemperature, specifier: "%.1f")°")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                
                Text("TARGET")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Drag to adjust")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .opacity(isDragging ? 0 : 0.8)
            }
    }
    
    private func handlePosition(for temperature: Double) -> CGPoint {
        let radius: CGFloat = 100
        let angle = (temperature - 16) / 14.0 * 2 * .pi - .pi / 2
        return CGPoint(
            x: radius + radius * cos(angle),
            y: radius + radius * sin(angle)
        )
    }
        
        var body: some View {
            let pos = position(for: temperature)
            Text("\(temperature)°")
                .font(.caption2)
                .foregroundColor(.gray)
                .position(x: pos.x, y: pos.y)
        }
        
        
        return ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 30)
                    .frame(width: 200, height: 200)
            progressRing()
                TemperatureMarkersView()
                centerDisplay
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let center = CGPoint(x: 100, y: 100)
                    let location = value.location
                    let angle = atan2(location.y - center.y, location.x - center.x)
                    let degrees = angle * 180 / .pi + 90
                    let normalizedDegrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
                    let temperature = 16 + (normalizedDegrees / 360) * 14
                    targetTemperature = min(30, max(16, temperature))
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
            .onTapGesture { location in
            let center = CGPoint(x: 100, y: 100)
            let location = location
            let angle = atan2(location.y - center.y, location.x - center.x)
            let degrees = angle * 180 / .pi + 90
            let normalizedDegrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
            let temperature = 16 + (normalizedDegrees / 360) * 14
            targetTemperature = min(30, max(16, temperature))
        }
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

struct TemperatureMarkersView: View {
    var body: some View {
        ZStack {
            ForEach([16, 20, 24, 28], id: \.self) { temp in
            Text("\(targetTemperature, specifier: "%.1f")°")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.white)
            
            Text("TARGET")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Drag to adjust")
                .font(.caption2)
                .foregroundColor(.gray)
                .opacity(isDragging ? 0 : 0.8)
        }
    }
        
        struct TemperatureMarker: View {
            let temperature: Int
            
            var body: some View {
                let pos = position(for: temperature)
                Text("\(temperature)°")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .position(x: pos.x, y: pos.y)
            }
            private func position(for temperature: Int) -> CGPoint {
                let radius: CGFloat = 115
                let angle = (Double(temperature - 16) / 14.0 * 2 * .pi) - .pi/2
                return CGPoint(
                    x: 100 + radius * cos(angle),
                    y: 100 + radius * sin(angle)
                )
            }
        }
    }
    
    private var centerDisplay: some View {
        VStack(spacing: 4) {
            Text("\(targetTemperature, specifier: "%.1f")°")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.white)
            
            Text("TARGET")
                .font(.caption)
                .foregroundColor(.gray)
            
    }
    
    private var temperatureRingView: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 30)
                .frame(width: 200, height: 200)
            
            progressRing
            centerDisplay
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDragging = true
                    let center = CGPoint(x: 100, y: 100)
                    let location = value.location
                    let angle = atan2(location.y - center.y, location.x - center.x)
                    let degrees = angle * 180 / .pi + 90
                    let normalizedDegrees = (degrees + 360).truncatingRemainder(dividingBy: 360)
                    let temperature = 16 + (normalizedDegrees / 360) * 14
                    targetTemperature = min(30, max(16, temperature))
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
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
