import Foundation
import CoreLocation

struct TomTomResponse: Codable, Hashable {
    let summary: Summary
    let results: [ChargingResult]
}

struct Summary: Codable, Hashable {
    let query: String
    let queryType: String
    let queryTime: Int
    let numResults: Int
    let offset: Int
    let totalResults: Int
    let fuzzyLevel: Int
    let geoBias: GeoBias?
}

struct GeoBias: Codable, Hashable {
    let lat: Double
    let lon: Double
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
    let viewport: Viewport
    let entryPoints: [EntryPoint]?
    let dataSources: DataSources?
}

struct POI: Codable, Hashable {
    let name: String
    let categorySet: [Category]?
    let categories: [String]?
    let classifications: [Classification]?
    let url: String?
    let phone: String?
}

struct Category: Codable, Hashable {
    let id: Int
}

struct Classification: Codable, Hashable {
    let code: String
    let names: [Name]?
}

struct Name: Codable, Hashable {
    let nameLocale: String
    let name: String
}

struct Address: Codable, Hashable {
    let streetNumber: String?
    let streetName: String?
    let municipalitySubdivision: String?
    let municipality: String?
    let countrySecondarySubdivision: String?
    let countrySubdivision: String?
    let postalCode: String?
    let extendedPostalCode: String?
    let countryCode: String?
    let country: String?
    let countryCodeISO3: String?
    let freeformAddress: String
}

struct Position: Codable, Hashable {
    let lat: Double
    let lon: Double
}

struct Viewport: Codable, Hashable {
    let topLeftPoint: Position
    let btmRightPoint: Position
}

struct EntryPoint: Codable, Hashable {
    let type: String
    let position: Position
}

struct DataSources: Codable, Hashable {
    let poiDetails: [POIDetail]?
}

struct POIDetail: Codable, Hashable {
    let id: String
    let sourceName: String
}
