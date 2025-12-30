import Foundation

@MainActor
class WorkspaceAPIClient: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var lastError: String?

    private var baseURL: String {
        SettingsManager.shared.serverURL
    }

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Health Check

    func checkHealth() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            isConnected = false
            return false
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                isConnected = false
                return false
            }

            let health = try JSONDecoder().decode(HealthResponse.self, from: data)
            isConnected = health.status == "ok"
            lastError = nil
            return isConnected
        } catch {
            isConnected = false
            lastError = error.localizedDescription
            return false
        }
    }

    // MARK: - Projects

    func getXcodeProjects() async throws -> XcodeProjectsResponse {
        return try await get("/api/xcode/projects")
    }

    func openInXcode(path: String) async throws -> OpenXcodeResponse {
        return try await post("/api/open-xcode", body: ["path": path])
    }

    // MARK: - Disk

    func getDiskOverview() async throws -> DiskOverviewResponse {
        return try await get("/api/disk/overview")
    }

    func getCacheInfo() async throws -> CacheResponse {
        return try await get("/api/disk/cache")
    }

    // MARK: - Cleanup

    func cleanupCache(targets: [String]) async throws -> CleanupResult {
        return try await post("/api/cleanup/cache", body: ["targets": targets])
    }

    func runMonthlyCleanup(dryRun: Bool = false) async throws -> MonthlyCleanupResult {
        return try await post("/api/cleanup/monthly", body: ["dry_run": dryRun])
    }

    // MARK: - iCloud / Backups

    func getICloudStatus() async throws -> ICloudStatusResponse {
        return try await get("/api/icloud/status")
    }

    func getBackups() async throws -> BackupsResponse {
        return try await get("/api/icloud/backups")
    }

    // MARK: - Stats

    func getWorkspaceSummary() async throws -> WorkspaceSummaryResponse {
        return try await get("/api/stats/summary")
    }

    // MARK: - Generic Request Methods

    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.serverError
            }

            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch is DecodingError {
            throw APIError.decodingError
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    private func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }

            guard httpResponse.statusCode == 200 else {
                throw APIError.serverError
            }

            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch is DecodingError {
            throw APIError.decodingError
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }
}
