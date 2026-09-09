import SwiftUI

struct VocabularyView: View {
    let chapter: Chapter
    @EnvironmentObject var store: AppStore

    @State private var practiceItem: VocabularyItem?
    @State private var showPractice = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tap a word to practise your pronunciation 🎤")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ForEach(chapter.vocabulary) { item in
                    vocabularyCard(item)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background)
        .navigationBarTitle("Vocabulary", displayMode: .inline)
        .sheet(isPresented: $showPractice) {
            if let item = practiceItem {
                VocabularyPracticeView(item: item, speech: store.speech, tts: store.tts)
            }
        }
    }

    private func vocabularyCard(_ item: VocabularyItem) -> some View {
        Card(accent: Color(hex: chapter.colorHex)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.word)
                        .font(.system(size: 20, weight: .bold))
                    Text(item.phonetic)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                partOfSpeechBadge(item.partOfSpeech)
            }

            HStack(spacing: 8) {
                Button(action: { store.tts.speak(item.word, rate: 0.4) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Listen")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.primary.opacity(0.12))
                    .foregroundColor(Theme.primary)
                    .cornerRadius(10)
                }

                Button(action: { practiceItem = item; showPractice = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "mic.fill")
                        Text("Practise")
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: chapter.colorHex).opacity(0.15))
                    .foregroundColor(Color(hex: chapter.colorHex))
                    .cornerRadius(10)
                }
            }

            Text(item.meaning)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(item.definition)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\"\(item.example)\"")
                .font(.footnote)
                .italic()
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
    }

    private func partOfSpeechBadge(_ pos: String) -> some View {
        Text(pos)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: chapter.colorHex).opacity(0.15))
            .foregroundColor(Color(hex: chapter.colorHex))
            .cornerRadius(6)
    }
}

// MARK: - Pronunciation practice (STT)

struct VocabularyPracticeView: View {
    let item: VocabularyItem
    @ObservedObject var speech: SpeechRecognizerService
    let tts: TTSProviding

    @Environment(\.presentationMode) var presentationMode

    @State private var resultText: String?
    @State private var resultColor: Color = .gray
    @State private var errorText: String?

    private var isRecording: Bool { speech.state == .recording }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text(item.word)
                        .font(.system(size: 44, weight: .bold))
                    Text(item.phonetic)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(item.meaning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Button(action: { tts.speak(item.word, rate: 0.35) }) {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Hear the word")
                    }
                    .font(.headline)
                    .foregroundColor(Theme.primary)
                }

                // Record button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Theme.danger : Theme.primary)
                            .frame(width: 96, height: 96)
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Text(isRecording ? "Listening… say the word" : "Tap to record")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Live / final transcript
                if !speech.transcript.isEmpty {
                    Text("\"\(speech.transcript)\"")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if let resultText = resultText {
                    Text(resultText)
                        .font(.headline)
                        .foregroundColor(resultColor)
                }

                if let errorText = errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundColor(Theme.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Pronunciation", displayMode: .inline)
            .navigationBarItems(leading: Button("Done") {
                speech.stop()
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if !speech.isAuthorized {
                    speech.requestAuthorization()
                }
            }
        }
    }

    private func toggleRecording() {
        resultText = nil
        errorText = nil

        if isRecording {
            stopAndScore()
        } else {
            do {
                try speech.start()
            } catch {
                errorText = "Could not start the microphone: \(error.localizedDescription)"
            }
        }
    }

    private func stopAndScore() {
        speech.stop()
        let recognized = speech.transcript
        let score = PronunciationScorer.score(recognized: recognized, target: item.word)

        switch score {
        case 0.85...:
            resultText = "Great job! 🎉 (\(Int(score * 100))%)"
            resultColor = Theme.success
        case 0.6..<0.85:
            resultText = "Close! Listen again and try. (\(Int(score * 100))%)"
            resultColor = Theme.warning
        default:
            resultText = "Keep practising — you can do it! (\(Int(score * 100))%)"
            resultColor = Theme.danger
        }
    }
}

// MARK: - Pronunciation scoring (Levenshtein-based)

enum PronunciationScorer {
    /// Returns a 0...1 similarity between the recognised speech and the target word.
    static func score(recognized: String, target: String) -> Double {
        let a = normalize(recognized)
        let b = normalize(target)
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let distance = levenshtein(a, b)
        let maxLength = max(a.count, b.count)
        return 1.0 - Double(distance) / Double(maxLength)
    }

    private static func normalize(_ string: String) -> String {
        let lowered = string.lowercased()
        let filtered = lowered.filter { $0.isLetter || $0 == " " }
        let words = filtered.split(separator: " ").map(String.init)
        return words.joined(separator: " ")
    }

    private static func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let a = Array(lhs)
        let b = Array(rhs)
        var dp = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)

        for i in 0...a.count { dp[i][0] = i }
        for j in 0...b.count { dp[0][j] = j }

        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                dp[i][j] = min(dp[i - 1][j] + 1,
                               min(dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost))
            }
        }
        return dp[a.count][b.count]
    }
}
