import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var apiClient: WorkspaceAPIClient
    @ObservedObject var settings = SettingsManager.shared

    @State private var isTestingConnection = false
    @State private var connectionStatus: ConnectionStatus = .unknown

    enum ConnectionStatus {
        case unknown
        case connected
        case disconnected

        var icon: String {
            switch self {
            case .unknown: return "questionmark.circle"
            case .connected: return "checkmark.circle.fill"
            case .disconnected: return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .unknown: return .gray
            case .connected: return .green
            case .disconnected: return .red
            }
        }

        var text: String {
            switch self {
            case .unknown: return "Not tested"
            case .connected: return "Connected"
            case .disconnected: return "Not connected"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Use Tailscale", isOn: $settings.useTailscale)

                    HStack {
                        Text("Server URL")
                        Spacer()
                        Text(settings.serverURL)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Connection")
                } footer: {
                    Text("Enable Tailscale to connect remotely. Disable for localhost (same network).")
                }

                Section {
                    HStack {
                        Text("Status")

                        Spacer()

                        if isTestingConnection {
                            ProgressView()
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: connectionStatus.icon)
                                    .foregroundStyle(connectionStatus.color)

                                Text(connectionStatus.text)
                                    .foregroundStyle(connectionStatus.color)
                            }
                        }
                    }

                    Button(action: testConnection) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Test Connection")
                        }
                    }
                    .disabled(isTestingConnection)
                } header: {
                    Text("Server Status")
                }

                Section {
                    Button(role: .destructive, action: {
                        settings.reset()
                        connectionStatus = .unknown
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("API Port")
                        Spacer()
                        Text("9004")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Tailscale IP")
                        Spacer()
                        Text("100.75.88.8")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("XcodeHub connects to the Workspace Manager API to control Xcode projects remotely.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func testConnection() {
        isTestingConnection = true

        Task {
            let isConnected = await apiClient.checkHealth()
            connectionStatus = isConnected ? .connected : .disconnected
            isTestingConnection = false
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(WorkspaceAPIClient())
}
