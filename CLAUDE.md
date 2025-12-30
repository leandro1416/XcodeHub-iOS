# XcodeHub-iOS

Remote control app for managing Xcode projects, disk usage, cleanup operations, and iCloud backups from iOS.

## Overview

- **Platform:** iOS 17+
- **Architecture:** MVVM + SwiftUI
- **Backend:** Workspace Manager API (port 9004)
- **Bundle ID:** `com.neog.XcodeHub`

## Project Structure

```
XcodeHub-iOS/
├── XcodeHub-iOS/
│   ├── XcodeHubApp.swift          # App entry point
│   ├── MainTabView.swift          # 6-tab navigation
│   ├── Info.plist                 # ATS exceptions for HTTP
│   │
│   ├── Models/
│   │   ├── XcodeProject.swift     # Project model + API response
│   │   ├── DiskInfo.swift         # Disk/cache info models
│   │   ├── CleanupResult.swift    # Cleanup results + targets enum
│   │   ├── Backup.swift           # iCloud backup models
│   │   ├── WorkspaceSummary.swift # Stats + API errors
│   │   └── LogEvent.swift         # Logging event model
│   │
│   ├── Services/
│   │   ├── WorkspaceAPIClient.swift  # Async/await API client
│   │   ├── SettingsManager.swift     # UserDefaults wrapper
│   │   └── LoggingService.swift      # Real-time event logging
│   │
│   ├── ViewModels/
│   │   ├── ProjectsViewModel.swift   # Projects list + filtering
│   │   ├── DiskViewModel.swift       # Disk usage data
│   │   ├── CleanupViewModel.swift    # Cache cleanup logic
│   │   └── BackupsViewModel.swift    # iCloud backups
│   │
│   ├── Views/
│   │   ├── Projects/
│   │   │   ├── ProjectsView.swift    # Projects grid
│   │   │   └── ProjectCard.swift     # Project card component
│   │   ├── Disk/
│   │   │   └── DiskView.swift        # Disk overview
│   │   ├── Cleanup/
│   │   │   └── CleanupView.swift     # Cleanup actions
│   │   ├── Backups/
│   │   │   └── BackupsView.swift     # iCloud status + backups
│   │   ├── Logs/
│   │   │   └── LogsView.swift        # Real-time logs viewer
│   │   └── Settings/
│   │       └── SettingsView.swift    # Server configuration
│   │
│   ├── Components/
│   │   ├── StorageCard.swift         # Storage info card
│   │   ├── StatRow.swift             # Stat row + badge
│   │   ├── ToastView.swift           # Toast notifications
│   │   └── ProgressRing.swift        # Circular progress
│   │
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/       # Blue/purple gradient icon
│
└── XcodeHub-iOS.xcodeproj/
```

## API Endpoints

Backend: `http://100.75.88.8:9004` (Tailscale) or `http://localhost:9004`

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/xcode/projects` | GET | List all iOS/macOS projects |
| `/api/open-xcode` | POST | Open project in Xcode |
| `/api/disk/overview` | GET | Disk usage by directory |
| `/api/disk/cache` | GET | Cache sizes (npm, pip, system) |
| `/api/cleanup/cache` | POST | Clean selected caches |
| `/api/cleanup/monthly` | POST | Run monthly cleanup script |
| `/api/icloud/status` | GET | iCloud connection status |
| `/api/icloud/backups` | GET | List workspace backups |
| `/api/logs/batch` | POST | Receive app logs |
| `/api/logs` | GET | Get stored logs |

## App Features

### 1. Projects Tab
- Grid of 55 Xcode projects (25 iOS, 30 macOS)
- Filter by platform (All/iOS/macOS)
- Search by name
- "Open in Xcode" button on each card
- Pull-to-refresh

### 2. Disk Tab
- Workspace usage overview
- Directory breakdown with sizes
- Cache list with sizes

### 3. Cleanup Tab
- Select caches to clean: `xcode`, `npm`, `pip`, `system`
- Confirmation dialog before deletion
- Monthly cleanup with dry-run option
- Shows freed space after cleanup

### 4. Backups Tab
- iCloud connection status
- Account email
- Total backup size
- List of workspace backups with dates

### 5. Logs Tab
- Real-time event viewer
- Filter by category (navigation, action, api, error, lifecycle)
- Search functionality
- Send to server / Clear options

### 6. Settings Tab
- Server URL configuration
- Test Connection button
- App version info

## Logging System

Events are captured and sent to server in batches:

```swift
// Categories
.navigation  // Screen changes
.action      // User interactions
.api         // API calls (success/failure)
.error       // Errors
.lifecycle   // App lifecycle events

// Usage
LoggingService.shared.logAction("Opening project", screen: "Projects")
LoggingService.shared.logAPI("/api/endpoint", success: true)
LoggingService.shared.logError("Failed to load", screen: "Backups")

// View modifier
.trackScreen("ScreenName")
```

## Network Configuration

App Transport Security exceptions in `Info.plist`:
- `100.75.88.8` (Tailscale IP)
- `localhost`
- `127.0.0.1`

Default server: `http://100.75.88.8:9004`

## Build & Run

```bash
# Build for simulator
cd ~/Apps/iOS/XcodeHub-iOS
xcodebuild -scheme XcodeHub-iOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for device (requires signing)
xcodebuild -scheme XcodeHub-iOS -destination 'id=DEVICE_UUID'

# Install on device
xcrun devicectl device install app --device DEVICE_UUID path/to/XcodeHub.app

# Launch on device
xcrun devicectl device process launch --device DEVICE_UUID com.neog.XcodeHub
```

## Dependencies

- No external dependencies
- Uses only Apple frameworks (SwiftUI, Foundation, UIKit)

## Related Files

- **Backend API:** `~/Services/servers/workspace-manager-api.py`
- **Web Dashboard:** `~/Web/tools/xcode-projects-hub.html`
- **Start API:** `~/Scripts/system/start-workspace-api.sh`

## Common Tasks

### Add new API endpoint
1. Add method to `WorkspaceAPIClient.swift`
2. Create response model in `Models/`
3. Update ViewModel to call the API
4. Add logging with `LoggingService.shared.logAPI()`

### Add new View
1. Create View in `Views/` folder
2. Create ViewModel in `ViewModels/`
3. Add `.trackScreen("Name")` modifier
4. Add tab in `MainTabView.swift`
5. Update `project.pbxproj` with new files

### Debug network issues
1. Check API is running: `curl http://100.75.88.8:9004/health`
2. Check ATS exceptions in `Info.plist`
3. View logs in Logs tab or: `curl http://100.75.88.8:9004/api/logs`
