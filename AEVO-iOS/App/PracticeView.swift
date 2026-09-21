import SwiftUI
import AEVOCore

@MainActor
struct PracticeView: View {
    var body: some View {
        List {
            Section {
                Text("Gut vorbereitet ins Gespräch.").font(.title2.bold())
                Text("Wähle, was du heute üben möchtest.").foregroundStyle(.secondary)
            }
            NavigationLink { PracticePlanEditorView() } label: {
                Label("Meinen Ablauf planen", systemImage: "person.text.rectangle").padding(.vertical, 8)
            }
            NavigationLink { OralTrainerView() } label: {
                Label("Fachgespräch üben", systemImage: "bubble.left.and.bubble.right").padding(.vertical, 8)
            }
            NavigationLink { CasesView() } label: {
                Label("Alltagssituationen durchspielen", systemImage: "arrow.triangle.branch").padding(.vertical, 8)
            }
            Section { Text("Die Vorgaben deiner Kammer bleiben maßgeblich.").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("Praxis").learningBackground()
    }
}

@MainActor
struct PracticePlanEditorView: View {
    @EnvironmentObject private var store: AppStore
    @State private var rehearsal = false
    var body: some View {
        Form {
            Section {
                Text("Deine Ausbildungssituation.").font(.title2.bold())
                Text("Entwickle einen nachvollziehbaren Ablauf und übe, deine Entscheidungen zu begründen. Die Vorgaben deiner Kammer bleiben maßgeblich.").foregroundStyle(.secondary)

            }
            Section("1 · Ausgangspunkt") {
                TextField("Ausbildungsberuf", text: binding(\.occupation))
                LabeledEditor(title: "Ausgangssituation & Lernstand", text: binding(\.situation))
                TextField("Dein Thema", text: binding(\.topic), axis: .vertical)
                DisclosureGroup("Vorkenntnisse genauer beschreiben") { detail("prerequisites") }
            }
            Section("2 · Ein beobachtbares Lernziel") {
                LabeledEditor(title: "Was soll die Person anschließend selbstständig können?", text: binding(\.objective))
                DisclosureGroup("Hilfe beim Formulieren") {
                    Text("Beschreibe eine beobachtbare Handlung, die Bedingungen und ein Erfolgskriterium.").font(.footnote)
                    detail("observable"); detail("conditions"); detail("criterion")
                }
            }

            Section("3 · Methode begründen") {
                LabeledEditor(title: "Welche Methode passt zu Ziel und Vorkenntnissen? Warum?", text: binding(\.method))
                DisclosureGroup("Alternative überlegen") { detail("alternative") }
            }
            Section("4 · Ablauf und Absicherung") {
                LabeledEditor(title: "Einstieg, Erarbeitung, Anwendung, Kontrolle, Abschluss mit Zeitansätzen", text: binding(\.steps))
                DisclosureGroup("Lernkontrolle und mögliche Schwierigkeiten") {
                    detail("assessment"); detail("fallback"); detail("transfer")
                }
            }
            Section("5 · Dein Planungscheck") {
                DisclosureGroup("Meinen Plan überprüfen") {
                    Text("Diese Fragen helfen beim Nachdenken. Es gibt keine Pflichtfelder und keine automatische Benotung.").font(.footnote)
                    Text("Ist das Lernziel beobachtbar? Passt die Methode zum Lernstand? Gibt es Gelegenheit zur selbstständigen Anwendung und eine Lernkontrolle?")
                }
                DisclosureGroup("Weitere Gedanken festhalten") {
                    LabeledEditor(title: "Begründungen und Gedanken zum Fachgespräch", text: binding(\.conversationNotes))
                }
                ShareLink(item: CoachingEngine.practiceExport(state: store.state)) { Label("Praxisplan als Text exportieren", systemImage: "square.and.arrow.up") }.frame(minHeight: 44)
                Button { PrintService.printText(CoachingEngine.practiceExport(state: store.state), title: "Mein AEVO-Praxisplan") } label: { Label("Praxisplan drucken oder als PDF sichern", systemImage: "printer") }.frame(minHeight: 44)
                Button { rehearsal = true } label: { Label("15 Minuten laut durchspielen", systemImage: "timer") }.frame(minHeight: 44)
                Text("Texte werden lokal gesichert. Export enthält deine eigenen Angaben; achte beim Teilen auf personenbezogene Daten.").font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Mein Ablauf").learningBackground().onAppear { store.activity() }.sheet(isPresented: $rehearsal) { RehearsalView() }
    }
    private func binding(_ key: WritableKeyPath<PracticePlan, String>) -> Binding<String> {
        Binding(get: { store.state.practice[keyPath: key] }, set: { value in store.activity(); store.commit { $0.practice[keyPath: key] = String(value.prefix(30_000)) } })
    }
    private func detail(_ id: String) -> some View {
        LabeledEditor(title: CoachingEngine.practiceFields.first { $0.0 == id }?.2 ?? id,
            text: Binding(get: { store.state.coaching.practiceDetails[id] ?? "" }, set: { value in store.activity(); store.commit { $0.coaching.practiceDetails[id] = String(value.prefix(30_000)) } }))
    }
}

@MainActor
enum PrintService {
    static func printText(_ text: String, title: String) {
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil); info.jobName = title; info.outputType = .general
        controller.printInfo = info
        let formatter = UISimpleTextPrintFormatter(text: text)
        formatter.font = .systemFont(ofSize: 12); formatter.color = .black
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        controller.printFormatter = formatter
        controller.present(animated: true, completionHandler: nil)
    }
}

@MainActor
struct RehearsalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var started: Date?
    @State private var objective = false
    @State private var method = false
    @State private var control = false
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Sprich deinen Ablauf laut durch.").font(.largeTitle.bold())
                Text("Es wird nichts aufgenommen. Die Zeit ist eine Übungshilfe.").foregroundStyle(.secondary)
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remaining = started.map { max(0, 900 - Int(context.date.timeIntervalSince($0))) } ?? 900
                    Text(String(format: "%02d:%02d", remaining / 60, remaining % 60)).font(.system(.largeTitle, design: .rounded, weight: .bold)).monospacedDigit()
                }
                PrimaryButton(title: started == nil ? "Timer starten" : "Neu beginnen", icon: "play") { started = Date() }
                Toggle("Lernziel klar beschrieben", isOn: $objective)
                Toggle("Methode nachvollziehbar begründet", isOn: $method)
                Toggle("Lernkontrolle erklärt", isOn: $control)
                Spacer()
            }.padding(24).learningBackground().toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } } }
        }
    }
}
