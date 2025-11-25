# Simple Podcast iOS App

iOS 팟캐스트 앱 - "김혜리의 필름클럽" (Kim Hye-ri's Film Club)

SBS RSS 피드에서 팟캐스트 에피소드를 가져와 재생하는 간단한 iOS 앱입니다.

## Features

- RSS 피드에서 에피소드 목록 자동 로드
- 오디오 스트리밍 재생
- 백그라운드 오디오 지원
- 다음 에피소드 자동 재생
- 재생 진행률 표시

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Architecture

```
SimplePodcast/
├── Models/
│   └── Episode.swift          # 에피소드 데이터 모델
├── Services/
│   └── RSSService.swift       # RSS 피드 파싱
├── ViewModels/
│   └── PodcastViewModel.swift # 상태 관리
└── Views/
    ├── ContentView.swift      # 메인 뷰
    ├── EpisodeListView.swift  # 에피소드 목록
    └── PlayerView.swift       # 오디오 플레이어
```

## Data Source

팟캐스트 에피소드는 SBS RSS 피드에서 가져옵니다:
- URL: `https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml`

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

## Backend Server (별도 프로젝트)

이 저장소에는 레거시 Flask 백엔드 서버 파일이 포함되어 있습니다. 이 파일들은 별도의 프로젝트로 이전될 예정입니다.

- `server.py` - Flask API 서버
- `requirements.txt` - Python 의존성
- `DEPLOYMENT.md` - 배포 가이드

## License

MIT License
