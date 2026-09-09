import SwiftUI

struct GrammarView: View {
    let chapter: Chapter
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Key grammar points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ForEach(chapter.grammar) { concept in
                    grammarCard(concept)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background)
        .navigationBarTitle("Grammar", displayMode: .inline)
    }

    private func grammarCard(_ concept: GrammarConcept) -> some View {
        Card(accent: Color(hex: chapter.colorHex)) {
            HStack {
                Text(concept.title)
                    .font(.headline)
                Spacer()
                Button(action: { store.tts.speak(concept.title, rate: 0.45) }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(Theme.primary)
                }
            }

            Text(concept.explanation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                Text("📌 Rule")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: chapter.colorHex))
                Text(concept.rule)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: chapter.colorHex).opacity(0.1))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 8) {
                Text("Examples")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                ForEach(concept.examples, id: \.self) { example in
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .foregroundColor(Color(hex: chapter.colorHex))
                        Text(example)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Button(action: { store.tts.speak(example, rate: 0.42) }) {
                            Image(systemName: "play.circle")
                                .foregroundColor(Theme.primary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
