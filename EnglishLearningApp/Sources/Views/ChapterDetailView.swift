import SwiftUI

/// A chapter is split into four tabs: Vocabulary, Grammar, Exercise, Reading.
/// The full chapter detail is loaded from the backend on appear.
struct ChapterDetailView: View {
    let summary: ChapterSummary
    @EnvironmentObject var store: AppStore

    var body: some View {
        Group {
            if let chapter = store.chapterDetail, chapter.id == summary.id {
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
            } else {
                VStack(spacing: 12) {
                    ActivityIndicator()
                    Text(store.contentError ?? "Loading chapter…")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationBarTitle(summary.title, displayMode: .inline)
        .onAppear { store.loadChapterDetail(id: summary.id) }
    }
}
