import SwiftUI

/// A chapter is split into four tabs: Vocabulary, Grammar, Exercise, Reading.
struct ChapterDetailView: View {
    let chapter: Chapter

    var body: some View {
        TabView {
            VocabularyView(chapter: chapter)
                .tabItem {
                    Image(systemName: "textformat.abc")
                    Text("Vocabulary")
                }

            GrammarView(chapter: chapter)
                .tabItem {
                    Image(systemName: "text.book.closed")
                    Text("Grammar")
                }

            ExerciseView(chapter: chapter)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Exercise")
                }

            ReadingView(chapter: chapter)
                .tabItem {
                    Image(systemName: "book")
                    Text("Reading")
                }
        }
        .navigationBarTitle("\(chapter.title)", displayMode: .inline)
    }
}
