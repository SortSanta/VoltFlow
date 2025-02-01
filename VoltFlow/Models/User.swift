import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    let createdAt: Date
    var cars: [String]  // Array of car IDs
    var favoriteStations: [String]  // Array of favorite charging station IDs
    var preferences: Preferences
    
    struct Preferences: Codable {
        var defaultChargingSpeed: ChargingSpeed
        var preferredPaymentMethod: String?
        var notificationsEnabled: Bool
        var darkModeEnabled: Bool
        
        enum ChargingSpeed: String, Codable {
            case slow
            case normal
            case fast
        }
    }
}
