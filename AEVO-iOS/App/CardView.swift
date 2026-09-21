import SwiftUI
import AEVOCore

@MainActor
struct CardView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    let card: LearningCard
    @State private var revealed = false
    @State private var editing = false
    @State private var restore = false
    private var personal: CardEdit? { store.state.cardEdits[card.id] }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                FieldLabel(field: card.field)
                Text(personal?.title ?? card.title).font(.largeTitle.bold())
                Text("Was fällt dir dazu ein? Formuliere den Gedanken kurz, bevor du die Karte aufdeckst.").foregroundStyle(.secondary)
                if revealed {
                    Surface {
                        Text(personal?.explanation ?? card.explanation).textSelection(.enabled)
                        if !(personal?.remember ?? card.remember).isEmpty {
                            Text("MERK DIR").font(.caption.bold()).tracking(1).foregroundStyle(theme.accent)
                            Text(personal?.remember ?? card.remember).font(.headline)
                        }
                        if !(personal?.example ?? card.example).isEmpty {
                            Text("Zum Beispiel").font(.subheadline.bold())
                            Text(personal?.example ?? card.example)
                        }
                    }
                    if let personal, !personal.notes.isEmpty {
                        Surface { Label("Deine Notizen", systemImage: "pencil.line").font(.headline); Text(personal.notes).textSelection(.enabled) }
                    }
                    HStack(spacing: 12) {
                        Button("Noch unsicher") { store.recall(card, understood: false) }.buttonStyle(.bordered).frame(minHeight: 44)
                        Button("Verstanden") { store.recall(card, understood: true) }.buttonStyle(.borderedProminent).tint(theme.action).foregroundStyle(theme.onAction).frame(minHeight: 44)
                    }
                    if let notice = store.notice { Text(notice).font(.footnote).foregroundStyle(.secondary).accessibilityAddTraits(.updatesFrequently) }
                    if let personal {
                        Surface {
                            Label("Deine persönliche Fassung", systemImage: "person.crop.circle").font(.headline)
                            if personal.baseVersion != card.version {
                                Text("Das Original wurde aktualisiert. Deine Fassung bleibt erhalten.").font(.subheadline)
                                if let revision = store.catalog.revisions?.last(where: { $0.contentID == card.id && $0.version == card.version }) { Text(revision.summary).font(.subheadline) }
                            }
                            DisclosureGroup("Original vergleichen") {
                                VStack(alignment: .leading, spacing: 12) { Text(card.title).bold(); Text(card.explanation); Text(card.remember); Text(card.example) }.padding(.top, 8)
                            }
                            Button("Originaltext übernehmen") { restore = true }.frame(minHeight: 44)
                            Text("Deine Notizen bleiben dabei erhalten.").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    SourceLinks(sources: card.sources)
                } else {
                    PrimaryButton(title: "Karte aufdecken", icon: "rectangle.on.rectangle") { store.activity(); revealed = true }
                }
                Button { editing = true } label: { Label(store.state.cardDrafts[card.id] == nil ? "Karte bearbeiten & Notizen ergänzen" : "Bearbeitungsentwurf fortsetzen", systemImage: "square.and.pencil") }.frame(minHeight: 44)
            }.padding(22)
        }.learningBackground().navigationTitle("Lernkarte").navigationBarTitleDisplayMode(.inline)
            .onAppear { store.notice = nil; store.activity() }
            .simultaneousGesture(DragGesture(minimumDistance: 20).onChanged { _ in store.activity() })
            .sheet(isPresented: $editing) {
                NavigationStack { CardEditor(card: card, initial: store.state.cardDrafts[card.id] ?? personal ?? CardEdit(card: card)) }.environmentObject(store)
            }
            .confirmationDialog("Originaltext übernehmen? Deine gespeicherten Notizen bleiben erhalten. Ein offener Bearbeitungsentwurf wird verworfen.", isPresented: $restore, titleVisibility: .visible) {
                Button("Original übernehmen") { store.commit { LearningEngine.restoreOriginal(state: &$0, card: card) } }
                Button("Abbrechen", role: .cancel) {}
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
