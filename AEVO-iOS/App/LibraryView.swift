import SwiftUI
import AEVOCore

@MainActor
struct LibraryView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    let openLearning: () -> Void
    @State private var section = 0
    @State private var field = 0
    @State private var query = ""
    @State private var filter: QuestionFilter = .mixed
    @State private var ownNotesOnly = false
    var questions: [Question] {
        let seen = LearningEngine.seenQuestions(state: store.state)
        let latest = Dictionary(store.state.attempts.map { ($0.questionID, $0) }, uniquingKeysWith: { _, newer in newer })
        return store.catalog.questions.filter { q in
            (field == 0 || q.field == field) && (query.isEmpty || (q.prompt + q.topic).localizedCaseInsensitiveContains(query)) &&
            (filter != .bookmarked || store.state.bookmarks.contains(q.id)) &&
            (filter != .unseen || !seen.contains(q.id)) &&
            (filter != .uncertain || latest[q.id].map { !$0.correct || $0.unsure } == true)
        }
    }
    var cards: [LearningCard] {
        store.catalog.cards.filter { c in
            let custom = store.state.cardEdits[c.id]
            return (field == 0 || c.field == field) &&
                (!ownNotesOnly || custom != nil || store.state.cardDrafts[c.id] != nil) &&
                (query.isEmpty || [c.title, c.explanation, custom?.title ?? "", custom?.notes ?? ""].joined(separator: " ").localizedCaseInsensitiveContains(query))
        }
    }
    var body: some View {
        List {
            Section {
                Picker("Inhalte", selection: $section) { Text("Aufgaben").tag(0); Text("Lernkarten").tag(1) }.pickerStyle(.segmented)
                Picker("Handlungsfeld", selection: $field) {
                    Text("Alle Handlungsfelder").tag(0)
                    ForEach(1...4, id: \.self) { Text("HF \($0) · \(FieldInfo.title($0))").tag($0) }
                }
                if section == 0 {
                    Picker("Auswahl", selection: $filter) { ForEach(QuestionFilter.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
                    Button {
                        if store.startRound(field: field == 0 ? nil : field, filter: filter) { openLearning() }
                    } label: { Label(store.state.session == nil ? "Kurze Runde starten" : "Angefangene Runde fortsetzen", systemImage: "play.fill").frame(minHeight: 44) }
                } else {
                    NavigationLink { CardDeckView(field: field == 0 ? nil : field) } label: {
                        Label("Karten swipen", systemImage: "hand.draw").frame(minHeight: 44)
                    }
                    Toggle("Nur eigene Fassungen & Notizen", isOn: $ownNotesOnly)
                }
            }
            if section == 0 {
                Section("\(questions.count) Aufgaben") {
                    ForEach(questions) { question in
                        Button {
                            if store.state.session != nil { openLearning() }
                            else if store.commit({ try LearningEngine.startRound(state: &$0, questions: [question]) }) { openLearning() }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                FieldLabel(field: question.field)
                                Text(question.prompt).foregroundStyle(.primary)
                                if store.state.bookmarks.contains(question.id) { Label("Gemerkt", systemImage: "bookmark.fill").font(.caption).foregroundStyle(theme.accent) }
                            }.padding(.vertical, 8)
                        }
                    }
                }
            } else {
                Section("\(cards.count) Lernkarten") {
                    ForEach(cards) { card in
                        NavigationLink { CardDeckView(field: field == 0 ? nil : field, startCard: card.id) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                FieldLabel(field: card.field)
                                Text(store.state.cardEdits[card.id]?.title ?? card.title)
                                if store.state.cardDrafts[card.id] != nil { Text("Bearbeitungsentwurf vorhanden").font(.caption).foregroundStyle(.secondary) }
                                else if store.state.cardEdits[card.id] != nil { Text("Mit deinen eigenen Gedanken").font(.caption).foregroundStyle(.secondary) }
                            }.padding(.vertical, 8)
                        }
                    }
                }
            }
        }.navigationTitle("Dein Lernstoff").searchable(text: $query, prompt: "Thema, Begriff oder Notiz suchen")
            .learningBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink("Eigene Notizen") { PersonalNotebookView() }
                        NavigationLink("Lernfortschritt") { CompetenceView() }
                    } label: { Image(systemName: "ellipsis.circle").frame(width: 44, height: 44) }.accessibilityLabel("Weitere Lernoptionen")
                }
            }
    }
}
