import Foundation

enum CarBrand: String, Codable {
    case tesla
    case porsche
    case bmw
    case audi
    case volkswagen
}

struct Car: Identifiable {
    let id: String
    let brand: CarBrand
    let model: String
    let batteryLevel: Double
    let range: Double
    let location: Location
    let isCharging: Bool
    let temperature: Double
    let mileage: Double
    let engineStarted: Bool
    
    // Control states
    var smartSummon: Bool = false
    var heightSetting: Double = 0.5 // 0.0 to 1.0
    var airFlow: Bool = false
    var climate: Bool = false
    var camera: Bool = false
    
    // Temperature settings
    var exteriorTemp: Double = 20.0
    var interiorTemp: Double = 20.0
    
    var formattedRange: String {
        return "\(Int(range)) km"
    }
    
    var formattedBatteryLevel: String {
        return "\(Int(batteryLevel * 100))%"
    }
    
    var formattedMileage: String {
        return String(format: "%.0f", mileage)
    }
    
    init(id: String, 
         brand: CarBrand, 
         model: String, 
         batteryLevel: Double, 
         range: Double, 
         location: Location, 
         isCharging: Bool, 
         temperature: Double, 
         mileage: Double = 0, 
         engineStarted: Bool = true) {
        
        self.id = id
        self.brand = brand
        self.model = model
        self.batteryLevel = batteryLevel
        self.range = range
        self.location = location
        self.isCharging = isCharging
        self.temperature = temperature
        self.mileage = mileage
        self.engineStarted = engineStarted
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?
}
