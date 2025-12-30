import SwiftUI

struct CleanupView: View {
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @StateObject private var viewModel = CleanupViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading && viewModel.cacheInfo.isEmpty {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        alertSection(message: error, type: .error)
                    } else {
                        // Success Message
                        if let success = viewModel.successMessage {
                            alertSection(message: success, type: .success)
                        }

                        // Cache Targets Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Select Caches to Clean")
                                    .font(.headline)

                                Spacer()

                                if viewModel.selectedTargets.isEmpty {
                                    Button("Select All") {
                                        viewModel.selectAll()
                                    }
                                    .font(.subheadline)
                                } else {
                                    Button("Deselect All") {
                                        viewModel.deselectAll()
                                    }
                                    .font(.subheadline)
                                }
                            }

                            ForEach(CleanupTarget.allCases) { target in
                                CleanupTargetRow(
                                    target: target,
                                    cacheInfo: viewModel.cacheInfo[target.rawValue],
                                    isSelected: viewModel.selectedTargets.contains(target)
                                ) {
                                    viewModel.toggleTarget(target)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Clean Button
                        Button(action: {
                            viewModel.showConfirmation = true
                        }) {
                            HStack {
                                if viewModel.isCleaning {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "trash")
                                }
                                Text(viewModel.isCleaning ? "Cleaning..." : "Clean Selected")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canClean ? Color.red : Color.gray)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.canClean)
                        .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)

                        // Monthly Cleanup Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Monthly Cleanup")
                                .font(.headline)

                            Text("Runs comprehensive cleanup including temp files, old logs, and development caches.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Button(action: {
                                    Task {
                                        await viewModel.runMonthlyCleanup(apiClient: apiClient, dryRun: true)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "eye")
                                        Text("Dry Run")
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .cornerRadius(10)
                                }
                                .disabled(viewModel.isCleaning)

                                Button(action: {
                                    Task {
                                        await viewModel.runMonthlyCleanup(apiClient: apiClient, dryRun: false)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text("Run")
                                    }
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .foregroundStyle(.orange)
                                    .cornerRadius(10)
                                }
                                .disabled(viewModel.isCleaning)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Cleanup")
            .refreshable {
                await viewModel.loadCacheInfo(apiClient: apiClient)
            }
            .task {
                await viewModel.loadCacheInfo(apiClient: apiClient)
            }
            .confirmationDialog(
                "Confirm Cleanup",
                isPresented: $viewModel.showConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clean Selected Caches", role: .destructive) {
                    Task {
                        await viewModel.runCleanup(apiClient: apiClient)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the selected caches. This action cannot be undone.")
            }
        }
        .trackScreen("Cleanup")
    }

    @ViewBuilder
    private func alertSection(message: String, type: ToastView.ToastType) -> some View {
        HStack {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)

            Text(message)
                .font(.subheadline)

            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CleanupTargetRow: View {
    let target: CleanupTarget
    let cacheInfo: CacheInfo?
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .gray)

                Image(systemName: target.icon)
                    .font(.title3)
                    .foregroundStyle(colorForTarget(target.color))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(target.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    if let info = cacheInfo {
                        Text(info.sizeHuman)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.05) : Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func colorForTarget(_ key: String) -> Color {
        switch key {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        default: return .gray
        }
    }
}

#Preview {
    CleanupView()
        .environmentObject(WorkspaceAPIClient())
}
