#!/usr/bin/env python3
"""
Flask API server for fetching and serving podcast RSS feed data.
Supports multiple podcasts with caching.
"""

from flask import Flask, jsonify
from flask_cors import CORS
import feedparser
from datetime import datetime
import time
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Podcast configurations
PODCASTS = {
    'film-club': {
        'name': '필름클럽',
        'subtitle': '김혜리의 필름클럽',
        'rss_url': 'https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml'
    },
    'taste-of-travel': {
        'name': '여행의 맛',
        'subtitle': '노중훈의 여행의 맛',
        'rss_url': 'https://minicast.imbc.com/PodCast/pod.aspx?code=1000621100000100000'
    },
    'seodam': {
        'name': '서담서담',
        'subtitle': '책으로 읽는 내 마음',
        'rss_url': 'https://minicast.imbc.com/PodCast/pod.aspx?code=1004084100000100000'
    }
}

# Simple in-memory cache (per podcast)
cache = {
    podcast_id: {
        'episodes': None,
        'last_updated': None,
        'cache_duration': 300  # 5 minutes in seconds
    }
    for podcast_id in PODCASTS.keys()
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

def fetch_rss_feed(podcast_id):
    """Fetch and parse the RSS feed for a specific podcast"""
    if podcast_id not in PODCASTS:
        return []

    rss_url = PODCASTS[podcast_id]['rss_url']

    try:
        print(f"Fetching RSS feed for {podcast_id} from {rss_url}...")
        feed = feedparser.parse(rss_url)

        if feed.bozo:
            print(f"Warning: Feed has parsing issues: {feed.bozo_exception}")

        episodes = []

        # Get channel image URL as fallback
        channel_image_url = ''
        if hasattr(feed.feed, 'image') and hasattr(feed.feed.image, 'href'):
            channel_image_url = feed.feed.image.href
        elif hasattr(feed.feed, 'itunes_image'):
            channel_image_url = feed.feed.itunes_image.get('href', '')

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

            # Clean HTML from description
            if episode['description']:
                import re
                episode['description'] = re.sub('<[^<]+?>', '', episode['description']).strip()

            # Extract audio URL from enclosures
            if hasattr(entry, 'enclosures') and entry.enclosures:
                for enclosure in entry.enclosures:
                    enc_type = enclosure.get('type', '')
                    if 'audio' in enc_type or enc_type == '':
                        episode['audioUrl'] = enclosure.get('href', enclosure.get('url', ''))
                        if episode['audioUrl']:
                            break

            # Fallback: check for media content
            if not episode['audioUrl'] and hasattr(entry, 'media_content'):
                for media in entry.media_content:
                    if 'audio' in media.get('type', ''):
                        episode['audioUrl'] = media.get('url', '')
                        break

            # Extract image URL
            if hasattr(entry, 'itunes_image'):
                episode['imageUrl'] = entry.itunes_image.get('href', '')
            elif hasattr(entry, 'image'):
                episode['imageUrl'] = entry.image.get('href', '')
            elif hasattr(entry, 'media_thumbnail') and entry.media_thumbnail:
                episode['imageUrl'] = entry.media_thumbnail[0].get('url', '')

            # Use channel image as fallback
            if not episode['imageUrl']:
                episode['imageUrl'] = channel_image_url

            # Extract duration
            if hasattr(entry, 'itunes_duration'):
                episode['duration'] = parse_duration(entry.itunes_duration)

            episodes.append(episode)

        print(f"Successfully parsed {len(episodes)} episodes for {podcast_id}")
        return episodes

    except Exception as e:
        print(f"Error fetching RSS feed for {podcast_id}: {e}")
        return []

def get_cached_episodes(podcast_id):
    """Get episodes from cache or fetch new ones"""
    if podcast_id not in cache:
        return []

    current_time = time.time()
    podcast_cache = cache[podcast_id]

    # Check if cache is valid
    if (podcast_cache['episodes'] is not None and
        podcast_cache['last_updated'] is not None and
        current_time - podcast_cache['last_updated'] < podcast_cache['cache_duration']):
        print(f"Returning cached episodes for {podcast_id}")
        return podcast_cache['episodes']

    # Fetch new data
    episodes = fetch_rss_feed(podcast_id)

    # Update cache
    podcast_cache['episodes'] = episodes
    podcast_cache['last_updated'] = current_time

    return episodes

@app.route('/api/podcasts', methods=['GET'])
def get_podcasts():
    """API endpoint to get list of available podcasts"""
    podcasts = [
        {
            'id': podcast_id,
            'name': config['name'],
            'subtitle': config['subtitle']
        }
        for podcast_id, config in PODCASTS.items()
    ]
    return jsonify({
        'success': True,
        'podcasts': podcasts
    })

@app.route('/api/episodes/<podcast_id>', methods=['GET'])
def get_episodes_by_podcast(podcast_id):
    """API endpoint to get episodes for a specific podcast"""
    if podcast_id not in PODCASTS:
        return jsonify({
            'success': False,
            'error': f'Unknown podcast: {podcast_id}'
        }), 404

    try:
        episodes = get_cached_episodes(podcast_id)
        return jsonify({
            'success': True,
            'podcast': {
                'id': podcast_id,
                'name': PODCASTS[podcast_id]['name'],
                'subtitle': PODCASTS[podcast_id]['subtitle']
            },
            'episodes': episodes,
            'count': len(episodes)
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/episodes', methods=['GET'])
def get_episodes():
    """API endpoint to get all podcast episodes (default: film-club for backwards compatibility)"""
    try:
        episodes = get_cached_episodes('film-club')
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
        'version': '2.0.0',
        'endpoints': {
            '/api/podcasts': 'Get list of available podcasts',
            '/api/episodes/<podcast_id>': 'Get episodes for a specific podcast',
            '/api/episodes': 'Get episodes (default: film-club)',
            '/api/health': 'Health check'
        },
        'available_podcasts': list(PODCASTS.keys())
    })

if __name__ == '__main__':
    print("Starting Flask server...")
    print(f"Available podcasts: {list(PODCASTS.keys())}")

    # Get port from environment variable (Railway sets this) or default to 5001
    port = int(os.environ.get('PORT', 5001))
    debug = os.environ.get('FLASK_ENV') != 'production'

    app.run(host='0.0.0.0', port=port, debug=debug)
