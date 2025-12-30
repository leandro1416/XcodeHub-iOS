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

    // Delete functionality
    @Published var isDeleting = false
    @Published var projectToDelete: XcodeProject?
    @Published var showDeleteConfirmation = false
    @Published var showDeleteSecondConfirmation = false
    @Published var deleteConfirmationText = ""

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

    // MARK: - Delete Project

    func initiateDelete(_ project: XcodeProject) {
        projectToDelete = project
        deleteConfirmationText = ""
        showDeleteConfirmation = true
    }

    func confirmFirstStep() {
        showDeleteConfirmation = false
        showDeleteSecondConfirmation = true
    }

    func cancelDelete() {
        showDeleteConfirmation = false
        showDeleteSecondConfirmation = false
        projectToDelete = nil
        deleteConfirmationText = ""
    }

    func deleteProject(apiClient: WorkspaceAPIClient) async {
        guard let project = projectToDelete else { return }

        // Verify confirmation code matches project name
        guard deleteConfirmationText == project.name else {
            toastMessage = "Confirmation code does not match"
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            toastMessage = nil
            return
        }

        isDeleting = true

        LoggingService.shared.logAction("Deleting project: \(project.name)", screen: "Projects", details: [
            "platform": project.platform.rawValue,
            "path": project.path
        ])

        do {
            let response = try await apiClient.deleteProject(path: project.path, confirmationCode: project.name)

            if response.status == "ok" {
                // Remove from local list
                if project.platform == .iOS {
                    iosProjects.removeAll { $0.path == project.path }
                } else {
                    macosProjects.removeAll { $0.path == project.path }
                }

                toastMessage = "Deleted \(project.name) (\(response.freedHuman ?? ""))"
                LoggingService.shared.logAPI("/api/xcode/delete", success: true, details: [
                    "project": project.name,
                    "freed": response.freedHuman ?? "unknown"
                ])
            } else {
                toastMessage = response.message ?? "Failed to delete"
                LoggingService.shared.logAPI("/api/xcode/delete", success: false, details: ["message": response.message ?? "Unknown"])
            }
        } catch {
            toastMessage = "Error: \(error.localizedDescription)"
            LoggingService.shared.logError("Failed to delete project: \(error.localizedDescription)", screen: "Projects")
        }

        isDeleting = false
        showDeleteSecondConfirmation = false
        projectToDelete = nil
        deleteConfirmationText = ""

        // Clear toast after delay
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        toastMessage = nil
    }
}
