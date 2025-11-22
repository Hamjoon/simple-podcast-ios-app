# Simple Podcast Web Player

A podcast web application for "김혜리의 필름클럽" (Kim Hye-ri's Film Club) with a Python Flask backend API that fetches episodes from an external RSS feed.

## Architecture

### Frontend (Static Web App)
- **index.html** - Main UI structure
- **styles.css** - Responsive styling with gradient design
- **app.js** - JavaScript application logic with API integration

### Backend (Flask API Server)
- **server.py** - Flask API server that fetches and parses RSS feed
- Fetches from: `https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml`
- Provides REST API at `http://localhost:5001/api/episodes`
- Includes 5-minute caching to reduce external requests

## Setup and Installation

### Prerequisites
- Python 3.7 or higher
- A web browser

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

This installs:
- Flask - Web framework
- flask-cors - CORS support for API
- feedparser - RSS feed parsing

### 2. Start the API Server

```bash
python server.py
```

The server will start on `http://localhost:5001`

You should see:
```
Starting Flask server...
RSS Feed URL: https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml
 * Running on http://0.0.0.0:5001
```

### 3. Open the Frontend

Open `index.html` in your web browser:

**Option 1: Direct file access**
```bash
open index.html
```

**Option 2: Using a local server (recommended to avoid CORS issues)**
```bash
# Python
python -m http.server 8000

# or Node.js
npx serve
```

Then visit `http://localhost:8000` in your browser.

## API Endpoints

### GET /api/episodes
Returns all podcast episodes from the RSS feed.

**Response:**
```json
{
  "success": true,
  "episodes": [
    {
      "id": 1,
      "title": "Episode Title",
      "description": "Episode description",
      "audioUrl": "http://...",
      "imageUrl": "http://...",
      "duration": "01:30:00",
      "pubDate": "Mon, 18 Nov 2024 00:00:00 GMT"
    }
  ],
  "count": 10
}
```

### GET /api/health
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-11-22T10:30:00"
}
```

## Features

- **Live RSS Feed** - Episodes are fetched from the external SBS RSS feed
- **Auto-refresh** - Backend caches data for 5 minutes, then refetches
- **Auto-play Next** - Automatically plays next episode when current ends
- **Responsive Design** - Works on desktop and mobile devices
- **Visual Feedback** - Highlights currently playing episode

## Troubleshooting

### "Unable to connect to the server"
- Make sure the Flask server is running (`python server.py`)
- Check that the server is accessible at `http://localhost:5001`

### CORS Errors
- The Flask server has CORS enabled
- If using file:// protocol, serve the frontend via HTTP instead (use `python -m http.server`)

### No Episodes Loading
- Check the Flask server console for error messages
- Verify the RSS feed URL is accessible
- The server will log fetching attempts and parsing results

## Development

### Modifying the RSS Feed Source
Edit `server.py` line 15:
```python
RSS_FEED_URL = "your-rss-feed-url-here"
```

### Adjusting Cache Duration
Edit `server.py` line 21:
```python
'cache_duration': 300  # Change seconds here
```

### Changing API Port
Edit `server.py` line 162 and `app.js` line 2:
```python
# server.py
app.run(host='0.0.0.0', port=5001, debug=True)
```
```javascript
// app.js
const API_BASE_URL = 'http://localhost:5001';
```

**Note:** Port 5000 is often used by AirPlay Receiver on macOS, so we use port 5001 by default.

## Deployment

### Deploy to Railway.app

For production deployment with 24/7 availability, see **[DEPLOYMENT.md](DEPLOYMENT.md)** for detailed Railway.app deployment instructions.

**Quick steps:**
1. Push code to GitHub
2. Connect GitHub repo to Railway.app
3. Railway auto-deploys with `Procfile` and `railway.json`
4. Update `app.js` with your Railway URL

Railway provides:
- Free $5 monthly credit (~500 hours)
- Automatic HTTPS
- Auto-deploy on git push
- Built-in monitoring and logs
