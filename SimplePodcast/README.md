# Simple Podcast iOS App

iOS native implementation of the Simple Podcast web application, built with SwiftUI.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Project Structure

```
SimplePodcast/
├── App/
│   └── SimplePodcastApp.swift      # App entry point
├── Models/
│   └── Episode.swift               # Data models
├── Views/
│   ├── ContentView.swift           # Main container view
│   ├── PlayerView.swift            # Audio player controls
│   ├── EpisodeListView.swift       # Episodes list
│   ├── EpisodeRowView.swift        # Single episode row
│   └── SleepTimerView.swift        # Sleep timer controls
├── ViewModels/
│   └── PodcastViewModel.swift      # Main view model
├── Services/
│   ├── APIService.swift            # Network layer
│   └── AudioPlayerService.swift    # AVPlayer wrapper
├── Utilities/
│   └── SleepTimerManager.swift     # Sleep timer logic
└── Resources/
    └── Assets.xcassets             # App assets
```

## Features

- Episode list fetched from REST API
- Audio playback with AVPlayer
- Background audio support
- Lock screen controls (play/pause, skip)
- Sleep timer with preset options (15, 30, 45, 60 minutes)
- Auto-play next episode
- Now Playing info integration

## Building the App

1. Open `SimplePodcast.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Choose a simulator or device
4. Build and run (Cmd + R)

## API Configuration

The app connects to the backend API at:
```
https://simple-podcast-production.up.railway.app/api/episodes
```

To change the API endpoint, modify `APIService.swift`:
```swift
private let baseURL = "YOUR_API_URL"
```

## Architecture

- **MVVM Pattern**: Views observe ViewModels, which coordinate with Services
- **SwiftUI**: Declarative UI framework
- **Combine**: Reactive programming for state management
- **Swift Concurrency**: async/await for network calls

## Key Components

### AudioPlayerService
Singleton service managing audio playback using AVPlayer. Handles:
- Play/pause/stop controls
- Seek and skip functionality
- Progress tracking
- Now Playing info updates
- Remote command handling

### SleepTimerManager
Manages sleep timer functionality with:
- Preset time intervals
- Countdown display
- Auto-pause on completion
- Local notifications

### PodcastViewModel
Main view model coordinating:
- Episode fetching
- Playback control delegation
- Auto-play next episode logic
