import SwiftUI
import LearningCore

@MainActor
struct CardView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var textSize
    @Environment(\.dismiss) private var dismiss
    let card: LearningCard
    var cards: [LearningCard]? = nil
    var resume = false
    @State private var started = false
    @State private var acceptingRatings = true
    @State private var editingCard: LearningCard?
    @State private var restore = false
    @GestureState private var drag = CGSize.zero
    private var session: CardStudySession? { store.state.cardStudy }
    private var current: LearningCard? {
        guard started, let id = session?.currentID else { return nil }
        return store.catalog.cards.first { $0.id == id }
    }
    private var pool: [LearningCard] { cards ?? store.catalog.cards }
    private var motion: Animation? { reduceMotion || store.state.coaching.quietMode ? nil : .easeInOut(duration: 0.18) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Color.clear.frame(height: 0).id("card-top")
                    if started, session?.complete == true {
                        completion
                    } else if let current {
                        HStack {
                            Text("Karte \((session?.index ?? 0) + 1) von \(session?.cardIDs.count ?? 0)").font(.subheadline).monospacedDigit()
                            Spacer()
                            Image(systemName: "rectangle.stack").foregroundStyle(theme.accent).accessibilityHidden(true)
                        }
                        ProgressView(value: Double(session?.index ?? 0), total: Double(max(1, session?.cardIDs.count ?? 1))).tint(theme.accent)
                        studyCard(current)
                            .id(current.id)
                            .offset(x: reduceMotion ? 0 : drag.width * 0.6)
                            .rotationEffect(.degrees(reduceMotion ? 0 : Double(drag.width / 35)))
                            .contentShape(Rectangle())
                            .simultaneousGesture(swipe(for: current))
                            .accessibilityAction(named: "Verstanden, nächste Karte") { rate(current, understood: true) }
                            .accessibilityAction(named: "Noch unsicher, nächste Karte") { rate(current, understood: false) }
                        Text("Nach rechts: verstanden. Nach links: noch unsicher.").font(.footnote).foregroundStyle(.secondary)
                        if let personal = store.state.cardEdits[current.id], !personal.notes.isEmpty {
                            Surface { Label("Deine Notizen", systemImage: "pencil.line").font(.headline); Text(personal.notes).textSelection(.enabled) }
                        }
                        Button { editingCard = current } label: {
                            Label(store.state.cardDrafts[current.id] == nil ? "Karte bearbeiten & Notizen ergänzen" : "Bearbeitungsentwurf fortsetzen", systemImage: "square.and.pencil")
                        }.frame(minHeight: 44)
                        if let personal = store.state.cardEdits[current.id] {
                            personalVersion(current, personal: personal)
                        }
                        SourceLinks(sources: current.sources).id("sources-" + current.id)
                    } else {
                        ProgressView("Lernkarten werden vorbereitet …")
                    }
                }.padding(22)
            }
            .safeAreaInset(edge: .bottom) {
                if let current {
                    let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 12))
                    layout {
                        Button { rate(current, understood: false) } label: {
                            Label("Noch unsicher", systemImage: "arrow.left").font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 48).padding(.horizontal, 10)
                                .background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                        }.buttonStyle(.plain).accessibilityHint("Speichert deine Einschätzung und zeigt die nächste Karte.")
                        Button { rate(current, understood: true) } label: {
                            Label("Verstanden", systemImage: "arrow.right").font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 48).padding(.horizontal, 10)
                                .foregroundStyle(theme.onAction).background(theme.action, in: RoundedRectangle(cornerRadius: 18))
                        }.buttonStyle(.plain).accessibilityHint("Speichert deine Einschätzung und zeigt die nächste Karte.")
                    }.padding(.horizontal, 22).padding(.vertical, 12).background(theme.background)
                }
            }
            .onChange(of: session?.currentID) { _, _ in proxy.scrollTo("card-top", anchor: .top) }
        }
        .learningBackground().navigationTitle("Lernkarten").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.activity()
            if !started { started = store.startCards(pool, startingID: card.id, resume: resume) }
        }
        .sheet(item: $editingCard) { item in
            NavigationStack {
                CardEditor(card: item, initial: store.state.cardDrafts[item.id] ?? store.state.cardEdits[item.id] ?? CardEdit(card: item))
            }.environmentObject(store)
        }
        .confirmationDialog("Originaltext übernehmen? Deine Notizen bleiben erhalten. Ein offener Bearbeitungsentwurf wird verworfen.", isPresented: $restore, titleVisibility: .visible) {
            Button("Original übernehmen") {
                if let current { store.commit { LearningEngine.restoreOriginal(state: &$0, card: current) } }
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }

    private func studyCard(_ item: LearningCard) -> some View {
        let personal = store.state.cardEdits[item.id]
        return Surface {
            FieldLabel(field: item.field)
            Text(personal?.title ?? item.title).font(.title.bold()).fixedSize(horizontal: false, vertical: true)
            Text(personal?.explanation ?? item.explanation).textSelection(.enabled)
            if !(personal?.remember ?? item.remember).isEmpty {
                Text("MERK DIR").font(.caption.bold()).tracking(1).foregroundStyle(theme.accent)
                Text(personal?.remember ?? item.remember).font(.headline)
            }
            if !(personal?.example ?? item.example).isEmpty {
                Text("Zum Beispiel").font(.subheadline.bold())
                Text(personal?.example ?? item.example)
            }
        }
        .overlay(alignment: .topTrailing) {
            if abs(drag.width) > 30 {
                Text(drag.width > 0 ? "Verstanden" : "Noch unsicher")
                    .font(.headline).padding(12).foregroundStyle(theme.onAction)
                    .background(theme.action, in: Capsule()).padding(12).accessibilityHidden(true)
            }
        }
    }

    private func personalVersion(_ item: LearningCard, personal: CardEdit) -> some View {
        DisclosureGroup("Deine Fassung & Original") {
            VStack(alignment: .leading, spacing: 12) {
                if personal.baseVersion != item.version { Text("Das Original wurde aktualisiert. Deine Fassung bleibt erhalten.").font(.subheadline) }
                Text(item.title).bold(); Text(item.explanation); Text(item.remember); Text(item.example)
                Button("Originaltext übernehmen") { restore = true }.frame(minHeight: 44)
                Text("Deine Notizen bleiben erhalten.").font(.footnote).foregroundStyle(.secondary)
            }.padding(.top, 8)
        }.id("personal-" + item.id)
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundStyle(theme.accent)
            Text("Kartenstapel geschafft.").font(.largeTitle.bold())
            Text("\(session?.cardIDs.count ?? 0) Karten bearbeitet. Dein Fortschritt ist gespeichert.")
            let uncertain = session?.uncertainIDs ?? []
            if !uncertain.isEmpty {
                PrimaryButton(title: "\(uncertain.count) unsichere Karten wiederholen", icon: "arrow.clockwise") {
                    _ = store.startCards(pool.filter { uncertain.contains($0.id) })
                }
            }
            Button("Alle Karten weiterüben") { _ = store.startCards(pool) }.frame(minHeight: 44)
            Button("Für jetzt fertig") { dismiss() }.frame(minHeight: 44)
        }
    }

    private func swipe(for item: LearningCard) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .updating($drag) { value, state, _ in
                if abs(value.translation.width) > abs(value.translation.height) * 1.5 { state = value.translation }
            }
            .onEnded { value in
                guard let result = CardSwipe.result(horizontal: Double(value.translation.width), vertical: Double(value.translation.height)) else { return }
                rate(item, understood: result == .understood)
            }
    }
    private func rate(_ item: LearningCard, understood: Bool) {
        guard acceptingRatings, session?.currentID == item.id else { return }
        acceptingRatings = false
        withAnimation(motion) { _ = store.rateCard(item, understood: understood) }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            acceptingRatings = true
        }
    }
}

