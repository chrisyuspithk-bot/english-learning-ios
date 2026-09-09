import Foundation

/// Loads the dummy learning content. Swap the bodies for real API calls later.
final class ContentService {

    func loadTextbook(completion: @escaping (Textbook) -> Void) {
        // Simulate a short fetch.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(SampleContent.textbook)
        }
    }

    func loadHomework(completion: @escaping ([HomeworkSession]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(SampleContent.homework)
        }
    }

    func loadAnnouncements(completion: @escaping ([Announcement]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion(SampleContent.announcements)
        }
    }
}
