import SwiftUI

struct ManayoKanjiSelection: Identifiable {
    let value: Character
    var id: String { String(value) }
}

public struct ManayoCardView: View {
    public let card: ManayoCard
    public let viewCount: Int
    public let isFavorite: Bool
    
    @State private var kanjiForPopup: ManayoKanjiSelection? = nil
    
    public init(card: ManayoCard, viewCount: Int, isFavorite: Bool) {
        self.card = card
        self.viewCount = viewCount
        self.isFavorite = isFavorite
    }

    public var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width * 0.9, 380)
            let height = width / 0.7

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .shadow(radius: 10)

                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            
                            ManayoJPInteractiveText(
                                text: card.jp,
                                highlighted: kanjiForPopup?.value,
                                onKanjiTap: { ch in
                                    kanjiForPopup = ManayoKanjiSelection(value: ch)
                                }
                            )
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                            Text(card.romaji)
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(card.type)
                                .font(.caption2.weight(.semibold))
                                .textCase(.uppercase)
                                .foregroundColor(.white.opacity(0.8))

                            Text("INT \(card.intensity)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    Text(card.meaning)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    if let usage = card.usage {
                        sectionHeader("Ejemplo de uso")
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if let jp = usage.jp {
                                Text(jp)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                            }
                            if let romaji = usage.romaji {
                                Text(romaji)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                    .italic()
                                    .padding(.top, 8)
                            }
                            if let es = usage.es {
                                Text(es)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            
                            if let jp = usage.jp, !jp.isEmpty {
                                Button(action: {
                                    ManayoSpeech.shared.speakUsage(card: card)
                                }) {
                                    Text("Escuchar")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                .padding(.top, 8)
                            }
                        }
                    }

                    Spacer()
                    
                    Button(action: {
                        ManayoSpeech.shared.speak(card: card)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    if let flavor = card.flavor {
                        Text(flavor)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .italic()
                            .padding(.top, 8)
                    }
                    
                    
                    if viewCount < 2 {
                        Text("NUEVO")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    } else {
                        Text("Visto \(viewCount) veces")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(16)
            }
            .frame(width: width, height: height)
            .overlay(alignment: .bottomTrailing) {
                if isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(16)
                }
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2 - ((geo.size.height / 32) * 2))
        }
        .sheet(item: $kanjiForPopup, onDismiss: {
            kanjiForPopup = nil
        }) { selection in
            ManayoKanjiPopupView(kanji: selection.value)
                .presentationDetents([.height(380)])
                .presentationBackground(.clear)
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            Text(text)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 6)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
}

#Preview("Card – Preview") {
    ManayoCardView(
        card: ManayoPreviewData.card,
        viewCount: 0,
        isFavorite: true
    )
}
