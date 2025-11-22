import SwiftUI

public struct ManayoKanjiPopupContent: View {
    public let info: KanjiAPIResponse

    @Binding public var showAllKun: Bool
    @Binding public var showAllOn: Bool
    @Binding public var showAllNames: Bool

    public init(
        info: KanjiAPIResponse,
        showAllKun: Binding<Bool>,
        showAllOn: Binding<Bool>,
        showAllNames: Binding<Bool>
    ) {
        self.info = info
        self._showAllKun = showAllKun
        self._showAllOn = showAllOn
        self._showAllNames = showAllNames
    }

    private var primaryMeaning: String? {
        info.meanings.first
    }

    private var secondaryMeanings: [String] {
        Array(info.meanings.dropFirst())
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

            GeometryReader { geo in
                
                ScrollView {
                    VStack(spacing: 16) {
                        // kanji + lecturas
                        HStack(alignment: .top, spacing: 20) {
                            Text(info.kanji)
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                if !info.kunReadings.isEmpty {
                                    readingSection(
                                        title: "kun-yomi",
                                        readings: info.kunReadings,
                                        showAll: $showAllKun
                                    )
                                }
                                
                                if !info.onReadings.isEmpty {
                                    readingSection(
                                        title: "on-yomi",
                                        readings: info.onReadings,
                                        showAll: $showAllOn
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                            .padding(.top, 8)
                        }
                        
                        /*
                         if hasExtraReadings {
                         Button {
                         showAllKun = true
                         showAllOn = true
                         showAllNames = true
                         } label: {
                         Text("Ver lista completa")
                         .font(.subheadline)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity)
                         .padding(.vertical, 10)
                         .background(Color.white.opacity(0.08))
                         .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                         }
                         }
                         */
                        
                        
                        // Meanings
                        VStack(spacing: 8) {
                            HStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(height: 1)
                                Text("Meanings")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                Rectangle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(height: 1)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            
                            if !info.meanings.isEmpty {
                                TagFlowLayout(spacing: 8) {
                                    if let primary = primaryMeaning {
                                        Text(primary)
                                            .font(.caption.weight(.semibold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.9))
                                            .foregroundColor(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                    
                                    ForEach(secondaryMeanings, id: \.self) { meaning in
                                        Text(meaning)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.2))
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Sin significados disponibles.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Spacer()
                        
                        Divider()
                            .overlay(Color.white.opacity(0.5))
                        
                        footerRow
                    }
                    .frame(minHeight: geo.size.height, alignment: .top)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var hasExtraReadings: Bool {
        info.kunReadings.count >= 3 ||
        info.onReadings.count >= 3 ||
        info.nameReadings.count >= 3
    }

    private func readingSection(
        title: String,
        readings: [String],
        showAll: Binding<Bool>
    ) -> some View {
        let visible: [String]
        let extraCount: Int

        if showAll.wrappedValue {
            visible = readings
            extraCount = 0
        } else {
            visible = Array(readings.prefix(2))
            extraCount = max(0, readings.count - visible.count)
        }

        return VStack(alignment: .leading, spacing: 4) {
            TagFlowLayout(spacing: 6) {
                ForEach(visible, id: \.self) { reading in
                    Text(reading)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                if extraCount > 0 && !showAll.wrappedValue {
                    Button {
                        showAll.wrappedValue = true
                    } label: {
                        Text("+\(extraCount)")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.4))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private var footerRow: some View {
        HStack {
            Spacer()
            
            footerItem(
                label: "GRADE",
                value: info.grade.map { "\($0)" } ?? "—"
            )
            
            Spacer()

            Divider()
                .frame(height: 16)
                .overlay(Color.white.opacity(0.6))
            
            Spacer()

            footerItem(
                label: "JLPT",
                value: info.jlpt.map { "N\($0)" } ?? "—"
            )
            
            Spacer()

            Divider()
                .frame(height: 16)
                .overlay(Color.white.opacity(0.6))
            
            Spacer()

            footerItem(
                label: "STROKES",
                value: info.strokeCount.map { "\($0)" } ?? "—"
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func footerItem(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ManayoKanjiPopupContent(
        info: KanjiAPIResponse(
            kanji: "生",
            grade: 1,
            strokeCount: 5,
            meanings: ["life", "birth", "genuine", "raw"],
            kunReadings: ["い.きる", "う.まれる", "なま", "は.える", "む.す"],
            onReadings: ["セイ", "ショウ"],
            nameReadings: ["あさ", "いき", "ふ", "み"],
            jlpt: 5,
            unicode: "751F"
        ),
        showAllKun: .constant(false),
        showAllOn: .constant(false),
        showAllNames: .constant(false)
    )
    .padding()
}
