import Foundation

public struct ManayoCardMeta: Codable {
    public var viewCount: Int
    public var isFavorite: Bool

    public init(viewCount: Int = 0, isFavorite: Bool = false) {
        self.viewCount = viewCount
        self.isFavorite = isFavorite
    }
}

public final class ManayoMetaStore {
    public static let shared = ManayoMetaStore()

    private let fileName = "manayo_meta.json"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    public func loadMeta() -> [String: ManayoCardMeta] {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            let meta = try decoder.decode([String: ManayoCardMeta].self, from: data)
            return meta
        } catch {
            print("⚠️ Failed to load meta:", error)
            return [:]
        }
    }

    public func saveMeta(_ meta: [String: ManayoCardMeta]) {
        guard let url = fileURL else { return }

        do {
            let data = try encoder.encode(meta)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("⚠️ Failed to save meta:", error)
        }
    }
}
