import SwiftUI
import AEVOCore

/// Swipe deck for the learning cards. Tap reveals the back, a swipe to the right means
/// "Verstanden", a swipe to the left "Noch unsicher". Either way the next card follows
/// immediately, so a repetition run never needs a trip back to a list.
@MainActor
struct CardDeckView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let field: Int?
    let startCard: String?

    @State private var queue: [LearningCard] = []
    @State private var index = 0
    @State private var revealed = false
    @State private var drag: CGSize = .zero
    @State private var leaving: CGFloat = 0
    @State private var understoodCount = 0
    @State private var repeatCount = 0
    @State private var editing = false

    init(field: Int? = nil, startCard: String? = nil) {
        self.field = field
        self.startCard = startCard
    }

    private var card: LearningCard? { queue.indices.contains(index) ? queue[index] : nil }
    private var personal: CardEdit? { card.flatMap { store.state.cardEdits[$0.id] } }
    private var animated: Bool { !reduceMotion && !store.state.coaching.quietMode }
    /// Positive means the card is heading towards "Verstanden".
    private var direction: CGFloat { drag.width }

    var body: some View {
        VStack(spacing: 18) {
            if let card {
                header
                deck(card)
                controls(card)
            } else {
                finished
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .learningBackground()
        .navigationTitle("Lernkarten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } }
        }
        .onAppear { load() }
        .sheet(isPresented: $editing) {
            if let card {
                NavigationStack { CardEditor(card: card, initial: store.state.cardDrafts[card.id] ?? personal ?? CardEdit(card: card)) }
                    .environmentObject(store)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Karte \(index + 1) von \(queue.count)").font(.subheadline.weight(.medium)).monospacedDigit()
                Spacer()
                Label("\(understoodCount)", systemImage: "checkmark.circle").font(.subheadline).monospacedDigit()
                    .accessibilityLabel("\(understoodCount) als verstanden eingeschätzt")
                Label("\(repeatCount)", systemImage: "arrow.counterclockwise").font(.subheadline).monospacedDigit()
                    .accessibilityLabel("\(repeatCount) für eine frühere Wiederholung vorgemerkt")
            }.foregroundStyle(.secondary)
            ProgressView(value: Double(index), total: Double(max(queue.count, 1))).tint(theme.accent)
        }
    }

    @ViewBuilder
    private func deck(_ card: LearningCard) -> some View {
        ZStack {
            if queue.indices.contains(index + 1) {
                cardFace(queue[index + 1], preview: true)
                    .scaleEffect(0.95).offset(y: 14).opacity(0.55).accessibilityHidden(true)
            }
            cardFace(card, preview: false)
                .offset(x: drag.width + leaving, y: drag.height / 12)
                .rotationEffect(.degrees(Double(drag.width + leaving) / 22))
                .overlay(alignment: .top) { verdictBadge }
                .gesture(
                    DragGesture(minimumDistance: 14)
                        .onChanged { value in
                            store.activity()
                            drag = CGSize(width: value.translation.width, height: value.translation.height)
                        }
                        .onEnded { value in
                            let width = value.translation.width
                            if abs(width) > 110 { rate(card, understood: width > 0) }
                            else { withAnimation(animated ? .spring(response: 0.3, dampingFraction: 0.8) : nil) { drag = .zero } }
                        }
                )
                .onTapGesture { store.activity(); withAnimation(animated ? .easeInOut(duration: 0.2) : nil) { revealed.toggle() } }
                .accessibilityElement(children: .contain)
                .accessibilityHint(revealed ? "Nach rechts wischen für Verstanden, nach links für Noch unsicher." : "Tippen, um die Rückseite aufzudecken.")
                .accessibilityAction(named: "Verstanden") { rate(card, understood: true) }
                .accessibilityAction(named: "Noch unsicher") { rate(card, understood: false) }
        }
        .animation(animated ? .spring(response: 0.34, dampingFraction: 0.85) : nil, value: index)
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func cardFace(_ card: LearningCard, preview: Bool) -> some View {
        let edit = store.state.cardEdits[card.id]
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                FieldLabel(field: card.field)
                Text(edit?.title ?? card.title).font(.title2.bold()).fixedSize(horizontal: false, vertical: true)
                if revealed && !preview {
                    Text(edit?.explanation ?? card.explanation).fixedSize(horizontal: false, vertical: true)
                    let remember = edit?.remember ?? card.remember
                    if !remember.isEmpty {
                        Text("MERK DIR").font(.caption.bold()).tracking(1).foregroundStyle(theme.accent)
                        Text(remember).font(.headline).fixedSize(horizontal: false, vertical: true)
                    }
                    let example = edit?.example ?? card.example
                    if !example.isEmpty {
                        Text("Zum Beispiel").font(.subheadline.bold())
                        Text(example).fixedSize(horizontal: false, vertical: true)
                    }
                    if let notes = edit?.notes, !notes.isEmpty {
                        Divider()
                        Label("Deine Notizen", systemImage: "pencil.line").font(.subheadline.bold())
                        Text(notes).fixedSize(horizontal: false, vertical: true)
                    }
                } else if !preview {
                    Text("Erklär es dir kurz selbst. Dann tippe die Karte an.").foregroundStyle(.secondary)
                    Spacer(minLength: 20)
                    Label("Tippen zum Aufdecken", systemImage: "hand.tap").font(.subheadline).foregroundStyle(theme.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 28))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(theme.accent.opacity(preview ? 0 : 0.3), lineWidth: 1))
    }

    @ViewBuilder
    private var verdictBadge: some View {
        if abs(direction) > 40 {
            Text(direction > 0 ? "VERSTANDEN" : "NOCH UNSICHER")
                .font(.subheadline.bold()).tracking(1.2)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(theme.surface, in: Capsule())
                .overlay(Capsule().stroke(theme.accent, lineWidth: 2))
                .padding(.top, 18)
                .opacity(min(1, Double(abs(direction)) / 110))
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private func controls(_ card: LearningCard) -> some View {
        VStack(spacing: 12) {
            if revealed {
                HStack(spacing: 12) {
                    Button { rate(card, understood: false) } label: {
                        Label("Noch unsicher", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity, minHeight: 44)
                    }.buttonStyle(.bordered)
                    Button { rate(card, understood: true) } label: {
                        Label("Verstanden", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 44)
                    }.buttonStyle(.borderedProminent).tint(theme.action).foregroundStyle(theme.onAction)
                }
            } else {
                Button { store.activity(); withAnimation(animated ? .easeInOut(duration: 0.2) : nil) { revealed = true } } label: {
                    Label("Karte aufdecken", systemImage: "rectangle.on.rectangle").frame(maxWidth: .infinity, minHeight: 44)
                }.buttonStyle(.borderedProminent).tint(theme.action).foregroundStyle(theme.onAction)
            }
            HStack(spacing: 18) {
                Button { editing = true } label: {
                    Label("Bearbeiten", systemImage: "square.and.pencil").font(.subheadline)
                }.frame(minHeight: 44)
                NavigationLink { CardView(card: card) } label: {
                    Label("Details", systemImage: "info.circle").font(.subheadline)
                }.frame(minHeight: 44)
                Spacer()
                Button { skip() } label: { Label("Überspringen", systemImage: "forward").font(.subheadline) }
                    .frame(minHeight: 44)
            }
        }
    }

    private var finished: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 46)).foregroundStyle(theme.accent)
            Text(queue.isEmpty ? "Keine Karten\nin dieser Auswahl." : "Stapel\ndurchgearbeitet.").font(.largeTitle.bold())
            if !queue.isEmpty {
                Text("\(understoodCount) als verstanden eingeschätzt, \(repeatCount) kommen früher wieder.").foregroundStyle(.secondary)
            }
            PrimaryButton(title: "Nächster Stapel", icon: "rectangle.stack") { load(reset: true) }
            Button("Fertig") { dismiss() }.frame(maxWidth: .infinity, minHeight: 44)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func load(reset: Bool = false) {
        queue = LearningEngine.nextCards(catalog: store.catalog, state: store.state, field: field,
                                         startingWith: reset ? nil : startCard)
        index = 0; revealed = false; drag = .zero; leaving = 0
        if reset { understoodCount = 0; repeatCount = 0 }
    }

    private func rate(_ card: LearningCard, understood: Bool) {
        store.recall(card, understood: understood)
        if understood { understoodCount += 1 } else { repeatCount += 1 }
        advance(offscreen: understood ? 700 : -700)
    }

    private func skip() {
        store.activity()
        advance(offscreen: 0)
    }

    /// The card leaves in the direction of the verdict, then the next one is already in place.
    private func advance(offscreen: CGFloat) {
        if animated && offscreen != 0 {
            withAnimation(.easeOut(duration: 0.22)) { leaving = offscreen - drag.width }
            Task {
                try? await Task.sleep(for: .milliseconds(220))
                step()
            }
        } else {
            step()
        }
    }

    private func step() {
        drag = .zero; leaving = 0; revealed = false
        index += 1
    }
}
