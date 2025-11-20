import SwiftUI

public struct ManayoKanjiPopupView: View {
    public let kanji: Character

    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var info: KanjiAPIResponse?

    @State private var showAllKun = false
    @State private var showAllOn = false
    @State private var showAllNames = false

    public init(kanji: Character) {
        self.kanji = kanji
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

            Group {
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Cargando kanji…")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                        Button("Reintentar") {
                            Task { await loadKanji() }
                        }
                        .font(.footnote.weight(.semibold))
                    }
                } else if let info {
                    ManayoKanjiPopupContent(
                        info: info,
                        showAllKun: $showAllKun,
                        showAllOn: $showAllOn,
                        showAllNames: $showAllNames
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                } else {
                    Text("Sin datos para este kanji.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .task {
            await loadKanji()
        }
    }

    private func loadKanji() async {
        isLoading = true
        errorMessage = nil
        info = nil

        do {
            let result = try await ManayoKanjiAPI.shared.fetchKanjiInfo(for: kanji)
            await MainActor.run {
                self.info = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "No se pudo cargar la información del kanji."
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ManayoKanjiPopupView(kanji: "食")
}
