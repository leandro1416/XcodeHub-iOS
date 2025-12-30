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
                                NavigationLink(destination: ProjectDetailView(project: project)) {
                                    ProjectCard(
                                        project: project,
                                        onOpen: {
                                            Task {
                                                await viewModel.openProject(project, apiClient: apiClient)
                                            }
                                        },
                                        onDelete: {
                                            viewModel.initiateDelete(project)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
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
            // First confirmation: Are you sure?
            .alert("Delete Project?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete", role: .destructive) {
                    viewModel.confirmFirstStep()
                }
            } message: {
                if let project = viewModel.projectToDelete {
                    Text("Are you sure you want to permanently delete \"\(project.name)\"?\n\nThis action cannot be undone and will remove all project files.")
                }
            }
            // Second confirmation: Type project name (2FA)
            .alert("Confirm Deletion", isPresented: $viewModel.showDeleteSecondConfirmation) {
                TextField("Type project name to confirm", text: $viewModel.deleteConfirmationText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button("Cancel", role: .cancel) {
                    viewModel.cancelDelete()
                }
                Button("Delete Permanently", role: .destructive) {
                    Task {
                        await viewModel.deleteProject(apiClient: apiClient)
                    }
                }
                .disabled(viewModel.projectToDelete?.name != viewModel.deleteConfirmationText)
            } message: {
                if let project = viewModel.projectToDelete {
                    Text("Type \"\(project.name)\" to confirm permanent deletion.")
                }
            }
            .overlay {
                if viewModel.isDeleting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Deleting...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                }
            }
        }
        .trackScreen("Projects")
    }
}

#Preview {
    ProjectsView()
        .environmentObject(WorkspaceAPIClient())
}
