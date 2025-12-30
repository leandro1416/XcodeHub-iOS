import Foundation

struct XcodeProject: Codable, Identifiable {
    let name: String
    let path: String

    var id: String { path }

    var platform: Platform {
        if path.contains("/iOS/") {
            return .iOS
        } else if path.contains("/macOS/") {
            return .macOS
        }
        return .unknown
    }

    var icon: String {
        switch platform {
        case .iOS: return "iphone"
        case .macOS: return "desktopcomputer"
        case .unknown: return "folder"
        }
    }

    enum Platform: String, CaseIterable {
        case iOS = "iOS"
        case macOS = "macOS"
        case unknown = "Unknown"
    }
}

struct XcodeProjectsResponse: Codable {
    let status: String
    let timestamp: String
    let data: ProjectsData
    let counts: ProjectCounts

    struct ProjectsData: Codable {
        let ios: [XcodeProject]
        let macos: [XcodeProject]
    }

    struct ProjectCounts: Codable {
        let ios: Int
        let macos: Int
        let total: Int
    }
}

struct OpenXcodeResponse: Codable {
    let status: String
    let message: String?
    let target: String?
}

struct DeleteProjectResponse: Codable {
    let status: String
    let message: String?
    let deletedPath: String?
    let freedBytes: Int?
    let freedHuman: String?
    let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case deletedPath = "deleted_path"
        case freedBytes = "freed_bytes"
        case freedHuman = "freed_human"
        case timestamp
    }
}

struct ProjectBriefingResponse: Codable {
    let status: String
    let data: ProjectBriefing
}

struct ProjectBriefing: Codable {
    let name: String
    let path: String
    let sizeBytes: Int
    let sizeHuman: String
    let lastModified: String
    let fileCount: Int
    let swiftFiles: Int
    let summary: String?
    let features: [String]
    let bundleId: String?
    let hasDocs: Bool

    enum CodingKeys: String, CodingKey {
        case name, path, summary, features
        case sizeBytes = "size_bytes"
        case sizeHuman = "size_human"
        case lastModified = "last_modified"
        case fileCount = "file_count"
        case swiftFiles = "swift_files"
        case bundleId = "bundle_id"
        case hasDocs = "has_docs"
    }

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: lastModified) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return lastModified
    }
}
