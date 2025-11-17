import Foundation

public final class ManayoLocalStore {
    public static let shared = ManayoLocalStore()

    private let fileName = "manayo_cards.json"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        encoder.outputFormatting = [.prettyPrinted]
    }

    private var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    public func loadCards() -> [ManayoCard] {
        guard let url = fileURL,
              FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let cards = try decoder.decode([ManayoCard].self, from: data)
            return cards
        } catch {
            print("⚠️ Failed to load cached cards:", error)
            return []
        }
    }

    public func saveCards(_ cards: [ManayoCard]) {
        guard let url = fileURL else { return }

        do {
            let data = try encoder.encode(cards)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("⚠️ Failed to save cached cards:", error)
        }
    }
}
