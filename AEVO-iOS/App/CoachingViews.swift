import SwiftUI
import LearningCore

@MainActor
struct DayPlanView: View {
    @EnvironmentObject private var store: AppStore
    @State private var minutes = 0
    @State private var learning = false
    private var plan: DayRecommendation { CoachingEngine.recommendation(catalog: store.catalog, state: store.state, overrideMinutes: minutes == 0 ? nil : minutes, practiceEnabled: store.enabled(.practicePreparation)) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Heute passt Lernen\nin deinen Alltag.").font(.largeTitle.bold())
                Picker("Zeit für diese Runde", selection: $minutes) {
                    Text("Mein Plan").tag(0); Text("3 Min.").tag(3); Text("5 Min.").tag(5); Text("10 Min.").tag(10)
                }.pickerStyle(.segmented)
                Surface {
                    Label("Etwa \(plan.minutes) Minuten", systemImage: "clock").font(.headline)
                    Text("\(plan.questions.count) Aufgaben" + (plan.practicalMinutes > 0 ? " · etwa \(plan.practicalMinutes) Minuten Praxis" : ""))
                    DisclosureGroup("Wie wird die Runde ausgewählt?") { Text(plan.explanation).font(.subheadline).foregroundStyle(.secondary) }
                    PrimaryButton(title: store.state.session == nil ? "Aufgaben starten" : "Gespeicherte Runde fortsetzen") {
                        if store.state.session != nil || store.commit({ try LearningEngine.startRound(state: &$0, questions: plan.questions) }) { learning = true }
                    }
                }
                if store.enabled(.flashcards), let card = plan.card { NavigationLink { CardView(card: card) } label: { Label("Lernkarte: \(card.title)", systemImage: "rectangle.stack").frame(minHeight: 44) } }
                if plan.practicalMinutes > 0 { NavigationLink { PracticePlanEditorView() } label: { Label("Praxisplan weiterentwickeln", systemImage: "person.text.rectangle").frame(minHeight: 44) } }
                NavigationLink("Zeitbudget anpassen") { LearningPreferencesView() }.frame(minHeight: 44)
                Text("Deine angefangene Runde bleibt gespeichert.").font(.footnote).foregroundStyle(.secondary)
            }.padding(22)
        }.learningBackground().navigationTitle("Dein Tagesplan").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $learning) { NavigationStack { LearningView() }.environmentObject(store) }
    }
}

@MainActor
struct LearningPreferencesView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        Form {
            Section("Dein Zeitbudget") {
                Picker("Montag bis Freitag", selection: binding(\.weekdayMinutes)) { ForEach([3,5,10,15,20,30], id: \.self) { Text("\($0) Minuten").tag($0) } }
                Picker("Samstag und Sonntag", selection: binding(\.weekendMinutes)) { ForEach([3,5,10,15,20,30], id: \.self) { Text("\($0) Minuten").tag($0) } }
                Text("Richtwerte für deinen Tagesplan. Es gibt kein Zeitlimit und keine Lernpflicht.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Ohne Zeitdruck") {
                Toggle("Ruhiger Modus", isOn: binding(\.quietMode))
                Text("Blendet Countdown, Tagesstrecke und Lernserie auf der Startseite aus und reduziert Animationen. Im Prüfungsmodus bleibt die Prüfungszeit sichtbar.").font(.footnote).foregroundStyle(.secondary)
            }
            NavigationLink("Prüfungstermine ändern") { ExamPlanView() }
        }.navigationTitle("Dein Lerntempo").learningBackground()
    }
    private func binding<T>(_ key: WritableKeyPath<CoachingState,T>) -> Binding<T> {
        Binding(get: { store.state.coaching[keyPath: key] }, set: { value in store.commit { $0.coaching[keyPath: key] = value } })
    }
}

