import SwiftUI

extension View {
    func placeholder(_ text: String = "", color: Color = .gray.opacity(0.5)) -> some View {
        self.modifier(PlaceholderStyle(show: text, color: color))
    }
}

private struct PlaceholderStyle: ViewModifier {
    let show: String
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content.opacity(0.99999) // para que SwiftUI no coma la interacción
        }
        .overlay(
            HStack {
                Text(show)
                    .foregroundColor(color)
                    .allowsHitTesting(false)
                Spacer()
            }
            .padding(.horizontal, 4)
            .opacity(isEmpty(content) ? 1 : 0)
        )
    }
    
    // SwiftUI no expone directamente el contenido, así que esto es simbólico.
    private func isEmpty(_ content: Content) -> Bool { true }
}
