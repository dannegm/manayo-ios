import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ManayoViewModel()
    
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1.0
    @State private var cardScale: CGFloat = 1.0
    @State private var showDeck: Bool = false
    
    @State private var showNewCardSheet: Bool = false
    @State private var showMenuSheet: Bool = false
    @State private var newCardMode: NewCardMode = .choice
    @State private var sheetDetent: PresentationDetent = .fraction(0.35)
    
    private enum NewCardMode {
        case choice
        case manual
        case ai
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Group {
                    // 1) If we already have cards, ALWAYS show the main card UI
                    if let current = viewModel.cards[safe: currentIndex] {
                        let meta = viewModel.metaFor(card: current)
                        
                        ZStack {
                            ManayoCardView(
                                card: current,
                                viewCount: meta.viewCount,
                                isFavorite: meta.isFavorite
                            )
                            .offset(dragOffset)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                            .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation
                                    }
                                    .onEnded { value in
                                        let horizontalThreshold: CGFloat = 80
                                        let verticalThreshold: CGFloat = 100
                                        let translation = value.translation
                                        
                                        // vertical swipe → open deck
                                        if abs(translation.height) > verticalThreshold &&
                                            abs(translation.width) < horizontalThreshold {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                dragOffset = .zero
                                                cardScale = 1.0
                                            }
                                            showDeck = true
                                            return
                                        }
                                        
                                        if translation.width > horizontalThreshold {
                                            favoriteAndAdvance()
                                        } else if translation.width < -horizontalThreshold {
                                            discardAndAdvance()
                                        } else {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                dragOffset = .zero
                                                cardScale = 1.0
                                            }
                                        }
                                    }
                            )
                            
                            bottomNavBar
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(.hidden, for: .navigationBar)
                        
                        // Optional: tiny loading badge if syncing in background
                        if viewModel.isLoading {
                            VStack {
                                Spacer()
                                Text("Syncing…")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.bottom, 8)
                            }
                            .transition(.opacity)
                        }
                        
                        // 2) No cards yet, but still loading → first-time loading state
                    } else if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading your deck…")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        // 3) Error and no cards
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task {
                                    await viewModel.loadCards()
                                }
                            }
                        }
                        
                        // 4) No cards, no error, no loading → empty state
                    } else {
                        Text("No cards available.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .task {
            await viewModel.loadCards()
            currentIndex = 0
            cardOpacity = 1.0
            cardScale = 1.0
            markCurrentSeen()
        }
        .sheet(isPresented: $showDeck) {
            ManayoDeckView(
                cards: viewModel.cards,
                metaProvider: { card in
                    viewModel.metaFor(card: card)
                },
                onSelect: { selected in
                    selectCardFromDeck(selected)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showNewCardSheet) {
            ZStack {
                // Fondo compartido para TODO el flujo
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
                    switch newCardMode {
                    case .choice:
                        NewCardModePickerView(
                            onManual: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    newCardMode = .manual
                                    sheetDetent = .large
                                }
                            },
                            onAI: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    newCardMode = .ai
                                    sheetDetent = .large
                                }
                            }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        
                    case .manual:
                        NewCardView { draft in
                            Task {
                                await viewModel.createCard(from: draft)
                                
                                if let newIndex = viewModel.cards.firstIndex(where: {
                                    $0.jp == draft.jp && $0.meaning == draft.meaning
                                }) {
                                    currentIndex = newIndex
                                    markCurrentSeen()
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                    case .ai:
                        ManayoAICardWizardView { draft in
                            Task {
                                await viewModel.createCard(from: draft)
                                
                                if let newIndex = viewModel.cards.firstIndex(where: {
                                    $0.jp == draft.jp && $0.meaning == draft.meaning
                                }) {
                                    currentIndex = newIndex
                                    markCurrentSeen()
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.9), value: newCardMode)
            .presentationDetents([.height(320), .large], selection: $sheetDetent)
            .presentationBackground(.clear)
        }
    }
    
    private var bottomNavBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 24) {
                Button(action: {
                    // future: open menu
                    // showMenuSheet = true
                    print("menu tapped")
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }

                Button(action: {
                    showDeck = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.3.layers.3d.top.filled")
                            .font(.system(size: 16, weight: .medium))
                        Text("Deck")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .clipShape(Capsule())
                }

                Button(action: {
                    newCardMode = .choice
                    sheetDetent = .fraction(0.35)
                    showNewCardSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
    
    private func discardAndAdvance() {
        withAnimation(.easeOut(duration: 0.15)) {
            cardOpacity = 0.0
            cardScale = 0.9
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            advanceIndex()
            dragOffset = .zero
            cardScale = 0.85
            cardOpacity = 0.0

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                cardOpacity = 1.0
                cardScale = 1.0
            }
        }
    }

    private func favoriteAndAdvance() {
        if let card = viewModel.cards[safe: currentIndex] {
            viewModel.toggleFavorite(for: card)
        }
        discardAndAdvance()
    }

    private func advanceIndex() {
        guard !viewModel.cards.isEmpty else { return }

        if currentIndex >= viewModel.cards.count - 1 {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        
        markCurrentSeen()
    }
    
    private func selectCardFromDeck(_ card: ManayoCard) {
        guard let newIndex = viewModel.cards.firstIndex(where: { $0.id == card.id }) else {
            return
        }

        currentIndex = newIndex
        dragOffset = CGSize(width: 0, height: 200)
        cardOpacity = 0.0
        cardScale = 0.95

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            dragOffset = .zero
            cardOpacity = 1.0
            cardScale = 1.0
        }
        
        markCurrentSeen()
    }
    
    private func markCurrentSeen() {
        if let card = viewModel.cards[safe: currentIndex] {
            viewModel.incrementViewCount(for: card)
        }
    }
}

#Preview {
    ContentView()
}
