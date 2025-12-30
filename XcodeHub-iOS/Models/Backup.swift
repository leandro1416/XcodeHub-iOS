import Foundation

struct Backup: Codable, Identifiable {
    let name: String
    let path: String
    let sizeBytes: Int64
    let sizeHuman: String
    let modified: String

    var id: String { path }

    var modifiedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: modified) ?? ISO8601DateFormatter().date(from: modified)
    }

    var formattedDate: String {
        guard let date = modifiedDate else { return modified }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case name, path, modified
        case sizeBytes = "size_bytes"
        case sizeHuman = "size_human"
    }
}

struct BackupsResponse: Codable {
    let status: String
    let timestamp: String
    let data: BackupsData

    struct BackupsData: Codable {
        let backups: [Backup]
        let total: Int
    }
}

struct ICloudStatus: Codable {
    let accountId: String?
    let syncActive: Bool
    let icloudPath: String
    let backupsPath: String
    let backupsSizeBytes: Int64
    let backupsSizeHuman: String

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case syncActive = "sync_active"
        case icloudPath = "icloud_path"
        case backupsPath = "backups_path"
        case backupsSizeBytes = "backups_size_bytes"
        case backupsSizeHuman = "backups_size_human"
    }
}

struct ICloudStatusResponse: Codable {
    let status: String
    let timestamp: String
    let data: ICloudStatus
}
