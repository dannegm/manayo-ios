import Foundation

@MainActor
public final class ManayoAICardViewModel: ObservableObject {
    public enum AIMode {
        case surprise
        case prompt(String)
    }

    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var suggestion: ManayoAISuggestion?
    @Published public private(set) var errorMessage: String?

    private var lastMode: AIMode?

    public init() {}

    public func generate(mode: AIMode) async {
        isLoading = true
        errorMessage = nil
        suggestion = nil
        lastMode = mode

        do {
            let (modeString, desc) = Self.payload(from: mode)
            let result = try await ManayoAPI.shared.fetchAISuggestion(
                mode: modeString,
                description: desc
            )
            suggestion = result
        } catch {
            let nsError = error as NSError
            print("❌ AI suggestion failed:", nsError)
            errorMessage = "No se pudo generar una carta con IA."
        }

        isLoading = false
    }

    public func retry() async {
        guard let lastMode else { return }
        await generate(mode: lastMode)
    }

    private static func payload(from mode: AIMode) -> (String, String?) {
        switch mode {
        case .surprise:
            return ("surprise", nil)
        case .prompt(let text):
            return ("prompt", text)
        }
    }

    public func makeDraftFromSuggestion() -> ManayoNewCardDraft? {
        guard let s = suggestion else { return nil }

        let usage = s.usage

        return ManayoNewCardDraft(
            jp: s.jp,
            romaji: s.romaji,
            meaning: s.meaning,
            type: s.type,
            intensity: s.intensity,
            usageJp: usage.jp,
            usageRomaji: usage.romaji,
            usageEs: usage.es,
            flavor: s.flavor,
            source: "ia"
        )
    }
}
