import SwiftUI
import StoreKit
import AEVOCore

@MainActor
struct LearningView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @State private var visible = false
    @State private var showTip = false
    @State private var completed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Anchor of the currently evaluated question, so the result scrolls into view by itself.
    private var resultAnchor: String? {
        guard let session = store.state.session, let question = session.current,
              session.submitted.contains(question.id) else { return nil }
        return "result-" + question.id
    }

    var body: some View {
        ScrollViewReader { scroll in
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if completed {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 48)).foregroundStyle(theme.accent)
                    Text("Ein Stück\nweitergekommen.").font(.largeTitle.bold())
                    Text("Deine Runde und dein Lernstand sind gespeichert. Lass das Gelernte kurz wirken.").foregroundStyle(.secondary)
                    PrimaryButton(title: "Für heute fertig", icon: "checkmark") { dismiss() }
                    Button("Noch eine Runde") { if store.startRound() { completed = false } }.frame(minHeight: 44)
                } else if let session = store.state.session, let question = session.current {
                    HStack { FieldLabel(field: question.field); Spacer(); Text("\(session.index + 1) / \(session.questions.count)").font(.caption).monospacedDigit() }
                    ProgressView(value: Double(session.index), total: Double(session.questions.count)).tint(theme.accent)
                    if !question.context.isEmpty { Text(question.context).foregroundStyle(.secondary) }
                    Text(question.prompt).font(.title2.weight(.semibold))
                    let submitted = session.submitted.contains(question.id)
                    let selected = session.selections[question.id] ?? []
                    if !submitted {
                        Text(question.multipleChoice
                             ? "Wähle \(question.correctIDs.count) Antworten und prüfe sie."
                             : "Tippe deine Antwort an. Sie wird sofort ausgewertet.")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    ForEach(question.options) { option in
                        AnswerRow(option: option, selected: selected.contains(option.id),
                                  evaluated: submitted, correct: question.correctIDs.contains(option.id)) {
                            // One tap answers a single-choice question: choose, see, move on.
                            if question.multipleChoice { store.select(option.id) } else { store.answer(option.id) }
                        }
                        .disabled(submitted)
                    }
                    if submitted {
                        Surface {
                            Label(question.isCorrect(selected) ? "Das passt." : "Schauen wir genauer hin.", systemImage: question.isCorrect(selected) ? "checkmark.circle" : "lightbulb")
                                .font(.headline).foregroundStyle(theme.accent)
                            Text(question.explanation).textSelection(.enabled)
                            DisclosureGroup("Alle Antwortmöglichkeiten verstehen") {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(question.options) { option in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(option.text).font(.subheadline.bold())
                                            Text(option.explanation).font(.subheadline)
                                        }
                                    }
                                }.padding(.top, 10)
                            }.id("answers-" + question.id)
                            if let card = store.catalog.card(for: question) { NavigationLink("Passende Lernkarte ansehen") { CardDeckView(startCard: card.id) }.frame(minHeight: 44) }
                        }.id("result-" + question.id)
                        PrimaryButton(title: session.index + 1 == session.questions.count ? "Runde abschließen" : "Nächste Aufgabe") {
                            if store.advance() { completed = true }
                        }
                        if question.isCorrect(selected) && !session.unsure.contains(question.id) {
                            Button { store.markUnsure() } label: {
                                Label("War eher geraten – nochmal zeigen", systemImage: "questionmark.circle").font(.subheadline)
                            }.frame(minHeight: 44)
                        } else if session.unsure.contains(question.id) {
                            Label("Für eine frühere Wiederholung vorgemerkt.", systemImage: "arrow.counterclockwise")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        DisclosureGroup("Eigene Notiz") { QuestionNotebook(question: question) }.id(question.id)
                        SourceLinks(sources: question.sources).id("sources-" + question.id)
                    } else if question.multipleChoice {
                        PrimaryButton(title: "Antwort prüfen", icon: "checkmark", action: store.submit).disabled(selected.isEmpty).opacity(selected.isEmpty ? 0.5 : 1)
                    }
                    Button { store.toggleBookmark(question.id) } label: { Label(store.state.bookmarks.contains(question.id) ? "Aus Merkliste entfernen" : "Für später merken", systemImage: store.state.bookmarks.contains(question.id) ? "bookmark.fill" : "bookmark") }.frame(minHeight: 44)
                }
            }.padding(22)
        }.animation(reduceMotion || store.state.coaching.quietMode ? nil : .easeInOut(duration: 0.2), value: completed).learningBackground().navigationTitle("Deine Lernrunde").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Schließen") { dismiss() } } }
            .onAppear { visible = true; store.activity() }
            .onDisappear { visible = false }
            .simultaneousGesture(DragGesture(minimumDistance: 20).onChanged { _ in store.activity() })
            .task(id: completed) {
                guard completed else { return }
                do { try await Task.sleep(for: .seconds(3)) } catch { return }
                guard !Task.isCancelled, completed, visible, scenePhase == .active,
                      store.state.session == nil, store.errorMessage == nil,
                      let kind = PromptPolicy.eligible(state: store.state, now: Date(), atSessionEnd: true) else { return }
                if kind == .review {
                    if store.commit({ $0.reviewRequests.append(Date()) }) { requestReview() }
                } else if store.commit({ $0.tipRequests.append(Date()) }) { showTip = true }
            }
            .sheet(isPresented: $showTip) {
                NavigationStack { SupportView(isAutomatic: true) }.environmentObject(store)
            }
            .onChange(of: resultAnchor) { _, anchor in
                guard let anchor else { return }
                withAnimation(reduceMotion || store.state.coaching.quietMode ? nil : .easeInOut(duration: 0.25)) {
                    scroll.scrollTo(anchor, anchor: .top)
                }
            }
        }
    }
}

@MainActor
struct AnswerRow: View {
    @Environment(\.learningTheme) private var theme
    let option: AnswerOption
    let selected: Bool
    var evaluated = false
    var correct = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: evaluated ? (correct ? "checkmark.circle.fill" : selected ? "xmark.circle.fill" : "circle") : selected ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundStyle(selected || (evaluated && correct) ? theme.accent : .secondary)
                VStack(alignment: .leading, spacing: 6) {
                    Text(option.text).foregroundStyle(.primary).multilineTextAlignment(.leading)
                    if evaluated && (correct || selected) { Text(correct ? "Richtige Antwort" : "Deine Auswahl passt hier nicht").font(.caption).foregroundStyle(.secondary) }
                }
                Spacer(minLength: 0)
            }.frame(maxWidth: .infinity, minHeight: 32, alignment: .leading).padding(17)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? theme.accent : .clear, lineWidth: 2))
        }.buttonStyle(.plain).accessibilityAddTraits(selected ? .isSelected : [])
    }
}

@MainActor
struct SourceLinks: View {
    let sources: [ContentSource]
    var body: some View {
        DisclosureGroup("Quellen") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sources, id: \.self) { source in
                    if let url = URL(string: source.url), ["https", "http"].contains(url.scheme ?? "") {
                        Link(source.title, destination: url).font(.footnote).frame(minHeight: 44, alignment: .leading)
                    }
                }
            }.padding(.top, 8)
        }
    }
}
