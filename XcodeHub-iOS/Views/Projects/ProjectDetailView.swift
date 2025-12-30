import SwiftUI

struct ProjectDetailView: View {
    let project: XcodeProject
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @State private var briefing: ProjectBriefing?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var toastMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let error = errorMessage {
                    ContentUnavailableView(
                        "Error Loading Details",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if let briefing = briefing {
                    // Header Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: project.icon)
                                .font(.largeTitle)
                                .foregroundStyle(project.platform == .iOS ? .blue : .purple)
                                .frame(width: 60, height: 60)
                                .background(
                                    (project.platform == .iOS ? Color.blue : Color.purple)
                                        .opacity(0.1)
                                )
                                .cornerRadius(14)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(briefing.name)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text(project.platform.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if briefing.hasDocs {
                                Image(systemName: "doc.text.fill")
                                    .foregroundStyle(.green)
                            }
                        }

                        Divider()

                        // Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            StatItem(value: briefing.sizeHuman, label: "Size", icon: "externaldrive.fill", color: .orange)
                            StatItem(value: "\(briefing.swiftFiles)", label: "Swift Files", icon: "swift", color: .orange)
                            StatItem(value: "\(briefing.fileCount)", label: "Total Files", icon: "doc.fill", color: .blue)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Summary Card
                    if let summary = briefing.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("About", systemImage: "info.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.blue)

                            Text(summary)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Features Card
                    if !briefing.features.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Features", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundStyle(.yellow)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(briefing.features, id: \.self) { feature in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                            .font(.caption)
                                            .padding(.top, 3)
                                        Text(feature)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Details Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Details", systemImage: "info.circle")
                            .font(.headline)
                            .foregroundStyle(.purple)

                        VStack(spacing: 8) {
                            DetailRow(label: "Last Modified", value: briefing.formattedDate)

                            if let bundleId = briefing.bundleId {
                                DetailRow(label: "Bundle ID", value: bundleId)
                            }

                            DetailRow(label: "Path", value: briefing.path, isCode: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await openInXcode()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "hammer.fill")
                                Text("Open in Xcode")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBriefing()
        }
        .toast(message: $toastMessage)
    }

    private func loadBriefing() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.getProjectBriefing(path: project.path)
            briefing = response.data
            LoggingService.shared.logAPI("/api/xcode/briefing", success: true, details: [
                "project": project.name,
                "has_docs": "\(response.data.hasDocs)"
            ])
        } catch {
            errorMessage = error.localizedDescription
            LoggingService.shared.logError("Failed to load briefing: \(error.localizedDescription)", screen: "ProjectDetail")
        }

        isLoading = false
    }

    private func openInXcode() async {
        do {
            let response = try await apiClient.openInXcode(path: project.path)
            if response.status == "ok" {
                toastMessage = "Opened in Xcode"
            } else {
                toastMessage = response.message ?? "Failed to open"
            }
        } catch {
            toastMessage = "Error: \(error.localizedDescription)"
        }

        try? await Task.sleep(nanoseconds: 2_000_000_000)
        toastMessage = nil
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isCode: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(isCode ? .caption : .subheadline)
                .fontDesign(isCode ? .monospaced : .default)
                .foregroundStyle(isCode ? .secondary : .primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(
            project: XcodeProject(
                name: "XcodeHub-iOS",
                path: "/Users/neog/Apps/iOS/XcodeHub-iOS"
            )
        )
        .environmentObject(WorkspaceAPIClient())
    }
}
