import Foundation

// MARK: - API client (shared networking + bearer token)

final class APIClient {
    static let shared = APIClient()

    /// Point this at your backend. Use your Mac's LAN IP for a physical device,
    /// e.g. `URL(string: "http://192.168.1.10:12000")!`.
    static let baseURL = URL(string: "http://127.0.0.1:12000")!

    var token: String?

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private let encoder = JSONEncoder()

    enum APIError: LocalizedError {
        case badStatus(Int, String)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code, let detail):
                return detail.isEmpty ? "Request failed (HTTP \(code))" : detail
            }
        }
    }

    func request<T: Decodable>(_ path: String,
                               method: String = "GET",
                               body: Encodable? = nil,
                               completion: @escaping (Result<T, Error>) -> Void) {
        var base = APIClient.baseURL.absoluteString
        if base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: base + path) else {
            completion(.failure(APIError.badStatus(-1, "Invalid URL")))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            request.httpBody = try? encoder.encode(body)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(APIError.badStatus(-1, "No data")))
                    return
                }
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    let detail = ((try? JSONSerialization.jsonObject(with: data)) as? [String: Any])?["detail"] as? String ?? ""
                    completion(.failure(APIError.badStatus(http.statusCode, detail)))
                    return
                }
                do {
                    completion(.success(try self.decoder.decode(T.self, from: data)))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - Login request body

private struct LoginBody: Encodable {
    let username: String
    let password: String
}

// MARK: - Auth errors

enum AuthError: LocalizedError {
    case emptyFields

    var errorDescription: String? {
        switch self {
        case .emptyFields: return "Please enter your username and password."
        }
    }
}

/// Real authentication against `POST /api/auth/student/login`.
final class AuthService {

    func login(username: String, password: String,
               completion: @escaping (Result<(token: String, user: User), Error>) -> Void) {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !password.isEmpty else {
            completion(.failure(AuthError.emptyFields))
            return
        }

        APIClient.shared.request("/api/auth/student/login",
                                 method: "POST",
                                 body: LoginBody(username: name, password: password)) { (result: Result<LoginResponse, Error>) in
            switch result {
            case .success(let response):
                APIClient.shared.token = response.token
                completion(.success((response.token, APIMapper.user(from: response.user))))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
