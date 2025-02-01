import Foundation

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
