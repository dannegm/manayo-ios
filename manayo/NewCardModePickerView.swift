import SwiftUI

public struct NewCardModePickerView: View {
    public let onManual: () -> Void
    public let onAI: () -> Void
    
    @ObservedObject public var viewModel: ManayoViewModel

    public init(
        viewModel: ManayoViewModel,
        onManual: @escaping () -> Void,
        onAI: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onManual = onManual
        self.onAI = onAI
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

            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Nueva carta")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                    Text("Elige cómo quieres invocarla")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 12)

                Button(action: onManual) {
                    HStack(spacing: 14) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 24, weight: .medium))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Crear manualmente")
                                .font(.headline)
                            Text("Escribe tú la frase, tono e intensidad.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                
                Button(action: onAI) {
                    HStack(spacing: 14) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 24, weight: .medium))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Generar con IA")
                                .font(.headline)
                            Text("Deja que la IA proponga un nuevo spell.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(!viewModel.iaEnabled)
                .opacity(viewModel.iaEnabled ? 1 : 0.35)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
        }
        .task {
            await viewModel.refreshIAEnabled()
        }
    }
}

#Preview {
    NewCardModePickerView(
        viewModel: ManayoViewModel(),
        onManual: {},
        onAI: {}
    )
}
