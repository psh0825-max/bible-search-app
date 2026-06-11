# 말씀찾기 (Bible Search)

AI가 마음에 맞는 성경 말씀을 찾아주는 Flutter 앱 — by LightOn Plus Lab.

- **AI 감정 검색** — 지금의 마음을 적으면 Gemini가 어울리는 구절을 골라줍니다 (음성 입력 지원)
- **성경 읽기** — 개역한글 66권 오프라인 열람, 이어 읽기, 글씨 크기 조절
- **오늘의 말씀** — 매일 바뀌는 추천 구절
- **읽기 진도** — 1,189장 장 단위 진도표
- **키워드 검색** — 오프라인 전문 검색 + 검색어 하이라이트
- **낭독(TTS)** — Google Cloud TTS Wavenet, 오프라인 시 기기 음성 자동 전환
- **북마크 & 노트** — 마음에 닿은 구절 저장, 공유

## 개발 빌드

```sh
flutter pub get
flutter run \
  --dart-define=GEMINI_API_KEY=<your-gemini-api-key>
```

API 키는 소스에 커밋하지 않고 `--dart-define`으로 주입합니다 (`lib/config/api_keys.dart`).

| 키 | 용도 | 없을 때 동작 |
|---|---|---|
| `GEMINI_API_KEY` | AI 감정 검색 | 안내 메시지 표시 (키워드 검색은 정상 동작) |
| `CLOUD_TTS_API_KEY` | Wavenet 낭독 (선택) | `GEMINI_API_KEY` 재사용, 둘 다 없으면 기기 TTS |

> ⚠️ 과거 커밋에 노출된 API 키가 있다면 Google Cloud Console에서 반드시
> **키를 폐기/재발급**하고, 새 키에는 Android 앱 제한(패키지명 + SHA-1)을 걸어주세요.

## Google Play 출시

### 1. 릴리즈 keystore 준비 (최초 1회)

```sh
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties.example`을 `android/key.properties`로 복사해 값을 채웁니다.
(이 파일과 keystore는 `.gitignore`에 이미 등록되어 있어 커밋되지 않습니다.)

### 2. App Bundle 빌드

```sh
flutter build appbundle --release \
  --dart-define=GEMINI_API_KEY=<your-gemini-api-key>
```

산출물: `build/app/outputs/bundle/release/app-release.aab`

- 패키지명: `com.lightonplus.biblesearch`
- 릴리즈 빌드는 R8 코드/리소스 축소가 켜져 있습니다 (`android/app/proguard-rules.pro`)

### 3. Play Console 체크리스트

- [ ] 앱 아이콘 512×512 — `store/play_store_icon_512.png` 사용 가능
- [ ] 그래픽 이미지(피처 그래픽) 1024×500
- [ ] 휴대전화 스크린샷 2장 이상
- [ ] 개인정보처리방침 URL (설정 화면 링크와 동일하게: `https://lightonplus.com/privacy`)
- [ ] 데이터 보안 양식 — 수집 데이터: 없음(검색어는 Gemini API로 전송되나 저장하지 않음을 명시),
      권한: 마이크(음성 검색), 인터넷
- [ ] 콘텐츠 등급 설문
- [ ] 버전 올릴 때 `pubspec.yaml`의 `version`(예: `1.0.1+2`)과
      `lib/config/constants.dart`의 `appVersion`을 함께 갱신

## 프로젝트 구조

```
lib/
├── config/        # 테마(Dawn), 상수, API 키 주입
├── models/        # Verse, BibleBook, Bookmark
├── providers/     # Riverpod 상태 (검색, 성경, 북마크, 설정)
├── screens/       # 찾기 / 성경 / 진도 / 저장 / 설정
├── services/      # Gemini, SQLite 성경 DB, TTS, STT
└── widgets/       # VerseCard, BottomNav 등
assets/bible.json  # 개역한글 전권 (최초 실행 시 SQLite로 임포트)
```
