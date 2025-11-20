import SwiftUI

public struct ManayoJPInteractiveText: View {
    public let text: String
    public let onKanjiTap: (Character) -> Void

    @State private var highlightedKanji: Character?

    public init(
        text: String,
        onKanjiTap: @escaping (Character) -> Void
    ) {
        self.text = text
        self.onKanjiTap = onKanjiTap
    }
    
    private var characters: [Character] {
        Array(text)
    }

    public var body: some View {
        let chars: [Character] = Array(text)   // fuerza un array real, sin RangeSets

        HStack(spacing: 2) {
            ForEach(Array(chars.enumerated()), id: \.offset) { index, ch in

                if isKanji(ch) {
                    Button {
                        highlightedKanji = ch
                        onKanjiTap(ch)
                    } label: {
                        Text(String(ch))
                            .foregroundColor(isKanji(ch) ? .white : .white.opacity(0.6))
                            .font(.system(size: 32, weight: .bold))
                            .background(
                                GeometryReader { geo in
                                    // Sólo dibujar si es kanji
                                    if isKanji(ch) {
                                        Path { path in
                                            let y = geo.size.height + 2  // separación desde el carácter
                                            path.move(to: .init(x: 0, y: y))
                                            path.addLine(to: .init(x: geo.size.width, y: y))
                                        }
                                        .stroke(
                                            Color.white.opacity(0.35),
                                            style: StrokeStyle(
                                                lineWidth: 3,       // grosor del underline visible
                                                dash: [5, 3]        // punteado
                                            )
                                        )
                                    }
                                }
                            )
                            .background(
                                isKanji(ch) && highlightedKanji == ch
                                ? RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.white.opacity(0.15))
                                : nil
                            )
                    }
                    .buttonStyle(.plain)

                } else {
                    Text(String(ch))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func isKanji(_ ch: Character) -> Bool {
        guard let scalar = ch.unicodeScalars.first else { return false }
        let value = scalar.value

        // rango básico de CJK (kanji) + extensión A (por si acaso)
        return (0x4E00...0x9FFF).contains(value) ||
               (0x3400...0x4DBF).contains(value)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 0.05, green: 0.05, blue: 0.1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
            Text("Preview kanji tap")
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)

            ManayoJPInteractiveText(
                text: "今日も猫と遊ぶぞ。",
                onKanjiTap: { ch in
                    print("Preview tapped kanji:", ch)
                }
            )
            .font(.footnote)
        }
        .padding()
    }
}
