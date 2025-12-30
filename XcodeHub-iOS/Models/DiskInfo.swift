import Foundation

struct DiskInfo: Codable, Identifiable {
    let path: String
    let sizeBytes: Int64
    let sizeHuman: String
    let exists: Bool

    var id: String { path }

    enum CodingKeys: String, CodingKey {
        case path
        case sizeBytes = "size_bytes"
        case sizeHuman = "size_human"
        case exists
    }
}

struct DiskOverviewResponse: Codable {
    let status: String
    let timestamp: String
    let data: [String: DiskInfo]
}

struct CacheInfo: Codable, Identifiable {
    let path: String
    let sizeBytes: Int64
    let sizeHuman: String
    let canDelete: Bool

    var id: String { path }

    var name: String {
        if path.contains("DerivedData") { return "Xcode DerivedData" }
        if path.contains(".npm") { return "NPM Cache" }
        if path.contains("pip") { return "Pip Cache" }
        if path.contains(".cache") { return "System Cache" }
        return path.components(separatedBy: "/").last ?? "Cache"
    }

    var icon: String {
        if path.contains("DerivedData") { return "hammer" }
        if path.contains(".npm") { return "shippingbox" }
        if path.contains("pip") { return "cube" }
        if path.contains(".cache") { return "internaldrive" }
        return "folder"
    }

    enum CodingKeys: String, CodingKey {
        case path
        case sizeBytes = "size_bytes"
        case sizeHuman = "size_human"
        case canDelete = "can_delete"
    }
}

struct CacheResponse: Codable {
    let status: String
    let timestamp: String
    let data: [String: CacheInfo]
}
