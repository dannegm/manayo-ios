import Foundation

public struct KanjiAPIResponse: Decodable {
    public let kanji: String
    public let grade: Int?
    public let strokeCount: Int?
    public let meanings: [String]
    public let kunReadings: [String]
    public let onReadings: [String]
    public let nameReadings: [String]
    public let jlpt: Int?
    public let unicode: String?
}

public final class ManayoKanjiAPI {
    public static let shared = ManayoKanjiAPI()
    private init() {}

    public func fetchKanjiInfo(for kanji: Character) async throws -> KanjiAPIResponse {
        let baseURL = URL(string: "https://kanjiapi.dev")!
        let url = baseURL.appendingPathComponent("v1/kanji/\(kanji)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(KanjiAPIResponse.self, from: data)
    }
}
