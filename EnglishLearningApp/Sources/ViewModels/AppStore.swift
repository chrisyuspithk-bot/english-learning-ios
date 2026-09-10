import Foundation
import Combine

/// Central observable state for the app, injected into the view hierarchy
/// via `.environmentObject(...)`. Kept as a single object for iOS 13
/// compatibility (no `@StateObject` needed).
final class AppStore: ObservableObject {

    // MARK: - Auth state
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false
    @Published var loginError: String?

    // MARK: - Content state
    @Published var chapters: [ChapterSummary] = []
    @Published var homework: [HomeworkSession] = []
    @Published var announcements: [Announcement] = []
    @Published var isLoadingContent = false
    @Published var contentError: String?

    // MARK: - Chapter detail state
    @Published var chapterDetail: Chapter?
    @Published var isLoadingChapter = false

    // MARK: - Shared services
    let tts: TTSProviding
    let speech = SpeechRecognizerService()

    private let auth = AuthService()
    private let content = ContentService()

    init(tts: TTSProviding = TTSFactory.makeEngine()) {
        self.tts = tts
    }

    // MARK: - Auth

    func login(username: String, password: String) {
        isLoggingIn = true
        loginError = nil
        auth.login(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            self.isLoggingIn = false
            switch result {
            case .success(let payload):
                self.user = payload.user
                self.isAuthenticated = true
                self.loadContent()
            case .failure(let error):
                self.loginError = error.localizedDescription
            }
        }
    }

    func logout() {
        APIClient.shared.token = nil
        user = nil
        isAuthenticated = false
        chapters = []
        homework = []
        announcements = []
        chapterDetail = nil
        speech.stop()
        tts.stop()
    }

    // MARK: - Content

    func loadContent() {
        isLoadingContent = true
        contentError = nil
        content.loadDashboard { [weak self] result in
            guard let self = self else { return }
            self.isLoadingContent = false
            switch result {
            case .success(let payload):
                self.user = payload.user
                self.chapters = payload.chapters
                self.homework = payload.homework
                self.announcements = payload.announcements
            case .failure(let error):
                self.contentError = error.localizedDescription
            }
        }
    }

    func loadChapterDetail(id: String) {
        guard chapterDetail?.id != id else { return }
        isLoadingChapter = true
        chapterDetail = nil
        content.loadChapter(id: id) { [weak self] result in
            guard let self = self else { return }
            self.isLoadingChapter = false
            switch result {
            case .success(let chapter):
                self.chapterDetail = chapter
            case .failure:
                self.contentError = "Could not load this chapter."
            }
        }
    }
}
