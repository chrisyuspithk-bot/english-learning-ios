import Foundation
import AVFoundation

/// Abstraction over text-to-speech so the app can use either Piper (via
/// piper-objc) or Apple's built-in `AVSpeechSynthesizer` without touching UI code.
protocol TTSProviding {
    func speak(_ text: String, rate: Float)
    func stop()
}

// MARK: - Fallback: Apple system voice (works out of the box on iOS 13+)

final class SystemTTSProvider: NSObject, TTSProviding {

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, rate: Float = 0.45) {
        stop()
        configureAudioSessionForPlayback()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// The speech-recogniser service sets the shared `AVAudioSession` to
    /// `.playAndRecord` + `.measurement` for the microphone, which is not
    /// suitable (and can be inaudible) for `AVSpeechSynthesizer`. Reconfigure
    /// the session for playback before speaking so TTS is always audible and
    /// is not silenced by the hardware mute switch.
    private func configureAudioSessionForPlayback() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
    }
}

// MARK: - Piper adapter (piper-objc)

/// Adapter for your `piper-objc` SDK.
///
/// Piper (https://github.com/rhasspy/piper) is an offline neural TTS engine
/// built on ONNX/VITS models. The `piper-objc` wrapper exposes that engine to
/// Objective-C/Swift. Because the exact symbol names vary between wrapper
/// versions, this class is intentionally a thin shell: the `#if canImport`
/// branch below is where the real Piper calls belong, and it falls back to the
/// system voice otherwise so the POC always runs.
final class PiperTTSProvider: NSObject, TTSProviding {

    // TODO: piper-objc integration -------------------------------------------
    // 1. Add the piper-objc framework/package + a voice model to your target.
    // 2. Fix the module name in `canImport` below to match your SDK.
    // 3. Replace the `#if` body with your SDK's actual API, e.g.:
    //
    //   #if canImport(PiperObjc)
    //   private let engine = PiperEngine(modelPath: "en_US-lessac-medium.onnx")
    //
    //   func speak(_ text: String, rate: Float) {
    //       engine.synthesize(text) { audioData in
    //           // play audioData through AVAudioPlayer / AVAudioEngine
    //       }
    //   }
    //   #endif
    // -------------------------------------------------------------------------

    #if canImport(PiperObjc)
    // Reference to the piper-objc engine once the SDK is linked in.
    // private var engine: PiperObjcEngine?
    #endif

    private let fallback = SystemTTSProvider()

    func speak(_ text: String, rate: Float) {
        #if canImport(PiperObjc)
        // Real Piper synthesis goes here (see TODO block above).
        fallback.speak(text, rate: rate)
        #else
        fallback.speak(text, rate: rate)
        #endif
    }

    func stop() {
        #if canImport(PiperObjc)
        // engine.stop()
        #endif
        fallback.stop()
    }
}

// MARK: - Factory

enum TTSFactory {
    /// Returns Piper when the piper-objc module is present, otherwise the system voice.
    static func makeEngine() -> TTSProviding {
        #if canImport(PiperObjc)
        return PiperTTSProvider()
        #else
        return SystemTTSProvider()
        #endif
    }
}
