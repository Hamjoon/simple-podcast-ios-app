# Simple Podcast iOS App

SBS 팟캐스트를 스트리밍하는 iOS 앱입니다.

## 지원 팟캐스트

| 팟캐스트 | 설명 |
|---------|------|
| 김혜리의 필름클럽 | 영화 리뷰 및 토론 |
| 라디오 북클럽 | MBC 라디오 북클럽 |
| 서담서담 | 책으로 읽는 내 마음 |

## Features

- 다중 팟캐스트 지원 (탭 UI)
- 백엔드 API에서 에피소드 목록 로드
- 오디오 스트리밍 재생
- 백그라운드 오디오 지원
- 다음 에피소드 자동 재생
- 재생 진행률 표시
- 수면 타이머 (15/30/45/60분)
- 이미지 캐싱

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Architecture

```
SimplePodcast/
├── App/
│   └── SimplePodcastApp.swift     # 앱 진입점
├── Models/
│   ├── Episode.swift              # 에피소드 데이터 모델
│   └── Podcast.swift              # 팟캐스트 메타데이터
├── Services/
│   ├── APIService.swift           # 백엔드 API 통신
│   └── AudioPlayerService.swift   # 오디오 재생
├── Utilities/
│   ├── ImageCache.swift           # 이미지 캐싱
│   └── SleepTimerManager.swift    # 수면 타이머
├── ViewModels/
│   └── PodcastViewModel.swift     # 상태 관리
└── Views/
    ├── ContentView.swift          # 메인 뷰
    ├── MainTabView.swift          # 탭 네비게이션
    ├── EpisodeListView.swift      # 에피소드 목록
    ├── EpisodeRowView.swift       # 에피소드 행
    ├── PlayerView.swift           # 오디오 플레이어
    ├── SleepTimerView.swift       # 수면 타이머 UI
    └── CachedAsyncImage.swift     # 캐시된 이미지 컴포넌트
```

## Data Source

팟캐스트 에피소드는 Railway에 배포된 백엔드 API에서 가져옵니다:
- API: `https://web-production-65db2.up.railway.app/api/episodes/{podcast-id}`
- 지원 ID: `film-club`, `radio-book-club`, `seodam`

## Getting Started

1. Xcode에서 프로젝트 열기
2. 시뮬레이터 또는 실제 기기 선택
3. Build and Run (⌘R)

## Build

```bash
# 빌드
xcodebuild -scheme SimplePodcast -configuration Debug build

# 테스트
xcodebuild test -scheme SimplePodcast -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Backend Server

Flask 백엔드 서버가 Railway에 배포되어 있습니다.

- `server.py` - Flask API 서버
- `requirements.txt` - Python 의존성
- `DEPLOYMENT.md` - 배포 가이드

## ML Pipeline

`ml/movie/` 디렉토리에는 에피소드 그룹화를 위한 ML 파이프라인이 포함되어 있습니다:

```
ml/movie/scripts/
├── 01_extract_episodes.py    # RSS에서 에피소드 추출
├── 02_generate_embeddings.py # 텍스트 임베딩 생성
├── 03_kmeans_clustering.py   # K-means 클러스터링
├── 04_assign_labels.py       # 클러스터 라벨 할당
└── 05_export_for_api.py      # API용 데이터 내보내기
```

## License

MIT License
