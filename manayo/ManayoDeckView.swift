import SwiftUI

public struct ManayoDeckView: View {
    public let cards: [ManayoCard]
    public let metaProvider: (ManayoCard) -> ManayoCardMeta
    public let onSelect: (ManayoCard) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DeckTab = .all

    public init(
       cards: [ManayoCard],
       metaProvider: @escaping (ManayoCard) -> ManayoCardMeta,
       onSelect: @escaping (ManayoCard) -> Void
    ) {
       self.cards = cards
       self.metaProvider = metaProvider
       self.onSelect = onSelect
    }

    public enum DeckTab: String, CaseIterable, Identifiable {
        case all = "Todos"
        case favorites = "Favoritos"
        case new = "Nuevos"

        public var id: String { rawValue }
    }

    public var body: some View {
        NavigationStack {
            VStack {
                Text("Deck")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                Picker("Filtro", selection: $selectedTab) {
                    ForEach(DeckTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                let filteredCards = filtered(cards: cards, for: selectedTab)

                if filteredCards.isEmpty {
                    VStack(spacing: 8) {
                        Text(emptyTitle(for: selectedTab))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text(emptySubtitle(for: selectedTab))
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredCards) { card in
                        let meta = metaProvider(card)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.kana)
                                    .font(.headline)
                                Text(card.romaji)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                if meta.viewCount == 0 {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .transition(.scale.combined(with: .opacity))
                                }
                                if meta.isFavorite {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.yellow)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(card)
                            dismiss()
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private func filtered(cards: [ManayoCard], for tab: DeckTab) -> [ManayoCard] {
        cards.filter { card in
            let meta = metaProvider(card)

            switch tab {
            case .all:
                return true
            case .favorites:
                return meta.isFavorite
            case .new:
                return meta.viewCount == 0
            }
        }
    }

    private func emptyTitle(for tab: DeckTab) -> String {
        switch tab {
        case .all:
            return "No hay cartas."
        case .favorites:
            return "Sin favoritos aún."
        case .new:
            return "No hay cartas nuevas."
        }
    }

    private func emptySubtitle(for tab: DeckTab) -> String {
        switch tab {
        case .all:
            return "Agrega cartas desde el seed o la IA."
        case .favorites:
            return "Haz swipe a la derecha en una carta para marcarla como favorita."
        case .new:
            return "Todas las cartas ya fueron vistas al menos una vez."
        }
    }
}

#Preview("Deck – Preview") {
    ManayoDeckView(
        cards: ManayoPreviewData.cards,
        metaProvider: { card in
            ManayoPreviewData.meta(for: card)
        },
        onSelect: { _ in }
    )
}
