import Foundation

struct ManayoCreatePayload: Encodable {
    let jp: String
    let kana: String
    let romaji: String
    let type: String
    let intensity: Int
    let meaning: String
    let usage: ManayoUsagePayload?
    let flavor: String?
    let source: String

    struct ManayoUsagePayload: Encodable {
        let jp: String?
        let kana: String?
        let romaji: String?
        let es: String?
    }
}

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
    
    public func createCard(from draft: ManayoNewCardDraft) async throws -> ManayoCard {
        let url = baseURL.appendingPathComponent("/api/collections/\(collection)/records")

        let usagePayload = ManayoCreatePayload.ManayoUsagePayload(
            jp: draft.usageJp,
            kana: draft.usageJp, // por ahora mismo valor
            romaji: draft.usageRomaji,
            es: draft.usageEs
        )

        let payload = ManayoCreatePayload(
            jp: draft.jp,
            kana: draft.jp, // por ahora mismo valor
            romaji: draft.romaji,
            type: draft.type,
            intensity: draft.intensity,
            meaning: draft.meaning,
            usage: (draft.usageJp == nil && draft.usageRomaji == nil && draft.usageEs == nil) ? nil : usagePayload,
            flavor: draft.flavor,
            source: draft.source
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // si luego necesitas auth, aquí va el header de token

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await urlSession.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
            print("❌ Create HTTP error")
            print(body)
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        let created = try decoder.decode(ManayoCard.self, from: data)
        return created
    }
}
