import SwiftUI
import LearningCore

@MainActor
struct CasesView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    var body: some View {
        List {
            Section {
                Text("Was würdest du tun?").font(.title2.bold())
                Text("\(store.practiceContent.cases.count) Fälle mit unterschiedlichen Entscheidungswegen. Probiere Entscheidungen aus und lerne ihre möglichen Folgen kennen.").font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(store.categories, id: \.self) { field in
                Section(store.environment.categoryTitle(field)) {
                    ForEach(store.practiceContent.cases.filter { $0.field == field }) { item in
                        NavigationLink { CaseDetailView(item: item) } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title).font(.headline)
                                Text(item.objective).font(.caption).foregroundStyle(.secondary)
                                if let run = store.state.coaching.caseRuns[item.id] { Text(run.choices.count >= 2 ? "Durchgespielt · erneut ausprobieren möglich" : "Angefangen · weiterführen").font(.caption).foregroundStyle(theme.accent) }
                            }.padding(.vertical, 6)
                        }
                    }
                }
            }
        }.navigationTitle(store.config.examTerminology.scenarios).learningBackground()
    }
}

@MainActor
struct CaseDetailView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    let item: TrainingCase
    @State private var reset = false
    @State private var selection: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var run: CaseRun { store.state.coaching.caseRuns[item.id] ?? CaseRun(version: item.version) }
    private var trail: [CaseChoice] { (try? PracticeContent.trail(for: item, run: run)) ?? [] }
    private var node: CaseNode? { try? PracticeContent.currentNode(for: item, run: run) }
    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Color.clear.frame(height: 0).id("case-top")
                FieldLabel(field: item.field)
                Text(item.title).font(.largeTitle.bold())
                Text(item.context)
                ForEach(Array(trail.enumerated()), id: \.offset) { index, choice in
                    Surface {
                        Text("Deine Entscheidung \(index + 1)").font(.caption.bold())
                        Text(choice.text).font(.headline)
                        Text(choice.consequence)
                        Text(choice.reasoning).font(.subheadline).foregroundStyle(.secondary)
                    }.id("case-feedback-" + String(index))
                }
                if run.version != item.version {
                    Text("Der Fall wurde aktualisiert. Dein bisheriger Weg bleibt gespeichert, bis du ausdrücklich neu beginnst.")
                } else if run.feedbackPending == true {
                    Text("Lies die Erklärung und gehe dann zum nächsten Schritt.").font(.footnote).foregroundStyle(.secondary)
                } else if let node {
                    Text(node.prompt).font(.title3.bold())
                    ForEach(node.choices.sorted { item.id.suffix(1) == "1" ? $0.id > $1.id : $0.id < $1.id }) { choice in
                        Button {
                            store.activity(); selection = choice.id
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selection == choice.id ? "checkmark.circle.fill" : "circle")
                                Text(choice.text).frame(maxWidth: .infinity, alignment: .leading)
                            }.padding(18).background(theme.surface, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(selection == choice.id ? theme.accent : .clear, lineWidth: 2))
                        }.buttonStyle(.plain).frame(minHeight: 44).accessibilityAddTraits(selection == choice.id ? .isSelected : [])
                    }
                } else {
                    Label("Situation durchgespielt", systemImage: "checkmark.circle").font(.headline).foregroundStyle(theme.accent)
                    Text("Welche Entscheidung würdest du in deinem Alltag genauso treffen? Was wäre dort anders?")
                    LabeledEditor(title: "Deine Reflexion", text: Binding(get: { run.reflection }, set: { value in store.activity(); store.commit { $0.coaching.caseRuns[item.id]?.reflection = String(value.prefix(30_000)) } }))
                    Text("Dein abgeschlossener Fall zählt zu deiner Tagesstrecke.").font(.caption).foregroundStyle(.secondary)
                }
                if !run.choices.isEmpty { Button("Anderen Weg ausprobieren") { reset = true }.frame(minHeight: 44) }
                ContentQualityView(contentID: item.id, version: item.version, sources: item.sources)
            }.padding(22)
        }
        .safeAreaInset(edge: .bottom) {
            if run.version == item.version, run.feedbackPending == true || node != nil {
                PrimaryButton(title: run.feedbackPending == true ? (node == nil ? "Fall abschließen" : "Nächste Entscheidung") : "Antwort einloggen", icon: run.feedbackPending == true ? "arrow.right" : "checkmark") {
                    store.activity()
                    if run.feedbackPending == true {
                        if store.commit({ PracticeContent.acknowledgeFeedback(in: item, state: &$0) }) { selection = nil }
                    } else if let selection {
                        if store.commit({ try PracticeContent.choose(selection, in: item, state: &$0) }) { self.selection = nil }
                    }
                }.disabled(run.feedbackPending != true && selection == nil)
                    .opacity(run.feedbackPending != true && selection == nil ? 0.5 : 1)
                    .padding(.horizontal, 22).padding(.vertical, 12).background(theme.background)
            }
        }
        .onChange(of: run.feedbackPending) { _, pending in
            DispatchQueue.main.async {
                proxy.scrollTo(pending == true ? "case-feedback-" + String(max(0, trail.count - 1)) : "case-top", anchor: .top)
            }
        }
        }.navigationTitle("Eine Entscheidung nach der anderen").navigationBarTitleDisplayMode(.inline).learningBackground().onAppear { store.activity() }
            .confirmationDialog("Den Entscheidungsweg neu beginnen? Deine Reflexion bleibt erhalten.", isPresented: $reset, titleVisibility: .visible) {
                Button("Neu beginnen") { store.commit { state in var new = CaseRun(version: item.version); new.reflection = run.reflection; state.coaching.caseRuns[item.id] = new }; selection = nil }
                Button("Abbrechen", role: .cancel) {}
            }
    }
}
