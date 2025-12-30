import Foundation
import UIKit

@MainActor
class LoggingService: ObservableObject {
    static let shared = LoggingService()

    @Published private(set) var events: [LogEvent] = []
    @Published private(set) var isSending = false

    private let maxLocalEvents = 500
    private let batchSize = 5  // Send frequently for real-time tracking
    private var pendingEvents: [LogEvent] = []

    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var osVersion: String {
        UIDevice.current.systemVersion
    }

    private init() {
        loadPersistedEvents()

        // Send logs when app goes to background
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                await self?.forceSend()
            }
        }
    }

    // MARK: - Logging Methods

    func log(_ action: String, category: LogEvent.Category = .action, screen: String? = nil, details: [String: String]? = nil, level: LogEvent.Level = .info) {
        let event = LogEvent(
            category: category,
            action: action,
            screen: screen,
            details: details,
            level: level
        )

        events.insert(event, at: 0)
        pendingEvents.append(event)

        // Trim old events
        if events.count > maxLocalEvents {
            events = Array(events.prefix(maxLocalEvents))
        }

        // Auto-send if batch size reached
        if pendingEvents.count >= batchSize {
            Task {
                await sendBatch()
            }
        }

        // Persist locally
        persistEvents()

        #if DEBUG
        print("[\(event.formattedTimestamp)] [\(event.category.rawValue.uppercased())] \(action)")
        #endif
    }

    // Convenience methods
    func logNavigation(to screen: String) {
        log("Navigated to \(screen)", category: .navigation, screen: screen)
    }

    func logAction(_ action: String, screen: String? = nil, details: [String: String]? = nil) {
        log(action, category: .action, screen: screen, details: details)
    }

    func logAPI(_ endpoint: String, success: Bool, details: [String: String]? = nil) {
        log(
            "\(success ? "Success" : "Failed"): \(endpoint)",
            category: .api,
            details: details,
            level: success ? .info : .error
        )
    }

    func logError(_ message: String, screen: String? = nil, details: [String: String]? = nil) {
        log(message, category: .error, screen: screen, details: details, level: .error)
    }

    func logLifecycle(_ event: String) {
        log(event, category: .lifecycle, level: .debug)
    }

    // MARK: - Sending to Server

    func sendBatch() async {
        guard !pendingEvents.isEmpty, !isSending else { return }

        isSending = true
        defer { isSending = false }

        let batch = LogBatch(
            device_id: deviceId,
            app_version: appVersion,
            os_version: osVersion,
            events: pendingEvents,
            sent_at: Date()
        )

        let baseURL = SettingsManager.shared.serverURL
        guard let url = URL(string: "\(baseURL)/api/logs/batch") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            request.httpBody = try encoder.encode(batch)
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                pendingEvents.removeAll()
                log("Sent \(batch.events.count) events to server", category: .lifecycle, level: .debug)
            }
        } catch {
            // Keep events for retry
            log("Failed to send logs: \(error.localizedDescription)", category: .error, level: .error)
        }
    }

    func forceSend() async {
        await sendBatch()
    }

    // MARK: - Persistence

    private var persistenceURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("pending_logs.json")
    }

    private func persistEvents() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(pendingEvents) {
            try? data.write(to: persistenceURL)
        }
    }

    private func loadPersistedEvents() {
        guard let data = try? Data(contentsOf: persistenceURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let loaded = try? decoder.decode([LogEvent].self, from: data) {
            pendingEvents = loaded
            events = loaded
        }
    }

    func clearLogs() {
        events.removeAll()
        pendingEvents.removeAll()
        try? FileManager.default.removeItem(at: persistenceURL)
    }
}

// MARK: - View Extension for Easy Logging

import SwiftUI

extension View {
    func trackScreen(_ name: String) -> some View {
        self.onAppear {
            LoggingService.shared.logNavigation(to: name)
        }
    }

    func trackTap(_ action: String, screen: String? = nil) -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            LoggingService.shared.logAction(action, screen: screen)
        })
    }
}
