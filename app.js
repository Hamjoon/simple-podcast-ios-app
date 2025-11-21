// Podcast episodes data from 김혜리의 필름클럽 (Kim Hye-ri's Film Club)
// RSS Feed: https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml
const podcastData = {
    episodes: [
        {
            id: 1,
            title: "부고니아",
            description: "요르고스 란티모스의 신작 '부고니아'에 대한 이야기와 김혜리 기자의 새로운 칼럼 연재 소식",
            audioUrl: "http://podcastdown.sbs.co.kr/powerfm/2025/11/podcast-v2000010143-20251118-1763083508347.mp3",
            imageUrl: "https://image.cloud.sbs.co.kr/2024/06/05/Yqc1717550363234.jpg",
            duration: "01:21:09"
        },
        {
            id: 2,
            title: "밀린 수다",
            description: "지난 두 달간 쌓인 청취자 사연 공유 에피소드",
            audioUrl: "http://podcastdown.sbs.co.kr/powerfm/2025/11/podcast-v2000010143-20251110-1762740994999.mp3",
            imageUrl: "https://image.cloud.sbs.co.kr/2024/06/05/Yqc1717550363234.jpg",
            duration: "00:53:17"
        },
        {
            id: 3,
            title: "세계의 주인 with 윤가은 감독",
            description: "윤가은 감독과의 100분을 채운 상세 대화 세션",
            audioUrl: "http://podcastdown.sbs.co.kr/powerfm/2025/10/podcast-v2000010143-20251027-1761107893693.mp3",
            imageUrl: "https://image.cloud.sbs.co.kr/2024/06/05/Yqc1717550363234.jpg",
            duration: "01:38:04"
        },
        {
            id: 4,
            title: "원 배틀 애프터 어나더",
            description: "영화 이야기로만 82분, 그 중 음악 이야기는 29분",
            audioUrl: "http://podcastdown.sbs.co.kr/powerfm/2025/10/podcast-v2000010143-20251017-1760690866827.mp3",
            imageUrl: "https://image.cloud.sbs.co.kr/2024/06/05/Yqc1717550363234.jpg",
            duration: "01:26:21"
        },
        {
            id: 5,
            title: "어쩔수가없다 with 박찬욱 감독",
            description: "박찬욱 감독과의 신작 상세 대담, 연기 디렉션 및 음악 선호도 논의",
            audioUrl: "http://podcastdown.sbs.co.kr/powerfm/2025/10/podcast-v2000010143-20251001-1759286133458.mp3",
            imageUrl: "https://image.cloud.sbs.co.kr/2024/06/05/Yqc1717550363234.jpg",
            duration: "01:50:54"
        }
    ]
};

// State management
let currentEpisode = null;

// DOM elements
const audioPlayer = document.getElementById('audio-player');
const episodeTitle = document.getElementById('episode-title');
const episodeDescription = document.getElementById('episode-description');
const episodeImage = document.getElementById('episode-image');
const episodesContainer = document.getElementById('episodes-container');

// Initialize the app
function init() {
    renderEpisodes();
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
