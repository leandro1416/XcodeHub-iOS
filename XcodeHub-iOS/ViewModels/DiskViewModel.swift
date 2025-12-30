import Foundation

@MainActor
class DiskViewModel: ObservableObject {
    @Published var diskInfo: [String: DiskInfo] = [:]
    @Published var cacheInfo: [String: CacheInfo] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    var sortedDiskEntries: [(key: String, value: DiskInfo)] {
        diskInfo.sorted { $0.value.sizeBytes > $1.value.sizeBytes }
    }

    var sortedCacheEntries: [(key: String, value: CacheInfo)] {
        cacheInfo.sorted { $0.value.sizeBytes > $1.value.sizeBytes }
    }

    var totalDiskUsage: Int64 {
        diskInfo.values.reduce(0) { $0 + $1.sizeBytes }
    }

    var totalCacheSize: Int64 {
        cacheInfo.values.reduce(0) { $0 + $1.sizeBytes }
    }

    var formattedTotalDisk: String {
        ByteCountFormatter.string(fromByteCount: totalDiskUsage, countStyle: .file)
    }

    var formattedTotalCache: String {
        ByteCountFormatter.string(fromByteCount: totalCacheSize, countStyle: .file)
    }

    func loadData(apiClient: WorkspaceAPIClient) async {
        isLoading = true
        errorMessage = nil

        do {
            async let diskResponse = apiClient.getDiskOverview()
            async let cacheResponse = apiClient.getCacheInfo()

            let (disk, cache) = try await (diskResponse, cacheResponse)
            diskInfo = disk.data
            cacheInfo = cache.data
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func iconForDirectory(_ name: String) -> String {
        switch name.lowercased() {
        case "archive": return "archivebox"
        case "apps": return "app.badge"
        case "web": return "globe"
        case "projects": return "folder"
        case "services": return "server.rack"
        case "scripts": return "terminal"
        default: return "folder"
        }
    }

    func colorForDirectory(_ name: String) -> String {
        switch name.lowercased() {
        case "archive": return "gray"
        case "apps": return "blue"
        case "web": return "green"
        case "projects": return "orange"
        case "services": return "purple"
        case "scripts": return "yellow"
        default: return "gray"
        }
    }
}
