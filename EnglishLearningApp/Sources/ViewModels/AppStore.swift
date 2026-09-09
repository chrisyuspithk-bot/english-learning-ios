import Foundation
import Combine

/// Central observable state for the POC, injected into the view hierarchy
/// via `.environmentObject(...)`. Kept as a single object for iOS 13
/// compatibility (no `@StateObject` needed).
final class AppStore: ObservableObject {

    // MARK: - Auth state
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false
    @Published var loginError: String?

    // MARK: - Content state
    @Published var chapters: [Chapter] = []
    @Published var homework: [HomeworkSession] = []
    @Published var announcements: [Announcement] = []
    @Published var isLoadingContent = false

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
            case .success(let user):
                self.user = user
                self.isAuthenticated = true
                self.loadContent()
            case .failure(let error):
                self.loginError = error.localizedDescription
            }
        }
    }

    func logout() {
        user = nil
        isAuthenticated = false
        chapters = []
        homework = []
        announcements = []
        speech.stop()
        tts.stop()
    }

    // MARK: - Content

    func loadContent() {
        isLoadingContent = true

        content.loadTextbook { [weak self] textbook in
            self?.chapters = textbook.chapters
            self?.isLoadingContent = false
        }
        content.loadHomework { [weak self] homework in
            self?.homework = homework
        }
        content.loadAnnouncements { [weak self] announcements in
            self?.announcements = announcements
        }
    }
}
