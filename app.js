// Configuration
const API_BASE_URL = 'http://localhost:5001';

// Podcast episodes data - will be fetched from API
let podcastData = {
    episodes: []
};

// State management
let currentEpisode = null;

// DOM elements
const audioPlayer = document.getElementById('audio-player');
const episodeTitle = document.getElementById('episode-title');
const episodeDescription = document.getElementById('episode-description');
const episodeImage = document.getElementById('episode-image');
const episodesContainer = document.getElementById('episodes-container');

// Fetch episodes from API
async function fetchEpisodes() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/episodes`);
        const data = await response.json();

        if (data.success && data.episodes) {
            podcastData.episodes = data.episodes;
            renderEpisodes();
        } else {
            console.error('Failed to load episodes:', data.error);
            showError('Failed to load episodes. Please try again later.');
        }
    } catch (error) {
        console.error('Error fetching episodes:', error);
        showError('Unable to connect to the server. Please check if the API server is running.');
    }
}

// Show error message
function showError(message) {
    episodesContainer.innerHTML = `
        <div style="padding: 20px; text-align: center; color: #666;">
            <p>${message}</p>
        </div>
    `;
}

// Initialize the app
async function init() {
    // Show loading state
    episodesContainer.innerHTML = '<div style="padding: 20px; text-align: center; color: #666;">Loading episodes...</div>';

    // Fetch episodes from API
    await fetchEpisodes();
}

// Render all episodes in the list
function renderEpisodes() {
    episodesContainer.innerHTML = '';

    podcastData.episodes.forEach(episode => {
        const episodeElement = createEpisodeElement(episode);
        episodesContainer.appendChild(episodeElement);
    });
}

// Create episode list item element
function createEpisodeElement(episode) {
    const episodeDiv = document.createElement('div');
    episodeDiv.className = 'episode-item';
    episodeDiv.dataset.episodeId = episode.id;

    episodeDiv.innerHTML = `
        <img src="${episode.imageUrl}" alt="${episode.title}">
        <div class="episode-details">
            <h4>${episode.title}</h4>
            <p>${episode.description}</p>
        </div>
        <span class="episode-duration">${episode.duration}</span>
    `;

    episodeDiv.addEventListener('click', () => playEpisode(episode));

    return episodeDiv;
}

// Play selected episode
function playEpisode(episode) {
    currentEpisode = episode;

    // Update player UI
    episodeTitle.textContent = episode.title;
    episodeDescription.textContent = episode.description;
    episodeImage.src = episode.imageUrl;
    episodeImage.alt = episode.title;

    // Update audio source and play
    audioPlayer.src = episode.audioUrl;
    audioPlayer.load();
    audioPlayer.play();

    // Update active state in episode list
    updateActiveEpisode(episode.id);
}

// Update active episode styling
function updateActiveEpisode(episodeId) {
    const allEpisodes = document.querySelectorAll('.episode-item');
    allEpisodes.forEach(item => {
        if (parseInt(item.dataset.episodeId) === episodeId) {
            item.classList.add('active');
        } else {
            item.classList.remove('active');
        }
    });
}

// Auto-play next episode when current one ends
audioPlayer.addEventListener('ended', () => {
    if (currentEpisode) {
        const currentIndex = podcastData.episodes.findIndex(ep => ep.id === currentEpisode.id);
        const nextIndex = currentIndex + 1;

        if (nextIndex < podcastData.episodes.length) {
            playEpisode(podcastData.episodes[nextIndex]);
        }
    }
});

// Start the app
init();
