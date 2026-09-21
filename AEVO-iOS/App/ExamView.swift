import SwiftUI
import AEVOCore

@MainActor
struct ExamView: View {
    @EnvironmentObject private var store: AppStore
    @State private var running = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("In Ruhe\nGeneralprobe machen.").font(.largeTitle.bold())
                Surface {
                    Label("80 Aufgaben · 180 Minuten", systemImage: "timer").font(.headline)
                    Text("Die Uhr läuft auch weiter, wenn du die App schließt. Antworten und Markierungen bleiben gespeichert. Lösungen siehst du nach der Abgabe.")
                    Text("Eigenes Übungsprofil: 12 Aufgaben aus HF 1, 18 aus HF 2, 38 aus HF 3 und 12 aus HF 4. Eine Aufgabenfamilie kommt höchstens einmal vor.").font(.footnote).foregroundStyle(.secondary)
                    Text("Jede vollständig richtige Auswahl zählt gleich viel. Ab 50 von 100 Übungspunkten liegt dein Ergebnis im ausreichenden Bereich. Das ist keine Bestehensprognose und keine Originalprüfung.").font(.footnote).foregroundStyle(.secondary)
                    PrimaryButton(title: store.state.exam == nil ? "Generalprobe starten" : store.state.exam?.submittedAt == nil ? "Generalprobe fortsetzen" : "Auswertung ansehen", icon: "play.fill") {
                        if store.startExam() { running = true }
                    }
                }
                NavigationLink { ExamPlanView() } label: {
                    Surface { Label("Deine Prüfungstermine", systemImage: "calendar").font(.headline); Text("Countdown und Lernplanung anpassen.").foregroundStyle(.secondary) }
                }.buttonStyle(.plain)
                if !store.state.examHistory.isEmpty {
                    Text("Deine bisherigen Versuche").font(.headline)
                    ForEach(store.state.examHistory.reversed()) { exam in
                        Surface {
                            Text(exam.startedAt.formatted(date: .abbreviated, time: .shortened)).font(.headline)
                            Text("\(exam.points, specifier: "%.1f") / 100 Übungspunkte")
                            if exam.timingUncertain { Text("Zeitlich nicht vergleichbar").font(.caption).foregroundStyle(.secondary) }
                        }
                    }
                }
            }.padding(22)
        }.learningBackground().navigationTitle("Prüfung").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $running) { NavigationStack { ExamSessionView() }.environmentObject(store) }
    }
}

