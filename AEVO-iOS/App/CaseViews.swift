import SwiftUI
import AEVOCore

@MainActor
struct CasesView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    var body: some View {
        List {
            Section {
                Text("Was würdest du tun?").font(.title2.bold())
                Text("16 kurze Fälle mit unterschiedlichen Entscheidungswegen. Die Reaktionen sind mögliche Verläufe, keine Vorhersagen. Alle Fälle sind redaktionelle Entwürfe.").font(.subheadline).foregroundStyle(.secondary)
            }
            ForEach(1...4, id: \.self) { field in
                Section(FieldInfo.title(field)) {
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
        }.navigationTitle("Ausbildungsalltag").learningBackground()
    }
}

@MainActor
struct CaseDetailView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    let item: TrainingCase
    @State private var reset = false
    @State private var revealNext = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var run: CaseRun { store.state.coaching.caseRuns[item.id] ?? CaseRun(version: item.version) }
    private var trail: [CaseChoice] { (try? PracticeContent.trail(for: item, run: run)) ?? [] }
    private var node: CaseNode? { try? PracticeContent.currentNode(for: item, run: run) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                FieldLabel(field: item.field)
                Text(item.title).font(.largeTitle.bold())
                Text(item.context)
                ForEach(Array(trail.enumerated()), id: \.offset) { index, choice in
                    Surface {
                        Text("Deine Entscheidung \(index + 1)").font(.caption.bold())
                        Text(choice.text).font(.headline)
                        Text(choice.consequence)
                        Text(choice.reasoning).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                if run.version != item.version {
                    Text("Der Fall wurde aktualisiert. Dein bisheriger Weg bleibt gespeichert, bis du ausdrücklich neu beginnst.")
                } else if let node {
                    Text(node.prompt).font(.title3.bold())
                    ForEach(node.choices.sorted { item.id.suffix(1) == "1" ? $0.id > $1.id : $0.id < $1.id }) { choice in
                        Button {
                            store.activity()
                            let animation: Animation? = reduceMotion || store.state.coaching.quietMode ? nil : .easeInOut(duration: 0.2)
                            withAnimation(animation) { store.commit { try PracticeContent.choose(choice.id, in: item, state: &$0) } }
                        } label: { Text(choice.text).frame(maxWidth: .infinity, alignment: .leading).padding(18).background(theme.surface, in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain).frame(minHeight: 44)
                    }
                } else {
                    Label("Situation durchgespielt", systemImage: "checkmark.circle").font(.headline).foregroundStyle(theme.accent)
                    Text("Welche Entscheidung würdest du in deinem Betrieb genauso treffen? Was wäre dort anders?")
                    LabeledEditor(title: "Deine Reflexion", text: Binding(get: { run.reflection }, set: { value in store.activity(); store.commit { $0.coaching.caseRuns[item.id]?.reflection = String(value.prefix(30_000)) } }))
                    Text("Der Abschluss zählt als Lernschritt, nicht als Nachweis praktischer Prüfungskompetenz.").font(.caption).foregroundStyle(.secondary)
                }
                if !run.choices.isEmpty { Button("Anderen Weg ausprobieren") { reset = true }.frame(minHeight: 44) }
                SourceLinks(sources: item.sources)
            }.padding(22)
        }.navigationTitle("Eine Entscheidung nach der anderen").navigationBarTitleDisplayMode(.inline).learningBackground().onAppear { store.activity() }
            .confirmationDialog("Den Entscheidungsweg neu beginnen? Deine Reflexion bleibt erhalten.", isPresented: $reset, titleVisibility: .visible) {
                Button("Neu beginnen") { store.commit { state in var new = CaseRun(version: item.version); new.reflection = run.reflection; state.coaching.caseRuns[item.id] = new } }
                Button("Abbrechen", role: .cancel) {}
            }
    }
}
