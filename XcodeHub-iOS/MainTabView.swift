import SwiftUI

struct MainTabView: View {
    @StateObject private var apiClient = WorkspaceAPIClient()
    @State private var selectedTab = 0

    private let tabNames = ["Projects", "Disk", "Cleanup", "Backups", "Logs", "Settings"]

    var body: some View {
        TabView(selection: $selectedTab) {
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
                .tag(0)

            DiskView()
                .tabItem {
                    Label("Disk", systemImage: "internaldrive")
                }
                .tag(1)

            CleanupView()
                .tabItem {
                    Label("Cleanup", systemImage: "trash")
                }
                .tag(2)

            BackupsView()
                .tabItem {
                    Label("Backups", systemImage: "icloud")
                }
                .tag(3)

            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "doc.text")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(5)
        }
        .environmentObject(apiClient)
        .onChange(of: selectedTab) { _, newTab in
            LoggingService.shared.logAction("Tab changed to \(tabNames[newTab])", screen: "MainTabView")
        }
        .task {
            LoggingService.shared.logLifecycle("App launched")
            _ = await apiClient.checkHealth()
        }
    }
}

#Preview {
    MainTabView()
}
