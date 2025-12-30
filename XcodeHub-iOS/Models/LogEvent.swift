import Foundation

struct LogEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let category: Category
    let action: String
    let screen: String?
    let details: [String: String]?
    let level: Level

    init(
        category: Category,
        action: String,
        screen: String? = nil,
        details: [String: String]? = nil,
        level: Level = .info
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.category = category
        self.action = action
        self.screen = screen
        self.details = details
        self.level = level
    }

    enum Category: String, Codable, CaseIterable {
        case navigation = "navigation"
        case action = "action"
        case api = "api"
        case error = "error"
        case lifecycle = "lifecycle"
        case user = "user"
    }

    enum Level: String, Codable {
        case debug = "debug"
        case info = "info"
        case warning = "warning"
        case error = "error"
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }

    var icon: String {
        switch category {
        case .navigation: return "arrow.right.circle"
        case .action: return "hand.tap"
        case .api: return "network"
        case .error: return "exclamationmark.triangle"
        case .lifecycle: return "arrow.clockwise"
        case .user: return "person.circle"
        }
    }

    var color: String {
        switch level {
        case .debug: return "gray"
        case .info: return "blue"
        case .warning: return "orange"
        case .error: return "red"
        }
    }
}

struct LogBatch: Codable {
    let device_id: String
    let app_version: String
    let os_version: String
    let events: [LogEvent]
    let sent_at: Date
}
