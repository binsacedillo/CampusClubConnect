import Foundation

struct ClubService {
    func fetchClubs(completion: @escaping (Result<[ClubDTO], Error>) -> Void) {
        guard let clubsURL = URL(
            string: "https://raw.githubusercontent.com/binsacedillo/CampusClubConnect/main/clubs.json"
        ) else {
            completion(.failure(ClubServiceError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: clubsURL) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data else {
                completion(.failure(ClubServiceError.invalidResponse))
                return
            }

            do {
                completion(.success(try JSONDecoder().decode([ClubDTO].self, from: data)))
            } catch {
                print("Club JSON decoding failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

private enum ClubServiceError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The club data URL is invalid."
        case .invalidResponse:
            return "The club server returned an unsuccessful response."
        }
    }
}
