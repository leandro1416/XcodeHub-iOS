import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @StateObject private var viewModel = ProjectsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats
                    HStack(spacing: 12) {
                        StatBadge(value: "\(viewModel.totalCount)", label: "Total", color: .primary)
                        StatBadge(value: "\(viewModel.iosCount)", label: "iOS", color: .blue)
                        StatBadge(value: "\(viewModel.macosCount)", label: "macOS", color: .purple)
                    }
                    .padding(.horizontal)

                    // Filter
                    Picker("Platform", selection: $viewModel.selectedPlatform) {
                        ForEach(ProjectsViewModel.PlatformFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Projects Grid
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView(
                            "Connection Error",
                            systemImage: "wifi.slash",
                            description: Text(error)
                        )
                    } else if viewModel.filteredProjects.isEmpty {
                        ContentUnavailableView(
                            "No Projects Found",
                            systemImage: "folder",
                            description: Text("No projects match your search")
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.filteredProjects) { project in
                                ProjectCard(project: project) {
                                    Task {
                                        await viewModel.openProject(project, apiClient: apiClient)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Projects")
            .searchable(text: $viewModel.searchText, prompt: "Search projects...")
            .refreshable {
                await viewModel.loadProjects(apiClient: apiClient)
            }
            .task {
                await viewModel.loadProjects(apiClient: apiClient)
            }
            .toast(message: $viewModel.toastMessage)
        }
        .trackScreen("Projects")
    }
}

#Preview {
    ProjectsView()
        .environmentObject(WorkspaceAPIClient())
}
