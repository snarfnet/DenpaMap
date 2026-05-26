import Foundation
import CoreLocation
import MapKit

struct SignalMeasurement: Identifiable, Codable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let latencyMs: Double
    let downloadSpeedMbps: Double
    let networkType: String // WiFi, 5G, LTE, 3G, etc.
    let ssid: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var quality: SignalQuality {
        if latencyMs < 30 && downloadSpeedMbps > 50 { return .excellent }
        if latencyMs < 80 && downloadSpeedMbps > 15 { return .good }
        if latencyMs < 150 && downloadSpeedMbps > 5 { return .fair }
        if latencyMs < 300 && downloadSpeedMbps > 1 { return .poor }
        return .dead
    }

    init(coordinate: CLLocationCoordinate2D, latencyMs: Double, downloadSpeedMbps: Double, networkType: String, ssid: String?) {
        self.id = UUID()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = Date()
        self.latencyMs = latencyMs
        self.downloadSpeedMbps = downloadSpeedMbps
        self.networkType = networkType
        self.ssid = ssid
    }
}

enum SignalQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case dead = "Dead"

    var color: String {
        switch self {
        case .excellent: return "qualityExcellent"
        case .good: return "qualityGood"
        case .fair: return "qualityFair"
        case .poor: return "qualityPoor"
        case .dead: return "qualityDead"
        }
    }

    var localizedName: String {
        switch self {
        case .excellent: return String(localized: "quality_excellent")
        case .good: return String(localized: "quality_good")
        case .fair: return String(localized: "quality_fair")
        case .poor: return String(localized: "quality_poor")
        case .dead: return String(localized: "quality_dead")
        }
    }
}
