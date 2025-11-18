import SwiftUI

public struct ManayoDeckView: View {
    public struct Item: Identifiable {
        public let card: ManayoCard
        public let meta: ManayoCardMeta

        public var id: String { card.id }
    }

    public let items: [Item]
    public let onSelect: (ManayoCard) -> Void

    @Environment(\.dismiss) private var dismiss

    private enum Tab: String, CaseIterable {
        case all = "Todos"
        case favorites = "Favoritos"
        case new = "Nuevos"
    }

    @State private var selectedTab: Tab = .all

    public init(
        cards: [ManayoCard],
        metaProvider: (ManayoCard) -> ManayoCardMeta,
        onSelect: @escaping (ManayoCard) -> Void
    ) {
        self.items = cards.map { .init(card: $0, meta: metaProvider($0)) }
        self.onSelect = onSelect
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                topBar
                segmentedTabs
                listContent
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    private var topBar: some View {
        HStack {
            Button("Cerrar") {
                dismiss()
            }
            .foregroundColor(.blue)

            Spacer()

            Text("Deck")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Spacer()

            // spacer to balance layout
            Color.clear
                .frame(width: 44, height: 1)
        }
    }

    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedTab == tab ? Color.white : Color.clear)
                        )
                        .foregroundColor(
                            selectedTab == tab ? .black : .white.opacity(0.8)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
    }

    private var filteredItems: [Item] {
        switch selectedTab {
        case .all:
            return items
        case .favorites:
            return items.filter { $0.meta.isFavorite }
        case .new:
            return items.filter { $0.meta.viewCount < 2 }
        }
    }

    private var listContent: some View {
        Group {
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Text(emptyTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(emptySubtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredItems) { item in
                            deckRow(for: item)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var emptyTitle: String {
        switch selectedTab {
        case .all: return "No hay cartas en el deck."
        case .favorites: return "Todavía no tienes favoritos."
        case .new: return "Ya conoces todas tus cartas."
        }
    }

    private var emptySubtitle: String {
        switch selectedTab {
        case .all: return "Crea una nueva carta o genera una con IA."
        case .favorites: return "Haz swipe a la derecha en una carta para marcarla."
        case .new: return "Cuando lleguen cartas nuevas aparecerán aquí."
        }
    }

    private func deckRow(for item: Item) -> some View {
        Button {
            onSelect(item.card)
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.card.jp)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text(item.card.romaji)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if item.meta.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }

                    if item.meta.viewCount < 2 {
                        Text("NUEVO")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
        .buttonStyle(.plain)
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
