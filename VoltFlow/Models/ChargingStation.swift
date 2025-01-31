import Foundation
import CoreLocation
import SwiftUI

struct ChargingStation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let type: StationType
    let powerOutput: Double
    let price: Double
    var distance: Double
    let address: String
    let operatorInfo: String?
    let usageType: String?
    let connectionTypes: [String]
    let available: Int
    let total: Int
    
    enum StationType: String, CaseIterable {
        case supercharger = "Tesla Supercharger"
        case ccs = "CCS"
        case chademo = "CHAdeMO"
        case type2 = "Type 2"
        case unknown = "Unknown"
        
        var imageName: String {
            switch self {
            case .supercharger: return "bolt.car.fill"
            case .ccs: return "bolt.fill"
            case .chademo: return "bolt.circle.fill"
            case .type2: return "bolt.square.fill"
            case .unknown: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .supercharger: return .red
            case .ccs: return Color(red: 0.2, green: 0.5, blue: 1.0)
            case .chademo: return Color(red: 0.3, green: 0.8, blue: 0.4)
            case .type2: return Color(red: 0.9, green: 0.6, blue: 0.2)
            case .unknown: return .gray
            }
        }
    }
}

extension ChargingStation: Hashable {
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
