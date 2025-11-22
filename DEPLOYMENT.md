# Railway.app 배포 가이드

## 준비사항
- GitHub 계정
- Railway.app 계정 (GitHub로 로그인 가능)

## 배포 단계

### 1. GitHub에 코드 푸시

```bash
# Git 초기화 (아직 안 했다면)
git init
git add .
git commit -m "Initial commit for Railway deployment"

# GitHub 저장소 생성 후
git remote add origin https://github.com/YOUR_USERNAME/simple-podcast.git
git branch -M main
git push -u origin main
```

### 2. Railway.app 배포

1. **Railway.app 접속**
   - https://railway.app 방문
   - "Start a New Project" 클릭

2. **GitHub 연동**
   - "Deploy from GitHub repo" 선택
   - 저장소 권한 허용
   - `simple-podcast` 저장소 선택

3. **자동 배포 시작**
   - Railway가 자동으로 `requirements.txt` 감지
   - Python 환경 설정 및 의존성 설치
   - `Procfile` 또는 `railway.json`의 명령어로 서버 시작

4. **도메인 확인**
   - 배포 완료 후 Settings → Networking
   - "Generate Domain" 클릭
   - 생성된 URL 복사 (예: `https://simple-podcast-production.up.railway.app`)

### 3. 프론트엔드 설정 업데이트

생성된 Railway URL을 `app.js`에 설정:

```javascript
// app.js
const API_BASE_URL = 'https://YOUR-APP.up.railway.app';
```

### 4. 프론트엔드 배포 (선택사항)

#### 옵션 A: Netlify (추천)
1. https://netlify.com 접속
2. "Add new site" → "Deploy manually"
3. `index.html`, `app.js`, `styles.css` 파일을 드래그 앤 드롭
4. 배포 완료!

#### 옵션 B: GitHub Pages
```bash
# gh-pages 브랜치 생성
git checkout -b gh-pages
git push origin gh-pages

# GitHub 저장소 Settings → Pages에서 활성화
```

#### 옵션 C: Vercel
1. https://vercel.com 접속
2. GitHub 저장소 연결
3. 자동 배포

## Railway 무료 티어 제한

- **월 $5 크레딧** (약 500시간 실행 가능)
- **500MB 메모리**
- **1GB 디스크**
- 충분히 작은 프로젝트에 적합

## 환경 변수 설정 (선택사항)

Railway 대시보드에서 환경 변수 추가 가능:

```
FLASK_ENV=production
RSS_FEED_URL=https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml
```

## 로그 확인

Railway 대시보드 → Deployments → 최신 배포 클릭 → Logs 탭

## 문제 해결

### 배포 실패 시
1. Railway 로그 확인
2. `requirements.txt`에 모든 의존성이 있는지 확인
3. Python 버전 확인 (`runtime.txt`)

### CORS 에러 시
- 이미 `flask-cors`로 모든 도메인 허용 설정됨
- 특정 도메인만 허용하려면 `server.py` 수정:
  ```python
  CORS(app, origins=["https://your-frontend-domain.com"])
  ```

### 서버 응답 없음
- Railway 대시보드에서 서비스 상태 확인
- Health check 엔드포인트 테스트: `https://YOUR-APP.up.railway.app/api/health`

## 자동 재배포

GitHub에 푸시할 때마다 Railway가 자동으로 재배포합니다:

```bash
git add .
git commit -m "Update code"
git push origin main
```

## 비용 절감 팁

- 무료 크레딧 소진 시 서비스 일시 중지됨
- 사용하지 않을 때는 Railway 대시보드에서 프로젝트 일시 중지 가능
- 캐시 시간 늘리기 (`server.py`의 `cache_duration` 증가)
