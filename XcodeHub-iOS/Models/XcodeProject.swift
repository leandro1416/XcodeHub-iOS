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
