import Foundation

@MainActor
public final class ManayoViewModel: ObservableObject {
    @Published public private(set) var cards: [ManayoCard] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var meta: [String: ManayoCardMeta] = [:]

    public init() {}

    public func loadCards() async {
        isLoading = true
        errorMessage = nil

        meta = ManayoMetaStore.shared.loadMeta()

        if cards.isEmpty {
            let cached = ManayoLocalStore.shared.loadCards()
            if !cached.isEmpty {
                cards = cached
            }
        }

        do {
            let result = try await ManayoAPI.shared.fetchAllCards()
            let shuffled = result.shuffled()
            cards = shuffled
            ManayoLocalStore.shared.saveCards(shuffled)

            var newMeta = meta

            let ids = Set(shuffled.map { $0.id })
            newMeta = newMeta.filter { ids.contains($0.key) }

            for card in shuffled {
                if newMeta[card.id] == nil {
                    newMeta[card.id] = ManayoCardMeta()
                }
            }

            meta = newMeta
            ManayoMetaStore.shared.saveMeta(newMeta)
        } catch {
            if cards.isEmpty {
                let nsError = error as NSError
                print("❌ Remote fetch failed, no cache:", nsError)
                errorMessage = "Offline and no local deck available."
            } else {
                let nsError = error as NSError
                print("⚠️ Remote fetch failed, using cache:", nsError)
            }
        }

        isLoading = false
    }
    
    public func metaFor(card: ManayoCard) -> ManayoCardMeta {
        meta[card.id] ?? ManayoCardMeta()
    }

    public func incrementViewCount(for card: ManayoCard) {
        var current = meta[card.id] ?? ManayoCardMeta()
        current.viewCount += 1
        meta[card.id] = current
        ManayoMetaStore.shared.saveMeta(meta)
    }
    
    public func toggleFavorite(for card: ManayoCard) {
        var current = meta[card.id] ?? ManayoCardMeta()
        current.isFavorite.toggle()
        meta[card.id] = current
        ManayoMetaStore.shared.saveMeta(meta)
    }
    
    public func createCard(from draft: ManayoNewCardDraft) async {
        do {
            let created = try await ManayoAPI.shared.createCard(from: draft)

            cards.insert(created, at: 0)

            var newMeta = meta
            newMeta[created.id] = ManayoCardMeta()
            meta = newMeta
            ManayoMetaStore.shared.saveMeta(newMeta)

            ManayoLocalStore.shared.saveCards(cards)

            errorMessage = nil
        } catch {
            let nsError = error as NSError
            print("❌ Create card failed:", nsError)
            errorMessage = "No se pudo crear la carta. Intenta de nuevo."
        }
    }
}
