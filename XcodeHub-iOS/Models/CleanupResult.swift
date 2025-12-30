import Foundation

struct CleanupResult: Codable {
    let status: String
    let timestamp: String
    let results: [String: CleanupTargetResult]?
    let totalFreedBytes: Int64?
    let totalFreedHuman: String?

    enum CodingKeys: String, CodingKey {
        case status, timestamp, results
        case totalFreedBytes = "total_freed_bytes"
        case totalFreedHuman = "total_freed_human"
    }
}

struct CleanupTargetResult: Codable {
    let freedBytes: Int64?
    let freedHuman: String?
    let success: Bool?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case freedBytes = "freed_bytes"
        case freedHuman = "freed_human"
        case success, message
    }
}

struct MonthlyCleanupResult: Codable {
    let status: String
    let timestamp: String
    let dryRun: Bool
    let output: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case status, timestamp, output, error
        case dryRun = "dry_run"
    }
}

enum CleanupTarget: String, CaseIterable, Identifiable {
    case xcode
    case npm
    case pip
    case system

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .xcode: return "Xcode DerivedData"
        case .npm: return "NPM Cache"
        case .pip: return "Pip Cache"
        case .system: return "System Cache"
        }
    }

    var icon: String {
        switch self {
        case .xcode: return "hammer.fill"
        case .npm: return "shippingbox.fill"
        case .pip: return "cube.fill"
        case .system: return "internaldrive.fill"
        }
    }

    var color: String {
        switch self {
        case .xcode: return "blue"
        case .npm: return "red"
        case .pip: return "green"
        case .system: return "orange"
        }
    }
}