@MainActor
struct CompetenceView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    @State private var learning = false
    var body: some View {
        List {
            Section {
                Text("Was du schon abrufen kannst.").font(.title2.bold())
                Text("Hier siehst du bearbeitete Themen und gefestigte Antworten.").font(.subheadline)
                DisclosureGroup("So entsteht die Einordnung") {
                    Text("Im Aufbau: mindestens eine Familie bearbeitet. Wiederholt abrufbar: mindestens zwei Familien sicher richtig, jeweils mit mindestens 24 Stunden Abstand zur ersten sicheren Lösung. Angewendet: zusätzlich zwei zuvor ungesehene Aufgaben aus anderen Familien desselben Lernziels nach mindestens 24 Stunden sicher richtig. Die Einordnung bezieht sich auf deine bearbeiteten Aufgaben.").font(.footnote)
                }
            }
            ForEach(store.categories, id: \.self) { field in
                DisclosureGroup(store.environment.categoryLabel(field)) {
                    ForEach(CoachingEngine.evidence(catalog: store.catalog, state: store.state).filter { $0.field == field }) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.title).font(.headline)
                            Text(item.stage).foregroundStyle(theme.accent).fontWeight(.semibold)
                            Text("\(item.coveredFamilies) von \(item.totalFamilies) Familien bearbeitet · \(item.delayedFamilies) verzögert abgerufen · \(item.transferFamilies) neu angewendet").font(.caption).foregroundStyle(.secondary)
                            Button("Dieses Lernziel üben") {
                                let qs = LearningEngine.nextQuestions(catalog: store.catalog, state: store.state, count: store.catalog.questions.count).filter { $0.competency == item.id }
                                if store.state.session != nil || store.commit({ try LearningEngine.startRound(state: &$0, questions: Array(qs.prefix(3))) }) { learning = true }
                            }.frame(minHeight: 44)
                        }.padding(.vertical, 6)
                    }
                }
            }
        }.navigationTitle("Deine Stärken").learningBackground()
            .sheet(isPresented: $learning) { NavigationStack { LearningView() }.environmentObject(store) }
    }
}

@MainActor
struct QuestionNotebook: View {
    @EnvironmentObject private var store: AppStore
    let question: Question
    var body: some View {
        LabeledEditor(title: "Dein Merksatz oder eigenes Beispiel", text: Binding(get: { store.state.coaching.notes[question.id] ?? "" }, set: { value in
            store.activity(); store.commit { $0.coaching.notes[question.id] = String(value.prefix(30_000)) }
        }))
        Text("Deine Notiz wird auf diesem Gerät gespeichert und gehört zur Datensicherung. Sie verändert die fachliche Lösung nicht.").font(.caption).foregroundStyle(.secondary)
    }
}

