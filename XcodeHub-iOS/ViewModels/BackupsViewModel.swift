import Foundation

@MainActor
class BackupsViewModel: ObservableObject {
    @Published var icloudStatus: ICloudStatus?
    @Published var backups: [Backup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isConnectedToICloud: Bool {
        icloudStatus?.syncActive ?? false
    }

    var accountEmail: String {
        icloudStatus?.accountId ?? "Not signed in"
    }

    var totalBackupSize: String {
        icloudStatus?.backupsSizeHuman ?? "0 B"
    }

    var backupCount: Int {
        backups.count
    }

    var sortedBackups: [Backup] {
        backups.sorted { ($0.modifiedDate ?? Date.distantPast) > ($1.modifiedDate ?? Date.distantPast) }
    }

    func loadData(apiClient: WorkspaceAPIClient) async {
        isLoading = true
        errorMessage = nil

        do {
            async let statusResponse = apiClient.getICloudStatus()
            async let backupsResponse = apiClient.getBackups()

            let (status, backupsList) = try await (statusResponse, backupsResponse)
            icloudStatus = status.data
            backups = backupsList.data.backups

            LoggingService.shared.logAPI("/api/icloud/status", success: true, details: [
                "account": status.data.accountId ?? "unknown",
                "sync": status.data.syncActive ? "active" : "inactive"
            ])
            LoggingService.shared.logAPI("/api/icloud/backups", success: true, details: [
                "count": "\(backupsList.data.backups.count)",
                "size": status.data.backupsSizeHuman ?? "0"
            ])
        } catch {
            errorMessage = error.localizedDescription
            LoggingService.shared.logError("Failed to load iCloud data: \(error.localizedDescription)", screen: "Backups")
        }

        isLoading = false
    }
}
