import Foundation

/// Loads learning content from the backend `GET /api/app/*` endpoints.
final class ContentService {

    func loadDashboard(completion: @escaping (Result<DashboardPayload, Error>) -> Void) {
        APIClient.shared.request("/api/app/dashboard") { (result: Result<DashboardResponse, Error>) in
            switch result {
            case .success(let response):
                let payload = DashboardPayload(
                    user: APIMapper.user(from: response),
                    chapters: APIMapper.chapterSummaries(from: response.chapters),
                    homework: APIMapper.homework(from: response.homework),
                    announcements: APIMapper.announcements(from: response.announcements)
                )
                completion(.success(payload))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadChapter(id: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        APIClient.shared.request("/api/app/chapters/\(id)") { (result: Result<ChapterDetailResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(APIMapper.chapter(from: response)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct DashboardPayload {
    let user: User
    let chapters: [ChapterSummary]
    let homework: [HomeworkSession]
    let announcements: [Announcement]
}
