import Foundation

public final class ManayoAPI {
    public static let shared = ManayoAPI()

    private let baseURL = URL(string: ManayoConfig.baseURL)!
    private let collection = ManayoConfig.collection
    private let urlSession: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.urlSession = URLSession(configuration: config)
    }

    public func fetchAllCards() async throws -> [ManayoCard] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("/api/collections/\(collection)/records"),
            resolvingAgainstBaseURL: false
        )!

        components.queryItems = [
            URLQueryItem(name: "perPage", value: "200"),
            URLQueryItem(name: "sort", value: "jp"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await urlSession.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
            print("❌ HTTP error:", http.statusCode)
            print("❌ Body:", body)
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let list = try decoder.decode(PocketBaseListResponse<ManayoCard>.self, from: data)
        return list.items
    }
}
