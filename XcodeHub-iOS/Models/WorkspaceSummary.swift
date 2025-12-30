import Foundation

struct WorkspaceSummary: Codable {
    let webHtmlFiles: Int
    let iosApps: Int
    let projectsTotal: Int
    let lastCleanup: String?
    let workspaceSizeBytes: Int64
    let workspaceSizeHuman: String

    enum CodingKeys: String, CodingKey {
        case webHtmlFiles = "web_html_files"
        case iosApps = "ios_apps"
        case projectsTotal = "projects_total"
        case lastCleanup = "last_cleanup"
        case workspaceSizeBytes = "workspace_size_bytes"
        case workspaceSizeHuman = "workspace_size_human"
    }
}

struct WorkspaceSummaryResponse: Codable {
    let status: String
    let timestamp: String
    let data: WorkspaceSummary
}

struct HealthResponse: Codable {
    let status: String
    let service: String
    let timestamp: String
}

struct APIError: LocalizedError {
    let message: String

    var errorDescription: String? { message }

    static let invalidURL = APIError(message: "Invalid URL")
    static let networkError = APIError(message: "Network error")
    static let decodingError = APIError(message: "Failed to decode response")
    static let serverError = APIError(message: "Server error")
    static let notConnected = APIError(message: "Not connected to server")
}
