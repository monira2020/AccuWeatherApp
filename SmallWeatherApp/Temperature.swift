import Foundation

struct Forecast: Codable {
    var Temperature: Temperature
}

struct Temperature: Codable {
    var Value: Double
    var Unit: String
    var UnitType: Int32
}
