import SwiftUI

public struct ManayoNewCardDraft {
    public let jp: String
    public let romaji: String
    public let meaning: String
    public let type: String
    public let intensity: Int
    public let usageJp: String?
    public let usageRomaji: String?
    public let usageEs: String?
    public let flavor: String?
    public let source: String
}

enum ManayoNewCardMode: String, CaseIterable {
    case japaneseFirst = "jp_first"
    case spanishFirst = "es_first"
}

enum Field: Hashable {
    case jp
    case romaji
    case meaning
    case usageJP
    case usageRomaji
    case usageES
    case flavor
}

public struct NewCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    public let onSave: (ManayoNewCardDraft) -> Void
    
    @State private var mode: ManayoNewCardMode = .japaneseFirst
    
    @State private var jp: String = ""
    @State private var romaji: String = ""
    @State private var meaning: String = ""
    
    @State private var type: String = "instant"
    @State private var intensityValue: Double = 3
    
    @State private var usageJp: String = ""
    @State private var usageRomaji: String = ""
    @State private var usageEs: String = ""
    
    @State private var flavor: String = ""
    
    @FocusState private var focusedField: Field?
    
    private let types = [
        "instant",
        "sorcery",
        "enchantment",
        "creature",
        "slang",
        "command",
        "expression",
    ]
    
    private var intensity: Int {
        Int(intensityValue.rounded())
    }
    
    private var isValid: Bool {
        !jp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !meaning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public init(onSave: @escaping (ManayoNewCardDraft) -> Void) {
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 0) {
                    topBar
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            modeSelector
                            coreFields
                            detailsSection
                            usageSection
                            flavorSection
                            
                            Button(action: handleSave) {
                                HStack {
                                    Spacer()
                                    Text("Guardar carta")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .background(isValid ? Color.white : Color.white.opacity(0.2))
                                .clipShape(Capsule())
                            }
                            .padding(.top, 10)
                            .disabled(!isValid)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    private var topBar: some View {
        HStack {
            Button("Cancelar") {
                dismiss()
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Text("Nueva carta")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Guardar") {
                handleSave()
            }
            .foregroundColor(isValid ? .blue : .gray)
            .disabled(!isValid)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color(red: 0.05, green: 0.05, blue: 0.1).opacity(0.95),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("¿Cómo quieres empezar?")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                modePill(
                    title: "Primero japonés",
                    isSelected: mode == .japaneseFirst
                ) {
                    mode = .japaneseFirst
                    focusedField = .jp
                }
                modePill(
                    title: "Primero español",
                    isSelected: mode == .spanishFirst
                ) {
                    mode = .spanishFirst
                    focusedField = .meaning
                }
            }
            .padding(6)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    
    private func modePill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(isSelected ? .black : .white.opacity(0.8))
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(
                    isSelected
                    ? Color.white
                    : Color.white.opacity(0.0)
                )
                .clipShape(Capsule())
        }
    }
    
    private var coreFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contenido principal")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            
            if mode == .japaneseFirst {
                cardField(
                    title: "Japonés",
                    placeholder: "真名やキメ台詞など",
                    text: $jp,
                    field: .jp,
                    next: .romaji,
                    isJP: true
                )
                cardField(
                    title: "Romaji",
                    placeholder: "mana yo / yare yare daze…",
                    text: $romaji,
                    field: .romaji,
                    next: .meaning,
                    isJP: false
                )
                cardField(
                    title: "Significado (español)",
                    placeholder: "Qué significa / cómo lo usarías",
                    text: $meaning,
                    field: .meaning,
                    next: .usageJP,
                    isJP: false
                )
            } else {
                cardField(
                    title: "Significado (español)",
                    placeholder: "Qué quieres decir con esta carta",
                    text: $meaning,
                    field: .meaning,
                    next: .jp,
                    isJP: false
                )
                cardField(
                    title: "Japonés",
                    placeholder: "Luego lo afinamos con IA",
                    text: $jp,
                    field: .jp,
                    next: .romaji,
                    isJP: true
                )
                cardField(
                    title: "Romaji",
                    placeholder: "Se sugerirá a partir del japonés",
                    text: $romaji,
                    field: .romaji,
                    next: .usageJP,
                    isJP: false
                )
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detalles")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(types, id: \.self) { t in
                            Button(action: { type = t }) {
                                Text(t.uppercased())
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(type == t ? .black : .white.opacity(0.8))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(
                                        type == t
                                        ? Color.white
                                        : Color.white.opacity(0.08)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Intensidad")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(intensity)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                }
                
                Slider(value: $intensityValue, in: 1...5, step: 1)
            }
        }
    }
    
    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ejemplo de uso")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            
            cardField(
                title: "Frase en japonés",
                placeholder: "Frase completa donde usarías la carta",
                text: $usageJp,
                field: .usageJP,
                next: .usageRomaji,
                isJP: true
            )
            
            cardField(
                title: "Romaji (sugerido por IA)",
                placeholder: "Se llenará a partir del japonés",
                text: $usageRomaji,
                field: .usageRomaji,
                next: .usageES,
                isJP: false
            )
            
            cardField(
                title: "Traducción al español",
                placeholder: "Sentido de la frase",
                text: $usageEs,
                field: .usageES,
                next: .flavor,
                isJP: false
            )
        }
    }
    
    private var flavorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flavor text")
                .font(.caption.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
            
            cardField(
                title: "Sabor de la carta",
                placeholder: "Una línea con personalidad (se puede sugerir con IA)",
                text: $flavor,
                field: .flavor,
                next: nil,
                isJP: false,
                multiline: true
            )
        }
    }
    
    private func cardField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        next: Field?,
        isJP: Bool,
        multiline: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            if multiline {
                TextField(placeholder, text: text, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .lineLimit(2...4)
                    .focused($focusedField, equals: field)
                    .submitLabel(next == nil ? .done : .next)
                    .onSubmit {
                        if let next = next {
                            focusedField = next
                        } else {
                            handleSave()
                        }
                    }
            } else {
                TextField(placeholder, text: text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .focused($focusedField, equals: field)
                    .submitLabel(next == nil ? .done : .next)
                    .onSubmit {
                        if let next = next {
                            focusedField = next
                        } else {
                            handleSave()
                        }
                    }
                    .textInputAutocapitalization(isJP ? .never : .sentences)
                    .autocorrectionDisabled(isJP)
            }
        }
    }
    
    private func handleSave() {
        guard isValid else { return }
        
        let trimmedJp = jp.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRomaji = romaji.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMeaning = meaning.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let draft = ManayoNewCardDraft(
            jp: trimmedJp,
            romaji: trimmedRomaji,
            meaning: trimmedMeaning,
            type: type,
            intensity: intensity,
            usageJp: usageJp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : usageJp,
            usageRomaji: usageRomaji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : usageRomaji,
            usageEs: usageEs.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : usageEs,
            flavor: flavor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : flavor,
            source: "user"
        )
        
        onSave(draft)
        dismiss()
    }
}

#Preview {
    NewCardView { draft in
        print("Preview saved:", draft.jp, draft.meaning)
    }
}
