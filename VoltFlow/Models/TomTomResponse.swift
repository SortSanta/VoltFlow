import Foundation
import CoreLocation

struct TomTomResponse: Codable, Hashable {
    let summary: Summary
    let results: [ChargingResult]
}

struct Summary: Codable, Hashable {
    let numResults: Int
}

struct ChargingResult: Codable, Hashable {
    let type: String
    let id: String
    let score: Double
    let dist: Double?
    let info: String
    let poi: POI
    let address: Address
    let position: Position
}

struct POI: Codable, Hashable {
    let name: String
    let phone: String?
}

struct Address: Codable, Hashable {
    let freeformAddress: String
}

struct Position: Codable, Hashable {
    let lat: Double
    let lon: Double
}
