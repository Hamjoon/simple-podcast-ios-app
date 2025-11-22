#!/usr/bin/env python3
"""
Flask API server for fetching and serving podcast RSS feed data.
Fetches from: https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml
"""

from flask import Flask, jsonify
from flask_cors import CORS
import feedparser
from datetime import datetime
import time
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# RSS feed URL
RSS_FEED_URL = "https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml"

# Simple in-memory cache
cache = {
    'episodes': None,
    'last_updated': None,
    'cache_duration': 300  # 5 minutes in seconds
}

def parse_duration(duration_str):
    """Convert duration string to HH:MM:SS format"""
    if not duration_str:
        return "00:00:00"

    try:
        # If already in correct format
        if ':' in duration_str:
            return duration_str

        # If in seconds
        seconds = int(duration_str)
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    except:
        return "00:00:00"

def fetch_rss_feed():
    """Fetch and parse the RSS feed"""
    try:
        print(f"Fetching RSS feed from {RSS_FEED_URL}...")
        feed = feedparser.parse(RSS_FEED_URL)

        if feed.bozo:
            print(f"Warning: Feed has parsing issues: {feed.bozo_exception}")

        episodes = []

        for idx, entry in enumerate(feed.entries, start=1):
            # Extract episode information
            episode = {
                'id': idx,
                'title': entry.get('title', 'Untitled Episode'),
                'description': entry.get('summary', entry.get('description', '')),
                'audioUrl': '',
                'imageUrl': '',
                'duration': '00:00:00',
                'pubDate': entry.get('published', '')
            }

            # Extract audio URL from enclosures
            if hasattr(entry, 'enclosures') and entry.enclosures:
                for enclosure in entry.enclosures:
                    if 'audio' in enclosure.get('type', ''):
                        episode['audioUrl'] = enclosure.get('href', '')
                        break

            # Fallback: check for media content
            if not episode['audioUrl'] and hasattr(entry, 'media_content'):
                for media in entry.media_content:
                    if 'audio' in media.get('type', ''):
                        episode['audioUrl'] = media.get('url', '')
                        break

            # Extract image URL
            if hasattr(entry, 'image'):
                episode['imageUrl'] = entry.image.get('href', '')
            elif hasattr(entry, 'media_thumbnail') and entry.media_thumbnail:
                episode['imageUrl'] = entry.media_thumbnail[0].get('url', '')
            elif hasattr(feed.feed, 'image'):
                episode['imageUrl'] = feed.feed.image.get('href', '')

            # Extract duration
            if hasattr(entry, 'itunes_duration'):
                episode['duration'] = parse_duration(entry.itunes_duration)

            episodes.append(episode)

        print(f"Successfully parsed {len(episodes)} episodes")
        return episodes

    except Exception as e:
        print(f"Error fetching RSS feed: {e}")
        return []

def get_cached_episodes():
    """Get episodes from cache or fetch new ones"""
    current_time = time.time()

    # Check if cache is valid
    if (cache['episodes'] is not None and
        cache['last_updated'] is not None and
        current_time - cache['last_updated'] < cache['cache_duration']):
        print("Returning cached episodes")
        return cache['episodes']

    # Fetch new data
    episodes = fetch_rss_feed()

    # Update cache
    cache['episodes'] = episodes
    cache['last_updated'] = current_time

    return episodes

@app.route('/api/episodes', methods=['GET'])
def get_episodes():
    """API endpoint to get all podcast episodes"""
    try:
        episodes = get_cached_episodes()
        return jsonify({
            'success': True,
            'episodes': episodes,
            'count': len(episodes)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/', methods=['GET'])
def index():
    """Root endpoint with API information"""
    return jsonify({
        'name': 'Simple Podcast API',
        'version': '1.0.0',
        'endpoints': {
            '/api/episodes': 'Get all podcast episodes',
            '/api/health': 'Health check'
        }
    })

if __name__ == '__main__':
    print("Starting Flask server...")
    print(f"RSS Feed URL: {RSS_FEED_URL}")
    
    # Get port from environment variable (Railway sets this) or default to 5001
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('FLASK_ENV') != 'production'
    
    app.run(host='0.0.0.0', port=port, debug=debug)