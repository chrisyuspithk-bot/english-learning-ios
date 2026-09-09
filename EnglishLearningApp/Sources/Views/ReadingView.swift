import SwiftUI

struct ReadingView: View {
    let chapter: Chapter
    @EnvironmentObject var store: AppStore

    private var passage: ReadingPassage { chapter.reading }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                passageCard

                SectionHeader(title: "Comprehension questions", icon: "questionmark.circle")
                    .padding(.horizontal)

                ForEach(passage.questions) { question in
                    MCQCard(question: question, accent: Color(hex: chapter.colorHex))
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background)
        .navigationBarTitle("Reading", displayMode: .inline)
    }

    private var passageCard: some View {
        Card(accent: Color(hex: chapter.colorHex)) {
            HStack {
                Text(passage.title)
                    .font(.headline)
                Spacer()
                Button(action: { store.tts.speak(passage.paragraphs.joined(separator: " "), rate: 0.42) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Read aloud")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Theme.primary)
                }
            }

            ForEach(passage.paragraphs.indices, id: \.self) { index in
                Text(passage.paragraphs[index])
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal)
    }
}