@MainActor
struct ExamSessionView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmSubmission = false
    @State private var showOverview = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let exam = store.state.exam {
                    if exam.submittedAt != nil {
                        Text("Deine Auswertung").font(.largeTitle.bold())
                        Surface {
                            Text("\(exam.points, specifier: "%.1f") / 100").font(.largeTitle.bold()).monospacedDigit()
                            Text("\(exam.correctCount) von \(exam.questions.count) Aufgaben vollständig richtig.")
                            Text("\(exam.questions.count - exam.answeredCount) offen · \(exam.newQuestionCount) zuvor nicht geübt").foregroundStyle(.secondary)
                            if exam.timingUncertain { Label("Zeitlich nicht vergleichbar: Die Zeitbasis hat sich verändert.", systemImage: "clock.badge.exclamationmark").font(.footnote) }
                            Text("Dein Übungsergebnis. Es zeigt, welche Themen jetzt dran sind.").font(.footnote).foregroundStyle(.secondary)
                        }
                        ForEach(1...4, id: \.self) { field in
                            let questions = exam.questions.filter { $0.field == field }
                            let correct = questions.filter { $0.isCorrect(exam.selections[$0.id] ?? []) }.count
                            Surface { FieldLabel(field: field); Text("\(correct) von \(questions.count) richtig").font(.headline) }
                        }
                        ForEach(exam.questions) { q in
                            DisclosureGroup {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(q.options) { option in
                                        AnswerRow(option: option, selected: (exam.selections[q.id] ?? []).contains(option.id), evaluated: true, correct: q.correctIDs.contains(option.id), action: {}).disabled(true)
                                    }
                                    Text(q.explanation)
                                    ForEach(q.options) { option in Text(option.explanation).font(.subheadline) }
                                }.padding(.top, 8)
                            } label: { Label(q.prompt, systemImage: q.isCorrect(exam.selections[q.id] ?? []) ? "checkmark.circle" : "lightbulb") }
                        }
                        PrimaryButton(title: "Versuch ablegen", icon: "checkmark") {
                            if store.commit({ state in if let current = state.exam { state.examHistory.append(current); state.exam = nil } }) { dismiss() }
                        }
                    } else if exam.questions.indices.contains(exam.index) {
                        let q = exam.questions[exam.index]
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            HStack {
                                Label(exam.timingUncertain ? "Zeit nicht vergleichbar" : remaining(until: exam.deadline, now: context.date), systemImage: "timer").monospacedDigit()
                                Spacer(); Text("\(exam.index + 1) / \(exam.questions.count)")
                            }.font(.subheadline)
                        }
                        FieldLabel(field: q.field)
                        if !q.context.isEmpty { Text(q.context).foregroundStyle(.secondary) }
                        Text(q.prompt).font(.title2.weight(.semibold))
                        Text("Wähle \(q.correctIDs.count) \(q.correctIDs.count == 1 ? "Antwort" : "Antworten").").font(.subheadline).foregroundStyle(.secondary)
                        ForEach(q.options) { option in
                            AnswerRow(option: option, selected: (exam.selections[q.id] ?? []).contains(option.id)) { store.setExamOption(option.id) }
                        }
                        Toggle("Für später markieren", isOn: Binding(get: { exam.marked.contains(q.id) }, set: { on in
                            store.commit { if on { $0.exam?.marked.insert(q.id) } else { $0.exam?.marked.remove(q.id) } }
                        }))
                        HStack {
                            Button("Zurück") { store.goToExamQuestion(max(0, exam.index - 1)) }.disabled(exam.index == 0)
                            Spacer()
                            Button("Weiter") { store.goToExamQuestion(min(exam.questions.count - 1, exam.index + 1)) }.disabled(exam.index == exam.questions.count - 1)
                        }.frame(minHeight: 44)
                        Button("Aufgabenübersicht") { showOverview = true }.frame(minHeight: 44)
                        PrimaryButton(title: "Generalprobe abgeben", icon: "checkmark.seal") { confirmSubmission = true }
                    }
                }
            }.padding(22)
        }.learningBackground().navigationTitle("Generalprobe").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Schließen") { dismiss() } } }
            .onAppear { store.commit { $0.exam?.observe(now: Date(), uptime: DeviceClock.now()) } }
            .confirmationDialog("Jetzt abgeben? Noch \((store.state.exam?.questions.count ?? 0) - (store.state.exam?.answeredCount ?? 0)) Aufgaben sind offen.", isPresented: $confirmSubmission, titleVisibility: .visible) {
                Button("Verbindlich abgeben") { store.commit { $0.exam?.submittedAt = Date() } }
                Button("Weiter bearbeiten", role: .cancel) {}
            }
            .sheet(isPresented: $showOverview) {
                NavigationStack {
                    List {
                        if let exam = store.state.exam {
                            ForEach(Array(exam.questions.enumerated()), id: \.element.id) { index, q in
                                Button {
                                    store.goToExamQuestion(index); showOverview = false
                                } label: {
                                    HStack {
                                        Text("\(index + 1). \(q.topic)")
                                        Spacer()
                                        Text((exam.selections[q.id] ?? []).isEmpty ? "Offen" : "Beantwortet").font(.caption)
                                        if exam.marked.contains(q.id) { Image(systemName: "bookmark.fill").accessibilityLabel("Markiert") }
                                    }.frame(minHeight: 44)
                                }
                            }
                        }
                    }.navigationTitle("Aufgabenübersicht").toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { showOverview = false } } }
                }
            }
    }
    private func remaining(until deadline: Date, now: Date) -> String {
        let seconds = max(0, Int(deadline.timeIntervalSince(now)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
