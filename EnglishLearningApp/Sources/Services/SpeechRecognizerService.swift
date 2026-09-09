import Foundation
import Combine
import Speech
import AVFoundation

/// Wraps Apple's `SFSpeechRecognizer` + `AVAudioEngine` to stream microphone
/// audio into a speech-recognition request and publish the live transcript.
final class SpeechRecognizerService: NSObject, ObservableObject {

    enum State {
        case idle, recording, unavailable, denied
    }

    @Published private(set) var transcript: String = ""
    @Published private(set) var state: State = .idle
    @Published private(set) var isAuthorized = false

    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private let localeIdentifier: String

    init(localeIdentifier: String = "en-US") {
        self.localeIdentifier = localeIdentifier
        super.init()
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        recognizer?.delegate = self
    }

    var isAvailable: Bool {
        recognizer?.isAvailable ?? false
    }

    /// Ask the user for mic + speech-recognition permission.
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = (status == .authorized)
                if status != .authorized {
                    self?.state = .denied
                }
            }
        }
    }

    /// Begin live transcription of the microphone.
    func start() throws {
        guard isAuthorized, isAvailable else {
            state = .denied
            return
        }

        // Cancel any in-flight session.
        stop(cleanupOnly: true)

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord,
                                     mode: .measurement,
                                     options: [.defaultToSpeaker, .allowBluetoothHFP])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        state = .recording
        transcript = ""

        task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                self.teardown()
            }
        }
    }

    /// Stop recognition and clean up audio resources.
    func stop() {
        stop(cleanupOnly: false)
    }

    private func stop(cleanupOnly: Bool) {
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)

        if !cleanupOnly {
            state = .idle
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func teardown() {
        request = nil
        task = nil
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        state = .idle
    }
}

extension SpeechRecognizerService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        DispatchQueue.main.async { [weak self] in
            if !available {
                self?.state = .unavailable
            }
        }
    }
}
