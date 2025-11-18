import SwiftUI

private enum AIWizardStep {
    case prompt
    case loading
    case result(ManayoAISuggestion)
    case error(String)
}

public struct ManayoAICardWizardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ManayoAICardViewModel()

    @State private var step: AIWizardStep = .prompt
    @State private var promptText: String = ""

    public let onSave: (ManayoNewCardDraft) -> Void

    public init(onSave: @escaping (ManayoNewCardDraft) -> Void = { _ in }) {
        self.onSave = onSave
    }
    
    private let stepTransition = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )

    public var body: some View {
        VStack(spacing: 0) {
            topBar

            ZStack {
                switch step {
                case .prompt:
                    promptView
                        .transition(stepTransition)

                case .loading:
                    loadingView
                        .transition(stepTransition)

                case .error(let message):
                    errorView(message: message)
                        .transition(stepTransition)

                case .result(let suggestion):
                    resultView(suggestion: suggestion)
                        .transition(stepTransition)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button("Cerrar") {
                dismiss()
            }
            .foregroundColor(.blue)

            Spacer()

            Text("Carta Mágica")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            Spacer()

            Color.clear
                .frame(width: 44, height: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Step views

    private var promptView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Describe tu hechizo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Cuéntale a la IA qué tipo de frase quieres: mood, intención o contexto.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                TextField(
                    "Ej. frase confiada pero cariñosa para amigos…",
                    text: $promptText,
                    axis: .vertical
                )
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .lineLimit(2...4)
                .textInputAutocapitalization(.sentences)
            }

            Button(action: {
                startGeneration(mode: .prompt(promptText))
            }) {
                HStack {
                    Spacer()
                    Text("Generar con esta descripción")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(canSendPrompt ? Color.white : Color.white.opacity(0.15))
                .foregroundColor(canSendPrompt ? .black : .black.opacity(0.4))
                .clipShape(Capsule())
            }
            .disabled(!canSendPrompt)

            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 1)

                Text("o")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)

                Rectangle()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Quiero que la IA me sorprenda")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Text("Deja que manayō invente una carta nueva a partir del mazo existente.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Button(action: {
                    startGeneration(mode: .surprise)
                }) {
                    HStack {
                        Spacer()
                        Text("Sorpréndeme")
                            .font(.footnote.weight(.semibold))
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.12))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            Spacer()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            LottieView(name: "manayo-loading", loopMode: .loop)
                .frame(width: 180, height: 180)
                .clipped()

            Text("Invocando un nuevo hechizo…")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Algo salió mal")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            Text(message)
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)

            Button(action: {
                withAnimation {
                    step = .prompt
                }
            }) {
                HStack {
                    Spacer()
                    Text("Volver a intentar")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(Capsule())
            }

            Spacer()
        }
    }

    private func resultView(suggestion: ManayoAISuggestion) -> some View {
        let card = ManayoCard(
            id: "ai-preview-\(UUID().uuidString)",
            jp: suggestion.jp,
            kana: suggestion.jp,
            romaji: suggestion.romaji,
            type: suggestion.type,
            intensity: suggestion.intensity,
            tags: nil,
            meaning: suggestion.meaning,
            usage: ManayoUsage(
                jp: suggestion.usage.jp,
                kana: suggestion.usage.kana,
                romaji: suggestion.usage.romaji,
                es: suggestion.usage.es
            ),
            flavor: suggestion.flavor,
            source: suggestion.source ?? "ia"
        )

        return VStack(alignment: .leading, spacing: 16) {
            ManayoCardView(
                card: card,
                viewCount: -1,
                isFavorite: false
            )

            if suggestion.duplicate == true {
                Text("⚠️ Posible duplicado de una carta existente")
                    .font(.caption2)
                    .foregroundColor(.yellow.opacity(0.9))
            }

            HStack(spacing: 12) {
                Button(action: {
                    retry()
                }) {
                    Text("Reintentar")
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Button(action: {
                    guard let draft = viewModel.makeDraftFromSuggestion() else { return }
                    onSave(draft)
                    dismiss()
                }) {
                    Text("Guardar")
                        .font(.footnote.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
    }

    // MARK: - Helpers

    private var canSendPrompt: Bool {
        !promptText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    private func startGeneration(mode: ManayoAICardViewModel.AIMode) {
        withAnimation {
            step = .loading
        }

        Task {
            await viewModel.generate(mode: mode)
            applyResultFromViewModel()
        }
    }

    private func retry() {
        withAnimation {
            step = .loading
        }

        Task {
            await viewModel.retry()
            applyResultFromViewModel()
        }
    }

    private func applyResultFromViewModel() {
        if let suggestion = viewModel.suggestion {
            withAnimation {
                step = .result(suggestion)
            }
        } else if let error = viewModel.errorMessage {
            withAnimation {
                step = .error(error)
            }
        } else {
            withAnimation {
                step = .prompt
            }
        }
    }
}

#Preview {
    ManayoAICardWizardView { draft in
        print("Preview save:", draft.jp, draft.meaning)
    }
}
