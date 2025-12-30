import Foundation

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var iosProjects: [XcodeProject] = []
    @Published var macosProjects: [XcodeProject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedPlatform: PlatformFilter = .all
    @Published var toastMessage: String?

    enum PlatformFilter: String, CaseIterable {
        case all = "All"
        case ios = "iOS"
        case macos = "macOS"
    }

    var filteredProjects: [XcodeProject] {
        var projects: [XcodeProject]

        switch selectedPlatform {
        case .all:
            projects = iosProjects + macosProjects
        case .ios:
            projects = iosProjects
        case .macos:
            projects = macosProjects
        }

        if searchText.isEmpty {
            return projects.sorted { $0.name < $1.name }
        }

        return projects.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.name < $1.name }
    }

    var totalCount: Int { iosProjects.count + macosProjects.count }
    var iosCount: Int { iosProjects.count }
    var macosCount: Int { macosProjects.count }

    func loadProjects(apiClient: WorkspaceAPIClient) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.getXcodeProjects()
            iosProjects = response.data.ios
            macosProjects = response.data.macos
            LoggingService.shared.logAPI("/api/xcode/projects", success: true, details: [
                "ios_count": "\(response.counts.ios)",
                "macos_count": "\(response.counts.macos)"
            ])
        } catch {
            errorMessage = error.localizedDescription
            LoggingService.shared.logAPI("/api/xcode/projects", success: false, details: ["error": error.localizedDescription])
        }

        isLoading = false
    }

    func openProject(_ project: XcodeProject, apiClient: WorkspaceAPIClient) async {
        LoggingService.shared.logAction("Opening project: \(project.name)", screen: "Projects", details: [
            "platform": project.platform.rawValue,
            "path": project.path
        ])

        do {
            let response = try await apiClient.openInXcode(path: project.path)
            if response.status == "ok" {
                toastMessage = "Opened \(project.name) in Xcode"
                LoggingService.shared.logAPI("/api/open-xcode", success: true, details: ["project": project.name])
            } else {
                toastMessage = response.message ?? "Failed to open"
                LoggingService.shared.logAPI("/api/open-xcode", success: false, details: ["message": response.message ?? "Unknown"])
            }
        } catch {
            toastMessage = "Error: \(error.localizedDescription)"
            LoggingService.shared.logError("Failed to open project: \(error.localizedDescription)", screen: "Projects")
        }

        // Clear toast after delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        toastMessage = nil
    }
}
