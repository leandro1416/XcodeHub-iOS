import Foundation

@MainActor
class CleanupViewModel: ObservableObject {
    @Published var cacheInfo: [String: CacheInfo] = [:]
    @Published var isLoading = false
    @Published var isCleaning = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showConfirmation = false
    @Published var selectedTargets: Set<CleanupTarget> = []
    @Published var lastCleanupResult: CleanupResult?

    var canClean: Bool {
        !selectedTargets.isEmpty && !isCleaning
    }

    func loadCacheInfo(apiClient: WorkspaceAPIClient) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.getCacheInfo()
            cacheInfo = response.data
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func toggleTarget(_ target: CleanupTarget) {
        if selectedTargets.contains(target) {
            selectedTargets.remove(target)
        } else {
            selectedTargets.insert(target)
        }
    }

    func selectAll() {
        selectedTargets = Set(CleanupTarget.allCases)
    }

    func deselectAll() {
        selectedTargets.removeAll()
    }

    func runCleanup(apiClient: WorkspaceAPIClient) async {
        guard canClean else { return }

        isCleaning = true
        errorMessage = nil
        successMessage = nil

        let targets = selectedTargets.map { $0.rawValue }
        LoggingService.shared.logAction("Starting cleanup", screen: "Cleanup", details: ["targets": targets.joined(separator: ", ")])

        do {
            let result = try await apiClient.cleanupCache(targets: targets)
            lastCleanupResult = result

            if result.status == "ok" {
                successMessage = "Freed \(result.totalFreedHuman ?? "some space")"
                LoggingService.shared.logAPI("/api/cleanup/cache", success: true, details: ["freed": result.totalFreedHuman ?? "0"])
            } else {
                errorMessage = "Cleanup completed with issues"
                LoggingService.shared.logAPI("/api/cleanup/cache", success: false)
            }

            // Refresh cache info
            await loadCacheInfo(apiClient: apiClient)
        } catch {
            errorMessage = error.localizedDescription
            LoggingService.shared.logError("Cleanup failed: \(error.localizedDescription)", screen: "Cleanup")
        }

        isCleaning = false
        selectedTargets.removeAll()
    }

    func runMonthlyCleanup(apiClient: WorkspaceAPIClient, dryRun: Bool) async {
        isCleaning = true
        errorMessage = nil
        successMessage = nil

        do {
            let result = try await apiClient.runMonthlyCleanup(dryRun: dryRun)

            if result.status == "ok" {
                if dryRun {
                    successMessage = "Dry run completed - no changes made"
                } else {
                    successMessage = "Monthly cleanup completed"
                }
            } else {
                errorMessage = result.error ?? "Cleanup failed"
            }

            // Refresh cache info
            await loadCacheInfo(apiClient: apiClient)
        } catch {
            errorMessage = error.localizedDescription
        }

        isCleaning = false
    }
}
