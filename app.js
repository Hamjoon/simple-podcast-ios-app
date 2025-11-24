// Configuration
const API_BASE_URL = 'https://simple-podcast-production.up.railway.app';

// Podcast episodes data - will be fetched from API
let podcastData = {
    episodes: []
};

// State management
let currentEpisode = null;

// Sleep timer state
let sleepTimerInterval = null;
let sleepTimerEndTime = null;

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

// ===== Sleep Timer Functions =====

// Start sleep timer with specified minutes
function startSleepTimer(minutes) {
    // Clear any existing timer
    stopSleepTimer();

    // Calculate end time
    sleepTimerEndTime = Date.now() + (minutes * 60 * 1000);

    // Get DOM elements
    const timerDisplay = document.getElementById('timer-display');
    const timerCountdown = document.getElementById('timer-countdown');
    const timerPresets = document.querySelector('.timer-presets');

    // Show timer display and hide preset buttons
    timerDisplay.style.display = 'flex';
    timerPresets.style.display = 'none';

    // Update display immediately
    updateTimerDisplay();

    // Update every second
    sleepTimerInterval = setInterval(() => {
        updateTimerDisplay();

        // Check if timer has expired
        const remaining = sleepTimerEndTime - Date.now();
        if (remaining <= 0) {
            handleTimerComplete();
        }
    }, 1000);
}

// Stop sleep timer
function stopSleepTimer() {
    if (sleepTimerInterval) {
        clearInterval(sleepTimerInterval);
        sleepTimerInterval = null;
    }

    sleepTimerEndTime = null;

    // Reset UI
    const timerDisplay = document.getElementById('timer-display');
    const timerPresets = document.querySelector('.timer-presets');

    if (timerDisplay && timerPresets) {
        timerDisplay.style.display = 'none';
        timerPresets.style.display = 'flex';
    }
}

// Update timer countdown display
function updateTimerDisplay() {
    const timerCountdown = document.getElementById('timer-countdown');

    if (!sleepTimerEndTime || !timerCountdown) return;

    const remaining = Math.max(0, sleepTimerEndTime - Date.now());
    const minutes = Math.floor(remaining / 60000);
    const seconds = Math.floor((remaining % 60000) / 1000);

    timerCountdown.textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

// Handle timer completion
function handleTimerComplete() {
    // Pause the audio
    audioPlayer.pause();

    // Stop the timer
    stopSleepTimer();

    // Optional: Show notification (if browser supports it)
    if ('Notification' in window && Notification.permission === 'granted') {
        new Notification('Sleep Timer', {
            body: 'Playback stopped - sleep well!',
            icon: episodeImage.src
        });
    }
}

// Initialize sleep timer controls
function initSleepTimer() {
    // Add event listeners to preset buttons
    const timerButtons = document.querySelectorAll('.timer-btn');
    timerButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            const minutes = parseInt(btn.dataset.minutes);
            startSleepTimer(minutes);
        });
    });

    // Add event listener to cancel button
    const cancelButton = document.getElementById('timer-cancel');
    if (cancelButton) {
        cancelButton.addEventListener('click', stopSleepTimer);
    }

    // Request notification permission (optional)
    if ('Notification' in window && Notification.permission === 'default') {
        Notification.requestPermission();
    }
}

// Start the app
init();

// Initialize sleep timer after DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSleepTimer);
} else {
    initSleepTimer();
}
