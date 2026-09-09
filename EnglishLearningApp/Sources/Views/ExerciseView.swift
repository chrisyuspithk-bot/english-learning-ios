import SwiftUI

struct ExerciseView: View {
    let chapter: Chapter
    @State private var results: [String: Bool] = [:]

    private var answeredCorrect: Int {
        results.values.filter { $0 }.count
    }

    private var total: Int { chapter.exercises.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                scoreSummary

                ForEach(chapter.exercises) { question in
                    MCQCard(question: question, accent: Color(hex: chapter.colorHex)) { correct in
                        results[question.id] = correct
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Theme.background)
        .navigationBarTitle("Exercise", displayMode: .inline)
    }

    private var scoreSummary: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(hex: chapter.colorHex).opacity(0.25), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Text("\(answeredCorrect)/\(total)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: chapter.colorHex))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Multiple-choice practice")
                    .font(.headline)
                Text("Choose the best answer for each question.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
