import Foundation

struct ManayoPreviewData {
    static let usage = ManayoUsage(
        jp: "まじかよ！そんなことある？",
        kana: "まじかよ！そんなことある？",
        romaji: "majikayo! sonna koto aru?",
        es: "¿Neta? ¿Eso puede pasar?"
    )

    static let card = ManayoCard(
        id: "preview-1",
        jp: "まじかよ",
        kana: "まじかよ",
        romaji: "majikayo",
        type: "slang",
        intensity: 2,
        tags: ["surprise", "casual"],
        meaning: "¿Es en serio?",
        usage: usage,
        flavor: "Cuando la realidad te trolea muy fuerte.",
        source: "official",
        created: nil,
        updated: nil
    )

    static let anotherCard = ManayoCard(
        id: "preview-2",
        jp: "ついてこい",
        kana: "ついてこい",
        romaji: "tsuite koi",
        type: "command",
        intensity: 3,
        tags: ["bossy"],
        meaning: "Sígueme.",
        usage: ManayoUsage(
            jp: "危ないから、ついてこい。",
            kana: "あぶないから、ついてこい。",
            romaji: "abunai kara, tsuite koi.",
            es: "Es peligroso, sígueme."
        ),
        flavor: "Energía de prota que sabe lo que hace.",
        source: "official",
        created: nil,
        updated: nil
    )

    static let cards: [ManayoCard] = [
        card,
        anotherCard,
    ]

    static func meta(for card: ManayoCard) -> ManayoCardMeta {
        switch card.id {
        case "preview-1":
            return ManayoCardMeta(viewCount: 3, isFavorite: true)
        case "preview-2":
            return ManayoCardMeta(viewCount: 0, isFavorite: false)
        default:
            return ManayoCardMeta()
        }
    }
}
