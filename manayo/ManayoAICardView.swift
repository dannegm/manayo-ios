import SwiftUI

public struct ManayoAICardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ManayoAICardViewModel()

    @State private var promptText: String = ""

    public let onSave: (ManayoNewCardDraft) -> Void

    public init(onSave: @escaping (ManayoNewCardDraft) -> Void = { _ in }) {
        self.onSave = onSave
    }

    public var body: some View {
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
                topBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if viewModel.suggestion == nil && viewModel.errorMessage == nil {
                            // sólo mostramos estas secciones cuando aún NO hay carta
                            promptSection
                            dividerSection
                            surpriseSection
                        }

                        resultSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView()
                    Text("Invocando un nuevo hechizo…")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button("Cerrar") {
                dismiss()
            }
            .foregroundColor(.blue)

            Spacer()

            Text("Carta generada por IA")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            Spacer()

            Color.clear
                .frame(width: 44, height: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe tu hechizo")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            Text("Cuéntale a la IA qué tipo de frase quieres. Puede ser el mood, la intención o el contexto.")
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
            .placeholder(color: .white.opacity(0.35))

            Button(action: {
                Task {
                    await viewModel.generate(
                        mode: .prompt(promptText)
                    )
                }
            }) {
                HStack {
                    Spacer()
                    Text("Generar con esta descripción")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(
                    promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
                    ? Color.white.opacity(0.15)
                    : Color.white
                )
                .foregroundColor(
                    promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
                    ? Color.black.opacity(0.4)
                    : Color.black
                )
                .clipShape(Capsule())
            }
            .disabled(
                promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading
            )
        }
    }

    private var dividerSection: some View {
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
        .padding(.top, 4)
    }

    private var surpriseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quiero que la IA me sorprenda")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            Text("Deja que manayō invente una carta nueva a partir del mazo existente.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Button(action: {
                Task {
                    await viewModel.generate(mode: .surprise)
                }
            }) {
                HStack {
                    Spacer()
                    Text("Sorpréndeme")
                        .font(.footnote.weight(.semibold))
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(
                    viewModel.isLoading
                    ? Color.white.opacity(0.15)
                    : Color.white.opacity(0.12)
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(viewModel.isLoading)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if let error = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 8) {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)

                Button(action: {
                    Task {
                        await viewModel.retry()
                    }
                }) {
                    Text("Reintentar")
                        .font(.caption.weight(.semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 12)
        } else if let suggestion = viewModel.suggestion {
            aiPreviewCard(from: suggestion)
        }
    }

    private func aiPreviewCard(from suggestion: ManayoAISuggestion) -> some View {
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
            source: suggestion.source ?? "ia",
        )

        return VStack(alignment: .leading, spacing: 16) {
            ManayoCardView(
                card: card,
                viewCount: 0,
                isFavorite: false
            )

            if suggestion.duplicate == true {
                Text("⚠️ Posible duplicado de una carta existente")
                    .font(.caption2)
                    .foregroundColor(.yellow.opacity(0.9))
            }

            HStack(spacing: 12) {
                Button(action: {
                    Task {
                        await viewModel.retry()
                    }
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
                    if let draft = viewModel.makeDraftFromSuggestion() {
                        onSave(draft)
                    }
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
            .padding(.top, 4)
        }
        .padding(.top, 20)
    }
}

#Preview {
    ManayoAICardView { draft in
        print("Preview save:", draft.jp, draft.meaning)
    }
}
