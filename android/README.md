# English Learning App — Android

An Android equivalent of the iOS SwiftUI POC, built with **Kotlin + Jetpack
Compose (Material 3)**, using an **MVVM** architecture with **Coroutines** and
**StateFlow**, **Retrofit2** for networking, and the **native Android
TextToSpeech / SpeechRecognizer** APIs for the voice features.

It talks to the same FastAPI backend (`backend/`) as the iOS app and mirrors its
business logic, screens, and REST calls.

## Project layout

```
android/
├── settings.gradle.kts
├── build.gradle.kts                 # AGP + Kotlin + Compose plugin versions
├── gradle.properties
├── gradle/wrapper/gradle-wrapper.properties
└── app/
    ├── build.gradle.kts             # dependencies + API_BASE_URL build field
    └── src/main/
        ├── AndroidManifest.xml      # INTERNET + RECORD_AUDIO permissions
        ├── res/values/              # app name + theme
        └── java/com/example/englishlearning/
            ├── EnglishLearningApp.kt        # Application + DI container
            ├── AppContainer.kt              # manual dependency container
            ├── MainActivity.kt              # single-activity entry point
            ├── data/
            │   ├── model/Models.kt          # domain models
            │   ├── remote/                  # Retrofit + DTOs + mapper
            │   │   ├── ApiService.kt        # REST endpoints
            │   │   ├── ApiDtos.kt (dto/)    # JSON DTOs (@SerializedName)
            │   │   ├── ApiMapper.kt         # DTO -> domain
            │   │   ├── RetrofitClient.kt
            │   │   ├── AuthInterceptor.kt
            │   │   ├── TokenStore.kt
            │   │   └── ApiResult.kt         # apiCall + error parsing
            │   └── repository/              # Auth / Content / Record repos
            ├── speech/
            │   ├── TtsManager.kt            # native TextToSpeech wrapper
            │   ├── SpeechRecognizerManager.kt  # native SpeechRecognizer wrapper
            │   └── PronunciationScorer.kt   # Levenshtein scoring
            └── ui/
                ├── theme/                   # colours, icons, typography
                ├── components/Components.kt # Card / MCQ / progress bar
                ├── auth / home / chapter    # ViewModels + StateFlow UiState
                ├── screens/                 # Login / Home / Chapter / Vocab /
                │                            # Grammar / Exercise / Reading
                └── EnglishLearningApp.kt    # NavHost + routes
```

## How it maps to the iOS app

| iOS file | Android equivalent |
| --- | --- |
| `Models.swift` + `APIMapper` | `data/model/Models.kt` + `data/remote/ApiMapper.kt` |
| `AuthService.swift` | `data/repository/AuthRepository.kt` |
| `ContentService.swift` | `data/repository/ContentRepository.kt` |
| `SpeechRecognizerService.swift` | `speech/SpeechRecognizerManager.kt` |
| `TTSService.swift` | `speech/TtsManager.kt` |
| `AppStore.swift` | `ui/auth/AuthViewModel.kt`, `ui/home/HomeViewModel.kt`, `ui/chapter/ChapterViewModel.kt` |
| `RootView.swift` | `ui/EnglishLearningApp.kt` (NavHost) |
| `Views/*.swift` | `ui/screens/*.kt` |

## REST API (matched to the backend)

- `POST /api/auth/student/login` — `{username, password}` → `{token, user}`
- `GET  /api/app/dashboard` — student + chapters + homework + announcements
- `GET  /api/app/chapters/{id}` — full chapter content
- `POST /api/app/records` / `GET /api/app/records` — practice records
  (available in `RecordRepository`; the iOS POC views do not submit records, so
  the Android views don't either — wire them in when needed)

The backend mixes `snake_case` (SQLAlchemy column serialization) with `camelCase`
(chapter JSON stored as-is), so every DTO field is annotated with
`@SerializedName` instead of a single global naming strategy.

## Backend URL

The base URL is a Gradle build field in `app/build.gradle.kts`:

```kotlin
buildConfigField("String", "API_BASE_URL", "\"http://10.0.2.2:12000/\"")
```

- `10.0.2.2` is the Android emulator's alias for the host machine's loopback
  (the iOS app uses `127.0.0.1:12000` directly).
- For a physical device, change it to your machine's LAN IP, e.g.
  `http://192.168.1.10:12000/`.
- Cleartext HTTP is allowed via `android:usesCleartextTraffic="true"` (same as
  the iOS `NSAllowsArbitraryLoads` relaxation). Use HTTPS in production.

## Running

1. Open the `android/` directory in Android Studio (or run
   `./gradlew :app:assembleDebug` if a Gradle wrapper is present — Android Studio
   can regenerate the wrapper with `gradle wrapper`).
2. Start the backend (see the repo root `README.md`):
   `python -m uvicorn app.main:app --host 0.0.0.0 --port 12000`
3. Run on an emulator or device and log in with the demo account
   `amy` / `student123`.

> Speech recognition needs a device or emulator with Google speech services and
> an active network connection for online recognition. The first time you open
> the pronunciation practice flow, Android prompts for microphone permission.

## Voice capabilities

- **TTS** — `TtsManager` wraps `android.speech.tts.TextToSpeech`. The iOS
  `rate` values (0.35–0.45, where 0.5 is normal) are scaled by 2 so they feel
  the same on Android. A Piper adapter could be swapped in behind the same
  manager, mirroring `PiperTTSProvider`.
- **STT** — `SpeechRecognizerManager` wraps `android.speech.SpeechRecognizer`
  with `RecognizerIntent`, exposing live `transcript` / `isListening` / `error`
  as `StateFlow`. Pronunciation is scored with the same normalised Levenshtein
  distance as `PronunciationScorer.swift`.
- **Permissions** — `RECORD_AUDIO` is requested in the Compose flow via
  `rememberLauncherForActivityResult(ActivityResultContracts.RequestPermission())`
  in the pronunciation practice dialog; `SpeechRecognizerManager.start()` also
  performs a defensive permission check.

## Security notes

- The bearer token is held in memory (`TokenStore`), matching the iOS POC. For a
  production app, persist it with `EncryptedSharedPreferences` / DataStore and
  add token-refresh + logout invalidation on the server.
- No secrets are hard-coded; credentials are entered by the user at login.
- Use HTTPS (and remove `usesCleartextTraffic`) before any real deployment.