@MainActor
struct CardEditor: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let card: LearningCard
    @State private var edit: CardEdit
    init(card: LearningCard, initial: CardEdit) { self.card = card; _edit = State(initialValue: initial) }
    var body: some View {
        Form {
            Section("Deine Fassung") {
                TextField("Titel", text: $edit.title, axis: .vertical)
                LabeledEditor(title: "Erklärung", text: $edit.explanation)
                LabeledEditor(title: "Merksatz", text: $edit.remember)
                LabeledEditor(title: "Beispiel", text: $edit.example)
            }
            Section("Deine zusätzlichen Notizen") { TextEditor(text: $edit.notes).frame(minHeight: 120).accessibilityLabel("Eigene Notizen") }
            Section {
                Text("Dein Bearbeitungsentwurf wird während der Eingabe lokal gesichert. Mit „Speichern“ übernimmst du ihn als persönliche Karte. Das Original und die Lösungen der Aufgaben bleiben erhalten.").font(.footnote).foregroundStyle(.secondary)
                if let error = store.errorMessage { Text(error).foregroundStyle(.red) }
            }
        }.navigationTitle("Deine Gedanken").navigationBarTitleDisplayMode(.inline).learningBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Schließen") { if store.commit({ $0.cardDrafts[card.id] = edit }) { dismiss() } } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern") { if store.saveCard(card, edit: edit) { dismiss() } }.fontWeight(.semibold) }
            }
            .onChange(of: edit) { _, value in
                store.activity(); store.commit { $0.cardDrafts[card.id] = value }
            }
            .interactiveDismissDisabled()
    }
}

@MainActor
struct LabeledEditor: View {
    let title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) { Text(title).font(.caption).foregroundStyle(.secondary); TextEditor(text: $text).frame(minHeight: 95).accessibilityLabel(title) }
    }
}