@MainActor
struct PersonalNotebookView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var learning = false
    private var questions: [Question] {
        store.catalog.questions.filter { q in
            let note = store.state.coaching.notes[q.id] ?? ""
            return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (query.isEmpty || (note + q.prompt).localizedCaseInsensitiveContains(query))
        }
    }
    private var ownCards: [LearningCard] { store.catalog.cards.filter { c in
        guard let edit = store.state.cardDrafts[c.id] ?? store.state.cardEdits[c.id] else { return false }
        return query.isEmpty || (edit.title + edit.notes + edit.explanation).localizedCaseInsensitiveContains(query)
    } }
    private var textExport: String {
        let qs = questions.map { "\($0.id) · \($0.prompt)\n\(store.state.coaching.notes[$0.id] ?? "")" }
        let cards = ownCards.map { c -> String in
            let e = store.state.cardDrafts[c.id] ?? store.state.cardEdits[c.id]!
            return "\(c.id) · \(e.title)\n\(e.explanation)\n\(e.remember)\n\(e.example)\n\(e.notes)"
        }
        return "MEINE LERNSAMMLUNG\nDeine persönlichen Texte aus der aktuellen Suchauswahl.\n\n" + (qs + cards).joined(separator: "\n\n")
    }
    var body: some View {
        List {
            Section {
                Text("Deine Gedanken verbinden den Lernstoff mit deinem Alltag.").font(.headline)
                ShareLink(item: textExport) { Label("Auswahl als Text teilen", systemImage: "square.and.arrow.up") }.frame(minHeight: 44)
                Button("Mit meinen Notiz-Aufgaben üben") {
                    if store.state.session != nil || store.commit({ try LearningEngine.startRound(state: &$0, questions: Array(questions.prefix(5))) }) { learning = true }
                }.disabled(questions.isEmpty).frame(minHeight: 44)
            }
            Section("Eigene Beispiele zu Aufgaben") {
                if questions.isEmpty { Text("Ergänze bei einer Lernaufgabe deinen ersten Merksatz.").foregroundStyle(.secondary) }
                ForEach(questions) { q in
                    NavigationLink { Form { Text(q.prompt).font(.headline); QuestionNotebook(question: q); ContentQualityView(contentID: q.id, version: q.version, sources: q.sources, approved: q.approved, reviewedOn: q.reviewedOn, reviewedBy: q.reviewedBy) }.navigationTitle("Dein Beispiel") } label: {
                        VStack(alignment: .leading, spacing: 8) { Text(q.topic).font(.headline); Text(store.state.coaching.notes[q.id] ?? "").lineLimit(3).foregroundStyle(.secondary) }
                    }
                }
            }
            if store.enabled(.flashcards) { Section("Persönliche Lernkarten") { ForEach(ownCards) { card in NavigationLink(store.state.cardEdits[card.id]?.title ?? card.title) { CardView(card: card) } } } }
        }.navigationTitle("Deine Lernsammlung").searchable(text: $query, prompt: "Eigene Texte suchen").learningBackground()
            .sheet(isPresented: $learning) { NavigationStack { LearningView() }.environmentObject(store) }
    }
}

@MainActor
struct ContentQualityView: View {
    let contentID: String
    let version: Int
    let sources: [ContentSource]
    var approved = false
    var reviewedOn: String?
    var reviewedBy: String?
    var body: some View { SourceLinks(sources: sources) }
}

@MainActor
struct ContentChangesView: View {
    @EnvironmentObject private var store: AppStore
    private var changed: [LearningCard] { store.catalog.cards.filter { c in
        (store.state.coaching.acknowledgedVersions[c.id].map { $0 != c.version } ?? false) || (store.state.cardEdits[c.id].map { $0.baseVersion != c.version } ?? false)
    } }
    private var questions: [Question] { store.catalog.questions.filter { q in store.state.coaching.acknowledgedVersions[q.id].map { $0 != q.version } ?? false } }
    var body: some View {
        List {
            Section("Inhaltsänderungen") {
                if changed.isEmpty && questions.isEmpty { Text("Keine neuen Versionsänderungen zum gespeicherten Stand.") }
                ForEach(changed) { c in
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink("\(c.title) · Version \(c.version)") { CardView(card: c) }
                        if let revision = store.catalog.revisions?.last(where: { $0.contentID == c.id && $0.version == c.version }) { Text("\(revision.date): \(revision.summary)").font(.subheadline) }
                    }
                }
                ForEach(questions) { q in VStack(alignment: .leading, spacing: 10) {
                    Text(q.prompt).font(.headline); Text("Neue Inhaltsversion \(q.version). Prüfe die aktuelle Erklärung; ältere Antworten zählen für diese Version nicht für den aktuellen Lernstand.").font(.caption)
                    if let revision = store.catalog.revisions?.last(where: { $0.contentID == q.id && $0.version == q.version }) { Text("\(revision.date): \(revision.summary)").font(.subheadline) }
                    Text(q.explanation)
                    Button("Änderung gelesen") { store.commit { $0.coaching.acknowledgedVersions[q.id] = q.version } }.frame(minHeight: 44)
                } }
                Text("Persönliche Fassungen werden niemals automatisch überschrieben. Wenn eine redaktionelle Änderungsbeschreibung mitgeliefert wurde, erscheint sie hier mit Datum.").font(.footnote).foregroundStyle(.secondary)
            }
            // The content report box was removed; nothing creates new entries. Older entries
            // stay in the saved data and in backups, they are simply no longer listed here.
        }.navigationTitle("Inhaltsänderungen").learningBackground()
    }
}
