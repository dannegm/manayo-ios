import Foundation

public struct ManayoUsage: Codable {
    public let jp: String?
    public let kana: String?
    public let romaji: String?
    public let es: String?
}

public struct ManayoCard: Identifiable, Codable {
    public let id: String
    public let jp: String
    public let kana: String
    public let romaji: String

    public let type: String
    public let intensity: Int
    public let tags: [String]?

    public let meaning: String
    public let usage: ManayoUsage?
    public let flavor: String?
    public let source: String

    public let created: String?
    public let updated: String?
}

public struct PocketBaseListResponse<T: Codable>: Codable {
    public let page: Int
    public let perPage: Int
    public let totalItems: Int
    public let items: [T]
}
