import SwiftUI

struct DiskView: View {
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @StateObject private var viewModel = DiskViewModel()

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
                        // Overview Card
                        VStack(spacing: 16) {
                            HStack {
                                Text("Workspace Usage")
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.formattedTotalDisk)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            }

                            Divider()

                            // Directory Breakdown
                            ForEach(viewModel.sortedDiskEntries, id: \.key) { key, info in
                                HStack {
                                    Image(systemName: viewModel.iconForDirectory(key))
                                        .foregroundStyle(colorForKey(viewModel.colorForDirectory(key)))
                                        .frame(width: 24)

                                    Text(key.capitalized)

                                    Spacer()

                                    Text(info.sizeHuman)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        // Cache Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Caches")
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.formattedTotalCache)
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }

                            ForEach(viewModel.sortedCacheEntries, id: \.key) { _, cache in
                                StorageCard(
                                    title: cache.name,
                                    size: cache.sizeHuman,
                                    icon: cache.icon,
                                    color: .orange
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Disk")
            .refreshable {
                await viewModel.loadData(apiClient: apiClient)
            }
            .task {
                await viewModel.loadData(apiClient: apiClient)
            }
        }
        .trackScreen("Disk")
    }

    private func colorForKey(_ key: String) -> Color {
        switch key {
        case "gray": return .gray
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        default: return .gray
        }
    }
}

#Preview {
    DiskView()
        .environmentObject(WorkspaceAPIClient())
}
