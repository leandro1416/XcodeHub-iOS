import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let serverURL = "serverURL"
        static let useTailscale = "useTailscale"
    }

    @Published var serverURL: String {
        didSet {
            defaults.set(serverURL, forKey: Keys.serverURL)
        }
    }

    @Published var useTailscale: Bool {
        didSet {
            defaults.set(useTailscale, forKey: Keys.useTailscale)
            updateServerURL()
        }
    }

    private init() {
        // Load saved settings or use defaults
        self.useTailscale = defaults.bool(forKey: Keys.useTailscale)

        if let savedURL = defaults.string(forKey: Keys.serverURL), !savedURL.isEmpty {
            self.serverURL = savedURL
        } else {
            // Default to Tailscale IP
            self.serverURL = "http://100.75.88.8:9004"
            self.useTailscale = true
        }
    }

    private func updateServerURL() {
        if useTailscale {
            serverURL = "http://100.75.88.8:9004"
        } else {
            serverURL = "http://localhost:9004"
        }
    }

    func reset() {
        useTailscale = true
        serverURL = "http://100.75.88.8:9004"
    }
}
