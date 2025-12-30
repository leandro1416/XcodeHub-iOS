import SwiftUI

struct BackupsView: View {
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @StateObject private var viewModel = BackupsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView(
                            "Connection Error",
                            systemImage: "wifi.slash",
                            description: Text(error)
                        )
                    } else {
                        // iCloud Status Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "icloud.fill")
                                    .font(.title)
                                    .foregroundStyle(viewModel.isConnectedToICloud ? .blue : .gray)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("iCloud Drive")
                                        .font(.headline)

                                    Text(viewModel.isConnectedToICloud ? "Connected" : "Not Connected")
                                        .font(.caption)
                                        .foregroundStyle(viewModel.isConnectedToICloud ? .green : .red)
                                }

                                Spacer()

                                Image(systemName: viewModel.isConnectedToICloud ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(viewModel.isConnectedToICloud ? .green : .red)
                            }

                            Divider()

                            StatRow(
                                label: "Account",
                                value: viewModel.accountEmail,
                                icon: "person.circle",
                                color: .blue
                            )

                            StatRow(
                                label: "Total Backup Size",
                                value: viewModel.totalBackupSize,
                                icon: "externaldrive.fill.badge.icloud",
                                color: .orange
                            )

                            StatRow(
                                label: "Backups",
                                value: "\(viewModel.backupCount)",
                                icon: "folder.fill",
                                color: .green
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Backups List
                        if !viewModel.backups.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Workspace Backups")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(viewModel.sortedBackups) { backup in
                                    BackupCard(backup: backup)
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            ContentUnavailableView(
                                "No Backups",
                                systemImage: "folder.badge.questionmark",
                                description: Text("No workspace backups found in iCloud Drive")
                            )
                            .padding(.top, 30)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Backups")
            .refreshable {
                await viewModel.loadData(apiClient: apiClient)
            }
            .task {
                await viewModel.loadData(apiClient: apiClient)
            }
        }
        .trackScreen("Backups")
    }
}

struct BackupCard: View {
    let backup: Backup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.blue)

                Text(backup.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                Text(backup.sizeHuman)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(backup.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    BackupsView()
        .environmentObject(WorkspaceAPIClient())
}
