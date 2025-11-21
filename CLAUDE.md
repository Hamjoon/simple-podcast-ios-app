# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A simple, static podcast web application built with vanilla HTML, CSS, and JavaScript. The app features hardcoded podcast episode data and uses the native HTML `<audio>` element for playback.

## Architecture

### Core Components

- **index.html**: Main application structure with player UI and episode list
- **styles.css**: Responsive styling with gradient background and modern card-based design
- **app.js**: Application logic, state management, and podcast data

### Data Structure

Podcast episodes are stored as a hardcoded JavaScript object in `app.js`:
- Each episode contains: `id`, `title`, `description`, `audioUrl`, `imageUrl`, `duration`
- The `podcastData` object is the single source of truth for all episode information

### State Management

Simple state tracking via `currentEpisode` variable (app.js:32):
- Tracks currently playing episode
- Used for auto-play next feature
- Updates UI active states

### Key Functionality

- **Episode Rendering**: `renderEpisodes()` dynamically generates episode list from data (app.js:43)
- **Playback Control**: `playEpisode()` handles audio source switching and UI updates (app.js:66)
- **Auto-Play**: Event listener on audio element advances to next episode on completion (app.js:90)

## Running the Application

This is a static web application with no build process required.

**Development:**
```bash
# Serve locally (any static file server works)
python -m http.server 8000
# or
npx serve
```

Then open `http://localhost:8000` in a browser.

**Production:**
Simply open `index.html` directly in a browser, or deploy all three files to any static hosting service.

## Modifying Podcast Data

To add/edit episodes, modify the `podcastData` object in `app.js` (lines 2-31):
```javascript
const podcastData = {
    episodes: [
        {
            id: 1,
            title: "Episode Title",
            description: "Episode description",
            audioUrl: "path/to/audio.mp3",
            imageUrl: "path/to/image.jpg",
            duration: "45:30"
        }
        // ... more episodes
    ]
};
```

## Styling Customization

Main theme colors defined in `styles.css`:
- Background gradient: `#667eea` to `#764ba2` (line 9)
- Active episode highlight: `#667eea` (line 113)
- Modify these for different color schemes
