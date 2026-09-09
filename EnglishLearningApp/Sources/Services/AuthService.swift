import Foundation

enum AuthError: LocalizedError {
    case emptyFields

    var errorDescription: String? {
        switch self {
        case .emptyFields: return "Please enter your username and password."
        }
    }
}

/// Dummy authentication for the POC. Any non-empty credentials succeed and
/// return the sample user. Replace with a real backend call later.
final class AuthService {

    func login(username: String, password: String,
               completion: @escaping (Result<User, Error>) -> Void) {
        // Simulate a short network round-trip.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty, !password.isEmpty else {
                completion(.failure(AuthError.emptyFields))
                return
            }
            completion(.success(SampleContent.user))
        }
    }
}
