import SwiftUI

public struct ManayoJPInteractiveText: View {
    public let text: String
    public let highlighted: Character?
    public let onKanjiTap: (Character) -> Void

    public init(
        text: String,
        highlighted: Character? = nil,
        onKanjiTap: @escaping (Character) -> Void
    ) {
        self.text = text
        self.highlighted = highlighted
        self.onKanjiTap = onKanjiTap
    }
    
    private var characters: [Character] {
        Array(text)
    }

    public var body: some View {
        let chars: [Character] = Array(text)   // fuerza un array real, sin RangeSets

        TagFlowLayout(spacing: 2) {
            ForEach(Array(chars.enumerated()), id: \.offset) { index, ch in

                if isKanji(ch) {
                    Button {
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
                                            let y = geo.size.height - 2  // separación desde el carácter
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
                                isKanji(ch) && highlighted == ch
                                ? RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.yellow.opacity(0.75))
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
    VStack {
        ManayoJPInteractiveText(
            text: "今日も猫 と遊ぶぞ今日も猫と遊ぶぞ今日も猫と遊ぶぞ。",
            highlighted: "猫",
            onKanjiTap: { ch in
                print("Preview tapped kanji:", ch)
            }
        )
        
        Spacer()
    }
    .padding()
    .padding(.top, 32)
}
