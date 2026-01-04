# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A simple iOS podcast application for "김혜리의 필름클럽(film-club), 라디오 북클럽(radio-book-club), 서담서담(seodam)".
The app fetches podcast episodes from an external RSS feed and provides audio playback functionality.

## Architecture

### Target Platform
- iOS 15.0+
- Swift 5.0+
- SwiftUI for UI components

### Core Components (To Be Implemented)

- **Models/Episode.swift**: Data model for podcast episodes
- **Services/RSSService.swift**: RSS feed fetching and parsing
- **Views/**: SwiftUI views for player UI and episode list
- **ViewModels/**: State management with ObservableObject

### Data Source

Podcast episodes are fetched from the SBS RSS feed:
- URL(film-club): `https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml`
- URL(radio-book-club): `https://minicast.imbc.com/PodCast/pod.aspx?code=1000698100000100000`
- URL(seodam): `https://minicast.imbc.com/PodCast/pod.aspx?code=1004084100000100000`
- Contains episode metadata: title, description, audio URL, image URL, duration, publish date

### Key Features

- RSS feed parsing and episode listing
- Audio playback with AVFoundation
- Background audio support
- Auto-play next episode
- Episode progress tracking

## Development

### Prerequisites
- Xcode 15.0+
- iOS 15.0+ device or simulator

### Build Commands
```bash
# Build the project
xcodebuild -scheme SimplePodcast -configuration Debug build

# Run tests
xcodebuild test -scheme SimplePodcast -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Backend API (Legacy)

A Flask backend server exists in this repository for serving episodes via REST API. This is maintained separately and may be moved to a different project in the future.

- **server.py**: Flask API server
- **requirements.txt**: Python dependencies
- See **DEPLOYMENT.md** for deployment instructions
