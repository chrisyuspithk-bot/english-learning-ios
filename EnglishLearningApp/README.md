# English Learning App — iOS POC

A proof-of-concept iOS app (Swift + SwiftUI, **iOS 13.0+**) for a Primary 5
English learning app aimed at Hong Kong primary-school students. It combines:

- **Apple Speech framework** (`SFSpeechRecognizer`) for on-device speech-to-text (STT) to test pronunciation.
- **Piper TTS** (via a `piper-objc` adapter) for text-to-speech, with an
  `AVSpeechSynthesizer` fallback so the POC runs immediately without any extra SDK.

---

## POC scope

After logging in with a **dummy account**, the student sees a home screen with:

1. **Textbook chapters** (a list of chapters for Primary 5 English).
2. **Latest homework session** (dummy data).
3. **Teacher announcement** (dummy data).

Each chapter contains four learning sections:

| Section | What it does |
| --- | --- |
| **Vocabulary** | Word cards with phonetics, meaning, example, and a **pronunciation practice** flow that uses STT to check how well the student pronounces each word. |
| **Grammar** | Key concepts with an explanation, a rule box, and examples (readable aloud via TTS). |
| **Exercise** | Multiple-choice questions with instant marking and an explanation. |
| **Reading** | One passage with 5 multiple-choice comprehension questions. |

A full **Primary 5 level sample** ("Healthy Living") is included, plus two more
chapters so the list feels real.

---

## Project structure

```
EnglishLearningApp/
├── project.yml                     # XcodeGen definition (optional)
├── Resources/Info.plist            # mic + speech permissions, scene manifest
└── Sources/
    ├── App/
    │   ├── AppLifecycle.swift      # AppDelegate + SceneDelegate (iOS 13 lifecycle)
    │   └── RootView.swift          # switches login <-> main app
    ├── Models/
    │   ├── Models.swift            # Codable domain models
    │   └── SampleContent.swift     # P5 Hong Kong sample content (dummy data)
    ├── Services/
    │   ├── AuthService.swift       # dummy login
    │   ├── ContentService.swift    # loads dummy chapters/homework/announcements
    │   ├── SpeechRecognizerService.swift  # STT (Apple Speech + AVAudioEngine)
    │   └── TTSService.swift        # TTS protocol + system fallback + piper-objc adapter
    ├── ViewModels/
    │   └── AppStore.swift          # central observable app state
    └── Views/
        ├── Theme.swift             # colours / helpers
        ├── Components.swift        # shared UI (cards, MC question, etc.)
        ├── LoginView.swift
        ├── HomeView.swift
        ├── ChapterDetailView.swift
        ├── VocabularyView.swift    # includes pronunciation practice (STT)
        ├── GrammarView.swift
        ├── ExerciseView.swift
        └── ReadingView.swift
```

---

## How to run

### Option A — open directly (easiest)

The `.xcodeproj` is committed, so no extra tools are needed:

```bash
git clone https://github.com/chrisyuspithk-bot/english-learning-ios.git
cd english-learning-ios/EnglishLearningApp
open EnglishLearningApp.xcodeproj
```

Then in Xcode: choose a simulator or your iPhone as the run destination, set
your **Signing Team** (Signing & Capabilities → Team) if running on a device,
and press **Run** (⌘R).

### Option B — regenerate with XcodeGen

If you add or remove source files, regenerate the project from `project.yml`:

```bash
brew install xcodegen
cd EnglishLearningApp
xcodegen generate
open EnglishLearningApp.xcodeproj
```

### Option C — create the project manually

1. In Xcode: **File → New → Project → iOS → App**.
2. Set **Interface** to *SwiftUI* and **Life Cycle** to *UIKit App Delegate*.
3. Set **Deployment Target** to **iOS 13.0**.
4. Delete the template files, then drag in the `Sources/` and `Resources/`
   folders (create groups, copy items if needed).
5. Make sure **AVFoundation.framework** and **Speech.framework** are linked
   (Project → target → General → Frameworks, Libraries, and Embedded Content).

### Run on a real device

Speech recognition and microphone access **do not work in the Simulator**.
Run on a physical iPhone/iPad to test the pronunciation practice. The first
time you open a feature that uses the mic, iOS will prompt for microphone and
speech-recognition permissions.

### Dummy login

Any non-empty username and password works. Try `demo` / `demo123`.

---

## TTS — integrating `piper-objc`

TTS is abstracted behind the `TTSProviding` protocol (`Sources/Services/TTSService.swift`):

- `SystemTTSProvider` uses `AVSpeechSynthesizer` — works out of the box, no setup.
- `PiperTTSProvider` is the adapter for your `piper-objc` SDK.

`TTSFactory.makeEngine()` selects Piper when the SDK module is present and
falls back to the system voice otherwise:

```swift
static func makeEngine() -> TTSProviding {
    #if canImport(PiperObjc)
    return PiperTTSProvider()
    #else
    return SystemTTSProvider()
    #endif
}
```

To plug in your `piper-objc` SDK:

1. Add the `piper-objc` framework/package and its voice model files to the target.
2. Adjust the module name in the `#if canImport(...)` guards in
   `TTSService.swift` to match your SDK's actual module (e.g. `Piper`, `PiperObjc`).
3. Implement the `PiperTTSProvider.speak(_:)` / `stop()` bodies against your
   SDK's symbols. The file contains a marked `// TODO: piper-objc integration`
   block where the real synthesis calls belong. The exact function names depend
   on the version of `piper-objc` you are using, so those two methods are the
   only places that should need editing.

Piper's runtime is an ONNX/VITS model, so you must bundle (or download) a voice
model (e.g. an `en_US` model) before speech can be generated.

---

## STT — how pronunciation scoring works

`SpeechRecognizerService` wraps `SFSpeechRecognizer` + `AVAudioEngine`:

1. Requests authorization and confirms availability.
2. Streams mic audio into an `SFSpeechAudioBufferRecognitionRequest`.
3. Exposes a live `transcript` and `isRecording` state via Combine.

`VocabularyView` compares the recognised text against the target word using a
normalised Levenshtein distance, producing a 0–1 score and a friendly result
("Great!", "Close!", "Try again"). This is intentionally simple for a POC — a
production app would use phoneme-level scoring.

The recogniser locale defaults to `en-US`; change it in
`SpeechRecognizerService.init()` if you prefer `en-GB` (common in Hong Kong).

---

## Sample content

`Sources/Models/SampleContent.swift` contains the textbook, homework session and
announcement dummy data. Chapter 1 ("Healthy Living") is the fully worked
Primary 5 sample: 8 vocabulary words, 2 grammar points, 5 exercises, and a
reading passage with 5 comprehension questions.
